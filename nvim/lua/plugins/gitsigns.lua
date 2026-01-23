-- Gitsigns configuration
-- Replaces vim-gitgutter

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      max_file_length = 40000,
      preview_config = {
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = vim.keymap.set
        local opts = { buffer = bufnr }

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, buffer = bufnr })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, buffer = bufnr })

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, opts)
        map("n", "<leader>hr", gs.reset_hunk, opts)
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, opts)
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, opts)
        map("n", "<leader>hS", gs.stage_buffer, opts)
        map("n", "<leader>hu", gs.undo_stage_hunk, opts)
        map("n", "<leader>hR", gs.reset_buffer, opts)
        map("n", "<leader>hp", gs.preview_hunk, opts)
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, opts)
        map("n", "<leader>tb", gs.toggle_current_line_blame, opts)
        map("n", "<leader>hd", gs.diffthis, opts)
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, opts)
        map("n", "<leader>td", gs.toggle_deleted, opts)

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", opts)
      end,
    })
  end,
}
