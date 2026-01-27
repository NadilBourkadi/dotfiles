-- Key mappings

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local utils = require("core.utils")

-- Save file
map("n", "<leader>w", ":w<CR>", opts)

-- Quick quit (save all and exit) - reopen with `nvim` to restore session
map("n", "<leader>qq", ":wqa<CR>", opts)

-- Restart Neovim (tmux only) - saves state then respawns pane with nvim
map("n", "<leader>rs", function()
  if not os.getenv("TMUX") then
    vim.notify("Not in tmux - use <leader>qq to quit", vim.log.levels.WARN)
    return
  end
  vim.cmd("silent! wall")
  local cwd = vim.fn.getcwd()
  local state_file = utils.get_state_file(cwd)

  -- Save nvim-tree state and flag to prevent VimLeavePre from overwriting
  utils.save_nvim_tree_state(state_file)
  vim.g.nvim_restarting = true

  -- Save session then respawn (with shell wrapper so pane survives nvim exit)
  require("persistence").save()
  vim.fn.system("tmux respawn-pane -k -c " .. vim.fn.shellescape(cwd) .. " 'zsh -c \"nvim; exec zsh\"'")
end, vim.tbl_extend("force", opts, { desc = "Restart Neovim" }))

-- Tab navigation
map("n", "<C-h>", ":tabprevious<CR>", opts)
map("n", "<C-l>", ":tabnext<CR>", opts)

-- Move tabs
map("n", "<S-Left>", ":-tabm<CR>", opts)
map("n", "<S-Right>", ":+tabm<CR>", opts)

-- Last active tab
vim.g.lasttab = 1
map("n", "<leader><Tab>", function() vim.cmd("tabn " .. vim.g.lasttab) end, opts)
vim.api.nvim_create_autocmd("TabLeave", {
  callback = function()
    vim.g.lasttab = vim.fn.tabpagenr()
  end,
})

-- Config file shortcut
map("n", "<leader>se", ":tabe $MYVIMRC<CR>", opts)

-- Insert newline without entering insert mode
map("n", "<C-m>", "i<CR><Esc>", opts)

-- Quickfix window
map("n", "<leader>cv", ":vert copen 70<CR>", opts)
map("n", "<leader>co", ":copen 15<CR>", opts)
map("n", "<leader>cc", ":cclose<CR>", opts)

-- Trim trailing whitespace
map("n", "<leader>dw", [[<cmd>let _s=@/ | %s/\s\+$//e | let @/=_s | nohl<CR>]], opts)

-- Move by visual line (screen line) rather than file line
map("n", "k", "gk", { noremap = true })
map("n", "j", "gj", { noremap = true })

-- Yank to system clipboard
map("v", "<leader>y", '"+y', opts)

-- Plugin install (lazy.nvim equivalent)
map("n", "<leader>pi", ":Lazy<CR>", opts)
