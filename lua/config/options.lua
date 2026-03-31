-- =============================================================================
-- Options
-- =============================================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- Disable netrw (neo-tree handles file browsing)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Disable LazyVim auto-format (safeformat handles it)
vim.g.autoformat = false

vim.opt.background    = "dark"
vim.opt.termguicolors = true
vim.opt.clipboard     = "unnamedplus"

-- Line numbers
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.numberwidth    = 3
vim.opt.statuscolumn   = ""
vim.opt.cursorline     = true
vim.opt.cursorlineopt  = "line"

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Shada cleanup
vim.opt.shada:remove("'")

-- Diagnostics
vim.diagnostic.config({
  virtual_text  = false,
  underline     = true,
  severity_sort = true,
  float         = { border = "rounded" },
})
