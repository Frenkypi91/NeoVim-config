-- =============================================================================
-- Colorscheme
-- =============================================================================
return {
  {
    "artcodespace/pax",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "dark"
      vim.cmd.colorscheme("pax")
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "pax",
    },
  },
}
