#!/bin/bash
#
# workflow-kit Installer
# Installs the workflow system into any project
#
# Usage:
#   ./install.sh                    # Install in current directory
#   ./install.sh /path/to/project   # Install in specific project
#   ./install.sh --version 1.0.0    # Install specific version
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
WORKFLOW_KIT_VERSION="${WORKFLOW_KIT_VERSION:-latest}"
PROJECT_ROOT="${1:-$(pwd)}"
GITHUB_REPO="tuti-cli/workflow-kit"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version|-v)
            WORKFLOW_KIT_VERSION="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [PROJECT_ROOT] [--version VERSION]"
            echo ""
            echo "Arguments:"
            echo "  PROJECT_ROOT    Path to project directory (default: current directory)"
            echo "  --version, -v   Specific version to install (default: latest)"
            echo ""
            echo "Example:"
            echo "  $0                              # Install in current directory"
            echo "  $0 /path/to/project             # Install in specific project"
            echo "  $0 --version 1.0.0              # Install version 1.0.0"
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

# Check requirements
check_requirements() {
    log_info "Checking requirements..."

    # Check for curl or wget
    if command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    else
        log_error "Either curl or wget is required"
        exit 1
    fi

    # Check project root exists
    if [ ! -d "$PROJECT_ROOT" ]; then
        log_error "Project directory does not exist: $PROJECT_ROOT"
        exit 1
    fi

    log_success "Requirements met"
}

# Read GitHub config from CLAUDE.md
read_github_config() {
    local claude_md="$PROJECT_ROOT/CLAUDE.md"

    if [ ! -f "$claude_md" ]; then
        log_warning "CLAUDE.md not found at $claude_md"
        log_info "You will need to configure GitHub settings manually after installation"
        GITHUB_OWNER=""
        GITHUB_REPO_NAME=""
        return
    fi

    log_info "Reading GitHub configuration from CLAUDE.md..."

    # Extract Owner
    GITHUB_OWNER=$(grep -A 5 "### GitHub Repository" "$claude_md" | grep -E "^\s*-\s*\*\*Owner:\*\*" | sed 's/.*\*\*Owner:\*\*\s*//' | tr -d ' ')

    # Extract Repo
    GITHUB_REPO_NAME=$(grep -A 5 "### GitHub Repository" "$claude_md" | grep -E "^\s*-\s*\*\*Repo:\*\*" | sed 's/.*\*\*Repo:\*\*\s*//' | tr -d ' ')

    if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_REPO_NAME" ]; then
        log_warning "Could not extract GitHub configuration from CLAUDE.md"
        log_info "Looking for pattern:"
        log_info "  - **Owner:** org-name"
        log_info "  - **Repo:** repo-name"
        GITHUB_OWNER=""
        GITHUB_REPO_NAME=""
    else
        log_success "Found GitHub config: $GITHUB_OWNER/$GITHUB_REPO_NAME"
    fi
}

# Get latest version from GitHub
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

# Download workflow-kit
download_kit() {
    local version="${1:-$LATEST_VERSION}"

    log_info "Downloading workflow-kit v$version..."

    TEMP_DIR=$(mktemp -d)
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v$version/workflow-kit.tar.gz"

    if [ "$DOWNLOADER" = "curl" ]; then
        curl -sL "$download_url" | tar xz -C "$TEMP_DIR"
    else
        wget -qO- "$download_url" | tar xz -C "$TEMP_DIR"
    fi

    if [ ! -d "$TEMP_DIR/kit" ]; then
        log_error "Download failed or archive structure unexpected"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    log_success "Downloaded to temporary directory"
}

# Create directory structure
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

    log_success "Directory structure created"
}

# Replace template variables
replace_template_vars() {
    local file="$1"

    if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO_NAME" ]; then
        sed -i "s|{{GITHUB_OWNER}}|$GITHUB_OWNER|g" "$file"
        sed -i "s|{{GITHUB_REPO}}|$GITHUB_REPO_NAME|g" "$file"
    fi
}

# Install agents
install_agents() {
    log_info "Installing agents..."

    local agent_count=0
    for agent in "$TEMP_DIR/kit/.claude/agents/"*.md; do
        if [ -f "$agent" ]; then
            local agent_name=$(basename "$agent")
            local dest="$PROJECT_ROOT/.claude/agents/$agent_name"

            cp "$agent" "$dest"
            replace_template_vars "$dest"
            ((agent_count++))
        fi
    done

    log_success "Installed $agent_count agents"
}

