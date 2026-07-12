-- =============================================================================
-- Options
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw (neo-tree handles file browsing)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable LazyVim auto-format (safeformat handles it)
vim.g.autoformat = false

vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 3
vim.opt.statuscolumn = ""
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Indentation defaults
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- General UX
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 6
vim.opt.undofile = true
vim.opt.confirm = true
vim.opt.wrap = false

-- Shada cleanup
vim.opt.shada:remove("'")
