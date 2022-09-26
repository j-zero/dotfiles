set nocompatible                   " be iMproved, required
filetype off                       " required
filetype plugin indent on           " required

" BASIC EDITOR SETUP
set number                " Line Numbers
set nowrap                " Start withou wrapping
set nocursorline            " Highlight the current line
set laststatus=2          " Always display status bar
set nocursorcolumn        " Cursor column highlight is slow set noswapfile            " Comment our rather than add to .gitignore
set encoding=utf8         " Unicode
set ffs=unix,dos,mac      " Unix as standard file type
set hlsearch              " Highlight searched words
set autochdir             " New files are automatically saved in dir of current file
syntax enable             " Enable syntax highlighting
set autoread              " Auto-reload file on change
set relativenumber        " relative line numbers
set undofile
set lazyredraw
syntax sync minlines=256
set synmaxcol=200

" enable wildmenu
set wildmenu

" enable ruler
set ruler
set cmdheight=1

" MAP THE LEADER KEY
let mapleader=","
set timeout timeoutlen=1500

" fast save
nmap <leader>w :w!<cr>

" tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabopen<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>tn :tabnew<cr>
map <leader>t<leader> :tabnext

" misc
" remove ^M
noremap <Leader>m mmHmt:%s/<0 noremap <LeadeC-V><cr>//ge<cr>'tzt'm
" quickly open scribble.md
map <leader>x :e ~/scribble.md<cr>

" let 'tl' toggle between this and last tab
let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()


" :W sudo save!
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Fix VIMs Regex Formatting for searches
nnoremap / /\v
vnoremap / /\v

" Case Insensitive Seach
set ignorecase
set smartcase

" Substitute globally by default
set gdefault

" Show results as typing
set incsearch
set showmatch
set hlsearch

" for regex turn on magic
set magic

" statusline
set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ (%r%{getcwd()}%h)\ \ \ Line:\ %l\ \ Column:\ %c

" Clear the Search
nnoremap <leader><space> :noh<cr>

" Change Cursor Shape for Different Modes
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Jump to Match w/ Tab
nnoremap <tab> %
vnoremap <tab> %

" set autoindent noexpandtab tabstop=2 shiftwidth=2

" Spaces
set autoindent expandtab shiftwidth=2 tabstop=2
retab


" FON SETTING
" set noantialias      " Turn on/off Anti-Aliased Fonts
set linespace=0       " Space between each line (pixels I think)

" Theme
try
   colorscheme codedark
catch
endtry
" let g:airline_theme='base16-flat'
set background=dark

" OTHER SETTINGS

" HANDLED IN COLOR SCHEME NOW
"" WHITESPACE LIST CHARS
set listchars=eol:˼,tab:»·,trail:.,extends:>,precedes:<,nbsp:_

" Line Wrapping
set nowrap
set textwidth=100
set formatoptions=qrn1
set colorcolumn=100

autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags

" UNDO LEVELS
set undodir=~/.vim/undo/
set undofile
set undolevels=1000
set undoreload=10000


" DISABLED TERMINAL BELL
autocmd! GUIEnter * set vb t_vb=

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

function! TrimWhiteSpace()
    %s/\s\+$//e
endfunction
" autocmd BufWritePre     *.* :call TrimWhiteSpace()




" REMOVE \N FROM EOL
" But preserve EOL if one already exists in the file
setlocal noeol | let b:PreserveNoEOL = 1


" HELPER FUNCTIONS

function! HasPaste()
  if &paste
      return 'PASTE MODE  '
  endif
  return ''
endfunction