# Install commands
install_commands() {
    log_info "Installing commands..."

    local cmd_count=0

    # Workflow commands
    for cmd in "$TEMP_DIR/kit/.claude/commands/workflow/"*.md; do
        if [ -f "$cmd" ]; then
            cp "$cmd" "$PROJECT_ROOT/.claude/commands/workflow/"
            ((cmd_count++))
        fi
    done

    # Agent commands
    for cmd in "$TEMP_DIR/kit/.claude/commands/agents/"*.md; do
        if [ -f "$cmd" ]; then
            cp "$cmd" "$PROJECT_ROOT/.claude/commands/agents/"
            ((cmd_count++))
        fi
    done

    log_success "Installed $cmd_count commands"
}

# Install skills
install_skills() {
    log_info "Installing skills..."

    local skill_count=0
    for skill_dir in "$TEMP_DIR/kit/.claude/skills/"*; do
        if [ -d "$skill_dir" ]; then
            local skill_name=$(basename "$skill_dir")
            cp -r "$skill_dir" "$PROJECT_ROOT/.claude/skills/"
            ((skill_count++))
        fi
    done

    log_success "Installed $skill_count skills"
}

# Install workflow templates
install_workflow_templates() {
    log_info "Installing workflow templates..."

    # Copy templates if they exist
    if [ -d "$TEMP_DIR/kit/.workflow/templates" ]; then
        cp -r "$TEMP_DIR/kit/.workflow/templates/"* "$PROJECT_ROOT/.workflow/templates/" 2>/dev/null || true
    fi

    # Copy documentation
    if [ -f "$TEMP_DIR/kit/.workflow/USAGE.md" ]; then
        [ ! -f "$PROJECT_ROOT/.workflow/USAGE.md" ] && cp "$TEMP_DIR/kit/.workflow/USAGE.md" "$PROJECT_ROOT/.workflow/"
    fi

    if [ -f "$TEMP_DIR/kit/.workflow/MASTER-REFERENCE.md" ]; then
        [ ! -f "$PROJECT_ROOT/.workflow/MASTER-REFERENCE.md" ] && cp "$TEMP_DIR/kit/.workflow/MASTER-REFERENCE.md" "$PROJECT_ROOT/.workflow/"
    fi

    log_success "Workflow templates installed"
}

# Write version file
write_version_file() {
    local version="${1:-$LATEST_VERSION}"

    log_info "Writing version file..."

    cat > "$PROJECT_ROOT/.workflow/.base-version" << EOF
{
    "version": "$version",
    "installed_at": "$(date -Iseconds)",
    "source": "tuti-cli/workflow-kit"
}
EOF

    log_success "Version file created"
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
    echo -e "${GREEN}  workflow-kit Installation Complete!   ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Installed to: $PROJECT_ROOT"
    echo "Version: v${LATEST_VERSION:-$WORKFLOW_KIT_VERSION}"
    echo ""

    if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO_NAME" ]; then
        echo "GitHub Configuration:"
        echo "  Owner: $GITHUB_OWNER"
        echo "  Repo:  $GITHUB_REPO_NAME"
        echo ""
    else
        echo -e "${YELLOW}Note: GitHub configuration not found in CLAUDE.md${NC}"
        echo "Please update your agents manually with your GitHub repo details."
        echo ""
    fi

    echo "Next Steps:"
    echo "  1. Run /workflow:discover to analyze your project"
    echo "  2. Run /agents:search <query> to find additional agents"
    echo "  3. Run /agents:install <name> to install recommended agents"
    echo ""
    echo "Update with: /workflow:update"
    echo "Check status with: /workflow:status"
}

# Main
main() {
    echo -e "${BLUE}"
    echo "════════════════════════════════════════"
    echo "     workflow-kit Installer"
    echo "════════════════════════════════════════"
    echo -e "${NC}"

    trap cleanup EXIT

    check_requirements
    read_github_config

    if [ "$WORKFLOW_KIT_VERSION" = "latest" ]; then
        get_latest_version
        WORKFLOW_KIT_VERSION="$LATEST_VERSION"
    fi

    download_kit "$WORKFLOW_KIT_VERSION"
    create_directories
    install_agents
    install_commands
    install_skills
    install_workflow_templates
    write_version_file "$WORKFLOW_KIT_VERSION"

    print_summary
}

main
