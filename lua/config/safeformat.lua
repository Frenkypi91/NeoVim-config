-- =============================================================================
-- Safeformat
-- =============================================================================
local M     = {}
local utils = require("config.utils")

local function run(cmd)
  if vim.fn.executable(cmd[1]) ~= 1 then return false end
  if vim.system then
    vim.system(cmd, { text = true }):wait()
  else
    pcall(vim.fn.system, cmd)
  end
  return true
end

local function mtime(path)
  local uv = vim.uv or vim.loop
  local ok, st = pcall(uv.fs_stat, path)
  if not ok or not st then return nil end
  return st.mtime and st.mtime.sec or nil
end

function M.format_file(file, ft)
  if not file or file == "" then return false end
  if utils.file_too_big(file) then return false end

  local before = mtime(file)

  if ft == "python" then
    if vim.fn.executable("ruff") == 1 then
      run({ "ruff", "format", file })
      run({ "ruff", "check", "--fix", "--select", "I", file })
    end
  elseif ft == "lua" then
    run({ "stylua", file })
  elseif ft == "c" or ft == "cpp" then
    run({ "clang-format", "-i", file })
  elseif ft == "rust" then
    run({ "rustfmt", file })
  elseif ft == "julia" then
    if vim.fn.executable("julia") == 1 then
      run({
        "julia", "--startup-file=no", "--history-file=no", "-e",
        [[try; using JuliaFormatter; format_file(ARGS[1]; indent=2); catch; end]],
        file,
      })
    end
  elseif ft == "fortran" then
    run({ "fprettify", "-w", file })
  elseif ft == "tex" then
    run({ "latexindent", "-w", file })
  elseif ft == "r" or ft == "rmd" or ft == "quarto" then
    if vim.fn.executable("Rscript") == 1 then
      run({
        "Rscript", "-e",
        "try({ if (requireNamespace('styler', quietly=TRUE)) styler::style_file(commandArgs(trailingOnly=TRUE)[1]) }, silent=TRUE)",
        file,
      })
    end
  else
    return false
  end

  local after = mtime(file)
  return before ~= nil and after ~= nil and after ~= before
end

function M.format_current()
  if not utils.is_real_file(0) then return false end
  return M.format_file(vim.api.nvim_buf_get_name(0), vim.bo.filetype)
end

return M
