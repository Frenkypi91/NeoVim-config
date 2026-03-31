-- =============================================================================
-- Treesitter
-- =============================================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      -- Keep this list aligned
      vim.list_extend(opts.ensure_installed, {
        -- Core
        "lua",
        "vim",
        "vimdoc",
        "bash",

        -- Your stack
        "python",
        "julia",
        "r",
        "c",
        "cpp",
        "rust",
        "fortran",

        -- Docs / writing
        "latex",
        "markdown",
        "markdown_inline",

        -- Web
        "html",
        "css",
        "json",
        "yaml",
        "toml",
      })

      return opts
    end,
  },
}
