-- =============================================================================
-- Utils
-- =============================================================================
local M = {}

function M.is_real_file(bufnr)
  bufnr = bufnr or 0
  local bt = vim.bo[bufnr].buftype
  return bt == "" or bt == "acwrite"
end

function M.file_too_big(path)
  local uv = vim.uv or vim.loop
  local ok, st = pcall(uv.fs_stat, path)
  return ok and st and st.size and st.size > 1080 * 1920
end

return M
