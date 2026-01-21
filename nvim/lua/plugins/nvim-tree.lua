-- nvim-tree configuration
-- Replaces NERDTree

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = {
    { "echasnovski/mini.icons", opts = {} },
  },
  config = function()
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Keymaps
    map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", opts)
    map("n", "<leader>n", "<cmd>NvimTreeFindFile<CR>", opts)
    map("n", "<leader>nr", "<cmd>NvimTreeRefresh<CR>", opts)
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = 35,
      },
      renderer = {
        group_empty = true,
        icons = {
          padding = " ",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
        highlight_git = true,
      },
      filters = {
        dotfiles = false,
        custom = { ".DS_Store" },
      },
      git = {
        enable = true,
        ignore = false,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
          },
        },
      },
    })

    -- Open tree on startup if opening a directory
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        local directory = vim.fn.isdirectory(data.file) == 1
        if directory then
          vim.cmd.cd(data.file)
          require("nvim-tree.api").tree.open()
        end
      end,
    })
  end,
}
