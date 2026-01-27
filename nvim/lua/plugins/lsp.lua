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

      -- Cache: project root -> poetry venv path (false = no poetry)
      local poetry_venv_cache = {}

      -- Async detect Poetry venv for a project, then call callback(venv_path_or_nil)
      local function get_poetry_venv_async(root_dir, callback)
        -- Cache hit
        if poetry_venv_cache[root_dir] ~= nil then
          local cached = poetry_venv_cache[root_dir]
          callback(cached ~= false and cached or nil)
          return
        end

        local pyproject = root_dir .. "/pyproject.toml"
        if vim.fn.filereadable(pyproject) == 0 then
          poetry_venv_cache[root_dir] = false
          callback(nil)
          return
        end

        local content = table.concat(vim.fn.readfile(pyproject), "\n")
        if not content:match("%[tool%.poetry%]") then
          poetry_venv_cache[root_dir] = false
          callback(nil)
          return
        end

        -- Async lookup
        vim.system(
          { "poetry", "env", "info", "--path" },
          { cwd = root_dir, text = true },
          function(result)
            vim.schedule(function()
              if result.code == 0 and result.stdout and result.stdout ~= "" then
                local venv_path = vim.trim(result.stdout)
                poetry_venv_cache[root_dir] = venv_path
                callback(venv_path)
              else
                poetry_venv_cache[root_dir] = false
                callback(nil)
              end
            end)
          end
        )
      end

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
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git", ".python-version" },
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git", ".python-version" }
          local root = vim.fs.root(bufnr, markers) or vim.fn.fnamemodify(fname, ":h")
          on_dir(root)
        end,
        on_init = function(client)
          -- Auto-detect Poetry venv and configure pyright (async)
          get_poetry_venv_async(client.root_dir, function(venv_path)
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
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          javascript = { "prettier" },
          json = { "prettier" },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>pp", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end)
    end,
  },
}
