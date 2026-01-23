-- Shared utility functions

local M = {}

--- Get the session state file path for the current working directory
--- Used by persistence.lua and keymaps.lua for nvim-tree state
---@param cwd? string Working directory (defaults to current)
---@return string path Full path to the state file
function M.get_state_file(cwd)
  cwd = cwd or vim.fn.getcwd()
  local name = cwd:gsub("/", "%%")
  return vim.fn.stdpath("state") .. "/sessions/" .. name .. ".state"
end

--- Save nvim-tree open/closed state to file
---@param state_file string Path to state file
---@return boolean was_open Whether nvim-tree was open
function M.save_nvim_tree_state(state_file)
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    return false
  end
  local was_open = api.tree.is_visible()
  vim.fn.writefile({ was_open and "1" or "0" }, state_file)
  if was_open then
    api.tree.close()
  end
  return was_open
end

--- Restore nvim-tree state from file
---@param state_file string Path to state file
function M.restore_nvim_tree_state(state_file)
  if vim.fn.filereadable(state_file) ~= 1 then
    return
  end
  local lines = vim.fn.readfile(state_file)
  if lines[1] == "1" then
    local ok, api = pcall(require, "nvim-tree.api")
    if ok then
      api.tree.open()
    end
  end
end

return M
