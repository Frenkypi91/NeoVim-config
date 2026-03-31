-- =============================================================================
-- Markdown
-- =============================================================================
return {
  {
    "davidgranstrom/nvim-markdown-preview",
    ft = "markdown",
    config = function()
      vim.g.nvim_markdown_preview_theme = "github"
      vim.g.nvim_markdown_preview_format = "markdown"
    end
  },

  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown" },
    opts = {},
  },
}


