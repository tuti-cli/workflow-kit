#!/bin/bash
#
# workflow-kit v3 Installer/Updater
# Installs or updates the workflow system in any project
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash
#   ./install.sh                    # Install/Update in current directory
#   ./install.sh /path/to/project   # Install/Update in specific project
#   ./install.sh --version 1.0.0    # Install specific version
#   ./install.sh --check            # Check for updates only
#   ./install.sh --force            # Force update, overwrite all files
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

WORKFLOW_KIT_VERSION="${WORKFLOW_KIT_VERSION:-latest}"
PROJECT_ROOT=""
CHECK_ONLY=false
FORCE_UPDATE=false
LOCAL_MODE=false
GITHUB_REPO="tuti-cli/workflow-kit"
CLAUDE_NEEDS_MIGRATION=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version|-v) WORKFLOW_KIT_VERSION="$2"; shift 2 ;;
        --check|-c)   CHECK_ONLY=true; shift ;;
        --force|-f)   FORCE_UPDATE=true; shift ;;
        --local|-l)   LOCAL_MODE=true; shift ;;
        --help|-h)
            echo "Usage: $0 [PROJECT_ROOT] [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --version, -v   Specific version to install (default: latest)"
            echo "  --check, -c     Check for updates without applying"
            echo "  --force, -f     Overwrite all files including modified ones"
            echo "  --local, -l     Use local kit-v3/ folder (for development)"
            exit 0
            ;;
        *) PROJECT_ROOT="$1"; shift ;;
    esac
done

[ -z "$PROJECT_ROOT" ] && PROJECT_ROOT="$(pwd)"

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Requirements ─────────────────────────────────────────────────────────────
check_requirements() {
    log_info "Checking requirements..."
    if [ "$LOCAL_MODE" = false ]; then
        if command -v curl &> /dev/null; then
            DOWNLOADER="curl"
        elif command -v wget &> /dev/null; then
            DOWNLOADER="wget"
        else
            log_error "Either curl or wget is required"
            exit 1
        fi
    fi
    if [ ! -d "$PROJECT_ROOT" ]; then
        log_error "Project directory does not exist: $PROJECT_ROOT"
        exit 1
    fi
    log_success "Requirements met"
}

# ── Existing installation ────────────────────────────────────────────────────
check_installed() {
    local version_file="$PROJECT_ROOT/.workflow/.base-version"
    if [ -f "$version_file" ]; then
        IS_UPDATE=true
        CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$version_file" | cut -d'"' -f4)
        log_info "Existing installation found: v$CURRENT_VERSION"
    else
        IS_UPDATE=false
    fi
}

# ── Read config from CLAUDE.md ───────────────────────────────────────────────
read_github_config() {
    local claude_md="$PROJECT_ROOT/CLAUDE.md"
    if [ ! -f "$claude_md" ]; then
        log_warning "CLAUDE.md not found — will create during install"
        GITHUB_OWNER=""
        GITHUB_REPO_NAME=""
        WORKFLOW_MODE="scratch"
        return
    fi

    log_info "Reading configuration from CLAUDE.md..."

    # v3 format: - owner: value / - repo: value
    GITHUB_OWNER=$(grep -E "^- owner:" "$claude_md" | sed 's/.*:\s*//' | tr -d ' ')
    GITHUB_REPO_NAME=$(grep -E "^- repo:" "$claude_md" | sed 's/.*:\s*//' | tr -d ' ')
    WORKFLOW_MODE=$(grep -E "^- mode:" "$claude_md" | sed 's/.*:\s*//' | tr -d ' ')

    # Fallback: v2 format
    if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO_NAME" ]; then
        GITHUB_OWNER=$(grep "^repo_owner:" "$claude_md" | sed 's/.*:\s*//' | tr -d ' ')
        GITHUB_REPO_NAME=$(grep "^repo_name:" "$claude_md" | sed 's/.*:\s*//' | tr -d ' ')
    fi

    # Fallback: v1 format
    if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO_NAME" ]; then
        GITHUB_OWNER=$(grep -A 5 "### GitHub Repository" "$claude_md" | grep -E "^\s*-\s*\*\*Owner:\*\*" | sed 's/.*\*\*Owner:\*\*\s*//' | tr -d ' ')
        GITHUB_REPO_NAME=$(grep -A 5 "### GitHub Repository" "$claude_md" | grep -E "^\s*-\s*\*\*Repo:\*\*" | sed 's/.*\*\*Repo:\*\*\s*//' | tr -d ' ')
    fi

    [ -z "$WORKFLOW_MODE" ] && WORKFLOW_MODE="scratch"

    if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO_NAME" ]; then
        log_warning "Could not extract GitHub config from CLAUDE.md"
        GITHUB_OWNER=""
        GITHUB_REPO_NAME=""
    else
        log_success "Found: $GITHUB_OWNER/$GITHUB_REPO_NAME (mode: $WORKFLOW_MODE)"
    fi
}

