-- =============================================================================
-- AI Chat
-- =============================================================================
return {
  {
    "jackMort/ChatGPT.nvim",
    cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions" },
    dependencies = {
      "MunifTanjim/nui.nvim", -- UI library
      "nvim-lua/plenary.nvim", -- Lua utilities
      "nvim-telescope/telescope.nvim", -- Telescope support
    },
    opts = {
      api_key_cmd = "echo $OPENAI_API_KEY", -- Read env key
    },
    keys = {
      { "<leader>ac", "<cmd>ChatGPT<cr>", desc = "Open AI chat" },
      { "<leader>ae", "<cmd>ChatGPTEditWithInstructions<cr>", desc = "Edit with AI" },
      { "<leader>aa", "<cmd>ChatGPTActAs<cr>", desc = "AI role mode" },
    },
  },
}
