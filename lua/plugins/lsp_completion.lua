-- =============================================================================
-- Lsp Completion
-- =============================================================================
return {

  -- --------------------------------------------------------------------------
  -- Completion: ghost text
  -- --------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.experimental             = opts.experimental or {}
      opts.experimental.ghost_text  = true
      return opts
    end,
  },

  -- --------------------------------------------------------------------------
  -- Mason: ensure LSP servers are installed
  -- --------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {
        "pyright",
        "r-languageserver",
        "clangd",
        "rust-analyzer",
        "fortls",
        "texlab",
        "html-lsp",
        "css-lsp",
        "marksman",
        "markdownlint",
      }
      return opts
    end,
  },

  -- --------------------------------------------------------------------------
  -- nvim-lspconfig: server-specific settings
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util    = require("lspconfig.util")
      opts.servers  = opts.servers or {}

      -- Fortran
      opts.servers.fortls          = opts.servers.fortls or {}
      opts.servers.fortls.settings = vim.tbl_deep_extend("force",
        opts.servers.fortls.settings or {}, {
          fortls = {
            maxLineLength        = 120,
            enable_code_actions  = true,
            enable_autocomplete  = true,
            disable_diagnostics  = false,
            incremental_sync     = true,
          },
        })

      -- Julia
      opts.servers.julials          = opts.servers.julials or {}
      opts.servers.julials.root_dir = util.root_pattern("Project.toml", "JuliaProject.toml", ".git")
      opts.servers.julials.cmd      = { "julia", "--startup-file=no", "--history-file=no" }

      return opts
    end,
  },
}
