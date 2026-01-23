-- Session management
-- Auto-saves sessions so you can quit and restore easily

return {
  "folke/persistence.nvim",
  lazy = false,
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
  },
  config = function(_, opts)
    require("persistence").setup(opts)

    local map = vim.keymap.set
    local persistence = require("persistence")
    local utils = require("core.utils")

    -- Save nvim-tree state before normal quit (skip if restarting via <leader>rs)
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        if vim.g.nvim_restarting then
          return
        end
        utils.save_nvim_tree_state(utils.get_state_file())
      end,
    })

    -- Auto-restore session if nvim opened without file arguments
    vim.api.nvim_create_autocmd("VimEnter", {
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
          persistence.load()
          -- Reopen nvim-tree if it was open before (defer to let session load first)
          vim.defer_fn(function()
            utils.restore_nvim_tree_state(utils.get_state_file())
          end, 50)
        end
      end,
    })

    -- Handle stdin (e.g., echo "text" | nvim)
    vim.api.nvim_create_autocmd("StdinReadPre", {
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })

    -- Restore session for current directory
    map("n", "<leader>sr", function() persistence.load() end, { desc = "Restore session" })
    -- Restore last session
    map("n", "<leader>sl", function() persistence.load({ last = true }) end, { desc = "Restore last session" })
    -- Stop auto-saving session
    map("n", "<leader>sd", function() persistence.stop() end, { desc = "Don't save session" })
  end,
}
