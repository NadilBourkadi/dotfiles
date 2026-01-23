-- Telescope configuration
-- Replaces ctrlp.vim, ack.vim, and vim-ripgrep

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "%.DS_Store",
        },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<Esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end,
        },
      },
    })

    telescope.load_extension("fzf")

    -- Keymaps (replacing ctrlp, ack, ripgrep)
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- File finder (replaces CtrlP)
    map("n", "<C-p>", builtin.find_files, opts)

    -- Live grep (replaces :Rg and :Ack)
    map("n", "<leader>sa", builtin.live_grep, opts)

    -- Grep word under cursor
    map("n", "<leader>sw", builtin.grep_string, opts)

    -- Buffers
    map("n", "<leader>fb", builtin.buffers, opts)

    -- Help tags
    map("n", "<leader>fh", builtin.help_tags, opts)

    -- Git files
    map("n", "<leader>gf", builtin.git_files, opts)

    -- Recent files
    map("n", "<leader>fr", builtin.oldfiles, opts)

    -- Resume last search
    map("n", "<leader>sp", builtin.resume, opts)

    -- LSP symbol search
    map("n", "<leader>fs", builtin.lsp_workspace_symbols, opts)
    map("n", "<leader>fd", builtin.lsp_document_symbols, opts)

    -- Call hierarchy
    map("n", "<leader>ci", builtin.lsp_incoming_calls, opts)
    map("n", "<leader>cr", builtin.lsp_outgoing_calls, opts)

    -- Diagnostics
    map("n", "<leader>xd", builtin.diagnostics, opts)
    map("n", "<leader>xD", function()
      builtin.diagnostics({ bufnr = 0 })
    end, opts)
  end,
}
