-- =============================================================================
-- Run-repl
-- =============================================================================
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      direction = "horizontal",
      size = 12,
      close_on_exit = false,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      local Terminal = require("toggleterm.terminal").Terminal


-- -----------------------------------------------------------------------------
-- Small utilities
-- -----------------------------------------------------------------------------
      local function shellescape(path)
      return vim.fn.shellescape(path)
    end

    local function ensure_written()
    if vim.bo.modified then
      vim.cmd("write")
    end
  end

  local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function has(bin)
return vim.fn.executable(bin) == 1
end

local function find_up(name)
return vim.fn.findfile(name, ".;")
end

local function dirname(p)
return vim.fn.fnamemodify(p, ":h")
end


-- -----------------------------------------------------------------------------
-- Runner terminal
-- -----------------------------------------------------------------------------
local runner = Terminal:new({
  cmd = "bash",
  hidden = true,
  direction = "horizontal",
  close_on_exit = false,
})

local function runner_toggle()
runner:toggle(12)
end

local function runner_exec(cmd)
runner_toggle()
runner:send(cmd, true)
end


-- -----------------------------------------------------------------------------
-- Universal run/build
-- -----------------------------------------------------------------------------
local function run_current_file(mode)
mode = mode or "run"  -- "run" | "debug"
local ft = vim.bo.filetype
local file = vim.fn.expand("%:p")

if file == "" then
  notify("No file path for current buffer.", vim.log.levels.WARN)
  return
end

ensure_written()

local f = shellescape(file)
local cmd = nil

local is_debug = (mode == "debug")

-- Helpers
local function mk_out(name)
return shellescape("/tmp/" .. name)
end

local function in_file_dir(prefix)
local dir = dirname(file)
return "cd " .. shellescape(dir) .. " && " .. prefix
end

-- Latex
if ft == "tex" then
  if has("latexmk") then
    local flags = "-pdf -synctex=1"
    if is_debug then
      flags = flags .. " -interaction=errorstopmode"
    else
      flags = flags .. " -interaction=nonstopmode"
    end
    cmd = in_file_dir("latexmk " .. flags .. " " .. f)
  else
    notify("latexmk not found. Install it (e.g., TeX Live) or use VimTeX.", vim.log.levels.WARN)
    return
  end

  -- Interpreted languages
elseif ft == "python" then
  if is_debug then
    -- Pdb-style debug run
    cmd = "python3 -u -m pdb " .. f
  else
    cmd = "python3 -u " .. f
  end
elseif ft == "julia" then
  if is_debug then
    cmd = "julia --project=@. --check-bounds=yes -g2 " .. f
  else
    cmd = "julia --project=@. " .. f
  end
elseif ft == "r" then
  if is_debug then
    cmd = "R --vanilla -q -f " .. f
  else
    cmd = "Rscript --vanilla " .. f
  end
elseif ft == "rmd" then
  if has("Rscript") then
    cmd = "Rscript --vanilla -e "
    .. shellescape("rmarkdown::render('" .. file .. "')")
  end
elseif ft == "quarto" then
  if has("quarto") then
    cmd = in_file_dir("quarto render " .. f)
  end
elseif ft == "lua" then
  cmd = "lua " .. f
elseif ft == "sh" then
  cmd = "bash " .. f
elseif ft == "zsh" then
  cmd = "zsh " .. f

  -- C / c++
elseif ft == "c" then
  local out = mk_out("nvim_run_c.out")
  if is_debug then
    cmd = "cc " .. f .. " -O0 -g -Wall -Wextra -fsanitize=address,undefined -fno-omit-frame-pointer -o " .. out .. " && " .. out
  else
    cmd = "cc " .. f .. " -O2 -Wall -Wextra -o " .. out .. " && " .. out
  end
