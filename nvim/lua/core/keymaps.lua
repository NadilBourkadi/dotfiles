-- Key mappings

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local utils = require("core.utils")

-- Save file
map("n", "<leader>w", ":w<CR>", vim.tbl_extend("force", opts, { desc = "Save file" }))

-- Quick quit (save all and exit) - reopen with `nvim` to restore session
map("n", "<leader>qq", ":wqa<CR>", vim.tbl_extend("force", opts, { desc = "Save all and quit" }))

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
map("n", "<C-h>", ":tabprevious<CR>", vim.tbl_extend("force", opts, { desc = "Previous tab" }))
map("n", "<C-l>", ":tabnext<CR>", vim.tbl_extend("force", opts, { desc = "Next tab" }))

-- Move tabs
map("n", "<S-Left>", ":-tabm<CR>", vim.tbl_extend("force", opts, { desc = "Move tab left" }))
map("n", "<S-Right>", ":+tabm<CR>", vim.tbl_extend("force", opts, { desc = "Move tab right" }))

-- Last active tab
vim.g.lasttab = 1
map("n", "<leader><Tab>", function() vim.cmd("tabn " .. vim.g.lasttab) end, vim.tbl_extend("force", opts, { desc = "Last active tab" }))
vim.api.nvim_create_autocmd("TabLeave", {
  callback = function()
    vim.g.lasttab = vim.fn.tabpagenr()
  end,
})

-- Config file shortcut
map("n", "<leader>se", ":tabe $MYVIMRC<CR>", vim.tbl_extend("force", opts, { desc = "Edit init.lua" }))

-- Quickfix window
map("n", "<leader>cv", ":vert copen 70<CR>", vim.tbl_extend("force", opts, { desc = "Open quickfix vertical" }))
map("n", "<leader>co", ":copen 15<CR>", vim.tbl_extend("force", opts, { desc = "Open quickfix horizontal" }))
map("n", "<leader>cc", ":cclose<CR>", vim.tbl_extend("force", opts, { desc = "Close quickfix" }))

-- Trim trailing whitespace
map("n", "<leader>dw", [[<cmd>let _s=@/ | %s/\s\+$//e | let @/=_s | nohl<CR>]], vim.tbl_extend("force", opts, { desc = "Delete trailing whitespace" }))

-- Move by visual line (screen line) rather than file line
map("n", "k", "gk", { noremap = true, desc = "Move up (visual line)" })
map("n", "j", "gj", { noremap = true, desc = "Move down (visual line)" })

-- Yank to system clipboard
map("v", "<leader>y", '"+y', vim.tbl_extend("force", opts, { desc = "Yank to clipboard" }))

-- Copy file path to system clipboard
map("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied absolute path" })
end, vim.tbl_extend("force", opts, { desc = "Copy absolute path" }))

map("n", "<leader>cP", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied relative path" })
end, vim.tbl_extend("force", opts, { desc = "Copy relative path" }))

-- Plugin install (lazy.nvim equivalent)
map("n", "<leader>pi", ":Lazy<CR>", vim.tbl_extend("force", opts, { desc = "Open Lazy plugin manager" }))
