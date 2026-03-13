#!/bin/bash
#
# workflow-kit Installer/Updater
# Installs or updates the workflow system in any project
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash
#   ./install.sh                    # Install/Update in current directory
#   ./install.sh /path/to/project   # Install/Update in specific project
#   ./install.sh --version 1.0.0    # Install specific version
#   ./install.sh --check            # Check for updates only
#   ./install.sh --force            # Force update, discard local overrides
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

WORKFLOW_KIT_VERSION="${WORKFLOW_KIT_VERSION:-latest}"
PROJECT_ROOT="${1:-$(pwd)}"
CHECK_ONLY=false
FORCE_UPDATE=false
LOCAL_MODE=false
GITHUB_REPO="tuti-cli/workflow-kit"

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
            echo "  --force, -f     Discard local overrides, use base versions"
            echo "  --local, -l     Use local kit/ folder (for development/testing)"
            exit 0
            ;;
        *) PROJECT_ROOT="$1"; shift ;;
    esac
done

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ─── Requirements ────────────────────────────────────────────────────────────
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

# ─── Existing installation ────────────────────────────────────────────────────
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

# ─── Read GitHub config from CLAUDE.md ───────────────────────────────────────
read_github_config() {
    local claude_md="$PROJECT_ROOT/CLAUDE.md"
    if [ ! -f "$claude_md" ]; then
        log_warning "CLAUDE.md not found — GitHub config must be set manually after install"
        GITHUB_OWNER=""
        GITHUB_REPO_NAME=""
        return
    fi

    log_info "Reading GitHub configuration from CLAUDE.md..."
    GITHUB_OWNER=$(grep -A 5 "### GitHub Repository" "$claude_md" | grep -E "^\s*-\s*\*\*Owner:\*\*" | sed 's/.*\*\*Owner:\*\*\s*//' | tr -d ' ')
    GITHUB_REPO_NAME=$(grep -A 5 "### GitHub Repository" "$claude_md" | grep -E "^\s*-\s*\*\*Repo:\*\*" | sed 's/.*\*\*Repo:\*\*\s*//' | tr -d ' ')

    if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO_NAME" ]; then
        log_warning "Could not extract GitHub config from CLAUDE.md"
        GITHUB_OWNER=""
        GITHUB_REPO_NAME=""
    else
        log_success "Found GitHub config: $GITHUB_OWNER/$GITHUB_REPO_NAME"
    fi
}

# ─── Auto-detect project stack → quality gates ───────────────────────────────
detect_stack() {
    log_info "Detecting project stack..."

    STACK="generic"
    QUALITY_GATE_LINT="echo 'No lint configured'"
    QUALITY_GATE_TEST="echo 'No tests configured'"

    # Laravel / PHP (composer.json with laravel/framework)
    if [ -f "$PROJECT_ROOT/composer.json" ]; then
        if grep -q "laravel/framework" "$PROJECT_ROOT/composer.json" 2>/dev/null; then
            STACK="laravel"
            QUALITY_GATE_LINT="composer lint"
            QUALITY_GATE_TEST="composer test"
        elif grep -q "laravel-zero/framework" "$PROJECT_ROOT/composer.json" 2>/dev/null; then
            STACK="laravel-zero"
            QUALITY_GATE_LINT="composer lint"
            QUALITY_GATE_TEST="composer test"
        else
            STACK="php"
            QUALITY_GATE_LINT="composer lint"
            QUALITY_GATE_TEST="composer test"
        fi
    fi

    # WordPress
    if [ -f "$PROJECT_ROOT/wp-config.php" ] || [ -f "$PROJECT_ROOT/wp-load.php" ]; then
        STACK="wordpress"
        QUALITY_GATE_LINT="composer lint"
        QUALITY_GATE_TEST="composer test"
    fi

    # Node / React / Vue
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        if grep -q '"react"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            STACK="react"
        elif grep -q '"vue"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            STACK="vue"
        elif [ "$STACK" = "generic" ]; then
            STACK="node"
        fi

        # Prefer npm scripts if they exist
        if grep -q '"lint"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            QUALITY_GATE_LINT="npm run lint"
        fi
        if grep -q '"test"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            QUALITY_GATE_TEST="npm test"
        elif grep -q '"pest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            QUALITY_GATE_TEST="npm run pest"
        fi
    fi

    # Python
    if [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
        STACK="python"
        QUALITY_GATE_LINT="flake8 . || ruff check ."
        QUALITY_GATE_TEST="pytest"
    fi

    log_success "Detected stack: $STACK (lint: $QUALITY_GATE_LINT | test: $QUALITY_GATE_TEST)"
}

# ─── Version management ───────────────────────────────────────────────────────
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
        log_info "Update available: v$CURRENT_VERSION → v$LATEST_VERSION"
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

# ─── Download ─────────────────────────────────────────────────────────────────
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
    if [ -z "$KIT_DIR" ] || [ ! -d "$KIT_DIR/kit" ]; then
        log_error "Download failed or archive structure unexpected"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    log_success "Downloaded successfully"
}

