-- =============================================================================
-- Keymaps
-- =============================================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Save / quit / reload
map("n", "<leader>w", "<cmd>w<CR>", opts)
map("n", "<leader>q", "<cmd>q<CR>", opts)
map("n", "<leader>Q", "<cmd>qa!<CR>", opts)
map("n", "<leader>r", "<cmd>source $MYVIMRC<CR>", opts)

-- Navigation
map("i", "jk", "<Esc>", opts)
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- Buffers
map("n", "<leader>bn", "<cmd>bnext<CR>", opts)
map("n", "<leader>bp", "<cmd>bprevious<CR>", opts)
map("n", "<leader>bd", "<cmd>bdelete<CR>", opts)
map("n", "<leader>bl", "<cmd>ls<CR>", opts)

-- Splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
map("n", "<leader>sh", "<cmd>split<CR>", opts)
map("n", "<leader>sc", "<cmd>close<CR>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Search
map("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)
map("v", "//", 'y/\\V<C-R>"<CR>', opts)
map("n", "<leader>s", function()
local s = vim.fn.input("Search: ")
local r = vim.fn.input("Replace with: ")
vim.cmd("%s/" .. s .. "/" .. r .. "/gc")
end, { desc = "Interactive search & replace" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<CR>==", opts)
map("n", "<A-k>", "<cmd>m .-2<CR>==", opts)
map("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv", opts)

-- Clipboard
map({ "n", "v" }, "<leader>y", '"+y', opts)
map("n", "<leader>Y", '"+Y', opts)
map("n", "<leader>p", '"+p', opts)

-- File explorer (Neo-tree)
map("n", "<leader>e", "<cmd>Neotree toggle left<CR>", opts)
map("v", "<leader>e", "<cmd><C-u>Neotree toggle left<CR>", {
  noremap = true,
  silent = true,
  desc = "Neo-tree toggle (visual-safe)",
})

-- Manual formatting shortcut
map("n", "<leader>f", function()
require("config.safeformat").format_current()
end, { noremap = true, silent = true, desc = "Format current file" })

-- Diagnostics shortcut (main LSP mappings are buffer-local in LspAttach)
map("n", "<leader>d", vim.diagnostic.open_float, opts)

-- PDF viewer (Okular)
map("n", "<leader>pdf", "<cmd>!okular %:r.pdf &<CR>", opts)

-- Telescope
map("n", "<leader>ff", function()
require("telescope.builtin").find_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
require("telescope.builtin").buffers()
end, { desc = "Buffers" })
map("n", "<leader>fr", function()
require("telescope.builtin").oldfiles()
end, { desc = "Recent files" })

-- Terminal: reusable shell in the current file directory
local ShellHere = {
  bufnr = nil,
  jobid = nil,
  winid = nil,
  cwd = nil,
}

local function set_terminal_window_options()
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "no"
vim.opt_local.foldcolumn = "0"
vim.opt_local.statuscolumn = ""
vim.opt_local.colorcolumn = ""

-- Disable visible whitespace markers inside the terminal
vim.opt_local.list = false

-- Useful visual options for terminal buffers
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
vim.opt_local.spell = false
end

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
  set_terminal_window_options()
  end,
})

local function shell_here_dir()
local file = vim.api.nvim_buf_get_name(0)

if file ~= "" then
  return vim.fn.fnamemodify(file, ":p:h")
  end

  return vim.fn.getcwd()
  end

  local function shell_buf_is_valid()
  return ShellHere.bufnr
  and vim.api.nvim_buf_is_valid(ShellHere.bufnr)
  end

  local function shell_job_is_running()
  return ShellHere.jobid
  and vim.fn.jobwait({ ShellHere.jobid }, 0)[1] == -1
  end

  local function shell_win_is_visible()
  if ShellHere.winid and vim.api.nvim_win_is_valid(ShellHere.winid) then
    return true
    end

    if shell_buf_is_valid() then
      local winid = vim.fn.bufwinid(ShellHere.bufnr)

      if winid ~= -1 then
        ShellHere.winid = winid
        return true
        end
        end

        return false
        end

        local function create_shell_buf(dir)
        ShellHere.bufnr = vim.api.nvim_create_buf(false, true)
        ShellHere.cwd = dir

        vim.api.nvim_buf_set_name(ShellHere.bufnr, "ShellHere")

        vim.api.nvim_set_option_value("bufhidden", "hide", {
          buf = ShellHere.bufnr,
        })

        vim.api.nvim_set_option_value("swapfile", false, {
          buf = ShellHere.bufnr,
        })

        ShellHere.jobid = vim.api.nvim_buf_call(ShellHere.bufnr, function()
        return vim.fn.termopen(vim.o.shell, {
          cwd = dir,

          on_exit = function()
          ShellHere.jobid = nil
          end,
        })
        end)
        end

        local function toggle_shell_here()
        local dir = shell_here_dir()

        -- If the terminal is already visible, hide only the window.
        -- The terminal buffer and shell process remain alive.
        if shell_win_is_visible() then
          pcall(vim.api.nvim_win_hide, ShellHere.winid)
          ShellHere.winid = nil
          return
          end

          -- If the buffer no longer exists or the shell process has stopped,
-- create a new terminal in the current file directory.
if not shell_buf_is_valid() or not shell_job_is_running() then
  ShellHere.bufnr = nil
  ShellHere.jobid = nil
  ShellHere.winid = nil
  ShellHere.cwd = nil

  create_shell_buf(dir)
  else
    -- Change directory only if the directory has actually changed.
    -- This prevents repeated lines such as:
    --
    -- cd '/home/francesco'
    -- cd '/home/francesco'
    -- cd '/home/francesco'
    if ShellHere.cwd ~= dir then
      vim.api.nvim_chan_send(
        ShellHere.jobid,
        "cd " .. vim.fn.shellescape(dir) .. "\n"
      )

      ShellHere.cwd = dir
      end
      end

      vim.cmd("silent! belowright split")
      vim.api.nvim_win_set_buf(0, ShellHere.bufnr)
      ShellHere.winid = vim.api.nvim_get_current_win()

      set_terminal_window_options()

      vim.cmd("startinsert")
      end

      map("n", "<F4>", toggle_shell_here, {
        noremap = true,
        silent = true,
        desc = "Toggle shell in current file directory",
      })

      map("t", "<F4>", toggle_shell_here, {
        noremap = true,
        silent = true,
        desc = "Toggle shell in current file directory",
      })

      -- Terminal mode
      map("t", "<Esc>", "<C-\\><C-n>", opts)

      -- Hide the terminal without deleting the buffer
      map("t", "<C-d>", [[<C-\><C-n><cmd>hide<CR>]], opts)

      map("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
      map("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
      map("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
      map("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)

      -- Lazy
      map("n", "<leader>l", "<cmd>Lazy<CR>", opts)
      map("n", "<leader>a", "<cmd>Lazy sync<CR>", opts)
      map("n", "<leader>u", "<cmd>Lazy update<CR>", opts)
      map("n", "<leader>c", "<cmd>Lazy clean<CR>", opts)

      -- F6: switch between windows
      map("n", "<F6>", "<C-w>w", opts)
      map("t", "<F6>", [[<C-\><C-n><C-w>w]], opts)
