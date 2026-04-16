set nocompatible
let mapleader = '\'

" set the runtime path to include vim-plug and initialize
let g:polyglot_disabled = ['sensible']
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'preservim/nerdtree'
nnoremap <leader>e :NERDTreeToggle<CR>

Plug 'tpope/vim-commentary'

Plug 'sheerun/vim-polyglot'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='raven'

Plug 'ryanoasis/vim-devicons'
set encoding=utf-8
set guifont=DroidSansM\ Nerd\ Font\ 11
let g:airline_powerline_fonts = 1

Plug 'joshdick/onedark.vim'


Plug 'tpope/vim-surround'

Plug 'cohama/lexima.vim'

Plug 'editorconfig/editorconfig-vim'

Plug 'airblade/vim-gitgutter'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>/ :Rg<CR>

Plug 'mattn/emmet-vim'

" Dot-repeat support for plugin mappings (surround, commentary, etc.)
Plug 'tpope/vim-repeat'

" Async linting and formatting (disable ALE's built-in LSP to avoid duplicates with vim-lsp)
Plug 'dense-analysis/ale'
let g:ale_disable_lsp = 1
let g:ale_fix_on_save = 1
let g:ale_sign_error = 'E'
let g:ale_sign_warning = 'W'

let g:ale_linters = {
\   'javascript':      ['eslint'],
\   'javascriptreact': ['eslint'],
\   'typescript':      ['eslint'],
\   'typescriptreact': ['eslint'],
\   'python':          ['flake8', 'mypy'],
\   'go':              ['golangci-lint'],
\   'rust':            ['cargo'],
\   'yaml':            ['yamllint'],
\   'markdown':        ['markdownlint'],
\   'json':            ['jsonlint'],
\   'css':             ['stylelint'],
\   'html':            ['htmlhint'],
\   'sh':              ['shellcheck'],
\}

let g:ale_fixers = {
\   '*':               ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript':      ['prettier', 'eslint'],
\   'javascriptreact': ['prettier', 'eslint'],
\   'typescript':      ['prettier', 'eslint'],
\   'typescriptreact': ['prettier', 'eslint'],
\   'python':          ['black', 'isort'],
\   'go':              ['goimports'],
\   'rust':            ['rustfmt'],
\   'yaml':            ['prettier'],
\   'markdown':        ['prettier'],
\   'json':            ['prettier'],
\   'css':             ['prettier'],
\   'html':            ['prettier'],
\   'sh':              ['shfmt'],
\}

" LSP client and auto language server installer
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
" NOTE: vim-lsp-ale auto-configures vim-lsp diagnostics (keeps collection
" enabled but disables vim-lsp's own signs/highlights/virtual-text so ALE
" renders them instead). Do NOT set g:lsp_diagnostics_enabled = 0 here.

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gD <plug>(lsp-declaration)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> gy <plug>(lsp-type-definition)
  nmap <buffer> K <plug>(lsp-hover)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> <leader>ca <plug>(lsp-code-action)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Bridge vim-lsp diagnostics through ALE for unified linting UI
Plug 'rhysd/vim-lsp-ale'

" Async autocompletion
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
let g:asyncomplete_auto_completeopt = 0
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Buffer word completion source
Plug 'prabirshrestha/asyncomplete-buffer.vim'
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'allowlist': ['*'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ 'config': { 'max_buffer_size': 5000000 },
    \ }))

" File path completion source
Plug 'prabirshrestha/asyncomplete-file.vim'
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    \ 'name': 'file',
    \ 'allowlist': ['*'],
    \ 'priority': 10,
    \ 'completor': function('asyncomplete#sources#file#completor'),
    \ }))


" Smart search/replace and case coercion (crs, crc, cru, etc.)
Plug 'tpope/vim-abolish'

" Undo tree visualization
Plug 'mbbill/undotree'
nnoremap <F5> :UndotreeToggle<CR>

" Multiple cursors
Plug 'mg979/vim-visual-multi'

" Highlight and strip trailing whitespace
Plug 'ntpeters/vim-better-whitespace'

" Live preview for :s substitutions
Plug 'markonm/traces.vim'

" Start screen with recent files and sessions
Plug 'mhinz/vim-startify'

" Flash yanked region
Plug 'machakann/vim-highlightedyank'

" Extended text objects (arguments, separators, seeking)
Plug 'wellle/targets.vim'

" Modern matchit replacement — enhances % for language keywords, adds i%/a% text objects
Plug 'andymass/vim-matchup'

" Bracket mappings for quickfix, buffers, blank lines, option toggling
Plug 'tpope/vim-unimpaired'

" Code outline / symbol viewer (works with vim-lsp)
Plug 'liuchengxu/vista.vim'
let g:vista_default_executive = 'vim_lsp'
nnoremap <F8> :Vista!!<CR>

" Snippet engine (VSCode format) + snippet collection
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'rafamadriz/friendly-snippets'
" Expand snippet
imap <expr> <C-l> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-l>'
smap <expr> <C-l> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-l>'
" Jump forward/backward through snippet tabstops
imap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
smap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'