elseif ft == "cpp" then
  local out = mk_out("nvim_run_cpp.out")
  if is_debug then
    cmd = "c++ " .. f .. " -O0 -g -Wall -Wextra -std=c++20 -fsanitize=address,undefined -fno-omit-frame-pointer -o " .. out .. " && " .. out
  else
    cmd = "c++ " .. f .. " -O2 -Wall -Wextra -std=c++20 -o " .. out .. " && " .. out
  end

  -- Fortran
elseif ft == "fortran" then
  local fpm = find_up("fpm.toml")
  if fpm ~= "" and has("fpm") then
    if is_debug then
      cmd = "fpm run --profile debug"
    else
      cmd = "fpm run"
    end
  else
    local out = mk_out("nvim_run_fortran.out")
    if is_debug then
      cmd = "gfortran " .. f .. " -O0 -g -Wall -Wextra -std=f2008 -fcheck=all -fbacktrace -o " .. out .. " && " .. out
    else
      cmd = "gfortran " .. f .. " -O2 -Wall -Wextra -std=f2008 -o " .. out .. " && " .. out
    end
  end

  -- Rust
elseif ft == "rust" then
  local cargo = find_up("Cargo.toml")
  if cargo ~= "" and has("cargo") then
    if is_debug then
      cmd = "cargo run"
    else
      cmd = "cargo run --release"
    end
  else
    local out = mk_out("nvim_run_rust.out")
    if is_debug then
      cmd = "rustc " .. f .. " -g -C debuginfo=2 -o " .. out .. " && " .. out
    else
      cmd = "rustc " .. f .. " -O -o " .. out .. " && " .. out
    end
  end

  -- Web-ish / docs
elseif ft == "html" or ft == "css" then
  -- Start a simple local
  if has("python3") then
    cmd = in_file_dir("python3 -m http.server 8000")
    notify("HTTP server running on http://127.0.0.1:8000 (Ctrl-C to stop)")
  else
    notify("python3 not found: cannot start http.server.", vim.log.levels.WARN)
    return
  end
elseif ft == "markdown" then
  if has("glow") then
    cmd = "glow -p " .. f
  elseif has("pandoc") then
    local out = mk_out("nvim_md_preview.html")
    cmd = "pandoc " .. f .. " -s -o " .. out .. " && echo 'Written: '" .. out
  else
    notify("Install glow (recommended) or pandoc for a quick Markdown preview.", vim.log.levels.WARN)
    return
  end
end

if not cmd then
  notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
  return
end

runner_exec(cmd)
end

vim.keymap.set("n", "<localleader>ll", function()
run_current_file("run")
end, {
  noremap = true,
  silent = true,
  desc = "Run/build current file (by filetype)",
})

vim.keymap.set("n", "<localleader>lL", function()
run_current_file("debug")
end, {
  noremap = true,
  silent = true,
  desc = "Debug build/run current file (by filetype)",
})


-- -----------------------------------------------------------------------------
-- Julia repl
-- -----------------------------------------------------------------------------
local julia = Terminal:new({
  cmd = "julia --project=@. --color=yes",
  hidden = true,
  direction = "horizontal",
  close_on_exit = false,
})

local function julia_toggle()
julia:toggle(12)
end

local function julia_send(text)
julia_toggle()
julia:send(text, true)
end

vim.keymap.set("n", "<localleader>jr", julia_toggle, {
  noremap = true,
  silent = true,
  desc = "Toggle Julia REPL",
})

vim.keymap.set("n", "<localleader>jl", function()
julia_send(vim.api.nvim_get_current_line())
end, {
  noremap = true,
  silent = true,
  desc = "Send current line to Julia",
})

vim.keymap.set("v", "<localleader>js", function()
local srow = vim.fn.getpos("'<")[2]
local erow = vim.fn.getpos("'>")[2]
local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
julia_send(table.concat(lines, "\n"))
end, {
  noremap = true,
  silent = true,
  desc = "Send visual selection to Julia",
})
end,
},
}
