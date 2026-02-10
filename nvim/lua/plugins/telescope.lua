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
    map("n", "<C-p>", builtin.find_files, vim.tbl_extend("force", opts, { desc = "Find files" }))

    -- Live grep (replaces :Rg and :Ack)
    map("n", "<leader>sa", builtin.live_grep, vim.tbl_extend("force", opts, { desc = "Live grep" }))

    -- Grep word under cursor
    map("n", "<leader>sw", builtin.grep_string, vim.tbl_extend("force", opts, { desc = "Grep word under cursor" }))

    -- Buffers
    map("n", "<leader>fb", builtin.buffers, vim.tbl_extend("force", opts, { desc = "Find buffers" }))

    -- Help tags
    map("n", "<leader>fh", builtin.help_tags, vim.tbl_extend("force", opts, { desc = "Find help tags" }))

    -- Git files
    map("n", "<leader>gf", builtin.git_files, vim.tbl_extend("force", opts, { desc = "Find git files" }))

    -- Recent files
    map("n", "<leader>fr", builtin.oldfiles, vim.tbl_extend("force", opts, { desc = "Find recent files" }))

    -- Resume last search
    map("n", "<leader>sp", builtin.resume, vim.tbl_extend("force", opts, { desc = "Resume last search" }))

    -- LSP symbol search
    map("n", "<leader>fs", builtin.lsp_workspace_symbols, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
    map("n", "<leader>fd", builtin.lsp_document_symbols, vim.tbl_extend("force", opts, { desc = "Document symbols" }))

    -- Call hierarchy
    map("n", "<leader>ci", builtin.lsp_incoming_calls, vim.tbl_extend("force", opts, { desc = "Incoming calls" }))
    map("n", "<leader>cr", builtin.lsp_outgoing_calls, vim.tbl_extend("force", opts, { desc = "Outgoing calls" }))

    -- Diagnostics
    map("n", "<leader>xd", builtin.diagnostics, vim.tbl_extend("force", opts, { desc = "All diagnostics" }))
    map("n", "<leader>xD", function()
      builtin.diagnostics({ bufnr = 0 })
    end, vim.tbl_extend("force", opts, { desc = "Buffer diagnostics" }))
  end,
}
