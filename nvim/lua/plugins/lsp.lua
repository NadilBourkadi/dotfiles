-- LSP configuration using Neovim 0.11+ native API

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()

      -- Add Mason bin to PATH so native LSP can find installed servers
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if not string.find(vim.env.PATH, mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
      end

      -- Auto-install LSP servers on startup (only refresh registry if something is missing)
      local ensure_installed = { "lua-language-server", "pyright", "stylua", "black", "prettier", "debugpy", "mypy", "flake8" }
      local registry = require("mason-registry")

      local function install_missing()
        for _, name in ipairs(ensure_installed) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end

      -- Check if any packages are missing before doing a network refresh
      local needs_refresh = false
      for _, name in ipairs(ensure_installed) do
        local ok, pkg = pcall(registry.get_package, name)
        if not ok or not pkg:is_installed() then
          needs_refresh = true
          break
        end
      end

      if needs_refresh then
        registry.refresh(install_missing)
      end

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        float = { border = "rounded" },
      })

      -- Auto-show full diagnostic on cursor hold
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
        end,
      })

      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = vim.keymap.set
          local opts = { noremap = true, silent = true, buffer = args.buf }

          map("n", "gd", vim.lsp.buf.definition, opts)
          map("n", "gD", vim.lsp.buf.declaration, opts)
          map("n", "gi", vim.lsp.buf.implementation, opts)
          map("n", "gr", vim.lsp.buf.references, opts)
          map("n", "K", vim.lsp.buf.hover, opts)
          map("n", "<leader>rn", vim.lsp.buf.rename, opts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          map("n", "<leader>ll", vim.diagnostic.open_float, opts)
          map("n", "[d", vim.diagnostic.goto_prev, opts)
          map("n", "]d", vim.diagnostic.goto_next, opts)

          -- Toggle inlay hints
          map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, opts)
        end,
      })

      local utils = require("core.utils")

      -- Configure LSP servers (Neovim 0.11+ native)
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git", ".python-version" }
          local root = vim.fs.root(bufnr, markers) or vim.fn.fnamemodify(fname, ":h")
          on_dir(root)
        end,
        on_init = function(client)
          -- Auto-detect Poetry venv and configure pyright (async)
          utils.get_poetry_venv(client.root_dir, function(venv_path)
            if venv_path then
              client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
                python = {
                  pythonPath = venv_path .. "/bin/python",
                },
              })
              client.notify("workspace/didChangeConfiguration", { settings = client.settings })
            end
          end)
        end,
      })

      -- Enable LSP servers
      vim.lsp.enable({ "lua_ls", "pyright" })
    end,
  },
}
