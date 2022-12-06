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

-- vim.keymay.set('mode', 'key', 'value')

-- Save
vim.keymap.set('n', '<leader>s', '<CMD>update<CR>')

-- Borne keyboard specific
vim.keymap.set('n', '<S-/>', '?')
-- Jump backwards to end of word
vim.keymap.set('n', 'h', 'ge')
vim.keymap.set('n', 'k', 'gE')

require('ayu').colorscheme()
require("mason").setup()
require("mason-lspconfig").setup()
-- :h mason-lspconfig-autoamtic-server-setup
require("mason-lspconfig").setup_handlers {
        function (server_name)
            require("lspconfig")[server_name].setup {}
        end
}

-- until these are fixed
-- https://github.com/neovim/neovim/issues/8350
-- https://github.com/neovim/neovim/issues/17676
