-- nvim-tree configuration
-- Replaces NERDTree

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  -- mini.icons is configured in plugins/init.lua (it mocks nvim-web-devicons,
  -- which is what nvim-tree asks for). Naming it here only orders the load.
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Keymaps
    map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", vim.tbl_extend("force", opts, { desc = "Toggle file tree" }))
    map("n", "<leader>n", "<cmd>NvimTreeFindFile<CR>", vim.tbl_extend("force", opts, { desc = "Find file in tree" }))
    map("n", "<leader>nr", "<cmd>NvimTreeRefresh<CR>", vim.tbl_extend("force", opts, { desc = "Refresh file tree" }))
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = {
          min = 20,
          max = 40,
        },
        adaptive_size = true,
      },
      renderer = {
        group_empty = true,
        icons = {
          padding = " ",
          -- Both default to Plane-15 glyphs -- see core/icons.lua.
          glyphs = {
            hidden = "\u{EAE7}", -- cod-eye_closed
            bookmark = "\u{F02E}", -- fa-bookmark
          },
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