" Two-character motion to jump anywhere on screen
Plug 'justinmk/vim-sneak'
let g:sneak#label = 1

" AI inline code completion (requires Vim 9.0+ and a Copilot subscription)
Plug 'github/copilot.vim'

" Async build/dispatch with quickfix integration
Plug 'tpope/vim-dispatch'

" Show available keybindings after pressing leader
Plug 'liuchengxu/vim-which-key'
nnoremap <silent> <leader> :WhichKey '\'<CR>

" Automatic continuous session saving
Plug 'tpope/vim-obsession'

" Indent level visualization
Plug 'Yggdroot/indentLine'
let g:indentLine_fileTypeExclude = ['json', 'markdown']

" Git conflict marker highlight and resolution (ct/co/cn/cb)
Plug 'rhysd/conflict-marker.vim'

" Quickfix list enhancements (:Keep, :Reject, auto-resize)
Plug 'romainl/vim-qf'

" Automatic indent detection per file
Plug 'tpope/vim-sleuth'

" Close buffers without breaking window layout (:Bdelete)
Plug 'moll/vim-bbye'
nnoremap <leader>q :Bdelete<CR>

" Uncomment if you use tmux:
" Plug 'christoomey/vim-tmux-navigator'

" Debugging (DAP protocol, same adapters as VS Code)
Plug 'puremourning/vimspector'
let g:vimspector_enable_mappings = ''
nmap <leader>dc <Plug>VimspectorContinue
nmap <leader>db <Plug>VimspectorToggleBreakpoint
nmap <leader>dB <Plug>VimspectorToggleConditionalBreakpoint
nmap <leader>ds <Plug>VimspectorStepOver
nmap <leader>di <Plug>VimspectorStepInto
nmap <leader>do <Plug>VimspectorStepOut
nmap <leader>dr <Plug>VimspectorRestart
nmap <leader>dx <Plug>VimspectorStop

" Test runner (:TestNearest, :TestFile, :TestSuite)
Plug 'vim-test/vim-test'
let test#strategy = 'dispatch'
nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ts :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>

" Unix shell helpers (:Delete, :Rename, :Move, :Mkdir, :SudoWrite)
Plug 'tpope/vim-eunuch'

" Terminal management (:FloatermNew, :FloatermToggle)
Plug 'voldikss/vim-floaterm'
nnoremap <F12> :FloatermToggle<CR>
tnoremap <F12> <C-\><C-n>:FloatermToggle<CR>

" Markdown preview in browser (:MarkdownPreview)
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown'] }

" Git log browser (:GV, :GV! for current file, :GV? for location list)
Plug 'junegunn/gv.vim'

" All of your Plugins must be added before the following line
call plug#end()

" CR mapping must be after plug#end() so lexima.vim doesn't overwrite it.
" Guard against either plugin failing to load so <CR> always works.
function! s:cr_mapping() abort
  if pumvisible()
    return exists('*asyncomplete#close_popup') ? asyncomplete#close_popup() : "\<CR>"
  endif
  return exists('*lexima#expand') ? lexima#expand('<CR>', 'i') : "\<CR>"
endfunction
inoremap <expr> <cr> <SID>cr_mapping()
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PlugInstall    - installs plugins
" :PlugUpdate     - installs or updates plugins
" :PlugClean      - confirms removal of unused plugins
" :PlugStatus     - check the status of plugins
"
" see https://github.com/junegunn/vim-plug for more details
" Put your non-Plugin stuff after this line

"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Auto-reload files changed outside Vim
set autoread

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu
set wildmode=longest:full,full

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <leader><space> to turn off highlighting)
set hlsearch

" Show search matches as you type
set incsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Highlight the current line
set cursorline

" Keep 5 lines visible above/below cursor when scrolling
set scrolloff=5

" Always show the sign column to prevent text shifting
set signcolumn=yes

" Open new splits below and to the right
set splitbelow
set splitright

" Faster CursorHold events for gitgutter, ALE, and vim-lsp (default 4000ms)
set updatetime=300

" Completion popup behavior (required for asyncomplete)
set completeopt=menuone,noinsert,noselect,popup
set shortmess+=c

" Hide redundant mode indicator (airline already shows it)
set noshowmode

" Time out on mappings after 500ms (needed for which-key), fast timeout on keycodes
set timeout timeoutlen=500 ttimeout ttimeoutlen=200


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=2
set softtabstop=2
set expandtab

" Use system clipboard for yank/paste
set clipboard=unnamedplus

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
"set shiftwidth=4
"set tabstop=4


"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
nnoremap Y y$

" Clear search highlighting
nnoremap <leader><space> :nohl<CR>

" Split navigation with Ctrl+h/j/k/l
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Persistent undo across sessions (undotree works much better with this)
if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undodir
  if !isdirectory(expand('~/.vim/undodir'))
    call mkdir(expand('~/.vim/undodir'), 'p')
  endif
endif

syntax on
colorscheme onedark
