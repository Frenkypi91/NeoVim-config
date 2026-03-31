-- ============================================================
-- Jupyter
-- ============================================================
return {
  {
    "benlubas/molten-nvim",
    ft = { "python", "julia", "markdown", "quarto" },
    cmd = {
      "MoltenInit",
      "MoltenEvaluateLine",
      "MoltenEvaluateVisual",
      "MoltenEvaluateCell",
      "MoltenOpenOutput",
      "MoltenHideOutput",
      "MoltenRestart",
    },
    build = ":UpdateRemotePlugins",
    dependencies = {
      "3rd/image.nvim",
    },
    init = function()
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
    vim.g.molten_virt_text_output = true
    vim.g.molten_output_win_max_height = 20
    end,
    config = function()
    local map = vim.keymap.set
    local opts = { silent = true }

    map("n", "<leader>mi", ":MoltenInit<CR>", opts)
    map("n", "<leader>ml", ":MoltenEvaluateLine<CR>", opts)
    map("v", "<leader>mv", ":MoltenEvaluateVisual<CR>", opts)
    map("n", "<leader>mc", ":MoltenEvaluateCell<CR>", opts)
    map("n", "<leader>mo", ":MoltenOpenOutput<CR>", opts)
    map("n", "<leader>mh", ":MoltenHideOutput<CR>", opts)
    map("n", "<leader>mr", ":MoltenRestart<CR>", opts)
    end,
  },

  {
    "3rd/image.nvim",
    ft = { "markdown", "quarto", "python", "julia" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true },
      },
    },
  },
}