# ── Auto-detect project stack ────────────────────────────────────────────────
detect_stack() {
    log_info "Detecting project stack..."

    STACK="generic"
    LANGUAGE=""
    QUALITY_GATE_LINT="echo 'No lint configured'"
    QUALITY_GATE_TEST="echo 'No tests configured'"

    # Laravel / PHP
    if [ -f "$PROJECT_ROOT/composer.json" ]; then
        LANGUAGE="php"
        if grep -q "laravel/framework" "$PROJECT_ROOT/composer.json" 2>/dev/null; then
            STACK="laravel"
        elif grep -q "laravel-zero/framework" "$PROJECT_ROOT/composer.json" 2>/dev/null; then
            STACK="laravel-zero"
        else
            STACK="php"
        fi
        QUALITY_GATE_LINT="composer lint"
        QUALITY_GATE_TEST="composer test"
    fi

    # WordPress
    if [ -f "$PROJECT_ROOT/wp-config.php" ] || [ -f "$PROJECT_ROOT/wp-load.php" ]; then
        STACK="wordpress"
        LANGUAGE="php"
        QUALITY_GATE_LINT="composer lint"
        QUALITY_GATE_TEST="composer test"
    fi

    # Node / React / Vue / Nuxt / Next
    # Only set stack from package.json if composer.json didn't already detect a PHP stack
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        [ -z "$LANGUAGE" ] && LANGUAGE="javascript"

        if grep -q '"typescript"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            [ "$LANGUAGE" != "php" ] && LANGUAGE="typescript"
        fi

        # Only override stack if no PHP framework was detected
        if [ "$STACK" = "generic" ]; then
            if grep -q '"next"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
                STACK="next"
            elif grep -q '"nuxt"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
                STACK="nuxt"
            elif grep -q '"react"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
                STACK="react"
            elif grep -q '"vue"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
                STACK="vue"
            else
                STACK="node"
            fi
        fi

        # Only override quality gates if not already set by composer
        if [ "$QUALITY_GATE_LINT" = "echo 'No lint configured'" ]; then
            if grep -q '"lint"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
                QUALITY_GATE_LINT="npm run lint"
            fi
        fi
        if [ "$QUALITY_GATE_TEST" = "echo 'No tests configured'" ]; then
            if grep -q '"test"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
                QUALITY_GATE_TEST="npm test"
            fi
        fi
    fi

    # Python
    if [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
        STACK="python"
        LANGUAGE="python"
        QUALITY_GATE_LINT="ruff check ."
        QUALITY_GATE_TEST="pytest"
    fi

    log_success "Stack: $STACK | Language: $LANGUAGE | Lint: $QUALITY_GATE_LINT | Test: $QUALITY_GATE_TEST"
}

# ── Version management ───────────────────────────────────────────────────────
get_latest_version() {
    log_info "Fetching latest version..."
    local version_url="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
    if [ "$DOWNLOADER" = "curl" ]; then
        LATEST_VERSION=$(curl -s "$version_url" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    else
        LATEST_VERSION=$(wget -qO- "$version_url" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    fi
    if [ -z "$LATEST_VERSION" ]; then
        log_error "Could not fetch latest version"
        exit 1
    fi
    log_success "Latest version: v$LATEST_VERSION"
}

compare_versions() {
    if [ "$IS_UPDATE" = true ] && [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo ""
        log_success "Already up to date! (v$CURRENT_VERSION)"
        exit 0
    fi
    if [ "$IS_UPDATE" = true ]; then
        echo ""
        log_info "Update available: v$CURRENT_VERSION -> v$LATEST_VERSION"
    fi
}

check_updates_only() {
    if [ "$CHECK_ONLY" = true ]; then
        echo ""
        echo "Run the installer again to apply:"
        echo "  curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash"
        exit 0
    fi
}

# ── Download ─────────────────────────────────────────────────────────────────
download_kit() {
    local version="${1:-$LATEST_VERSION}"
    log_info "Downloading workflow-kit v$version..."
    TEMP_DIR=$(mktemp -d)
    local download_url="https://github.com/$GITHUB_REPO/archive/refs/tags/v$version.tar.gz"
    if [ "$DOWNLOADER" = "curl" ]; then
        curl -sL "$download_url" | tar xz -C "$TEMP_DIR"
    else
        wget -qO- "$download_url" | tar xz -C "$TEMP_DIR"
    fi
    KIT_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "workflow-kit*" | head -1)
    if [ -z "$KIT_DIR" ] || [ ! -d "$KIT_DIR/kit-v3" ]; then
        log_error "Download failed or archive structure unexpected"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    KIT_DIR="$KIT_DIR/kit-v3"
    log_success "Downloaded successfully"
}

# ── Template variable replacement ────────────────────────────────────────────
replace_template_vars() {
    local file="$1"
    if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO_NAME" ]; then
        sed -i "s|{{GITHUB_OWNER}}|$GITHUB_OWNER|g" "$file"
        sed -i "s|{{GITHUB_REPO}}|$GITHUB_REPO_NAME|g" "$file"
    fi
    sed -i "s|{{QUALITY_GATE_LINT}}|$QUALITY_GATE_LINT|g" "$file"
    sed -i "s|{{QUALITY_GATE_TEST}}|$QUALITY_GATE_TEST|g" "$file"
    sed -i "s|{{STACK}}|$STACK|g" "$file"
    sed -i "s|{{LANGUAGE}}|$LANGUAGE|g" "$file"
    sed -i "s|{{PROJECT_NAME}}|$(basename "$PROJECT_ROOT")|g" "$file"
    sed -i "s|{{WK_VERSION}}|${LATEST_VERSION:-$WORKFLOW_KIT_VERSION}|g" "$file"
}

install_file() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    replace_template_vars "$dest"
}

# ── Create directory structure ───────────────────────────────────────────────
create_directories() {
    log_info "Creating directory structure..."

    # .claude
    mkdir -p "$PROJECT_ROOT/.claude/agents"
    mkdir -p "$PROJECT_ROOT/.claude/commands/ww"
    mkdir -p "$PROJECT_ROOT/.claude/rules/base"
    mkdir -p "$PROJECT_ROOT/.claude/rules/project"
    mkdir -p "$PROJECT_ROOT/.claude/rules/features"
    mkdir -p "$PROJECT_ROOT/.claude/skills/workflow"
    mkdir -p "$PROJECT_ROOT/.claude/skills/stack"
    mkdir -p "$PROJECT_ROOT/.claude/skills/tools"

    # .workflow
    mkdir -p "$PROJECT_ROOT/.workflow/core"
    mkdir -p "$PROJECT_ROOT/.workflow/analysis"
    mkdir -p "$PROJECT_ROOT/.workflow/decisions/ADRs"
    mkdir -p "$PROJECT_ROOT/.workflow/execution/patches"
    mkdir -p "$PROJECT_ROOT/.workflow/execution/features"
    mkdir -p "$PROJECT_ROOT/.workflow/meta/proposals"
    mkdir -p "$PROJECT_ROOT/.workflow/meta/challenges"

    # .gitkeep for empty directories
    for dir in \
        "$PROJECT_ROOT/.workflow/core" \
        "$PROJECT_ROOT/.workflow/analysis" \
        "$PROJECT_ROOT/.workflow/decisions/ADRs" \
        "$PROJECT_ROOT/.workflow/execution/patches" \
        "$PROJECT_ROOT/.workflow/execution/features" \
        "$PROJECT_ROOT/.workflow/meta/proposals" \
        "$PROJECT_ROOT/.workflow/meta/challenges" \
        "$PROJECT_ROOT/.claude/skills/stack"; do
        [ ! -f "$dir/.gitkeep" ] && touch "$dir/.gitkeep"
    done

    # GitHub
    mkdir -p "$PROJECT_ROOT/.github/ISSUE_TEMPLATE"
    mkdir -p "$PROJECT_ROOT/.github/workflows"

    # Scripts
    mkdir -p "$PROJECT_ROOT/scripts"

    log_success "Directory structure created"
}

# ── Install components ───────────────────────────────────────────────────────
install_components() {
    local count

    # Agents
    log_info "Installing agents..."
    count=0
    for f in "$KIT_DIR/.claude/agents/"*.md; do
        [ -f "$f" ] || continue
        install_file "$f" "$PROJECT_ROOT/.claude/agents/$(basename "$f")"
        count=$((count + 1))
    done
    log_success "Installed $count agents"

    # Commands
    log_info "Installing commands..."
    count=0
    for f in "$KIT_DIR/.claude/commands/ww/"*.md; do
        [ -f "$f" ] || continue
        install_file "$f" "$PROJECT_ROOT/.claude/commands/ww/$(basename "$f")"
        count=$((count + 1))
    done
    log_success "Installed $count commands"

    # Rules (base layer)
    log_info "Installing rules..."
    count=0
    for layer in base project features; do
        for f in "$KIT_DIR/.claude/rules/$layer/"*.md; do
            [ -f "$f" ] || continue
            install_file "$f" "$PROJECT_ROOT/.claude/rules/$layer/$(basename "$f")"
            count=$((count + 1))
        done
    done
    log_success "Installed $count rule files"

    # Skills (with nested directories)
    log_info "Installing skills..."
    count=0
    for category in workflow stack tools; do
        [ -d "$KIT_DIR/.claude/skills/$category" ] || continue
        for skill_dir in "$KIT_DIR/.claude/skills/$category/"*/; do
            [ -d "$skill_dir" ] || continue
            local skill_name
            skill_name=$(basename "$skill_dir")
            for f in "$skill_dir"*.md; do
                [ -f "$f" ] || continue
                install_file "$f" "$PROJECT_ROOT/.claude/skills/$category/$skill_name/$(basename "$f")"
                count=$((count + 1))
            done
        done
        # Handle .gitkeep files
        [ -f "$KIT_DIR/.claude/skills/$category/.gitkeep" ] && \
            cp "$KIT_DIR/.claude/skills/$category/.gitkeep" "$PROJECT_ROOT/.claude/skills/$category/.gitkeep"
    done
    log_success "Installed $count skill files"

    # GitHub templates
    log_info "Installing GitHub templates..."
    count=0
    if [ -d "$KIT_DIR/.github" ]; then
        for f in "$KIT_DIR/.github/ISSUE_TEMPLATE/"*; do
            [ -f "$f" ] || continue
            cp "$f" "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/$(basename "$f")"
            count=$((count + 1))
        done
        for f in "$KIT_DIR/.github/workflows/"*; do
            [ -f "$f" ] || continue
            cp "$f" "$PROJECT_ROOT/.github/workflows/$(basename "$f")"
            count=$((count + 1))
        done
        [ -f "$KIT_DIR/.github/PULL_REQUEST_TEMPLATE.md" ] && \
            cp "$KIT_DIR/.github/PULL_REQUEST_TEMPLATE.md" "$PROJECT_ROOT/.github/PULL_REQUEST_TEMPLATE.md" && \
            count=$((count + 1))
    fi
    log_success "Installed $count GitHub templates"

    # Scripts
    if [ -f "$KIT_DIR/scripts/setup-labels.sh" ]; then
        cp "$KIT_DIR/scripts/setup-labels.sh" "$PROJECT_ROOT/scripts/setup-labels.sh"
        chmod +x "$PROJECT_ROOT/scripts/setup-labels.sh"
        log_success "setup-labels.sh installed"
    fi

    # WORKFLOW.md
    if [ -f "$KIT_DIR/WORKFLOW.md" ] && [ ! -f "$PROJECT_ROOT/WORKFLOW.md" ]; then
        install_file "$KIT_DIR/WORKFLOW.md" "$PROJECT_ROOT/WORKFLOW.md"
        log_success "WORKFLOW.md installed"
    fi
}

# ── Create or migrate CLAUDE.md ──────────────────────────────────────────────
setup_claude_md() {
    local claude_md="$PROJECT_ROOT/CLAUDE.md"

    if [ ! -f "$claude_md" ]; then
        # No CLAUDE.md — create from template
        log_info "Creating CLAUDE.md from template..."
        if [ -f "$KIT_DIR/config/CLAUDE.example.md" ]; then
            install_file "$KIT_DIR/config/CLAUDE.example.md" "$claude_md"
            log_success "CLAUDE.md created"
        else
            log_warning "CLAUDE.md template not found — create manually"
        fi
    else
        # CLAUDE.md exists — rename old, install fresh template
        log_warning "Existing CLAUDE.md found — renaming to CLAUDE-OLD.md"
        mv "$claude_md" "$PROJECT_ROOT/CLAUDE-OLD.md"
        if [ -f "$KIT_DIR/config/CLAUDE.example.md" ]; then
            install_file "$KIT_DIR/config/CLAUDE.example.md" "$claude_md"
            log_success "New CLAUDE.md created from v3 template"
        fi
        CLAUDE_NEEDS_MIGRATION=true
        log_info "CLAUDE-OLD.md preserved — run /ww:discover to migrate rules"
        log_info "Delete CLAUDE-OLD.md manually after migration is complete"
    fi
}

# ── Update components ────────────────────────────────────────────────────────
update_components() {
    local updated=0 preserved=0 skipped=0

    log_info "Updating components..."

    # Update agents
    for f in "$KIT_DIR/.claude/agents/"*.md; do
        [ -f "$f" ] || continue
        local dest="$PROJECT_ROOT/.claude/agents/$(basename "$f")"
        if [ ! -f "$dest" ] || [ "$FORCE_UPDATE" = true ]; then
            install_file "$f" "$dest"
            updated=$((updated + 1))
        else
            # Check if file differs from source (after template replacement)
            local tmp
            tmp=$(mktemp)
            cp "$f" "$tmp"
            replace_template_vars "$tmp"
            if diff -q "$tmp" "$dest" > /dev/null 2>&1; then
                updated=$((updated + 1))
            else
                preserved=$((preserved + 1))
                log_warning "Preserved: .claude/agents/$(basename "$f")"
            fi
            rm -f "$tmp"
        fi
    done

    # Update commands (always overwrite — these are system files)
    for f in "$KIT_DIR/.claude/commands/ww/"*.md; do
        [ -f "$f" ] || continue
        install_file "$f" "$PROJECT_ROOT/.claude/commands/ww/$(basename "$f")"
        updated=$((updated + 1))
    done

    # Update base rules (always overwrite)
    for f in "$KIT_DIR/.claude/rules/base/"*.md; do
        [ -f "$f" ] || continue
        install_file "$f" "$PROJECT_ROOT/.claude/rules/base/$(basename "$f")"
        updated=$((updated + 1))
    done

    # Skip project and features rules (user-owned)
    for layer in project features; do
        for f in "$KIT_DIR/.claude/rules/$layer/"*.md; do
            [ -f "$f" ] || continue
            local dest="$PROJECT_ROOT/.claude/rules/$layer/$(basename "$f")"
            if [ ! -f "$dest" ]; then
                install_file "$f" "$dest"
                updated=$((updated + 1))
            else
                skipped=$((skipped + 1))
            fi
        done
    done

    # Update workflow skills (system-owned)
    for skill_dir in "$KIT_DIR/.claude/skills/workflow/"*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name=$(basename "$skill_dir")
        for f in "$skill_dir"*.md; do
            [ -f "$f" ] || continue
            install_file "$f" "$PROJECT_ROOT/.claude/skills/workflow/$skill_name/$(basename "$f")"
            updated=$((updated + 1))
        done
    done

    # Update tools skills (system-owned)
    for skill_dir in "$KIT_DIR/.claude/skills/tools/"*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name=$(basename "$skill_dir")
        for f in "$skill_dir"*.md; do
            [ -f "$f" ] || continue
            install_file "$f" "$PROJECT_ROOT/.claude/skills/tools/$skill_name/$(basename "$f")"
            updated=$((updated + 1))
        done
    done

    # Skip stack skills (user-installed via /ww:discover)

    log_success "Updated $updated files"
    if [ "$preserved" -gt 0 ]; then log_warning "Preserved $preserved modified files"; fi
    if [ "$skipped" -gt 0 ]; then log_info "Skipped $skipped user-owned files"; fi
}

# ── Version files ────────────────────────────────────────────────────────────
write_version_file() {
    cat > "$PROJECT_ROOT/.workflow/.base-version" << EOF
{
    "version": "${1:-$LATEST_VERSION}",
    "installed_at": "$(date -Iseconds)",
    "stack": "$STACK",
    "source": "tuti-cli/workflow-kit",
    "architecture": "v3"
}
EOF
}

update_version_file() {
    cat > "$PROJECT_ROOT/.workflow/.base-version" << EOF
{
    "version": "${1:-$LATEST_VERSION}",
    "updated_at": "$(date -Iseconds)",
    "previous_version": "$CURRENT_VERSION",
    "stack": "$STACK",
    "source": "tuti-cli/workflow-kit",
    "architecture": "v3"
}
EOF
}

# ── Summaries ────────────────────────────────────────────────────────────────
print_install_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}  workflow-kit v3 Installed!            ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "  Location: $PROJECT_ROOT"
    echo "  Version:  v${LATEST_VERSION:-$WORKFLOW_KIT_VERSION}"
    echo "  Stack:    $STACK"
    echo "  Mode:     $WORKFLOW_MODE"
    if [ -n "$GITHUB_OWNER" ]; then
        echo "  GitHub:   $GITHUB_OWNER/$GITHUB_REPO_NAME"
    fi
    echo ""
    echo "  Next steps:"
    if [ "$CLAUDE_NEEDS_MIGRATION" = true ]; then
        echo "    /ww:discover          — MIGRATE CLAUDE.md + analyze project"
    else
        echo "    /ww:discover          — analyze project, install skills"
    fi
    echo "    /ww:describe <file>   — create project description"
    echo "    /ww:plan              — plan your first feature"
    echo ""
    echo "  All commands: /ww:<tab> for autocomplete"
    echo ""
}

