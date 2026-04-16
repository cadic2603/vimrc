#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC_SRC="$SCRIPT_DIR/.vimrc"
VIMRC_DEST="$HOME/.vimrc"
VIM_DIR="$HOME/.vim"
UNDO_DIR="$VIM_DIR/undodir"
PLUG_FILE="$VIM_DIR/autoload/plug.vim"
FONT_DIR="$HOME/.local/share/fonts"
NERD_FONT="DroidSansM"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ------------------------------------------------------------------
# 1. Detect package manager
# ------------------------------------------------------------------
detect_pm() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v pacman &>/dev/null; then echo "pacman"
  elif command -v brew &>/dev/null; then echo "brew"
  else echo "unknown"; fi
}

PM=$(detect_pm)
info "Detected package manager: $PM"

# ------------------------------------------------------------------
# 2. Install system dependencies
# ------------------------------------------------------------------
install_deps() {
  local packages=()

  case "$PM" in
    apt)
      packages=(vim-gtk3 curl git unzip ripgrep xclip nodejs python3 python3-dev python3-pip pipx universal-ctags)
      # NodeSource nodejs bundles npm and conflicts with the separate npm package.
      # Only add npm when NodeSource is NOT present.
      if [[ ! -f /etc/apt/sources.list.d/nodesource.list ]] && \
         ! grep -rqs 'deb.*nodesource' /etc/apt/sources.list.d/ 2>/dev/null; then
        packages+=(npm)
      fi
      info "Updating package lists..."
      sudo apt-get update -qq
      info "Installing dependencies: ${packages[*]}"
      sudo apt-get install -y -qq "${packages[@]}"
      ;;
    dnf)
      packages=(vim-enhanced vim-X11 curl git unzip ripgrep xclip nodejs npm python3 python3-pip pipx ctags)
      info "Installing dependencies: ${packages[*]}"
      sudo dnf install -y -q "${packages[@]}"
      ;;
    pacman)
      packages=(gvim curl git unzip ripgrep xclip nodejs npm python python-pipx ctags)
      info "Installing dependencies: ${packages[*]}"
      sudo pacman -S --noconfirm --needed "${packages[@]}"
      ;;
    brew)
      packages=(vim curl git ripgrep node python universal-ctags)
      info "Installing dependencies: ${packages[*]}"
      brew install "${packages[@]}" 2>/dev/null || true
      ;;
    *)
      warn "Unknown package manager. Please install manually:"
      warn "  vim 9.0+, curl, git, ripgrep, xclip, nodejs, npm, python3, universal-ctags"
      ;;
  esac
}

install_deps

# ------------------------------------------------------------------
# 2b. Ensure Vim 9.0+ (required for copilot.vim)
#     Distro packages (especially Ubuntu/Debian) often ship Vim 8.x.
#     Build from source when the installed version is too old.
# ------------------------------------------------------------------
VIM_MIN_MAJOR=9
VIM_MIN_MINOR=0

need_vim_upgrade() {
  if ! command -v vim &>/dev/null; then
    return 0
  fi
  local ver
  ver=$(vim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  local major minor
  major=$(echo "$ver" | cut -d. -f1)
  minor=$(echo "$ver" | cut -d. -f2)
  if (( major < VIM_MIN_MAJOR || (major == VIM_MIN_MAJOR && minor < VIM_MIN_MINOR) )); then
    return 0
  fi
  return 1
}

build_vim_from_source() {
  info "Building Vim from source (this may take a few minutes)..."

  # Install build dependencies
  case "$PM" in
    apt)
      sudo apt-get install -y -qq \
        build-essential libncurses-dev libpython3-dev libxt-dev
      ;;
    dnf)
      sudo dnf install -y -q \
        gcc make ncurses-devel python3-devel libX11-devel libXt-devel
      ;;
    *)
      warn "Please install C compiler, ncurses-dev, python3-dev manually"
      ;;
  esac

  local tmp_dir
  tmp_dir=$(mktemp -d)

  git clone --depth 1 https://github.com/vim/vim.git "$tmp_dir/vim"
  cd "$tmp_dir/vim"

  ./configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --with-python3-command=python3 \
    --enable-cscope \
    --prefix=/usr/local \
    --quiet

  make -j"$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 1)" -s
  sudo make install -s

  cd "$SCRIPT_DIR"
  rm -rf "$tmp_dir"

  # Verify
  local new_ver
  new_ver=$(/usr/local/bin/vim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  info "Vim $new_ver installed to /usr/local/bin/vim"
}

