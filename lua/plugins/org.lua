-- =============================================================================
-- Org mode
-- =============================================================================
return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("orgmode").setup({
        org_agenda_files = { "~/org/**/*" },
        org_default_notes_file = "~/org/inbox.org",
      })
    end,
  },
}
