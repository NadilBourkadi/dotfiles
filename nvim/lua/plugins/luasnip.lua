-- Snippet engine and custom snippets

return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Custom Python snippets
    ls.add_snippets("python", {
      -- Google-style docstring
      s("docg", {
        t({ '"""', "" }),
        i(1, "Short description."),
        t({ "", "", "Args:" }),
        t({ "", "    " }),
        i(2, "arg"),
        t(": "),
        i(3, "description"),
        t({ "", "", "Returns:" }),
        t({ "", "    " }),
        i(4, "description"),
        t({ "", '"""' }),
      }),

      -- pytest test function with AAA comments
      s("testfn", {
        t("def test_"),
        i(1, "name"),
        t("("),
        i(2),
        t({ "):", "    # Arrange", "    " }),
        i(3),
        t({ "", "    # Act", "    " }),
        i(4),
        t({ "", "    # Assert", "    assert " }),
        i(5),
        t({ "", "" }),
      }),

      -- FastAPI route pattern
      s("faroute", {
        t("@router."),
        i(1, "get"),
        t('("'),
        i(2, "/path"),
        t({ '")', "" }),
        t("async def "),
        i(3, "handler"),
        t("("),
        i(4),
        t({ ") -> ", "" }),
        i(5, "Response"),
        t({ ":", "    " }),
        i(6, "pass"),
        t({ "", "" }),
      }),

      -- pytest fixture
      s("fixture", {
        t("@pytest.fixture"),
        i(1),
        t({ "", "def " }),
        i(2, "fixture_name"),
        t("("),
        i(3),
        t({ "):", "    " }),
        i(4, "pass"),
        t({ "", "" }),
      }),
    })

    -- Snippet navigation keymaps
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, { silent = true })
  end,
}
