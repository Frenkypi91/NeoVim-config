-- =============================================================================
-- Utils
-- =============================================================================
local M = {}

function M.is_real_file(bufnr)
  bufnr = bufnr or 0
  local bt = vim.bo[bufnr].buftype
  return bt == "" or bt == "acwrite"
end

function M.executable(bin)
  return vim.fn.executable(bin) == 1
end

function M.file_too_big(path, max_bytes)
  max_bytes = max_bytes or (2 * 1024 * 1024)
  local uv = vim.uv or vim.loop
  local ok, st = pcall(uv.fs_stat, path)
  return ok and st and st.size and st.size > max_bytes
end

function M.file_dir(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

function M.mtime(path)
  local uv = vim.uv or vim.loop
  local ok, st = pcall(uv.fs_stat, path)
  if not ok or not st or not st.mtime then
    return nil
  end
  local sec = st.mtime.sec or 0
  local nsec = st.mtime.nsec or 0
  return string.format("%d:%d", sec, nsec)
end

return M
