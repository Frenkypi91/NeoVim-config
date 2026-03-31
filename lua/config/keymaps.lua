-- =============================================================================
-- Keymaps  (merged from keymaps.lua + keybindings.lua — keybindings.lua removed)
-- =============================================================================
local map  = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ----------------------------------------------------------------------------
-- Save / quit / reload
-- ----------------------------------------------------------------------------
map("n", "<leader>w", "<cmd>w<CR>",              opts)
map("n", "<leader>q", "<cmd>q<CR>",              opts)
map("n", "<leader>Q", "<cmd>qa!<CR>",            opts)
map("n", "<leader>r", "<cmd>source $MYVIMRC<CR>", opts)

-- ----------------------------------------------------------------------------
-- Navigation
-- ----------------------------------------------------------------------------
map("i", "jk", "<Esc>", opts)
map("n", "j",  "gj",    opts)   -- wrapped-line movement
map("n", "k",  "gk",    opts)

-- Centered scroll / search
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n",     "nzzzv",   opts)
map("n", "N",     "Nzzzv",   opts)

-- ----------------------------------------------------------------------------
-- Buffers
-- ----------------------------------------------------------------------------
map("n", "<leader>bn", "<cmd>bnext<CR>",     opts)
map("n", "<leader>bp", "<cmd>bprevious<CR>", opts)
map("n", "<leader>bd", "<cmd>bdelete<CR>",   opts)
map("n", "<leader>bl", "<cmd>ls<CR>",        opts)

-- ----------------------------------------------------------------------------
-- Splits
-- ----------------------------------------------------------------------------
map("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
map("n", "<leader>sh", "<cmd>split<CR>",  opts)
map("n", "<leader>sc", "<cmd>close<CR>",  opts)

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- ----------------------------------------------------------------------------
-- Search
-- ----------------------------------------------------------------------------
map("n", "<leader>h",  "<cmd>nohlsearch<CR>", opts)
map("v", "//",         'y/\\V<C-R>"<CR>',     opts)   -- search selected text

-- Interactive search & replace
map("n", "<leader>s", function()
  local s = vim.fn.input("Search: ")
  local r = vim.fn.input("Replace with: ")
  vim.cmd("%s/" .. s .. "/" .. r .. "/gc")
end, { desc = "Interactive search & replace" })

-- ----------------------------------------------------------------------------
-- Move lines
-- ----------------------------------------------------------------------------
map("n", "<A-j>", "<cmd>m .+1<CR>==",   opts)
map("n", "<A-k>", "<cmd>m .-2<CR>==",   opts)
map("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv", opts)

-- ----------------------------------------------------------------------------
-- Clipboard
-- ----------------------------------------------------------------------------
map({ "n", "v" }, "<leader>y", '"+y', opts)
map("n",          "<leader>Y", '"+Y', opts)
map("n",          "<leader>p", '"+p', opts)

-- ----------------------------------------------------------------------------
-- File explorer (Neo-tree)
-- ----------------------------------------------------------------------------
map("n", "<leader>e", "<cmd>Neotree toggle left<CR>",        opts)
map("v", "<leader>e", "<cmd><C-u>Neotree toggle left<CR>",
  { noremap = true, silent = true, desc = "Neo-tree toggle (visual-safe)" })

-- ----------------------------------------------------------------------------
-- LSP
-- ----------------------------------------------------------------------------
map("n", "gd",         vim.lsp.buf.definition,  opts)
map("n", "gr",         vim.lsp.buf.references,  opts)
map("n", "K",          vim.lsp.buf.hover,        opts)
map("n", "<leader>rn", vim.lsp.buf.rename,       opts)
map("n", "<leader>ca", vim.lsp.buf.code_action,  opts)
map("n", "<leader>f",  function() require("config.safeformat").format_current() end,
  { noremap = true, silent = true, desc = "Format current file" })

-- ----------------------------------------------------------------------------
-- Diagnostics
-- ----------------------------------------------------------------------------
map("n", "[d",        vim.diagnostic.goto_prev,  opts)
map("n", "]d",        vim.diagnostic.goto_next,  opts)
map("n", "<leader>d", vim.diagnostic.open_float, opts)

-- ----------------------------------------------------------------------------
-- PDF viewer (okular)
-- ----------------------------------------------------------------------------
map("n", "<leader>pdf", "<cmd>!okular %:r.pdf &<CR>", opts)

-- ----------------------------------------------------------------------------
-- Telescope
-- ----------------------------------------------------------------------------
map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("telescope.builtin").live_grep()  end, { desc = "Live grep" })
map("n", "<leader>fb", function() require("telescope.builtin").buffers()    end, { desc = "Buffers" })

-- ----------------------------------------------------------------------------
-- Terminal: single reusable shell in file's directory  (<localleader>ll)
-- NOTE: <localleader>ll is also set by run-repl.lua for run/build.
--       That mapping wins for code files; this fallback is for non-code buffers.
-- ----------------------------------------------------------------------------
local ShellHere = { bufnr = nil, jobid = nil }

local function open_shell_here()
  local file = vim.api.nvim_buf_get_name(0)
  local dir  = file ~= "" and vim.fn.fnamemodify(file, ":p:h") or vim.fn.getcwd()

  if ShellHere.bufnr and not vim.api.nvim_buf_is_valid(ShellHere.bufnr) then
    ShellHere.bufnr, ShellHere.jobid = nil, nil
  end

  if ShellHere.bufnr then
    vim.cmd("belowright split")
    vim.api.nvim_win_set_buf(0, ShellHere.bufnr)
    if ShellHere.jobid and vim.fn.jobwait({ ShellHere.jobid }, 0)[1] == -1 then
      vim.api.nvim_chan_send(ShellHere.jobid, "cd " .. vim.fn.fnameescape(dir) .. "\n")
    else
      vim.api.nvim_buf_call(ShellHere.bufnr, function()
        ShellHere.jobid = vim.fn.termopen(vim.o.shell, { cwd = dir })
      end)
    end
  else
    ShellHere.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(ShellHere.bufnr, "ShellHere")
    vim.cmd("belowright split")
    vim.api.nvim_win_set_buf(0, ShellHere.bufnr)
    ShellHere.jobid = vim.api.nvim_buf_call(ShellHere.bufnr, function()
      return vim.fn.termopen(vim.o.shell, { cwd = dir })
    end)
  end

  vim.cmd("startinsert")
end

map("n", "<localleader>tt", open_shell_here,
  { noremap = true, silent = true, desc = "Shell in current file's directory (reuse)" })

-- Terminal escape / close
map("t", "<Esc>", "<C-\\><C-n>",                        opts)
map("t", "<C-d>", [[<C-\><C-n><cmd>bdelete!<CR>]],      opts)

-- ----------------------------------------------------------------------------
-- Lazy
-- ----------------------------------------------------------------------------
map("n", "<leader>l", "<cmd>Lazy<CR>",        opts)
map("n", "<leader>a", "<cmd>Lazy sync<CR>",   opts)
map("n", "<leader>u", "<cmd>Lazy update<CR>", opts)
map("n", "<leader>c", "<cmd>Lazy clean<CR>",  opts)
