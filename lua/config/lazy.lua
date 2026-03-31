-- =============================================================================
-- Lazy bootstrap
-- =============================================================================
vim.g.lazyvim_check_order = false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "plugins" },
}, {
  defaults  = { lazy = false, version = false },
  install   = { colorscheme = { "pax", "habamax" } },
  checker   = { enabled = true, notify = false },
})
