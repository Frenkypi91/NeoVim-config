-- =============================================================================
-- Autocmds
-- =============================================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local utils = require("config.utils")

-- Optional behavior: always open files at top
vim.g.start_at_top = vim.g.start_at_top or true

-- ---------------------------------------------------------------------------
-- Helper functions
-- ---------------------------------------------------------------------------
local function is_normal_buffer(bufnr)
bufnr = bufnr or 0
return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == ""
end

local function set_neotree_hl()
vim.api.nvim_set_hl(0, "MyNeoTreeWhite", { fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#E5C07B", bold = true })
vim.api.nvim_set_hl(0, "NeoTreeDirectoryIconOpen", { fg = "#D7BA7D", bold = true })
vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", {})
vim.api.nvim_set_hl(0, "NeoTreeDirectoryNameOpen", {})
vim.api.nvim_set_hl(0, "NeoTreeRootName", {})
end

-- ---------------------------------------------------------------------------
-- Indentation and text width by filetype
-- ---------------------------------------------------------------------------
autocmd("FileType", {
  group = augroup("UserIndentByFiletype", { clear = true }),
        callback = function(args)
        if not utils.is_real_file(args.buf) then
          return
          end

          local ft = vim.bo[args.buf].filetype

          vim.opt_local.expandtab = true
          vim.opt_local.autoindent = true
          vim.opt_local.smartindent = true

          local two_space = {
            lua = true,
            html = true,
            css = true,
            json = true,
            yaml = true,
            toml = true,
            markdown = true,
          }

          if two_space[ft] then
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
            vim.opt_local.softtabstop = 2
            else
              vim.opt_local.tabstop = 4
              vim.opt_local.shiftwidth = 4
              vim.opt_local.softtabstop = 4
              end

              local width_cfg = {
                python = { indent = 4, cc = "89" },
                julia = { cc = "93" },
                r = { cc = "101" },
                rmd = { cc = "101" },
                quarto = { cc = "101" },
                c = { cc = "101" },
                cpp = { cc = "101" },
                fortran = { cc = "101" },
              }

              local cfg = width_cfg[ft]
              if cfg then
                if cfg.indent then
                  vim.opt_local.tabstop = cfg.indent
                  vim.opt_local.shiftwidth = cfg.indent
                  vim.opt_local.softtabstop = cfg.indent
                  end
                  if cfg.cc then
                    vim.opt_local.colorcolumn = cfg.cc
                    vim.opt_local.textwidth = tonumber(cfg.cc) - 1
                    end
                    end

                    if ft == "c" or ft == "cpp" then
                      vim.opt_local.cindent = true
                      end
                      end,
})

-- ---------------------------------------------------------------------------
-- Highlight on yank
-- ---------------------------------------------------------------------------
autocmd("TextYankPost", {
  group = augroup("UserHighlightYank", { clear = true }),
        callback = function()
        vim.highlight.on_yank({ timeout = 200 })
        end,
})

-- ---------------------------------------------------------------------------
-- Auto checktime when returning to nvim/buffer
-- ---------------------------------------------------------------------------
autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("UserAutoChecktime", { clear = true }),
        command = "checktime",
})

-- ---------------------------------------------------------------------------
-- Auto-create parent directories before save
-- ---------------------------------------------------------------------------
autocmd("BufWritePre", {
  group = augroup("UserAutoMkdir", { clear = true }),
        callback = function(args)
        if not utils.is_real_file(args.buf) then
          return
          end

          local file = vim.api.nvim_buf_get_name(args.buf)
          if file == "" then
            return
            end

            local dir = vim.fn.fnamemodify(file, ":p:h")
            if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
              pcall(vim.fn.mkdir, dir, "p")
              end
              end,
})

-- ---------------------------------------------------------------------------
-- Safe format on save
-- ---------------------------------------------------------------------------
autocmd("BufWritePost", {
  group = augroup("UserSafeFormatOnSave", { clear = true }),
        callback = function(args)
        if not utils.is_real_file(args.buf) then
          return
          end

          if vim.b[args.buf].safeformat_running then
            return
            end

            vim.b[args.buf].safeformat_running = true

            local ok, sf = pcall(require, "config.safeformat")
            local changed = false

            if ok and sf then
              changed = sf.format_file(
                vim.api.nvim_buf_get_name(args.buf),
                                       vim.bo[args.buf].filetype
              ) or false
              end

              vim.b[args.buf].safeformat_running = false

              if changed then
                pcall(vim.cmd, "checktime")
                end
                end,
})

-- ---------------------------------------------------------------------------
-- Always start at top, if enabled
-- ---------------------------------------------------------------------------
autocmd({ "BufReadPost", "BufWinEnter", "VimEnter" }, {
  group = augroup("UserStartAtTop", { clear = true }),
        callback = function(args)
        if not vim.g.start_at_top then
          return
          end

          local buf = args.buf or 0
          if buf ~= 0 and not is_normal_buffer(buf) then
            return
            end

            vim.schedule(function()
            if buf ~= 0 and not vim.api.nvim_buf_is_valid(buf) then
              return
              end

              if buf ~= 0 and vim.bo[buf].buftype ~= "" then
                return
                end

                local win = vim.api.nvim_get_current_win()
                if buf ~= 0 and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
                  pcall(vim.cmd, "normal! gg0")
                  end
                  end)
            end,
})

-- ---------------------------------------------------------------------------
-- LaTeX buffer UX
-- ---------------------------------------------------------------------------
autocmd("FileType", {
  group = augroup("UserLatexUx", { clear = true }),
        pattern = "tex",
        callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.conceallevel = 2
        vim.opt_local.textwidth = 0
        end,
})

-- ---------------------------------------------------------------------------
-- Neo-tree highlights
-- ---------------------------------------------------------------------------
autocmd({ "ColorScheme", "VimEnter" }, {
  group = augroup("UserNeoTreeHighlights", { clear = true }),
        desc = "Neo-tree highlights",
        callback = function()
        vim.schedule(set_neotree_hl)
        end,
})

set_neotree_hl()

autocmd("FileType", {
  group = augroup("UserNeoTreeWindow", { clear = true }),
        pattern = "neo-tree",
        desc = "Neo-tree window settings",
        callback = function()
        set_neotree_hl()

        vim.wo.winhighlight = table.concat({
          "Normal:MyNeoTreeWhite",
          "NeoTreeNormal:MyNeoTreeWhite",
          "NeoTreeDirectoryName:MyNeoTreeWhite",
          "NeoTreeFileName:MyNeoTreeWhite",
        }, ",")

        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        end,
})

-- ---------------------------------------------------------------------------
-- Cursorline highlight override
-- ---------------------------------------------------------------------------
autocmd({ "ColorScheme", "VimEnter" }, {
  group = augroup("UserCursorLineHighlight", { clear = true }),
        desc = "Force cursorline color",
        callback = function()
        vim.api.nvim_set_hl(0, "CursorLine", { bg = "#4a4a4a" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "#5a5a5a" })
        end,
})

-- ---------------------------------------------------------------------------
-- Terminal window cleanup
-- ---------------------------------------------------------------------------
autocmd("TermOpen", {
  group = augroup("UserTerminalWindow", { clear = true }),
        pattern = "term://*",
        callback = function(args)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.buflisted = false
        vim.wo.winbar = ""
        vim.wo.statuscolumn = ""

        vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          local job = vim.b[args.buf].terminal_job_id
          if job then
            pcall(vim.api.nvim_chan_send, job, "clear\n")
            end
            end
            end)
        end,
})
