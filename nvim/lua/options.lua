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

-- Filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.foldmethod = "indent"
  end,
})

-- Project-specific tab settings
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufEnter" }, {
  pattern = { "*/react-web-app/*", "*/lantum-native/*" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Native LSP configuration (Neovim 0.11+)
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

-- LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true, buffer = args.buf }

    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "<leader>ll", vim.diagnostic.open_float, opts)
    map("n", "[d", vim.diagnostic.goto_prev, opts)
    map("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})

-- Configure LSP servers (Neovim 0.11+ native)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("pyright", {})

-- Enable LSP servers
vim.lsp.enable({ "lua_ls", "pyright" })
