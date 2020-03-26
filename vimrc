" Use Vim settings instead of Vi. Must be first because
" it changes other options.
set nocompatible

map <C-L> :tabnext<CR>
map <C-H> :tabprevious<CR>
map <C-K> :tabnew<CR>
map <leader>n :NERDTreeToggle<CR>
set guioptions=-T
set guioptions=-b
if has("gui_macvim")
	set guifont=Monaco:h12
else
	set guifont=Monospace\ 8
endif

nore ; :
cnoreabbrev W w
cnoreabbrev Q q

"clipboard sanity
set clipboard=unnamed

" Enable syntax highlighting
syntax on
syntax enable
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case

"---- Indentation ----"
filetype off
filetype plugin on
filetype plugin indent on	" Turn on indentation rules per language
set smartindent
set tabstop=4
set shiftwidth=4		    " Use 4 spaces for smartindent
set expandtab
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

"Hightlight line
set cursorline

"
"Clojure
au BufEnter *.clj RainbowParenthesesActivate
au Syntax clojure RainbowParenthesesLoadRound
au Syntax clojure RainbowParenthesesLoadSquare
au Syntax clojure RainbowParenthesesLoadBraces

"Fireplace-Clojure
map <C-E> :Eval<CR>

"

call plug#begin('~/.vim/plugged')
set rtp+=/usr/local/bin/fzf
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'micha/vim-colors-solarized'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'artur-shaik/vim-javacomplete2'
Plug 'mhinz/vim-startify'
Plug 'davidhalter/jedi-vim'



" Initialize plugin system
call plug#end()
nnoremap <C-o> :FZF<CR>

"---- ctags ----"
set tags=./tags;            " Look for tag file all the way up to root.
let g:go_version_warning = 0


" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
"
"Solarized
if has("gui_running")
	set guifont=Monaco:h10
    set background=dark
    colorscheme solarized
else
    let g:solarized_termcolors=256
    colorscheme solarized
	set guifont=Monospace\ 8
endif

"java autocomplete
autocmd FileType java setlocal omnifunc=javacomplete#Complete

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
