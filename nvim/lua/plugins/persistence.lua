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

    -- Helper to get state file path for current directory
    local function get_state_file()
      local cwd = vim.fn.getcwd()
      local name = cwd:gsub("/", "%%")
      return vim.fn.stdpath("state") .. "/sessions/" .. name .. ".state"
    end

    -- Save nvim-tree state before normal quit (skip if restarting via <leader>rs)
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        if vim.g.nvim_restarting then
          return
        end
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          local state_file = get_state_file()
          local was_open = api.tree.is_visible() and "1" or "0"
          vim.fn.writefile({ was_open }, state_file)
        end
      end,
    })

    -- Auto-restore session if nvim opened without file arguments
    vim.api.nvim_create_autocmd("VimEnter", {
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
          persistence.load()
          -- Reopen nvim-tree if it was open before
          vim.defer_fn(function()
            local state_file = get_state_file()
            if vim.fn.filereadable(state_file) == 1 then
              local lines = vim.fn.readfile(state_file)
              if lines[1] == "1" then
                local ok, api = pcall(require, "nvim-tree.api")
                if ok then
                  api.tree.open()
                end
              end
            end
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
