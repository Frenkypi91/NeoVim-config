-- =============================================================================
-- Writing  (pandoc + auto-pandoc + markdown + org + latex)
-- Absorbed: pandoc.lua · auto-pandoc.lua · latex.lua · org.lua · markdown-preview.lua
-- =============================================================================
return {

  -- --------------------------------------------------------------------------
  -- Pandoc integration
  -- --------------------------------------------------------------------------
  {
    "vim-pandoc/vim-pandoc",
    ft           = { "markdown", "pandoc", "markdown.mdx" },
    dependencies = {},
    init = function()
      vim.g["pandoc#filetypes#handled"]  = { "markdown", "pandoc" }
      vim.g["pandoc#syntax#conceal#use"] = 0
      vim.g["pandoc#biblio#sources"]     = "g"
      vim.g["pandoc#biblio#bibs"]        = { vim.fn.expand("~/.pandoc/default.bib") }
    end,
    config = function()
      local defaults = vim.fn.expand("~/.pandoc/defaults.yaml")
      local function run(cmd) vim.cmd("silent ! " .. cmd); vim.cmd("redraw!") end
      local function fmt(tgt, extra)
        return string.format(
          "pandoc --defaults=%s%s %s -o %s",
          vim.fn.shellescape(defaults),
          extra or "",
          vim.fn.shellescape(vim.fn.expand("%:p")),
          vim.fn.shellescape(vim.fn.expand("%:p:r") .. tgt)
        )
      end

      vim.api.nvim_create_user_command("PandocPDF",  function() run(fmt(".pdf"))          end, {})
      vim.api.nvim_create_user_command("PandocOrg",  function() run(fmt(".org",  " -t org"))  end, {})
      vim.api.nvim_create_user_command("PandocHTML", function() run(fmt(".html", " -t html")) end, {})

      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "markdown", "pandoc", "markdown.mdx" },
        callback = function()
          vim.opt_local.conceallevel = 0
          vim.opt_local.spell        = false
        end,
      })

      local map = vim.keymap.set
      map("n", "<leader>mp", "<cmd>PandocPDF<CR>",  { desc = "Pandoc → PDF" })
      map("n", "<leader>mo", "<cmd>PandocOrg<CR>",  { desc = "Pandoc → Org" })
      map("n", "<leader>mh", "<cmd>PandocHTML<CR>", { desc = "Pandoc → HTML" })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Auto-pandoc (run pandoc via "go" in markdown)
  -- --------------------------------------------------------------------------
  {
    "jghauser/auto-pandoc.nvim",
    ft = { "markdown", "pandoc", "markdown.mdx" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "markdown", "pandoc", "markdown.mdx" },
        callback = function()
          vim.keymap.set("n", "go", function()
            local ok, ap = pcall(require, "auto-pandoc")
            if ok then ap.run_pandoc() end
          end, { silent = true, buffer = true, desc = "Auto-Pandoc: run" })
        end,
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Markdown render / preview
  -- --------------------------------------------------------------------------
  {
    "OXY2DEV/markview.nvim",
    ft   = { "markdown", "pandoc", "markdown.mdx" },
    opts = {},
  },
  {
    "davidgranstrom/nvim-markdown-preview",
    ft     = { "markdown", "pandoc", "markdown.mdx" },
    config = function()
      vim.g.nvim_markdown_preview_theme  = "github"
      vim.g.nvim_markdown_preview_format = "markdown"
    end,
  },

  -- --------------------------------------------------------------------------
  -- Org mode
  -- --------------------------------------------------------------------------
  {
    "nvim-orgmode/orgmode",
    ft           = { "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("orgmode").setup({
        org_agenda_files       = { "~/org/**/*" },
        org_default_notes_file = "~/org/inbox.org",
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- LaTeX (vimtex + okular)
  -- --------------------------------------------------------------------------
  {
    "lervag/vimtex",
    ft   = { "tex" },
    init = function()
      vim.g.vimtex_view_method          = "general"
      vim.g.vimtex_view_general_viewer  = "okular"
      vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
      vim.g.vimtex_view_automatic       = 1

      vim.g.vimtex_compiler_method  = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir  = "",
        callback   = 1,
        continuous = 1,
        executable = "latexmk",
        options    = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
      }

      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_complete_enabled         = 1
    end,
  },
}
