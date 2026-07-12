-- =============================================================================
-- Coding
-- =============================================================================
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
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
      })
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
      })

      local hover = vim.lsp.buf.hover
      vim.lsp.buf.hover = function()
        return hover({ border = "rounded", max_width = 100, max_height = 30 })
      end

      local signature_help = vim.lsp.buf.signature_help
      vim.lsp.buf.signature_help = function()
        return signature_help({ border = "rounded", max_width = 100, max_height = 30 })
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          map("n", "K", vim.lsp.buf.hover, "LSP Hover")
          map("n", "gd", vim.lsp.buf.definition, "LSP Definition")
          map("n", "gD", vim.lsp.buf.declaration, "LSP Declaration")
          map("n", "gi", vim.lsp.buf.implementation, "LSP Implementation")
          map("n", "gr", vim.lsp.buf.references, "LSP References")
          map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cf", function()
            local ok, safeformat = pcall(require, "config.safeformat")
            if ok and safeformat.format_current() then
              return
            end
            vim.lsp.buf.format({ async = true })
          end, "Format Buffer")

          if client.supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
            map("n", "<leader>uh", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
            end, "Toggle Inlay Hints")
          end
        end,
      })
    end,
    opts = function(_, opts)
      local util = require("lspconfig.util")
      opts.servers = opts.servers or {}

      opts.servers.pyright = opts.servers.pyright or {}
      opts.servers.r_language_server = opts.servers.r_language_server or {}
      opts.servers.html = opts.servers.html or {}
      opts.servers.cssls = opts.servers.cssls or {}
      opts.servers.marksman = opts.servers.marksman or {}

      opts.servers.clangd = vim.tbl_deep_extend("force", opts.servers.clangd or {}, {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
      })

      opts.servers.rust_analyzer = vim.tbl_deep_extend("force", opts.servers.rust_analyzer or {}, {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            procMacro = { enable = true },
            inlayHints = {
              parameterHints = { enable = true },
              typeHints = { enable = true },
            },
          },
        },
      })

      opts.servers.fortls = vim.tbl_deep_extend("force", opts.servers.fortls or {}, {
        settings = {
          fortls = {
            maxLineLength = 120,
            enable_code_actions = true,
            enable_autocomplete = true,
            disable_diagnostics = false,
            incremental_sync = true,
          },
        },
      })

      opts.servers.julials = vim.tbl_deep_extend("force", opts.servers.julials or {}, {
        root_dir = util.root_pattern("Project.toml", "JuliaProject.toml", ".git"),
        cmd = { "julia", "--startup-file=no", "--history-file=no" },
      })

      opts.servers.texlab = vim.tbl_deep_extend("force", opts.servers.texlab or {}, {
        settings = {
          texlab = {
            build = { onSave = true, forwardSearchAfter = false },
            chktex = { onOpenAndSave = true, onEdit = false },
          },
        },
      })

      return opts
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.experimental = opts.experimental or {}
      opts.experimental.ghost_text = true
      opts.completion = opts.completion or {}
      opts.completion.completeopt = "menu,menuone,noinsert"
      opts.window = opts.window or {}
      opts.window.completion = vim.tbl_deep_extend("force", opts.window.completion or {}, {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      })
      opts.window.documentation = vim.tbl_deep_extend("force", opts.window.documentation or {}, {
        border = "rounded",
      })
      opts.mapping = opts.mapping or {}
      opts.mapping["<CR>"] = cmp.mapping.confirm({ select = false })
      opts.mapping["<C-Space>"] = cmp.mapping.complete()
      opts.mapping["<Tab>"] = cmp.mapping.select_next_item()
      opts.mapping["<S-Tab>"] = cmp.mapping.select_prev_item()
      return opts
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "lua", "vim", "vimdoc", "bash", "python", "julia", "r", "c", "cpp", "rust", "fortran",
        "latex", "markdown", "markdown_inline", "html", "css", "json", "yaml", "toml",
      })
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.indent = opts.indent or {}
      opts.indent.enable = true
      opts.incremental_selection = opts.incremental_selection or {}
      opts.incremental_selection.enable = true
      opts.incremental_selection.keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        scope_incremental = "<S-CR>",
        node_decremental = "<BS>",
      }
      return opts
    end,
  },
}
