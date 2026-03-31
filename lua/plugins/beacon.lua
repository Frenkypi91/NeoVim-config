-- =============================================================================
-- Beacon
-- =============================================================================
return {
  {
    "danilamihailov/beacon.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("beacon").setup({
        enabled   = true,
        min_jump  = 5,   -- trigger only on jumps ≥ 5 lines (1 is too aggressive)
        width     = 30,
        winblend  = 40,
        speed     = 1,
        fps       = 60,

        cursor_events = { "CursorMoved", "CursorMovedI" },
        window_events = { "WinEnter", "FocusGained" },

        highlight = { bg = "#63686d" },

        ignore_filetypes = {
          "help", "lazy", "mason", "qf",
          "TelescopePrompt", "Trouble",
          "neo-tree", "NvimTree",
          "dashboard", "alpha",
        },
        ignore_buftypes = { "terminal", "nofile", "prompt" },
      })

      vim.g.beacon_enabled = true
      vim.keymap.set("n", "<leader>b", function()
        local ok, beacon = pcall(require, "beacon")
        if not ok then return end
        vim.g.beacon_enabled = not vim.g.beacon_enabled
        beacon.setup({ enabled = vim.g.beacon_enabled })
      end, { desc = "Toggle Beacon" })
    end,
  },
}
