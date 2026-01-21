-- Key mappings
-- Ported from vimrc

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Save file
map("n", "<leader>w", ":w<CR>", opts)

-- Tab navigation
map("n", "<C-h>", ":tabprevious<CR>", opts)
map("n", "<C-l>", ":tabnext<CR>", opts)

-- Move tabs
map("n", "<S-Left>", ":-tabm<CR>", opts)
map("n", "<S-Right>", ":+tabm<CR>", opts)

-- Last active tab
vim.g.lasttab = 1
map("n", "<leader><Tab>", ':exe "tabn " .. vim.g.lasttab<CR>', opts)
vim.api.nvim_create_autocmd("TabLeave", {
  callback = function()
    vim.g.lasttab = vim.fn.tabpagenr()
  end,
})

-- Config file shortcuts (adjusted for Neovim)
map("n", "<leader>ss", ":source $MYVIMRC<CR>", opts)
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
