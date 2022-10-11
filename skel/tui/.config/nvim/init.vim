" Arch defaults
runtime! archlinux.vim

" use system clipboard (requires +clipboard)
set clipboard^=unnamed,unnamedplus

set tabstop=4
set shiftwidth=4
set relativenumber     " relative line numbers 
set number             " line number on current line

set confirm            " ask confirmation to quit on unsaved file
set shortmess=AImoOstx
set ignorecase         " ingore case during search
set smartcase          " do not ignore case if capital letter are explicitly used 
set nrformats=         " Treat all numbers as decimal numbers
set termguicolors
colorscheme ayu
let ayucolor="dark"
