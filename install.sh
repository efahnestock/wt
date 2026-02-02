#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Installing wt - Git worktree management tool"
echo ""

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Copy wt script
cp "$SCRIPT_DIR/wt" "$HOME/.local/bin/wt"
chmod +x "$HOME/.local/bin/wt"
echo -e "${GREEN}✓${NC} Installed wt to ~/.local/bin/wt"

# Detect shell and install appropriate integration
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    bash)
        RC_FILE="$HOME/.bashrc"
        INTEGRATION_FILE="$SCRIPT_DIR/wt.bash"
        SOURCE_LINE="source \"$HOME/.local/bin/wt.bash\""
        cp "$INTEGRATION_FILE" "$HOME/.local/bin/wt.bash"
        echo -e "${GREEN}✓${NC} Installed shell integration to ~/.local/bin/wt.bash"
        ;;
    zsh)
        RC_FILE="$HOME/.zshrc"
        INTEGRATION_FILE="$SCRIPT_DIR/wt.zsh"
        SOURCE_LINE="source \"$HOME/.local/bin/wt.zsh\""
        cp "$INTEGRATION_FILE" "$HOME/.local/bin/wt.zsh"
        echo -e "${GREEN}✓${NC} Installed shell integration to ~/.local/bin/wt.zsh"
        ;;
    *)
        echo -e "${YELLOW}⚠${NC} Unknown shell: $SHELL_NAME"
        echo "  Please manually source the appropriate integration file"
        exit 1
        ;;
esac

# Check if source line already exists in rc file
if grep -qF "wt.bash" "$RC_FILE" 2>/dev/null || grep -qF "wt.zsh" "$RC_FILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} Shell integration already configured in $RC_FILE"
else
    echo "" >> "$RC_FILE"
    echo "# wt - Git worktree management tool" >> "$RC_FILE"
    echo "$SOURCE_LINE" >> "$RC_FILE"
    echo -e "${GREEN}✓${NC} Added source line to $RC_FILE"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠${NC} ~/.local/bin is not in your PATH"
    echo "  Add this line to your $RC_FILE:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Restart your shell or run:"
echo "  source $RC_FILE"
echo ""
echo "Then try:"
echo "  wt --help"