# ─── Template variable replacement ───────────────────────────────────────────
# Replaces ALL template vars in agents, commands, AND skills
replace_template_vars() {
    local file="$1"
    if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO_NAME" ]; then
        sed -i "s|{{GITHUB_OWNER}}|$GITHUB_OWNER|g" "$file"
        sed -i "s|{{GITHUB_REPO}}|$GITHUB_REPO_NAME|g" "$file"
    fi
    sed -i "s|{{QUALITY_GATE_LINT}}|$QUALITY_GATE_LINT|g" "$file"
    sed -i "s|{{QUALITY_GATE_TEST}}|$QUALITY_GATE_TEST|g" "$file"
    sed -i "s|{{STACK}}|$STACK|g" "$file"
}

# ─── Install / update helpers ─────────────────────────────────────────────────
install_file() {
    local src="$1"
    local dest="$2"
    cp "$src" "$dest"
    replace_template_vars "$dest"
}

# Backup existing file with .old suffix (or .old.TIMESTAMP if .old exists)
backup_existing_file() {
    local dest="$1"
    if [ -f "$dest" ]; then
        local backup="${dest}.old"
        # If .old already exists, add timestamp
        if [ -f "$backup" ]; then
            backup="${dest}.old.$(date +%Y%m%d%H%M%S)"
        fi
        mv "$dest" "$backup"
        log_warning "Existing file renamed to: $(basename "$backup")"
    fi
}

update_file() {
    local src="$1"
    local dest="$2"
    local base_dest="$3"   # path to save new base version

    local content
    content=$(cat "$src")

    # Apply template vars to content using bash parameter expansion
    if [ -n "$GITHUB_OWNER" ]; then
        content="${content//\{\{GITHUB_OWNER\}\}/$GITHUB_OWNER}"
        content="${content//\{\{GITHUB_REPO\}\}/$GITHUB_REPO_NAME}"
    fi
    content="${content//\{\{QUALITY_GATE_LINT\}\}/$QUALITY_GATE_LINT}"
    content="${content//\{\{QUALITY_GATE_TEST\}\}/$QUALITY_GATE_TEST}"
    content="${content//\{\{STACK\}\}/$STACK}"

    if [ -f "$dest" ]; then
        if [ "$FORCE_UPDATE" = true ]; then
            echo "$content" > "$dest"
            echo "updated"
        elif diff -q <(echo "$content") "$dest" > /dev/null 2>&1; then
            echo "$content" > "$dest"
            echo "updated"
        else
            # Override detected — preserve user file, save new base
            mkdir -p "$(dirname "$base_dest")"
            echo "$content" > "$base_dest"
            echo "preserved"
        fi
    else
        echo "$content" > "$dest"
        echo "new"
    fi
}

# ─── Install all components ───────────────────────────────────────────────────
create_directories() {
    log_info "Creating directory structure..."
    mkdir -p "$PROJECT_ROOT/.claude/agents"
    mkdir -p "$PROJECT_ROOT/.claude/commands/workflow"
    mkdir -p "$PROJECT_ROOT/.claude/commands/agents"
    mkdir -p "$PROJECT_ROOT/.claude/skills"
    mkdir -p "$PROJECT_ROOT/.workflow/patches"
    mkdir -p "$PROJECT_ROOT/.workflow/ADRs"
    mkdir -p "$PROJECT_ROOT/.workflow/features"
    mkdir -p "$PROJECT_ROOT/.workflow/state"
    mkdir -p "$PROJECT_ROOT/.workflow/templates"
    mkdir -p "$PROJECT_ROOT/.github/ISSUE_TEMPLATE"
    mkdir -p "$PROJECT_ROOT/.github/workflows"

    # Add .gitkeep to .workflow subdirectories so Git tracks them
    touch "$PROJECT_ROOT/.workflow/patches/.gitkeep"
    touch "$PROJECT_ROOT/.workflow/ADRs/.gitkeep"
    touch "$PROJECT_ROOT/.workflow/features/.gitkeep"
    touch "$PROJECT_ROOT/.workflow/state/.gitkeep"
    touch "$PROJECT_ROOT/.workflow/templates/.gitkeep"

    log_success "Directory structure created"
}

