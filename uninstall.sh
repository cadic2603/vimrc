#!/usr/bin/env bash
set -euo pipefail

VIMRC_DEST="$HOME/.vimrc"
VIM_DIR="$HOME/.vim"
UNDO_DIR="$VIM_DIR/undodir"
PLUGGED_DIR="$VIM_DIR/plugged"
PLUG_FILE="$VIM_DIR/autoload/plug.vim"
AUTOLOAD_DIR="$VIM_DIR/autoload"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ------------------------------------------------------------------
# 1. Restore original .vimrc from the OLDEST backup (pre-install),
#    or remove if no backup exists. Clean up any younger backups.
# ------------------------------------------------------------------
shopt -s nullglob
backups=("$VIMRC_DEST".bak.*)
shopt -u nullglob

if (( ${#backups[@]} > 0 )); then
  # Timestamp suffix makes lexical sort chronological
  oldest=$(printf '%s\n' "${backups[@]}" | sort | head -1)
  info "Restoring $VIMRC_DEST from oldest backup: $oldest"
  mv "$oldest" "$VIMRC_DEST"
  for b in "${backups[@]}"; do
    [[ "$b" == "$oldest" ]] && continue
    [[ -f "$b" ]] || continue
    info "Removing stale backup: $b"
    rm -f "$b"
  done
elif [[ -f "$VIMRC_DEST" ]]; then
  info "No backup found — removing $VIMRC_DEST"
  rm -f "$VIMRC_DEST"
else
  info "$VIMRC_DEST does not exist — nothing to restore"
fi

# ------------------------------------------------------------------
# 2. Remove plugins installed by PlugInstall
# ------------------------------------------------------------------
if [[ -d "$PLUGGED_DIR" ]]; then
  info "Removing plugin directory: $PLUGGED_DIR"
  rm -rf "$PLUGGED_DIR"
fi

# ------------------------------------------------------------------
# 3. Remove vim-plug
# ------------------------------------------------------------------
if [[ -f "$PLUG_FILE" ]]; then
  info "Removing vim-plug: $PLUG_FILE"
  rm -f "$PLUG_FILE"
fi
[[ -d "$AUTOLOAD_DIR" ]] && rmdir "$AUTOLOAD_DIR" 2>/dev/null || true

# ------------------------------------------------------------------
# 4. Remove undo directory
# ------------------------------------------------------------------
if [[ -d "$UNDO_DIR" ]]; then
  info "Removing undo directory: $UNDO_DIR"
  rm -rf "$UNDO_DIR"
fi

# ------------------------------------------------------------------
# 5. Remove ~/.vim if now empty
# ------------------------------------------------------------------
[[ -d "$VIM_DIR" ]] && rmdir "$VIM_DIR" 2>/dev/null || true

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Vim restored to initial state${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  NOT removed (remove manually if desired):"
echo "    - System packages (vim, curl, git, ripgrep, nodejs, python3, ...)"
echo "    - DroidSansM Nerd Font (~/.local/share/fonts/)"
echo "    - Terminal emulator font configs (gnome-terminal, kitty, alacritty, ...)"
echo "    - Language tools (eslint, prettier, flake8, gopls, rust-analyzer, ...)"
echo ""
