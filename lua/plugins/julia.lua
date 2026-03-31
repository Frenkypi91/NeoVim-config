-- =============================================================================
-- Julia
-- =============================================================================
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")
      opts.servers = opts.servers or {}

      opts.servers.julials = {
        root_dir = util.root_pattern("Project.toml", "JuliaProject.toml", ".git"),
        -- Keep the default command
        cmd = { "julia", "--startup-file=no", "--history-file=no" },
        }

        return opts
      end,
    },
  }
