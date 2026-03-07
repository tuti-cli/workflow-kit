#!/bin/bash
#
# workflow-kit Updater
# Updates workflow system while preserving local overrides
#
# Usage:
#   ./update.sh [PROJECT_ROOT] [--check] [--force]
#
# Options:
#   PROJECT_ROOT   Path to project directory (default: current directory)
#   --check        Check for updates without applying
#   --force        Discard local overrides, use base versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PROJECT_ROOT="${1:-$(pwd)}"
CHECK_ONLY=false
FORCE_UPDATE=false
GITHUB_REPO="tuti-cli/workflow-kit"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --check|-c)
            CHECK_ONLY=true
            shift
            ;;
        --force|-f)
            FORCE_UPDATE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [PROJECT_ROOT] [--check] [--force]"
            echo ""
            echo "Options:"
            echo "  PROJECT_ROOT   Path to project directory"
            echo "  --check, -c    Check for updates without applying"
            echo "  --force, -f    Discard local overrides, use base versions"
            echo ""
            echo "Example:"
            echo "  $0                    # Update current project"
            echo "  $0 --check            # Check for updates only"
            echo "  $0 /path/to/project   # Update specific project"
            exit 0
            ;;
        *)
            PROJECT_ROOT="$1"
            shift
            ;;
    esac
done

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if workflow-kit is installed
check_installed() {
    local version_file="$PROJECT_ROOT/.workflow/.base-version"

    if [ ! -f "$version_file" ]; then
        log_error "workflow-kit is not installed in $PROJECT_ROOT"
        log_info "Run /workflow:init to install"
        exit 1
    fi

    CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$version_file" | cut -d'"' -f4)
    log_info "Current version: v$CURRENT_VERSION"
}

# Get latest version from GitHub
get_latest_version() {
    log_info "Checking for updates..."

    if command -v curl &> /dev/null; then
        LATEST_VERSION=$(curl -sI "https://github.com/$GITHUB_REPO/releases/latest" 2>/dev/null | \
            grep -i "location:" | \
            sed 's/.*tag\/v\([^"]*\).*/\1/' | \
            tr -d '\r\n')
    elif command -v wget &> /dev/null; then
        LATEST_VERSION=$(wget -Sq "https://github.com/$GITHUB_REPO/releases/latest" -O /dev/null 2>&1 | \
            grep -i "location:" | \
            sed 's/.*tag\/v\([^"]*\).*/\1/' | \
            tr -d '\r\n')
    fi

    if [ -z "$LATEST_VERSION" ]; then
        log_error "Could not fetch latest version"
        exit 1
    fi

    log_info "Latest version: v$LATEST_VERSION"
}

# Compare versions
compare_versions() {
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo ""
        log_success "Already up to date! (v$CURRENT_VERSION)"
        exit 0
    fi

    echo ""
    log_info "Update available: v$CURRENT_VERSION → v$LATEST_VERSION"
}

# Check for updates only
check_updates() {
    if [ "$CHECK_ONLY" = true ]; then
        echo ""
        echo "Run /workflow:update to apply this update"
        exit 0
    fi
}

# Download new version
download_kit() {
    log_info "Downloading workflow-kit v$LATEST_VERSION..."

    TEMP_DIR=$(mktemp -d)
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v$LATEST_VERSION/workflow-kit.tar.gz"

    if command -v curl &> /dev/null; then
        curl -sL "$download_url" | tar xz -C "$TEMP_DIR" 2>/dev/null
    elif command -v wget &> /dev/null; then
        wget -qO- "$download_url" | tar xz -C "$TEMP_DIR" 2>/dev/null
    fi

    if [ ! -d "$TEMP_DIR/kit" ]; then
        log_error "Download failed or invalid package"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    log_success "Downloaded v$LATEST_VERSION"
}

# Detect overrides
detect_overrides() {
    local base_dir="$1"
    OVERRIDE_COUNT=0
    OVERRIDE_FILES=""

    # Check agents
    for agent in "$base_dir/kit/.claude/agents/"*.md; do
        [ -f "$agent" ] || continue
        local agent_name=$(basename "$agent")
        local dest="$PROJECT_ROOT/.claude/agents/$agent_name"

        if [ -f "$dest" ]; then
            if ! diff -q "$agent" "$dest" > /dev/null 2>&1; then
                OVERRIDE_COUNT=$((OVERRIDE_COUNT + 1))
                OVERRIDE_FILES="$OVERRIDE_FILES\n  - .claude/agents/$agent_name"
            fi
        fi
    done

    # Check skills
    for skill_dir in "$base_dir/kit/.claude/skills/"*; do
        [ -d "$skill_dir" ] || continue
        local skill_name=$(basename "$skill_dir")
        local dest="$PROJECT_ROOT/.claude/skills/$skill_name"

        if [ -d "$dest" ]; then
            # Compare skill files
            for skill_file in "$skill_dir/"*.md; do
                [ -f "$skill_file" ] || continue
                local file_name=$(basename "$skill_file")
                local dest_file="$dest/$file_name"

                if [ -f "$dest_file" ]; then
                    if ! diff -q "$skill_file" "$dest_file" > /dev/null 2>&1; then
                        OVERRIDE_COUNT=$((OVERRIDE_COUNT + 1))
                        OVERRIDE_FILES="$OVERRIDE_FILES\n  - .claude/skills/$skill_name/$file_name"
                    fi
                fi
            done
        fi
    done
}

