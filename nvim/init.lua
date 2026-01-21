-- Neovim Configuration
-- Migrated from vimrc to Lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before loading plugins
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Load core configuration
require("options")
require("keymaps")

-- Load plugins
require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
  },
})
