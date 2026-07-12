-- =============================================================================
-- Safeformat
-- =============================================================================
local M = {}
local utils = require("config.utils")

local function run(cmd)
  if not cmd or not cmd[1] or vim.fn.executable(cmd[1]) ~= 1 then
    return false
  end

  if vim.system then
    local ok, obj = pcall(vim.system, cmd, { text = true })
    if not ok or not obj then
      return false
    end
    local result = obj:wait()
    return result and result.code == 0
  end

  local ok = pcall(vim.fn.system, cmd)
  return ok
end

function M.format_file(file, ft)
  if not file or file == "" then
    return false
  end
  if utils.file_too_big(file) then
    return false
  end

  local before = utils.mtime(file)
  local changed = false

  if ft == "python" then
    if utils.executable("ruff") then
      changed = run({ "ruff", "check", "--fix", "--select", "I", file }) or changed
      changed = run({ "ruff", "format", file }) or changed
    elseif utils.executable("black") then
      changed = run({ "black", file }) or changed
    end

  elseif ft == "lua" then
    changed = run({ "stylua", file }) or changed

  elseif ft == "c" or ft == "cpp" then
    changed = run({ "clang-format", "-i", file }) or changed

  elseif ft == "rust" then
    changed = run({ "rustfmt", file }) or changed

  elseif ft == "julia" then
    if utils.executable("julia") then
      changed = run({
        "julia",
        "--startup-file=no",
        "--history-file=no",
        "-e",
        [[
          try
            using JuliaFormatter
            format_file(ARGS[1]; indent = 2)
          catch
          end
        ]],
        file,
      }) or changed
    end

  elseif ft == "fortran" then
    changed = run({ "fprettify", "-w", file }) or changed

  elseif ft == "tex" then
    changed = run({ "latexindent", "-w", file }) or changed

  elseif ft == "r" or ft == "rmd" or ft == "quarto" then
    if utils.executable("Rscript") then
      changed = run({
        "Rscript",
        "-e",
        "try({ if (requireNamespace('styler', quietly = TRUE)) styler::style_file(commandArgs(trailingOnly=TRUE)[1]) }, silent=TRUE)",
        file,
      }) or changed
    end
  end

  local after = utils.mtime(file)
  return changed and before ~= nil and after ~= nil and before ~= after
end

function M.format_current()
  if not utils.is_real_file(0) then
    return false
  end

  local file = vim.api.nvim_buf_get_name(0)
  local ft = vim.bo.filetype
  if file == "" then
    return false
  end

  if vim.bo.modified then
    vim.cmd("silent noautocmd write")
  end

  local ok = M.format_file(file, ft)
  if ok then
    vim.cmd("checktime")
    vim.cmd("edit")
  end
  return ok
end

return M