# Apply update with override preservation
apply_update() {
    local base_dir="$TEMP_DIR"
    local updated_count=0
    local preserved_count=0

    log_info "Applying update..."

    # Create backup directory for new base versions
    mkdir -p "$PROJECT_ROOT/.claude/base"

    # Update agents
    for agent in "$base_dir/kit/.claude/agents/"*.md; do
        [ -f "$agent" ] || continue
        local agent_name=$(basename "$agent")
        local dest="$PROJECT_ROOT/.claude/agents/$agent_name"

        # Replace template variables
        local content=$(cat "$agent")
        if [ -n "$GITHUB_OWNER" ]; then
            content=$(echo "$content" | sed "s/{{GITHUB_OWNER}}/$GITHUB_OWNER/g")
        fi
        if [ -n "$GITHUB_REPO_NAME" ]; then
            content=$(echo "$content" | sed "s/{{GITHUB_REPO}}/$GITHUB_REPO_NAME/g")
        fi

        if [ -f "$dest" ]; then
            if [ "$FORCE_UPDATE" = true ]; then
                echo "$content" > "$dest"
                updated_count=$((updated_count + 1))
            elif diff -q <(echo "$content") "$dest" > /dev/null 2>&1; then
                # Files identical, safe to update
                echo "$content" > "$dest"
                updated_count=$((updated_count + 1))
            else
                # Override detected, preserve and save new base
                echo "$content" > "$PROJECT_ROOT/.claude/base/$agent_name"
                preserved_count=$((preserved_count + 1))
                log_warning "Override preserved: .claude/agents/$agent_name"
            fi
        else
            # New file
            echo "$content" > "$dest"
            updated_count=$((updated_count + 1))
        fi
    done

    # Update commands
    cp -r "$base_dir/kit/.claude/commands/"* "$PROJECT_ROOT/.claude/commands/" 2>/dev/null || true
    updated_count=$((updated_count + 5))

    # Update skills
    for skill_dir in "$base_dir/kit/.claude/skills/"*; do
        [ -d "$skill_dir" ] || continue
        local skill_name=$(basename "$skill_dir")
        local dest="$PROJECT_ROOT/.claude/skills/$skill_name"

        mkdir -p "$dest"
        cp -r "$skill_dir/"* "$dest/" 2>/dev/null || true
        updated_count=$((updated_count + 1))
    done

    # Update workflow templates
    cp -r "$base_dir/kit/.workflow/templates/"* "$PROJECT_ROOT/.workflow/templates/" 2>/dev/null || true
    [ -f "$base_dir/kit/.workflow/USAGE.md" ] && cp "$base_dir/kit/.workflow/USAGE.md" "$PROJECT_ROOT/.workflow/"
    [ -f "$base_dir/kit/.workflow/MASTER-REFERENCE.md" ] && cp "$base_dir/kit/.workflow/MASTER-REFERENCE.md" "$PROJECT_ROOT/.workflow/"

    log_success "Updated $updated_count files"
    if [ $preserved_count -gt 0 ]; then
        log_warning "Preserved $preserved_count overrides (new base saved to .claude/base/)"
    fi
}

# Update version file
update_version_file() {
    cat > "$PROJECT_ROOT/.workflow/.base-version" << EOF
{
    "version": "$LATEST_VERSION",
    "updated_at": "$(date -Iseconds)",
    "previous_version": "$CURRENT_VERSION",
    "source": "tuti-cli/workflow-kit"
}
EOF

    log_success "Version updated to v$LATEST_VERSION"
}

# Cleanup
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}     workflow-kit Updated!              ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Previous: v$CURRENT_VERSION"
    echo "Current:  v$LATEST_VERSION"
    echo ""

    if [ -n "$OVERRIDE_FILES" ]; then
        echo "Overrides preserved:"
        echo -e "$OVERRIDE_FILES"
        echo ""
        echo "To review new base versions, check .claude/base/"
        echo "To discard overrides and use new base, run: /workflow:update --force"
    fi
}

# Read GitHub config from CLAUDE.md
read_github_config() {
    local claude_md="$PROJECT_ROOT/CLAUDE.md"

    if [ -f "$claude_md" ]; then
        # Extract GitHub owner
        GITHUB_OWNER=$(grep -A5 "### GitHub Repository" "$claude_md" 2>/dev/null | \
            grep -i "owner:" | \
            head -1 | \
            sed 's/.*Owner:[[:space:]]*//' | \
            tr -d '*` ' | \
            tr -d '\r')

        # Extract GitHub repo
        GITHUB_REPO_NAME=$(grep -A5 "### GitHub Repository" "$claude_md" 2>/dev/null | \
            grep -i "repo:" | \
            grep -v "Full" | \
            head -1 | \
            sed 's/.*Repo:[[:space:]]*//' | \
            tr -d '*` ' | \
            tr -d '\r')
    fi
}

# Main
main() {
    echo -e "${BLUE}"
    echo "════════════════════════════════════════"
    echo "      workflow-kit Updater"
    echo "════════════════════════════════════════"
    echo -e "${NC}"

    trap cleanup EXIT

    check_installed
    read_github_config
    get_latest_version
    compare_versions
    check_updates
    download_kit
    detect_overrides "$TEMP_DIR"
    apply_update
    update_version_file
    print_summary
}

main
