-- =============================================================================
-- Autocmds
-- =============================================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local utils   = require("config.utils")

-- ----------------------------------------------------------------------------
-- Indent defaults by filetype
-- ----------------------------------------------------------------------------
autocmd("FileType", {
  group = augroup("IndentByFt", { clear = true }),
  callback = function(args)
    if not utils.is_real_file(args.buf) then return end
    local ft = vim.bo[args.buf].filetype

    vim.opt_local.expandtab   = true
    vim.opt_local.tabstop     = 2
    vim.opt_local.shiftwidth  = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.autoindent  = true
    vim.opt_local.smartindent = true

    local tw_cc = {
      python  = { 4, "89" },
      julia   = { nil, "93" },
      r       = { nil, "101" },
      rmd     = { nil, "101" },
      quarto  = { nil, "101" },
      c       = { nil, "101" },
      cpp     = { nil, "101" },
      fortran = { nil, "101" },
    }
    local cfg = tw_cc[ft]
    if cfg then
      if cfg[1] then
        vim.opt_local.tabstop     = cfg[1]
        vim.opt_local.shiftwidth  = cfg[1]
        vim.opt_local.softtabstop = cfg[1]
      end
      vim.opt_local.textwidth   = tonumber(cfg[2]) - 1
      vim.opt_local.colorcolumn = cfg[2]
    end
  end,
})

-- ----------------------------------------------------------------------------
-- Yank highlight
-- ----------------------------------------------------------------------------
autocmd("TextYankPost", {
  group    = augroup("HighlightYank", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- ----------------------------------------------------------------------------
-- Auto reload on focus/enter
-- ----------------------------------------------------------------------------
autocmd({ "FocusGained", "BufEnter" }, {
  group   = augroup("AutoChecktime", { clear = true }),
  command = "checktime",
})

-- ----------------------------------------------------------------------------
-- Auto mkdir on save
-- ----------------------------------------------------------------------------
autocmd("BufWritePre", {
  group = augroup("AutoMkdir", { clear = true }),
  callback = function(args)
    if not utils.is_real_file(args.buf) then return end
    local file = vim.api.nvim_buf_get_name(args.buf)
    if not file or file == "" then return end
    local dir = vim.fn.fnamemodify(file, ":p:h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      pcall(vim.fn.mkdir, dir, "p")
    end
  end,
})

-- ----------------------------------------------------------------------------
-- Safe format on save
-- ----------------------------------------------------------------------------
autocmd("BufWritePost", {
  group = augroup("SafeformatSave", { clear = true }),
  callback = function(args)
    if not utils.is_real_file(args.buf) then return end
    if vim.b[args.buf].safeformat_running then return end
    vim.b[args.buf].safeformat_running = true
    local ok, sf = pcall(require, "config.safeformat")
    local changed = ok and sf and sf.format_file(vim.api.nvim_buf_get_name(args.buf), vim.bo[args.buf].filetype) or false
    vim.b[args.buf].safeformat_running = false
    if changed then pcall(vim.cmd, "checktime") end
  end,
})

-- ----------------------------------------------------------------------------
-- Disable LSP formatting (safeformat handles it)
-- ----------------------------------------------------------------------------
autocmd("LspAttach", {
  group = augroup("DisableLspFmt", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    client.server_capabilities.documentFormattingProvider      = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

-- ----------------------------------------------------------------------------
-- Start at top of file
-- ----------------------------------------------------------------------------
autocmd({ "BufReadPost", "BufWinEnter", "VimEnter" }, {
  group = augroup("StartAtTop", { clear = true }),
  callback = function(args)
    local buf = args.buf or 0
    if buf ~= 0 and vim.bo[buf].buftype ~= "" then return end
    vim.schedule(function()
      if buf ~= 0 and not vim.api.nvim_buf_is_valid(buf) then return end
      pcall(vim.cmd, "normal! gg0")
    end)
  end,
})

-- ----------------------------------------------------------------------------
-- LaTeX tweaks
-- ----------------------------------------------------------------------------
autocmd("FileType", {
  group   = augroup("LatexUx", { clear = true }),
  pattern = "tex",
  callback = function()
    vim.opt_local.wrap         = true
    vim.opt_local.linebreak    = true
    vim.opt_local.spell        = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.textwidth    = 0
  end,
})

-- ----------------------------------------------------------------------------
-- Neo-tree: combined highlight + UI tweaks (single FileType handler)
-- ----------------------------------------------------------------------------
local function set_neotree_hl()
  vim.api.nvim_set_hl(0, "MyNeoTreeWhite", { fg = "#ffffff" })
end

local function apply_neotree_icons()
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon",     { fg = "#E5C07B", bold = true })
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryIconOpen", { fg = "#D7BA7D", bold = true })
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryName",     {})
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryNameOpen", {})
  vim.api.nvim_set_hl(0, "NeoTreeRootName",          {})
end

autocmd({ "ColorScheme", "VimEnter" }, {
  desc     = "Neo-tree highlights",
  callback = function()
    vim.schedule(function()
      apply_neotree_icons()
      set_neotree_hl()
    end)
  end,
})
apply_neotree_icons()
set_neotree_hl()

autocmd("FileType", {
  pattern  = "neo-tree",
  desc     = "Neo-tree window settings",
  callback = function()
    set_neotree_hl()
    vim.wo.winhighlight = table.concat({
      "Normal:MyNeoTreeWhite",
      "NeoTreeNormal:MyNeoTreeWhite",
      "NeoTreeDirectoryName:MyNeoTreeWhite",
      "NeoTreeFileName:MyNeoTreeWhite",
    }, ",")
    vim.opt_local.signcolumn     = "no"
    vim.opt_local.foldcolumn     = "0"
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
  end,
})

-- ----------------------------------------------------------------------------
-- Cursorline highlight (survives colorscheme changes)
-- ----------------------------------------------------------------------------
autocmd({ "ColorScheme", "VimEnter" }, {
  desc     = "Force cursorline color",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#4a4a4a" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "#5a5a5a" })
  end,
})

-- ----------------------------------------------------------------------------
-- Terminal: clean UI
-- ----------------------------------------------------------------------------
autocmd("TermOpen", {
  group   = augroup("TermNoWinbar", { clear = true }),
  pattern = "term://*",
  callback = function(args)
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn     = "no"
    vim.opt_local.foldcolumn     = "0"
    vim.opt_local.buflisted      = false
    vim.wo.winbar                = ""
    vim.wo.statuscolumn          = ""
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        local job = vim.b[args.buf].terminal_job_id
        if job then vim.api.nvim_chan_send(job, "clear\n") end
      end
    end)
  end,
})
