" Use Vim settings instead of Vi. Must be first because
" it changes other options.
set nocompatible

map <C-L> :tabnext<CR>
map <C-H> :tabprevious<CR>
map <C-K> :tabnew<CR>
map <leader>n :NERDTreeToggle<CR>
set guioptions=-T
set guioptions=-b
set guifont=Monospace\ 8
colorscheme molokai

nore ; :
cnoreabbrev W w
cnoreabbrev Q q

"Activate pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Enable syntax highlighting
syntax on

"---- Indentation ----"
filetype plugin on
filetype plugin indent on	" Turn on indentation rules per language
set tabstop=4
set shiftwidth=4		    " Use 4 spaces for smartindent
set autoindent
set mouse=a

"---- Console UI & Text Display ----"
set showcmd			        " Show info about current command
set ruler			        " Show line number in status bar
set noerrorbells	        " No error sounds
set scrolloff=3		        " Keep 5 lines above and below
set wildmode=longest:full   " Better completion!
set wildmenu                " Better completion!

set guioptions+=a

"Searching options
set ignorecase
set showmatch
set incsearch
set hlsearch

set backup
set backupdir=~/.vim.backup/
set directory=~/.vim.backup/
set writebackup


"Command t file limit
let g:CommandTMaxFiles=200000
let g:CommandTMaxDepth=40
let g:CommandTMaxCachedDirectories=40

"---- ctags ----"
set tags=./tags;            " Look for tag file all the way up to root.

