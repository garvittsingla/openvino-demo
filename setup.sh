#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="health-chat"
DATA_DIR="$HOME/.local/share/openvino-health-chat"
HISTORY_DIR="$DATA_DIR/history"
CONFIG_FILE="$DATA_DIR/config.yml"
BIN_DIR="$HOME/.local/bin"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

setup_chat_history() {
    echo ""
    echo "Setting up local chat history storage..."
    
    if [ ! -d "$DATA_DIR" ]; then
        mkdir -p "$DATA_DIR"
        print_status "Created data directory: $DATA_DIR"
    else
        print_warning "Data directory already exists: $DATA_DIR"
    fi
    
    if [ ! -d "$HISTORY_DIR" ]; then
        mkdir -p "$HISTORY_DIR"
        print_status "Created history directory: $HISTORY_DIR"
    else
        print_warning "History directory already exists: $HISTORY_DIR"
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" <<EOF
server:
  base_url: "http://localhost:8000"
  timeout: 30

history:
  enabled: true
  max_sessions: 50
  directory: "$HISTORY_DIR"

current_session: null
EOF
        print_status "Created config file: $CONFIG_FILE"
    else
        print_warning "Config file already exists: $CONFIG_FILE"
    fi
}

setup_executable() {
    echo ""
    echo "Setting up executable..."
    
    if [ ! -d "$BIN_DIR" ]; then
        mkdir -p "$BIN_DIR"
        print_status "Created bin directory: $BIN_DIR"
    fi
    
    EXECUTABLE="$BIN_DIR/$APP_NAME"
    cat > "$EXECUTABLE" <<EOF
#!/usr/bin/env bash

SCRIPT_DIR="$SCRIPT_DIR"
DATA_DIR="$DATA_DIR"
CONFIG_FILE="$CONFIG_FILE"
HISTORY_DIR="$HISTORY_DIR"

if [ -d "\$SCRIPT_DIR/venv" ]; then
    source "\$SCRIPT_DIR/venv/bin/activate"
fi

export HEALTH_CHAT_DATA_DIR="\$DATA_DIR"
export HEALTH_CHAT_CONFIG="\$CONFIG_FILE"
export HEALTH_CHAT_HISTORY_DIR="\$HISTORY_DIR"

python "\$SCRIPT_DIR/health_chat.py" "\$@"
EOF
    
    chmod +x "$EXECUTABLE"
    print_status "Created executable: $EXECUTABLE"
    
    setup_path
}

setup_path() {
    echo ""
    echo "Checking PATH configuration..."
    
    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        bash)
            SHELL_RC="$HOME/.bashrc"
            ;;
        zsh)
            SHELL_RC="$HOME/.zshrc"
            ;;
        *)
            SHELL_RC="$HOME/.profile"
            ;;
    esac
    
    if echo "$PATH" | grep -q "$BIN_DIR"; then
        print_status "$BIN_DIR is already in PATH"
    else
        PATH_EXPORT="export PATH=\"\$HOME/.local/bin:\$PATH\""
        
        if [ -f "$SHELL_RC" ] && grep -q ".local/bin" "$SHELL_RC"; then
            print_warning "PATH export already exists in $SHELL_RC"
        else
            echo "" >> "$SHELL_RC"
            echo "$PATH_EXPORT" >> "$SHELL_RC"
            print_status "Added PATH export to $SHELL_RC"
        fi
        
        print_warning "Please run: source $SHELL_RC"
        print_warning "Or restart your terminal for PATH changes to take effect"
    fi
}

main() {
    echo "=============================================="
    echo "  OpenVINO Health Chat - Local Setup"
    echo "=============================================="
    
    setup_chat_history
    setup_executable
    
    echo ""
    echo "=============================================="
    echo "  Setup Complete!"
    echo "=============================================="
    echo ""
    echo "Data directory: $DATA_DIR"
    echo "Config file:    $CONFIG_FILE"
    echo "History dir:    $HISTORY_DIR"
    echo "Executable:     $BIN_DIR/$APP_NAME"
    echo ""
    echo "After sourcing your shell config, run:"
    echo "  $APP_NAME"
    echo ""
}

main "$@"