# Install .github files with backup for existing files
install_github_files() {
    log_info "Installing .github templates..."
    local count=0

    # Ensure directories exist
    mkdir -p "$PROJECT_ROOT/.github/ISSUE_TEMPLATE"
    mkdir -p "$PROJECT_ROOT/.github/workflows"

    # ISSUE_TEMPLATE files
    if [ -d "$KIT_DIR/kit/.github/ISSUE_TEMPLATE" ]; then
        for f in "$KIT_DIR/kit/.github/ISSUE_TEMPLATE/"*; do
            [ -f "$f" ] || continue
            local name dest
            name=$(basename "$f")
            dest="$PROJECT_ROOT/.github/ISSUE_TEMPLATE/$name"
            backup_existing_file "$dest"
            cp "$f" "$dest"
            count=$((count + 1))
        done
    fi

    # workflows
    if [ -d "$KIT_DIR/kit/.github/workflows" ]; then
        for f in "$KIT_DIR/kit/.github/workflows/"*; do
            [ -f "$f" ] || continue
            local name dest
            name=$(basename "$f")
            dest="$PROJECT_ROOT/.github/workflows/$name"
            backup_existing_file "$dest"
            cp "$f" "$dest"
            count=$((count + 1))
        done
    fi

    # PULL_REQUEST_TEMPLATE.md
    if [ -f "$KIT_DIR/kit/.github/PULL_REQUEST_TEMPLATE.md" ]; then
        local dest="$PROJECT_ROOT/.github/PULL_REQUEST_TEMPLATE.md"
        backup_existing_file "$dest"
        cp "$KIT_DIR/kit/.github/PULL_REQUEST_TEMPLATE.md" "$dest"
        count=$((count + 1))
    fi

    log_success "Installed $count .github templates"
}

install_components() {
    log_info "Installing agents..."
    local count=0
    local name dest
    for f in "$KIT_DIR/kit/.claude/agents/"*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        dest="$PROJECT_ROOT/.claude/agents/$name"
        backup_existing_file "$dest"
        install_file "$f" "$dest"
        count=$((count + 1))
    done
    log_success "Installed $count agents"

    log_info "Installing commands..."
    count=0
    for f in "$KIT_DIR/kit/.claude/commands/workflow/"*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        dest="$PROJECT_ROOT/.claude/commands/workflow/$name"
        backup_existing_file "$dest"
        install_file "$f" "$dest"
        count=$((count + 1))
    done
    for f in "$KIT_DIR/kit/.claude/commands/agents/"*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        dest="$PROJECT_ROOT/.claude/commands/agents/$name"
        backup_existing_file "$dest"
        install_file "$f" "$dest"
        count=$((count + 1))
    done
    log_success "Installed $count commands"

    log_info "Installing skills..."
    count=0
    for skill_dir in "$KIT_DIR/kit/.claude/skills/"*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name=$(basename "$skill_dir")
        mkdir -p "$PROJECT_ROOT/.claude/skills/$skill_name"
        for f in "$skill_dir"*.md; do
            [ -f "$f" ] || continue
            name=$(basename "$f")
            dest="$PROJECT_ROOT/.claude/skills/$skill_name/$name"
            backup_existing_file "$dest"
            install_file "$f" "$dest"
            count=$((count + 1))
        done
    done
    log_success "Installed $count skills"

    # Install .github files with backup handling
    install_github_files

    if [ -f "$KIT_DIR/kit/scripts/setup-labels.sh" ]; then
        mkdir -p "$PROJECT_ROOT/scripts"
        dest="$PROJECT_ROOT/scripts/setup-labels.sh"
        backup_existing_file "$dest"
        install_file "$KIT_DIR/kit/scripts/setup-labels.sh" "$dest"
        chmod +x "$dest"
        log_success "setup-labels.sh installed"
    fi

    if [ -f "$KIT_DIR/kit/WORKFLOW.md" ]; then
        if [ ! -f "$PROJECT_ROOT/WORKFLOW.md" ]; then
            install_file "$KIT_DIR/kit/WORKFLOW.md" "$PROJECT_ROOT/WORKFLOW.md"
        fi
    fi
}

