-- General Neovim options
-- Ported from vimrc

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.ruler = true
opt.cursorline = true
opt.scrolloff = 8

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Backspace behavior
opt.backspace = "indent,eol,start"

-- Status line
opt.laststatus = 2
opt.showmode = false

-- Wild menu (command completion)
opt.wildmenu = true
opt.wildmode = "longest,list"

-- Persistent undo
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true

-- Update time (for gitgutter/gitsigns)
opt.updatetime = 100

-- List characters (trailing whitespace)
opt.list = true
opt.listchars = { trail = ".", extends = ">" }

-- Clipboard (system clipboard)
opt.clipboard = "unnamedplus"

-- Disable netrw (using nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Project-specific tab settings
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufEnter" }, {
  pattern = { "*/react-web-app/*", "*/lantum-native/*" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

