"
" Plugin Installation
"
call plug#begin('~/.vim/plugged')

Plug 'janko/vim-test'
Plug 'vim-syntastic/syntastic'
Plug 'kien/ctrlp.vim'
Plug 'mileszs/ack.vim'
Plug 'neomake/neomake'
Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree'
Plug 'wavded/vim-stylus'
Plug 'mboughaba/i3config.vim'
Plug 'skywind3000/asyncrun.vim'

call plug#end()
filetype plugin indent on


"
" General config
"

:let mapleader = ","

:color lucius
:syntax on
:set number
:set relativenumber
:set tabstop=4
:set shiftwidth=4
:set expandtab
:set ruler
:set nolist
:set autoindent
:set ignorecase

syntax on

set splitbelow
set splitright

" Display status bar regardless of windows
set laststatus=2


" Navigate tabs with Ctrl + Left/Right
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-l> :tabnext<CR>

" Move tabs with Shift + Left/Right
nnoremap <S-Left> :-tabm<CR>
nnoremap <S-Right> :+tabm<CR>

" Leader + Tab to go to last active tab
if !exists('g:lasttab')
  let g:lasttab = 1
endif
nmap <leader><Tab> :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

nnoremap <leader>p :PlugInstall<CR>

" .vimrc mappings
nnoremap <leader>ss :so ~/.vimrc<CR><CR>
nnoremap <leader>se :tabe ~/.vimrc<CR>

:map <C-m> i<CR><Esc>

" Match bash file completion
set wildmenu
set wildmode=longest,list

" Search globally with <leader>aa
nnoremap <leader>aa :Ack!<space>

" Save with Leader+l
nnoremap <leader>w :w<CR>

" Open/Close Quickfix window
nnoremap <leader>cv :vert copen85<CR>
nnoremap <leader>co :copen15<CR>
nnoremap <leader>cc :cclose<CR>

" Trim whitespace with leader+dw
:nnoremap <leader>dw :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>


" Move by line on the screen rather than by line in the file
nnoremap <buffer> k gk
nnoremap <buffer> j gj

" Persist undos
set undodir=~/.vim/undodir
set undofile

set updatetime=100

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" Cursor change
let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"
hi MatchParen cterm=bold ctermbg=none ctermfg=magenta

set list listchars=trail:.,extends:>

" tree
autocmd StdinReadPre * let s:std_in=1

" Leader + c to paste from global clipboard
vnoremap <leader>y "+y


"
" Vim-Test config
"

map <leader>tn :TestNearest<CR>
map <leader>tt :TestFile<CR>
map <leader>ts :TestSuite<CR>
map <leader>tl :TestLast<CR>
map <leader>tv :TestVisit<CR>

let test#strategy = "asyncrun"

let test#python#djangotest#executable = 'cd ~/Dev/stack/ && docker-compose run timesheet python manage.py test'
let test#python#runner = 'djangotest'

"
" Lightline Config
"

let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" Transparent background
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE


"
" Syntastic Config
"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
let g:syntastic_ignore_files = ['/node_modules/']

" Auto adjust height of errors pane
function! SyntasticCheckHook(errors)
    if !empty(a:errors)
        let g:syntastic_loc_list_height = min([len(a:errors), 10])
    endif
endfunction

" Syntastic mappings
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
nnoremap <leader>lt :SyntasticToggleMode<CR>
nnoremap <leader>ll :SyntasticCheck<CR>
nnoremap <leader>lr :SyntasticReset<CR>

"
" CTRLP Config
"

let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'


"
" NerdTree config
"
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

let NERDTreeShowHidden=1

nnoremap <leader>n :NERDTree %<CR>
map <C-n> :NERDTreeToggle<CR>

call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

autocmd vimenter * NERDTree
