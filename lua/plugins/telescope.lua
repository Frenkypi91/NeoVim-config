-- =============================================================================
-- Telescope
-- =============================================================================
return {
  "nvim-telescope/telescope.nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    defaults = {
      layout_strategy = "center",
      layout_config = { width = 0.8, height = 0.7 },
      border = true,
      winblend = 0,
    },
  },
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
  },
}
