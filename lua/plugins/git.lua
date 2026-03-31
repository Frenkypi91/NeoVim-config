-- ============================================================================
-- Git
-- ============================================================================
return {

  -- --------------------------------------------------------------------------
  -- Hunks / blame in gutter
  -- --------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs  = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        map("n", "]h",        gs.next_hunk,                      "Next hunk")
        map("n", "[h",        gs.prev_hunk,                      "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk,                    "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk,                    "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk,                  "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  -- --------------------------------------------------------------------------
  -- Git commands inside Neovim
  -- --------------------------------------------------------------------------
  { "tpope/vim-fugitive", cmd = { "Git", "G" } },

  -- --------------------------------------------------------------------------
  -- Diff UI
  -- --------------------------------------------------------------------------
  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" } },

  -- --------------------------------------------------------------------------
  -- GitHub PR / Issues / Review
  -- --------------------------------------------------------------------------
  {
    "pwntester/octo.nvim",
    cmd          = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = { suppress_missing_scope = { projects_v2 = true } },
    keys = {
      { "<leader>gpl", "<cmd>Octo pr list<CR>",    desc = "PR list" },
      { "<leader>gil", "<cmd>Octo issue list<CR>", desc = "Issue list" },
    },
  },

  -- --------------------------------------------------------------------------
  -- Auto-sync a repo (set path before use)
  -- --------------------------------------------------------------------------
  {
    "luispflamminger/git-sync.nvim",
    cmd  = { "GitSync", "GitSyncStart", "GitSyncStop" },
    opts = {
      repos = {
        {
          -- TODO: set your repo path, e.g. vim.fn.expand("~/projects/my-repo")
          path             = "",
          sync_interval    = 5,
          pull             = true,
          push             = true,
          commit_message   = "sync: {timestamp}",
        },
      },
    },
    keys = {
      { "<leader>gss", "<cmd>GitSyncStart<CR>", desc = "GitSync start" },
      { "<leader>gsx", "<cmd>GitSyncStop<CR>",  desc = "GitSync stop" },
      { "<leader>gs1", "<cmd>GitSync<CR>",      desc = "GitSync now" },
    },
  },
}
