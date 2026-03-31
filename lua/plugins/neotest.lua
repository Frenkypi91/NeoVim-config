-- ============================================================
-- Neotest
-- ============================================================
return {
  {
    "nvim-neotest/neotest",
    ft = { "python", "rust" },
    keys = {
      {
        "<leader>tt",
        function()
        require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>tT",
        function()
        require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run current test file",
      },
      {
        "<leader>to",
        function()
        require("neotest").output.open({ enter = true })
        end,
        desc = "Open test output",
      },
      {
        "<leader>ts",
        function()
        require("neotest").summary.toggle()
        end,
        desc = "Toggle test summary",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
    },
    opts = function(_, opts)
    opts.adapters = opts.adapters or {}

    table.insert(opts.adapters, require("neotest-python")({
      runner = "pytest",
    }))

    table.insert(opts.adapters, require("neotest-rust")({}))

    return opts
    end,
  },
}