update_components() {
    local updated=0 preserved=0
    mkdir -p "$PROJECT_ROOT/.claude/base"

    for section in "agents" "commands/workflow" "commands/agents"; do
        for f in "$KIT_DIR/kit/.claude/$section/"*.md; do
            [ ! -f "$f" ] && continue
            local name dest base_dest result
            name=$(basename "$f")
            dest="$PROJECT_ROOT/.claude/$section/$name"
            base_dest="$PROJECT_ROOT/.claude/base/$section/$name"
            result=$(update_file "$f" "$dest" "$base_dest")
            case "$result" in
                updated|new) updated=$((updated + 1)) ;;
                preserved)
                    preserved=$((preserved + 1))
                    log_warning "Override preserved: .claude/$section/$name"
                    ;;
            esac
        done
    done

    for skill_dir in "$KIT_DIR/kit/.claude/skills/"*/; do
        [ ! -d "$skill_dir" ] && continue
        local skill_name
        skill_name=$(basename "$skill_dir")
        mkdir -p "$PROJECT_ROOT/.claude/skills/$skill_name"
        for f in "$skill_dir"*.md; do
            [ ! -f "$f" ] && continue
            local name dest base_dest result
            name=$(basename "$f")
            dest="$PROJECT_ROOT/.claude/skills/$skill_name/$name"
            base_dest="$PROJECT_ROOT/.claude/base/skills/$skill_name/$name"
            result=$(update_file "$f" "$dest" "$base_dest")
            case "$result" in
                updated|new) updated=$((updated + 1)) ;;
                preserved)
                    preserved=$((preserved + 1))
                    log_warning "Override preserved: .claude/skills/$skill_name/$name"
                    ;;
            esac
        done
    done

    # Update .github files with backup handling
    log_info "Updating .github templates..."
    if [ -d "$KIT_DIR/kit/.github" ]; then
        install_github_files
    fi

    log_success "Updated $updated files"
    [ "$preserved" -gt 0 ] && log_warning "Preserved $preserved overrides (new base saved to .claude/base/)"
}

# ─── Version files ────────────────────────────────────────────────────────────
write_version_file() {
    cat > "$PROJECT_ROOT/.workflow/.base-version" << EOF
{
    "version": "${1:-$LATEST_VERSION}",
    "installed_at": "$(date -Iseconds)",
    "stack": "$STACK",
    "source": "tuti-cli/workflow-kit"
}
EOF
    log_success "Version file created"
}

update_version_file() {
    cat > "$PROJECT_ROOT/.workflow/.base-version" << EOF
{
    "version": "${1:-$LATEST_VERSION}",
    "updated_at": "$(date -Iseconds)",
    "previous_version": "$CURRENT_VERSION",
    "stack": "$STACK",
    "source": "tuti-cli/workflow-kit"
}
EOF
    log_success "Version updated to v${1:-$LATEST_VERSION}"
}

# ─── Summaries ────────────────────────────────────────────────────────────────
print_install_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}  workflow-kit Installation Complete!   ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Installed to: $PROJECT_ROOT"
    echo "Version:      v${LATEST_VERSION:-$WORKFLOW_KIT_VERSION}"
    echo "Stack:        $STACK"
    echo ""
    if [ -n "$GITHUB_OWNER" ]; then
        echo "GitHub: $GITHUB_OWNER/$GITHUB_REPO_NAME"
        echo ""
    else
        echo -e "${YELLOW}⚠ GitHub config not found in CLAUDE.md — update agents manually${NC}"
        echo ""
    fi
    echo "Next Steps:"
    echo "  1. Run: ./scripts/setup-labels.sh        (creates GitHub labels)"
    echo "  2. Run: /workflow:discover                (analyzes project)"
    echo "  3. Run: /agents:search <query>            (find specialist agents)"
    echo "  4. Run: /agents:install <name>            (install recommended agents)"
    echo ""
    echo "Update with: curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash"
}

print_update_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}     workflow-kit Updated!              ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Previous: v$CURRENT_VERSION → Current: v${LATEST_VERSION:-$WORKFLOW_KIT_VERSION}"
    [ "$FORCE_UPDATE" = true ] && echo -e "${YELLOW}Force update: local overrides were discarded${NC}"
}

cleanup() {
    [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo -e "${BLUE}"
    echo "════════════════════════════════════════"
    echo "     workflow-kit Installer"
    echo "════════════════════════════════════════"
    echo -e "${NC}"

    trap cleanup EXIT

    check_requirements
    check_installed
    read_github_config
    detect_stack

    # Handle local mode
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
        write_version_file "$WORKFLOW_KIT_VERSION"
        print_install_summary
    fi
}

main
