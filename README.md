# vimrc

My personal Vim configuration with 54 plugins covering LSP, completion, debugging, testing, Git, fuzzy finding, snippets, and more.

## Quick Install

```bash
git clone https://github.com/cadic2603/vimrc.git ~/vimrc
cd ~/vimrc
./install.sh
```

The script handles everything: system dependencies, Nerd Font, vim-plug, plugin installation, and backup of your existing `.vimrc`.

### Supported systems

- Debian/Ubuntu (apt)
- Fedora/RHEL (dnf)
- Arch Linux (pacman)
- macOS (Homebrew)

### Manual install

If you prefer to install manually:

```bash
# Copy config
cp .vimrc ~/.vimrc

# Install vim-plug (auto-installs on first vim launch, or manually):
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Open vim and install plugins
vim +PlugInstall
```

### Prerequisites

- Vim 9.0+ (the install script auto-builds from source if your distro ships an older version)
- git, curl, unzip
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for `:Rg` search)
- [Node.js](https://nodejs.org/) (for GitHub Copilot)
- [Nerd Font](https://www.nerdfonts.com/) (for devicons and powerline symbols)
- xclip or xsel (for system clipboard on Linux)

## Plugins

### Git

| Plugin | Description |
|--------|-------------|
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git commands (`:Git`, `:Git blame`, etc.) |
| [vim-gitgutter](https://github.com/airblade/vim-gitgutter) | Git diff signs in the gutter |
| [conflict-marker.vim](https://github.com/rhysd/conflict-marker.vim) | Highlight and resolve git conflict markers |
| [gv.vim](https://github.com/junegunn/gv.vim) | Git log browser (`:GV`) |

### Navigation

| Plugin | Description |
|--------|-------------|
| [NERDTree](https://github.com/preservim/nerdtree) | File explorer sidebar |
| [fzf.vim](https://github.com/junegunn/fzf.vim) | Fuzzy finder (files, buffers, ripgrep) |
| [vista.vim](https://github.com/liuchengxu/vista.vim) | Code outline / symbol viewer (LSP-powered) |
| [vim-sneak](https://github.com/justinmk/vim-sneak) | Two-character motion with labels |

### LSP, Completion & Snippets

| Plugin | Description |
|--------|-------------|
| [vim-lsp](https://github.com/prabirshrestha/vim-lsp) | LSP client (definition, hover, rename, references) |
| [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings) | Auto-install language servers |
| [vim-lsp-ale](https://github.com/rhysd/vim-lsp-ale) | Bridge vim-lsp diagnostics through ALE |
| [ALE](https://github.com/dense-analysis/ale) | Async linting and formatting |
| [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim) | Async autocompletion |
| [asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim) | LSP completion source |
| [asyncomplete-buffer.vim](https://github.com/prabirshrestha/asyncomplete-buffer.vim) | Buffer word completion source |
| [asyncomplete-file.vim](https://github.com/prabirshrestha/asyncomplete-file.vim) | File path completion source |
| [vim-vsnip](https://github.com/hrsh7th/vim-vsnip) | Snippet engine (VSCode format) |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Snippet collection |
| [copilot.vim](https://github.com/github/copilot.vim) | GitHub Copilot AI completion |

### Editing

| Plugin | Description |
|--------|-------------|
| [vim-surround](https://github.com/tpope/vim-surround) | Surround text with brackets/quotes/tags |
| [vim-commentary](https://github.com/tpope/vim-commentary) | Toggle comments (`gcc` / `gc`) |
| [lexima.vim](https://github.com/cohama/lexima.vim) | Auto-close brackets and quotes |
| [vim-repeat](https://github.com/tpope/vim-repeat) | Dot-repeat for plugin mappings |
| [vim-abolish](https://github.com/tpope/vim-abolish) | Smart substitution and case coercion |
| [vim-unimpaired](https://github.com/tpope/vim-unimpaired) | Bracket mappings (`]q`, `[b`, `]e`, etc.) |
| [targets.vim](https://github.com/wellle/targets.vim) | Extended text objects (arguments, separators) |
| [vim-matchup](https://github.com/andymass/vim-matchup) | Enhanced `%` matching for language keywords |
| [vim-visual-multi](https://github.com/mg979/vim-visual-multi) | Multiple cursors |
| [emmet-vim](https://github.com/mattn/emmet-vim) | HTML/CSS expansion |
| [traces.vim](https://github.com/markonm/traces.vim) | Live preview for `:s` substitutions |
| [vim-better-whitespace](https://github.com/ntpeters/vim-better-whitespace) | Highlight/strip trailing whitespace |

### Debugging & Testing

| Plugin | Description |
|--------|-------------|
| [vimspector](https://github.com/puremourning/vimspector) | DAP debugger (same adapters as VS Code) |
| [vim-test](https://github.com/vim-test/vim-test) | Test runner (`:TestNearest`, `:TestFile`, `:TestSuite`) |
| [vim-dispatch](https://github.com/tpope/vim-dispatch) | Async build/dispatch with quickfix |

### UI & Appearance

| Plugin | Description |
|--------|-------------|
| [vim-airline](https://github.com/vim-airline/vim-airline) | Status/tabline (theme: `raven`) |
| [vim-devicons](https://github.com/ryanoasis/vim-devicons) | File-type icons |
| [onedark.vim](https://github.com/joshdick/onedark.vim) | One Dark color scheme |
| [indentLine](https://github.com/Yggdroot/indentLine) | Indent level visualization |
| [vim-highlightedyank](https://github.com/machakann/vim-highlightedyank) | Flash yanked region |

### Utilities

| Plugin | Description |
|--------|-------------|
| [vim-eunuch](https://github.com/tpope/vim-eunuch) | Unix helpers (`:Delete`, `:Rename`, `:SudoWrite`) |
| [vim-floaterm](https://github.com/voldikss/vim-floaterm) | Terminal management |
| [vim-obsession](https://github.com/tpope/vim-obsession) | Continuous session saving |
| [vim-startify](https://github.com/mhinz/vim-startify) | Start screen with recent files |
| [vim-which-key](https://github.com/liuchengxu/vim-which-key) | Keybinding discovery popup |
| [undotree](https://github.com/mbbill/undotree) | Undo tree visualization |
| [vim-bbye](https://github.com/moll/vim-bbye) | Close buffers without breaking layout |
| [vim-qf](https://github.com/romainl/vim-qf) | Quickfix list enhancements |
| [vim-sleuth](https://github.com/tpope/vim-sleuth) | Automatic indent detection |
| [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim) | EditorConfig support |
| [vim-polyglot](https://github.com/sheerun/vim-polyglot) | Language pack (syntax, indent, ftdetect) |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live markdown preview in browser (`:MarkdownPreview`) |

## Language Support

The install script sets up linters, formatters, and language servers automatically.

| Language | LSP Server (auto-installed) | Linter | Formatter | Fix on Save |
|---|---|---|---|---|
| Go | gopls | golangci-lint | gofmt + goimports | Yes |
| Rust | rust-analyzer | cargo | rustfmt | Yes |
| TypeScript / TSX | typescript-language-server | eslint | eslint + prettier | Yes |
| JavaScript / JSX | typescript-language-server | eslint | eslint + prettier | Yes |
| Python | pylsp or pyright | flake8, mypy | black, isort | Yes |
| YAML | yaml-language-server | yamllint | prettier | Yes |
| Markdown | marksman | markdownlint | prettier | Yes |
| JSON | json-languageserver | jsonlint | prettier | Yes |
| HTML | — | htmlhint | prettier | Yes |
| CSS | — | stylelint | prettier | Yes |
| Shell/Bash | — | shellcheck | shfmt | Yes |

LSP servers are auto-installed by `vim-lsp-settings` when you first open a file of that type — just run `:LspInstallServer` when prompted.

Markdown preview: open a `.md` file and run `:MarkdownPreview` to see a live preview in your browser.

## Key Mappings

### General

| Key | Mode | Action |
|-----|------|--------|
| `Y` | Normal | Yank to end of line |
| `<leader><space>` | Normal | Clear search highlighting |
| `Ctrl+H/J/K/L` | Normal | Navigate between splits |
| `<leader>q` | Normal | Close buffer (keep window layout) |

### File Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | Normal | Toggle NERDTree |
| `Ctrl+P` | Normal | Fuzzy find files |
| `<leader>b` | Normal | Fuzzy find buffers |
| `<leader>/` | Normal | Ripgrep search |
| `F8` | Normal | Toggle code outline (Vista) |

### LSP

| Key | Mode | Action |
|-----|------|--------|
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gr` | Normal | Find references |
| `gi` | Normal | Go to implementation |
| `gy` | Normal | Go to type definition |
| `K` | Normal | Hover documentation |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code action |
| `[g` / `]g` | Normal | Previous/next diagnostic |

### Completion & Snippets

| Key | Mode | Action |
|-----|------|--------|
| `Tab` / `S-Tab` | Insert | Navigate completion popup |
| `Enter` | Insert | Accept completion |
| `Ctrl+L` | Insert | Expand snippet |
| `Ctrl+J` / `Ctrl+K` | Insert | Jump to next/previous snippet tabstop |

### Debugging (Vimspector)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>dc` | Normal | Continue |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dB` | Normal | Conditional breakpoint |
| `<leader>ds` | Normal | Step over |
| `<leader>di` | Normal | Step into |
| `<leader>do` | Normal | Step out |
| `<leader>dr` | Normal | Restart |
| `<leader>dx` | Normal | Stop |

### Testing (vim-test)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tn` | Normal | Test nearest |
| `<leader>tf` | Normal | Test file |
| `<leader>ts` | Normal | Test suite |
| `<leader>tl` | Normal | Test last |

### Other

| Key | Mode | Action |
|-----|------|--------|
| `F5` | Normal | Toggle undo tree |
| `F12` | Normal/Terminal | Toggle terminal (floaterm) |
| `gcc` | Normal | Toggle comment on line |
| `gc` | Visual | Toggle comment on selection |
| `s{char}{char}` | Normal | Sneak — jump to two-character match |
| `crs` / `crc` / `cru` | Normal | Coerce to snake_case / camelCase / UPPER_CASE |

## Settings

- **Theme**: One Dark + Airline `raven`
- **Font**: DroidSansM Nerd Font 11
- **Indentation**: 2 spaces (auto-detected per file by vim-sleuth)
- **Line numbers**: Absolute
- **Search**: Incremental, case-insensitive unless uppercase used (`smartcase`)
- **Mouse**: Enabled in all modes
- **Clipboard**: System clipboard (`unnamedplus`)
- **Undo**: Persistent across sessions (`~/.vim/undodir/`)
- **Update time**: 300ms (for fast gutter/diagnostic updates)
- **Completion**: `menuone,noinsert,noselect,popup`
