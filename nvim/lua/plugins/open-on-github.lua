-- GitHub line opener (no external dependencies)

-- Build GitHub URL and open in browser
local function open_github_url(mode, ref)
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  -- Get remote URL and extract owner/repo
  local remote_url = vim.fn.systemlist("git remote get-url origin")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("No origin remote found", vim.log.levels.ERROR)
    return
  end

  -- Parse GitHub URL (handles both SSH and HTTPS)
  local repo = remote_url:match("github%.com[:/](.+)$")
  if not repo then
    vim.notify("Not a GitHub repository", vim.log.levels.ERROR)
    return
  end
  repo = repo:gsub("%.git$", "")

  -- Get file path relative to git root
  local file_path = vim.fn.expand("%:p")
  local rel_path = file_path:sub(#git_root + 2) -- +2 for the trailing slash

  -- Get line numbers
  local lstart, lend
  if mode == "v" then
    lstart = vim.fn.line("'<")
    lend = vim.fn.line("'>")
  else
    lstart = vim.fn.line(".")
    lend = lstart
  end

  -- Build URL
  local url = string.format("https://github.com/%s/blob/%s/%s#L%d", repo, ref, rel_path, lstart)
  if lend ~= lstart then
    url = url .. "-L" .. lend
  end

  -- Open in browser
  vim.ui.open(url)
end

return {
  -- Virtual plugin entry for lazy.nvim keymaps (no actual plugin needed)
  dir = vim.fn.stdpath("config") .. "/lua/plugins",
  name = "open-on-github",
  keys = {
    {
      "<leader>go",
      function()
        open_github_url("n", "master")
      end,
      mode = "n",
      desc = "Open line on GitHub (master)",
    },
    {
      "<leader>go",
      function()
        open_github_url("v", "master")
      end,
      mode = "v",
      desc = "Open selection on GitHub (master)",
    },
    {
      "<leader>gO",
      function()
        -- Use current commit SHA for permalink
        local rev = vim.fn.systemlist("git rev-parse HEAD")[1]
        open_github_url("n", rev)
      end,
      mode = "n",
      desc = "Open line on GitHub (current commit)",
    },
    {
      "<leader>gO",
      function()
        local rev = vim.fn.systemlist("git rev-parse HEAD")[1]
        open_github_url("v", rev)
      end,
      mode = "v",
      desc = "Open selection on GitHub (current commit)",
    },
  },
}