print_update_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}  workflow-kit v3 Updated!              ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "  Previous: v$CURRENT_VERSION"
    echo "  Current:  v${LATEST_VERSION:-$WORKFLOW_KIT_VERSION}"
    if [ "$FORCE_UPDATE" = true ]; then echo -e "  ${YELLOW}Force update: local modifications overwritten${NC}"; fi
    echo ""
}

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo -e "${BLUE}"
    echo "════════════════════════════════════════"
    echo "     workflow-kit v3 Installer"
    echo "════════════════════════════════════════"
    echo -e "${NC}"

    trap cleanup EXIT

    check_requirements
    check_installed
    read_github_config
    detect_stack

    # Local mode (development)
    if [ "$LOCAL_MODE" = true ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        KIT_DIR="$SCRIPT_DIR"
        WORKFLOW_KIT_VERSION="local"
        log_info "Using local kit from: $KIT_DIR"
    else
        if [ "$WORKFLOW_KIT_VERSION" = "latest" ]; then
            get_latest_version
            WORKFLOW_KIT_VERSION="$LATEST_VERSION"
        fi

        if [ "$IS_UPDATE" = true ]; then
            compare_versions
            check_updates_only
        fi

        download_kit "$WORKFLOW_KIT_VERSION"
    fi

    if [ "$IS_UPDATE" = true ]; then
        update_components
        update_version_file "$WORKFLOW_KIT_VERSION"
        print_update_summary
    else
        create_directories
        install_components
        setup_claude_md
        write_version_file "$WORKFLOW_KIT_VERSION"
        print_install_summary
    fi
}

main