if need_vim_upgrade; then
  local_ver=$(vim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "not found")
  warn "Vim $local_ver is too old (need 9.0+ for copilot.vim)"
  build_vim_from_source
else
  local_ver=$(vim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  info "Vim $local_ver is already 9.0+ — no upgrade needed"
fi

# ------------------------------------------------------------------
# 3. Back up existing .vimrc
# ------------------------------------------------------------------
if [[ -f "$VIMRC_DEST" ]]; then
  BACKUP="$VIMRC_DEST.bak.$(date +%Y%m%d%H%M%S)"
  warn "Existing .vimrc found — backing up to $BACKUP"
  cp "$VIMRC_DEST" "$BACKUP"
fi

# ------------------------------------------------------------------
# 4. Copy .vimrc
# ------------------------------------------------------------------
if [[ ! -f "$VIMRC_SRC" ]]; then
  error ".vimrc not found at $VIMRC_SRC"
fi

cp "$VIMRC_SRC" "$VIMRC_DEST"
info "Copied .vimrc to $VIMRC_DEST"

# ------------------------------------------------------------------
# 5. Create required directories
# ------------------------------------------------------------------
mkdir -p "$UNDO_DIR"
info "Created undo directory: $UNDO_DIR"

# ------------------------------------------------------------------
# 6. Install vim-plug
# ------------------------------------------------------------------
if [[ ! -f "$PLUG_FILE" ]]; then
  info "Installing vim-plug..."
  curl -fLo "$PLUG_FILE" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  info "vim-plug installed"
else
  info "vim-plug already installed"
fi

# ------------------------------------------------------------------
# 7. Install Nerd Font (for vim-devicons)
# ------------------------------------------------------------------
install_nerd_font() {
  if fc-list 2>/dev/null | grep -qi "$NERD_FONT"; then
    info "Nerd Font ($NERD_FONT) already installed"
    return
  fi

  info "Installing $NERD_FONT Nerd Font..."
  mkdir -p "$FONT_DIR"

  local tmp_dir
  tmp_dir=$(mktemp -d)
  local zip_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/DroidSansMono.zip"

  if curl -fsSL -o "$tmp_dir/font.zip" "$zip_url"; then
    unzip -qo "$tmp_dir/font.zip" -d "$FONT_DIR"
    fc-cache -f "$FONT_DIR" 2>/dev/null || true
    info "Nerd Font installed to $FONT_DIR"
  else
    warn "Failed to download Nerd Font — install manually from https://www.nerdfonts.com"
  fi

  rm -rf "$tmp_dir"
}

# Set Nerd Font in GNOME Terminal profile
set_gnome_terminal_font() {
  if ! command -v gsettings &>/dev/null; then return; fi
  local profile
  profile=$(timeout 5 gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'" || true)
  if [[ -z "$profile" ]]; then return; fi

  if ! command -v dconf &>/dev/null; then return; fi
  local dconf_path="/org/gnome/terminal/legacy/profiles:/:${profile}"
  timeout 5 dconf write "${dconf_path}/use-system-font" "false" 2>/dev/null || return 0
  timeout 5 dconf write "${dconf_path}/font" "'DroidSansM Nerd Font 11'" 2>/dev/null || return 0
  info "Set GNOME Terminal font to DroidSansM Nerd Font 11"
}

# Set Nerd Font in kitty
set_kitty_font() {
  local conf="$HOME/.config/kitty/kitty.conf"
  if ! command -v kitty &>/dev/null && [[ ! -f "$conf" ]]; then return; fi

  if [[ -f "$conf" ]] && grep -q 'DroidSansM' "$conf"; then return; fi

  mkdir -p "$(dirname "$conf")"
  if [[ -f "$conf" ]] && grep -q '^font_family' "$conf"; then
    sed -i 's/^font_family .*/font_family DroidSansM Nerd Font/' "$conf"
  else
    printf '\nfont_family DroidSansM Nerd Font\nfont_size 11.0\n' >> "$conf"
  fi
  info "Set kitty font to DroidSansM Nerd Font"
}

# Set Nerd Font in Alacritty (TOML for v0.13+, YAML for older)
set_alacritty_font() {
  if ! command -v alacritty &>/dev/null; then return; fi
  local conf_dir="$HOME/.config/alacritty"
  local conf_toml="$conf_dir/alacritty.toml"
  local conf_yml="$conf_dir/alacritty.yml"

  mkdir -p "$conf_dir"

  if [[ -f "$conf_toml" ]]; then
    if grep -q 'DroidSansM' "$conf_toml"; then return; fi
    if grep -q '^\[font' "$conf_toml"; then
      warn "Alacritty config has existing font settings — set font manually to 'DroidSansM Nerd Font'"
      return
    fi
    printf '\n[font]\nsize = 11.0\n\n[font.normal]\nfamily = "DroidSansM Nerd Font"\n' >> "$conf_toml"
  elif [[ -f "$conf_yml" ]]; then
    if grep -q 'DroidSansM' "$conf_yml"; then return; fi
    if grep -q '^font:' "$conf_yml"; then
      warn "Alacritty config has existing font settings — set font manually to 'DroidSansM Nerd Font'"
      return
    fi
    printf '\nfont:\n  normal:\n    family: "DroidSansM Nerd Font"\n  size: 11.0\n' >> "$conf_yml"
  else
    printf '[font]\nsize = 11.0\n\n[font.normal]\nfamily = "DroidSansM Nerd Font"\n' > "$conf_toml"
  fi
  info "Set Alacritty font to DroidSansM Nerd Font"
}

# Set Nerd Font in Konsole (KDE)
set_konsole_font() {
  if ! command -v konsole &>/dev/null; then return; fi
  local profile_dir="$HOME/.local/share/konsole"
  local profile=""

  # Find default profile from konsolerc
  if [[ -f "$HOME/.config/konsolerc" ]]; then
    local default_name
    default_name=$(grep '^DefaultProfile=' "$HOME/.config/konsolerc" 2>/dev/null | cut -d= -f2-)
    [[ -n "$default_name" && -f "$profile_dir/$default_name" ]] && profile="$profile_dir/$default_name"
  fi

  # Fallback: first .profile file
  if [[ -z "$profile" ]]; then
    for f in "$profile_dir"/*.profile; do
      [[ -f "$f" ]] && profile="$f" && break
    done
  fi

  [[ -z "$profile" ]] && return
  if grep -q 'DroidSansM' "$profile" 2>/dev/null; then return; fi

  local font_value="DroidSansM Nerd Font,11,-1,5,50,0,0,0,0,0"
  if grep -q '^Font=' "$profile"; then
    sed -i "s/^Font=.*/Font=$font_value/" "$profile"
  elif grep -q '^\[Appearance\]' "$profile"; then
    sed -i "/^\[Appearance\]/a Font=$font_value" "$profile"
  else
    printf '\n[Appearance]\nFont=%s\n' "$font_value" >> "$profile"
  fi
  info "Set Konsole font to DroidSansM Nerd Font"
}

# Set Nerd Font in WezTerm (creates config only if none exists)
set_wezterm_font() {
  if ! command -v wezterm &>/dev/null; then return; fi
  local conf="$HOME/.config/wezterm/wezterm.lua"
  local conf_alt="$HOME/.wezterm.lua"

  if [[ -f "$conf" ]] || [[ -f "$conf_alt" ]]; then
    local existing="$conf"
    [[ -f "$conf_alt" ]] && existing="$conf_alt"
    if grep -q 'DroidSansM' "$existing"; then return; fi
    warn "WezTerm config exists — add: config.font = wezterm.font('DroidSansM Nerd Font')"
    return
  fi

  mkdir -p "$(dirname "$conf")"
  cat > "$conf" <<'WEZEOF'
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font('DroidSansM Nerd Font')
config.font_size = 11.0

return config
WEZEOF
  info "Set WezTerm font to DroidSansM Nerd Font"
}

# Set Nerd Font in iTerm2 (macOS — modifies default profile via PlistBuddy)
set_iterm2_font() {
  [[ "$PM" != "brew" ]] && return
  local plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
  [[ ! -f "$plist" ]] && return

  local pb="/usr/libexec/PlistBuddy"
  [[ ! -x "$pb" ]] && return

  # Check if already set
  if "$pb" -c "Print ':New Bookmarks:0:Normal Font'" "$plist" 2>/dev/null | grep -q 'DroidSansM'; then
    return
  fi

  local font="DroidSansMNerdFont-Regular 11"
  "$pb" -c "Set ':New Bookmarks:0:Normal Font' '$font'" "$plist" 2>/dev/null || return 0
  info "Set iTerm2 font to DroidSansM Nerd Font (restart iTerm2 to apply)"
}

# Set Nerd Font in Terminator
set_terminator_font() {
  if ! command -v terminator &>/dev/null; then return; fi
  local conf="$HOME/.config/terminator/config"

  if [[ -f "$conf" ]] && grep -q 'DroidSansM' "$conf"; then return; fi

  mkdir -p "$(dirname "$conf")"

  if [[ ! -f "$conf" ]]; then
    cat > "$conf" <<'EOF'
[global_config]
[keybindings]
[profiles]
  [[default]]
    font = DroidSansM Nerd Font 11
    use_system_font = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOF
    info "Set Terminator font to DroidSansM Nerd Font"
    return
  fi

  # Config exists — update font line or insert after [[default]]
  if grep -q '^\s*font\s*=' "$conf"; then
    sed -i 's/^\(\s*\)font\s*=.*/\1font = DroidSansM Nerd Font 11/' "$conf"
  elif grep -q '^\s*\[\[default\]\]' "$conf"; then
    sed -i '/^\s*\[\[default\]\]/a\    font = DroidSansM Nerd Font 11' "$conf"
  else
    printf '\n[profiles]\n  [[default]]\n    font = DroidSansM Nerd Font 11\n    use_system_font = False\n' >> "$conf"
    info "Set Terminator font to DroidSansM Nerd Font"
    return
  fi

  # Ensure use_system_font is disabled
  if grep -q '^\s*use_system_font\s*=' "$conf"; then
    sed -i 's/^\(\s*\)use_system_font\s*=.*/\1use_system_font = False/' "$conf"
  elif grep -q '^\s*\[\[default\]\]' "$conf"; then
    sed -i '/^\s*\[\[default\]\]/a\    use_system_font = False' "$conf"
  fi

  info "Set Terminator font to DroidSansM Nerd Font"
}

# Set Nerd Font in Guake (uses dconf/gsettings)
set_guake_font() {
  if ! command -v guake &>/dev/null; then return; fi
  if ! command -v gsettings &>/dev/null; then return; fi

  if timeout 5 gsettings get org.guake.style.font style 2>/dev/null | grep -q 'DroidSansM'; then
    return
  fi

  timeout 5 gsettings set org.guake.style.font style "DroidSansM Nerd Font 11" 2>/dev/null || return 0
  info "Set Guake font to DroidSansM Nerd Font"
}

# ------------------------------------------------------------------
# 7a. Install font files
# ------------------------------------------------------------------
if [[ "$PM" != "brew" ]]; then
  install_nerd_font
else
  if ! brew list --cask font-droid-sans-mono-nerd-font &>/dev/null; then
    info "Installing Nerd Font via Homebrew..."
    brew install --cask font-droid-sans-mono-nerd-font 2>/dev/null || \
      warn "Failed to install Nerd Font — install manually from https://www.nerdfonts.com"
  else
    info "Nerd Font already installed"
  fi
fi

# ------------------------------------------------------------------
# 7b. Configure font in detected terminal emulators
# ------------------------------------------------------------------
set_gnome_terminal_font || true
set_kitty_font || true
set_alacritty_font || true
set_konsole_font || true
set_wezterm_font || true
set_iterm2_font || true
set_terminator_font || true
set_guake_font || true

# ------------------------------------------------------------------
# 8. Install all Vim plugins
# ------------------------------------------------------------------
info "Installing Vim plugins (this may take a few minutes)..."
# Source the real .vimrc via a wrapper that silences errors, so a
# not-yet-installed colorscheme/plugin doesn't surface E185 during first run.
plug_vimrc=$(mktemp)
printf 'set nocompatible\nsilent! source %s\n' "$VIMRC_DEST" > "$plug_vimrc"
vim -u "$plug_vimrc" -i NONE --not-a-term +"PlugInstall --sync" +qall
rm -f "$plug_vimrc"

info "Plugins installed"

# ------------------------------------------------------------------
# 9. Install language tools (linters, formatters used by ALE)
# ------------------------------------------------------------------
info "Installing language tools for ALE linting/formatting..."

# Node.js tools (JS/TS/JSX/TSX, JSON, Markdown, HTML, CSS, YAML)
if command -v npm &>/dev/null; then
  npm_pkgs=(
    eslint prettier
    typescript typescript-language-server
    markdownlint-cli jsonlint htmlhint stylelint
    yaml-language-server
  )
  info "Installing npm packages: ${npm_pkgs[*]}"
  sudo npm install -g "${npm_pkgs[@]}" 2>/dev/null || npm install -g "${npm_pkgs[@]}" || true
fi

# Python tools
pip_pkgs=(flake8 mypy black isort yamllint)
if command -v pipx &>/dev/null; then
  info "Installing Python packages via pipx: ${pip_pkgs[*]}"
  for pkg in "${pip_pkgs[@]}"; do
    pipx install "$pkg" 2>/dev/null || pipx upgrade "$pkg" 2>/dev/null || true
  done
  pipx ensurepath 2>/dev/null || true
elif command -v pip3 &>/dev/null; then
  info "Installing Python packages: ${pip_pkgs[*]}"
  pip3 install --user --break-system-packages "${pip_pkgs[@]}" 2>/dev/null \
    || pip3 install --user "${pip_pkgs[@]}" 2>/dev/null || true
elif command -v python3 &>/dev/null; then
  info "Installing Python packages: ${pip_pkgs[*]}"
  python3 -m pip install --user --break-system-packages "${pip_pkgs[@]}" 2>/dev/null \
    || python3 -m pip install --user "${pip_pkgs[@]}" 2>/dev/null || true
fi

# Go tools (only if Go is installed)
if command -v go &>/dev/null; then
  info "Installing Go tools: gopls, goimports, golangci-lint..."
  go install golang.org/x/tools/gopls@latest 2>/dev/null || true
  go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null || true
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b "$(go env GOPATH)/bin" 2>/dev/null || true
else
  warn "Go not found — skipping Go tools (install from https://go.dev/dl/)"
fi

# Rust tools (only if Rust is installed)
if command -v rustup &>/dev/null; then
  info "Installing Rust tools: rust-analyzer, rustfmt..."
  rustup component add rust-analyzer 2>/dev/null || true
  rustup component add rustfmt 2>/dev/null || true
elif command -v cargo &>/dev/null; then
  warn "rustup not found but cargo is — install rustup for rust-analyzer and rustfmt"
else
  warn "Rust not found — skipping Rust tools (install from https://rustup.rs/)"
fi

# Shell tools
case "$PM" in
  apt)     sudo apt-get install -y -qq shellcheck shfmt 2>/dev/null || true ;;
  dnf)     sudo dnf install -y -q ShellCheck shfmt 2>/dev/null || true ;;
  pacman)  sudo pacman -S --noconfirm --needed shellcheck shfmt 2>/dev/null || true ;;
  brew)    brew install shellcheck shfmt 2>/dev/null || true ;;
esac

info "Language tools installed"

# ------------------------------------------------------------------
# 10. Summary
# ------------------------------------------------------------------
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Vim configuration installed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Plugins:    ~/.vim/plugged/"
echo "  Config:     ~/.vimrc"
echo "  Undo dir:   ~/.vim/undodir/"
echo "  vim-plug:   ~/.vim/autoload/plug.vim"
echo ""
echo "  Next steps:"
echo "    1. Open vim and run :PlugStatus to verify"
echo "    2. If your terminal font wasn't set automatically, set it to 'DroidSansM Nerd Font'"
echo "    3. For GitHub Copilot: run :Copilot setup"
echo "    4. For tmux integration: uncomment vim-tmux-navigator in .vimrc"

# Warn if vim binary lacks clipboard support (common on Fedora)
if vim --version 2>/dev/null | grep -q '\-clipboard'; then
  if command -v vimx &>/dev/null; then
    echo ""
    echo -e "  ${YELLOW}NOTE:${NC} Your 'vim' binary lacks +clipboard (system clipboard won't work)."
    echo "    Fix: add to your shell profile (~/.bashrc or ~/.zshrc):"
    echo "      alias vim=vimx"
  fi
fi
echo ""
