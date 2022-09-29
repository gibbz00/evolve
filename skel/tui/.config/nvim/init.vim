" Theme
set termguicolors     " enable true colors support
" let ayucolor="light"  " for light version of theme
" let ayucolor="mirage" " for mirage version of theme
let ayucolor="dark"   " for dark version of theme
colorscheme ayu

" Arch defaults
runtime! archlinux.vim

" use system clipboard (requires +clipboard)
set clipboard^=unnamed,unnamedplus
set encoding=utf8
set modeline           " enable vim modelines
set hlsearch           " highlight search items
set incsearch          " searches are performed as you type
set number             " enable line numbers
set confirm            " ask confirmation like save before quit.
set wildmenu           " Tab completion menu when using command mode
set expandtab          " Tab key inserts spaces not tabs
set softtabstop=4      " spaces to enter for each tab
set shiftwidth=4       " amount of spaces for indentation
set shortmess+=aAcIws  " Hide or shorten certain messages
set showcmd             " Show command that is entered
set ignorecase          " ingore case during search
set nrformats=          " Treat all numbers as decimal numbers
set history=200
set timeoutlen=3  "pressing escape key delay fix
set ttimeoutlen=0       

" force write
cnoremap w! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" == Netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
" 25 percent width
let g:netrw_winsize = 25
nnoremap <silent> ~ :Vexplore<CR>

" set spell spelllang=en_us,sv

" Split direction
set splitbelow
set splitright

" Securely run vimrc configs from current working directory	
" set exrc
" set secure
filetype plugin indent on

" Hide end of buffer '~'
highlight EndOfBuffer ctermfg=black ctermbg=black

" undo directory 
set undodir=~/.config/nvim/undodir
set undofile
set undolevels=1000
set undoreload=10000

" --- Remappings ---
"
"  Adding alt+<key> functionality:
"  https://unix.stackexchange.com/questions/14765/how-to-map-alt-key-in-vimrc
for i in range(97,122)
  let c = nr2char(i)
  exec "map \e".c." <M-".c.">"
  exec "map! \e".c." <M-".c.">"
endfor

" inserting inkscape figures (requires vimtex and inkscape-figureso)
inoremap <M-f> <Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/figures/"'<CR><CR>:w<CR>
nnoremap <M-f> : silent exec '!inkscape-figures edit "'.b:vimtex.root.'/figures/" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR><CR>

" spellcheck on the fly
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" Leader
let mapleader=" "
let maplocalleader = "\\"

" buffer change remapping
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>
" Clear highlight searches
nnoremap <silent> <C-L> :noh<CR>

" --- Plugins ---=

" Autopairs (uncommented due to arch repo having vim as dependency)
" let g:AutoPairsFlyMode = 1
" let g:AutoPairsShortcutBackInsert = '<M-b>'
" let g:AutoPairsShortcutFastWrap = '<M-e>'
" let g:AutoPairsShortcutToggle = ''

" ALE
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

"LanguageClient-neovim
let g:LanguageClient_serverCommands = {
            \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
            \ 'python': ['/usr/local/bin/pyls'],
            \ }
noremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>

" Vimtex
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
" concealment with vim-tex-concal
set conceallevel=2
let g:tex_conceal="abdgms"

" toggle table of contents
noremap <M-t> :VimtexTocToggle<CR>
" synctex view 
noremap <M-v> :VimtexView<CR>
" compile and open pdfreader
noremap <M-c> :VimtexCompile<CR>

" neovim synctex requirement, neovim-remote must aditionally be used for
" synctex to work properly. 
let g:vimtex_compiler_progname = 'nvr'

" ultinips
" let g:UltiSnipsExpandTrigger = '<tab>'
" let g:UltiSnipsJumpForwardTrigger = '<tab>'
" let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" jump to last
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif


function! Prose()
  call lexical#init()
  call textobj#sentence#init()
  Goyo

  " replace common punctuation
  iabbrev <buffer> -- –
  iabbrev <buffer> --- —
  iabbrev <buffer> << «
  iabbrev <buffer> >> »
endfunction


autocmd Filetype ruby setlocal tabstop=2 shiftwidth=2 expandtab
" autocmd Filetype tex,latex !python3 ~/code/inkscape-shortcut-manager/main.py
" autocmd Filetype tex,latex !inkscape-figures watch

let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'
