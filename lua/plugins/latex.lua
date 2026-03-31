-- =============================================================================
-- LaTeX
-- =============================================================================
return {
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      -- Use okular for pdf
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "okular"
      -- This enables forward-search
      vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"

      -- Open/refresh the pdf viewer
      vim.g.vimtex_view_automatic = 1

      -- Enable latexmk
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }

      -- Quickfix behavior
      vim.g.vimtex_quickfix_open_on_warning = 0  -- Open only on errors

      -- Improve lsp-ish diagnostics via
      vim.g.vimtex_complete_enabled = 1
    end,
  },
}
