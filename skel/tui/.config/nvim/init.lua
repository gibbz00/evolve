-- add arch defaults
vim.opt.clipboard = 'unnamed,unnamedplus'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.confirm = true 
vim.opt.shortmess = 'AImoOstx'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.nrformats = 'unsigned'
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.g.mapleader = ' '

require('ayu').colorscheme()

-- until these are fixed
-- https://github.com/neovim/neovim/issues/8350
-- https://github.com/neovim/neovim/issues/17676
