# NeoVim-config

A modern, modular Neovim configuration built with Lua and Lazy.nvim. Optimized for academic research, computational economics, and multi-language development with seamless IDE features, interactive computing, and Bayesian workflows.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Dependencies on Arch Linux](#dependencies-on-arch-linux)
  - [Configuration Setup](#configuration-setup)
- [Architecture](#architecture)
- [Configuration Sections](#configuration-sections)
- [Plugins](#plugins)
- [Keybindings](#keybindings)
- [Language Support](#language-support)
- [Troubleshooting](#troubleshooting)

## Overview

This is a production-grade Neovim configuration emphasizing:

- **Modern Lua-based architecture**: Fully written in Lua (no VimScript)
- **Lazy loading**: Smart plugin loading for instant startup (~100ms)
- **Integrated IDE**: LSP, debugging (DAP), testing (Neotest), and linting
- **Academic tooling**: LaTeX, Jupyter/IPython integration, REPL support (Python, Julia, R, Fortran)
- **Interactive computing**: Send code to terminal or Jupyter kernels
- **Multi-language**: Python, Julia, R, C/C++, Rust, Fortran, Markdown, LaTeX
- **Git integration**: Fugitive, Gitsigns, Diffview
- **Treesitter-powered**: AST-based syntax highlighting and text objects
- **Terminal multiplexing**: Toggleterm for interactive shells
- **AI integration**: Local or remote AI completions (Ollama, OpenAI)
- **Type checking**: Full Python type checking with LSP diagnostics
- **Keyboard-centric**: Space leader, extensive custom keybindings

## Requirements

### System Requirements

- **OS**: Linux (tested on Arch Linux)
- **Neovim**: Version 0.9+ (latest recommended)
- **Terminal**: 24-bit color support, UTF-8
- **Node.js**: For language servers via Mason
- **Git**: Required for Lazy.nvim and plugin management

### Arch Linux Dependencies

```bash
# Core editor
sudo pacman -S neovim

# Essential tools
sudo pacman -S git nodejs npm ripgrep fd

# Lua language server (optional but recommended)
sudo pacman -S lua-language-server
```

### Optional System Dependencies

Based on language and feature support:

```bash
# Programming languages
sudo pacman -S python julia rust gcc gdb go

# LaTeX
sudo pacman -S texlive-latex texlive-fonts texlive-xetex texlive-bibtex-extra

# Language servers & linters (auto-installed by Mason, but pre-install optional)
sudo pacman -S python-lsp-server flake8 black shellcheck shfmt

# Version control & utilities
sudo pacman -S git ripgrep fd sqlite3 pandoc

# Jupyter support
pip install jupyter ipython notebook

# Spell checking
sudo pacman -S aspell aspell-en

# Nerd Font (for icons)
sudo pacman -S nerd-fonts
```

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/nvim-config ~/.config/nvim
cd ~/.config/nvim
```

### 2. Install Neovim

Ensure you have Neovim 0.9+:

```bash
nvim --version  # Should show 0.9 or later
```

For latest version:

```bash
sudo pacman -Syu neovim
```

### 3. Start Neovim

```bash
nvim
```

On first startup:
- **Lazy.nvim** will be auto-downloaded from GitHub
- All plugins will be automatically installed
- LSP servers will be installed via Mason
- The configuration will be loaded

This typically takes 1-3 minutes on first launch.

### 4. Verify Installation

Inside Neovim, run:

```vim
:Lazy
:Mason
:checkhealth nvim
```

All should show success status.

### 5. Configure LSP (Optional)

Language servers are auto-managed by Mason. To add custom language servers:

```vim
:Mason
```

Then navigate and install additional language servers as needed.

---

## Architecture

The configuration is modular and organized as follows:

```
~/.config/nvim/
├── init.lua              # Entry point (loads config modules)
├── lua/
│   ├── config/           # Core configuration
│   │   ├── lazy.lua      # Plugin manager bootstrap
│   │   ├── options.lua   # Vim options & settings
│   │   ├── keymaps.lua   # Keybindings
│   │   ├── autocmds.lua  # Autocommands
│   │   ├── safeformat.lua # Safe formatting logic
│   │   └── utils.lua     # Utility functions
│   └── plugins/          # Plugin configurations (one file per plugin)
│       ├── lsp.lua       # LSP configuration
│       ├── lsp_completion.lua  # Completion (Cmp)
│       ├── treesitter.lua      # Syntax highlighting
│       ├── neotree.lua         # File explorer
│       ├── telescope.lua       # Fuzzy finder
│       ├── git.lua            # Git integration
│       ├── dap.lua            # Debugging
│       ├── neotest.lua        # Testing
│       ├── run-repl.lua       # Execute & REPL
│       ├── jupyter.lua        # Jupyter integration
│       ├── latex.lua          # LaTeX tools
│       ├── julia.lua          # Julia-specific setup
│       ├── ai.lua            # AI integration
│       ├── colorscheme.lua    # Theme & colors
│       ├── ui.lua            # UI enhancements
│       ├── writing.lua       # Writing tools
│       ├── cursor.lua        # Cursor movements
│       ├── org.lua           # Org-mode
│       ├── beacon.lua        # Visual feedback
│       ├── cmp.lua           # Additional completion
│       ├── markdown-preview.lua  # Markdown preview
│       ├── extras.lua        # Extra utilities
│       └── disable.lua       # Disable unnecessary plugins
```

---

## Configuration Sections

### **Core Configuration**

#### **Options** (`lua/config/options.lua`)

```lua
vim.g.mapleader      = " "      -- Space as leader
vim.g.maplocalleader = "\\"     -- Backslash for local leader
vim.opt.background   = "dark"
vim.opt.termguicolors = true    -- 24-bit color
vim.opt.clipboard    = "unnamedplus"  -- System clipboard
```

**Line Numbers & Display**:
```lua
vim.opt.number         = true   -- Show absolute line numbers
vim.opt.relativenumber = true   -- Show relative numbers
vim.opt.cursorline     = true   -- Highlight current line
vim.opt.wrap           = true   -- Soft wrap long lines
```

**Splits & Windows**:
```lua
vim.opt.splitright = true  -- New split opens right
vim.opt.splitbelow = true  -- New split opens below
```

**Diagnostics**:
```lua
vim.diagnostic.config({
  virtual_text = false,  -- Don't show errors inline (less clutter)
  underline = true,      -- Underline errors
  severity_sort = true,  -- Sort by severity
  float = { border = "rounded" },  -- Nice borders on error popups
})
```

**Disables**:
```lua
vim.g.loaded_netrw = 1         -- Neo-tree handles file browsing
vim.g.autoformat = false       -- Safeformat handles formatting
```

#### **Keymaps** (`lua/config/keymaps.lua`)

**Save/Quit**:
```lua
<leader>w     -- Save
<leader>q     -- Quit
<leader>Q     -- Quit all (force)
<leader>r     -- Reload config
```

**Navigation**:
```lua
jk             -- Escape from insert mode
j, k           -- Move with line wrapping (gj, gk)
<C-d>, <C-u>   -- Page down/up + center
n, N           -- Next/prev search + center + unfold
```

**Buffers**:
```lua
<leader>bn     -- Next buffer
<leader>bp     -- Previous buffer
<leader>bd     -- Delete buffer
<leader>bl     -- List buffers
```

**Splits**:
```lua
<leader>sv     -- Vertical split
<leader>sh     -- Horizontal split
<leader>sc     -- Close split
<C-h/j/k/l>    -- Navigate splits
```

**Search & Replace**:
```lua
<leader>h      -- Clear search highlight
<leader>s      -- Interactive search & replace
v// 			-- Search selected text
<A-j/k>        -- Move lines up/down
```

**Clipboard**:
```lua
<leader>y      -- Copy to system clipboard
<leader>Y      -- Copy line to clipboard
<leader>p      -- Paste from system clipboard
```

**IDE Features**:
```lua
gd             -- Go to definition
gr             -- Find references
K              -- Show hover documentation
<leader>rn     -- Rename symbol
<leader>ca     -- Code actions
<leader>f      -- Format current file
[d, ]d         -- Previous/next diagnostic
<leader>d      -- Show diagnostics
```

**File Navigation**:
```lua
<leader>e      -- Toggle Neo-tree file explorer
<leader>ff     -- Find files (Telescope)
<leader>fg     -- Live grep (Telescope)
<leader>fb     -- Search buffers (Telescope)
```

**Terminal & REPL**:
```lua
<localleader>tt  -- Shell in current file's directory (toggleterm)
<Esc>            -- Exit terminal mode
<C-d>            -- Close terminal
```

**Plugin Management**:
```lua
<leader>l      -- Lazy status & management
<leader>a      -- Lazy sync (install/update)
<leader>u      -- Lazy update
<leader>c      -- Lazy clean (remove unused)
```

#### **Autocommands** (`lua/config/autocmds.lua`)

**Filetype-specific Indentation**:
- Default: 2 spaces, UTF-8 expandtab
- Python: 4 spaces, 89-char textwidth
- Julia: 93-char column marker
- R/Rmd/Quarto: 101-char column marker
- C/C++/Fortran: 101-char column marker

**Auto-Features**:
- **Yank highlight**: Brief visual feedback when copying
- **Auto-reload**: Files reloaded if changed externally
- **Auto mkdir**: Directories created on save if missing
- **Safe format**: Auto-format on save (non-destructive)
- **LaTeX tweaks**: Word wrap, spell check, concealment for LaTeX
- **Cursor line**: Persistent highlighting across color schemes
- **Terminal UI**: Clean terminal (no line numbers, minimal clutter)
- **Start at top**: Files open at line 1 (not last position)

#### **Safe Formatting** (`lua/config/safeformat.lua`)

Custom formatting system that:
- Prevents unwanted formatting changes
- Checks for common mistakes before applying
- Supports per-language formatting rules
- Triggers on save via autocmd

---

### **Plugin Configurations**

#### **Lazy.nvim Bootstrap** (`lua/config/lazy.lua`)

```lua
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
  defaults = { lazy = false, version = false },
  checker = { enabled = true, notify = false },
})
```

- Auto-downloads Lazy.nvim on first launch
- Imports all plugins from `lua/plugins/`
- Auto-checks for updates in background

---

## Plugins

### **Core IDE Plugins**

#### **Mason** (Language Server Installation)
```lua
Plug 'mason-org/mason.nvim'
```
- Auto-installs language servers: `pyright`, `r-languageserver`, `clangd`, `rust-analyzer`, `fortls`, `texlab`, `html-lsp`, `css-lsp`, `marksman`
- Run `:Mason` to browse/install additional servers

#### **nvim-lspconfig** (LSP Configuration)
```lua
Plug 'neovim/nvim-lspconfig'
```
- Configures language servers
- **Julia setup**: Uses `LanguageServer.jl` with `--startup-file=no` for faster startup
- **Fortran setup**: MaxLineLength 120, code actions enabled, autocomplete
- **Root pattern detection**: Finds `Project.toml`, `JuliaProject.toml`, `.git`

#### **Completion & Snippets**

**nvim-cmp** (Autocompletion):
```lua
Plug 'hrsh7th/nvim-cmp'
```
- Ghost text completion (subtle inline suggestions)
- Tab/Shift-Tab to navigate, Enter to confirm
- Context-aware completions from LSP

**UltiSnips** (Snippet Engine):
```lua
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
```
- Expandable code templates
- Tab to jump between placeholders
- Example: `for<Tab>` expands to Python for-loop

#### **Treesitter** (Syntax Highlighting & Text Objects)
```lua
Plug 'nvim-treesitter/nvim-treesitter'
```
- AST-based (Abstract Syntax Tree) syntax highlighting
- Incremental parsing: faster, more accurate than regex
- Better indentation and text objects
- Languages: Python, Julia, R, C, C++, Rust, Fortran, Lua, and 100+ more

---

### **File Navigation & Search**

#### **Neo-tree** (File Explorer)
```lua
Plug 'nvim-neo-tree/neo-tree.nvim'
```

**Features**:
- Left sidebar file tree
- Icons and colors for file types
- Follow current file in tree
- Hidden files toggle: `<C-h>`
- Recursive directory operations

**Keybindings**:
- `<leader>e`: Toggle tree
- `o`: Open file / expand directory
- `a`: Add file/directory
- `d`: Delete file/directory
- `r`: Rename
- `m`: Move
- `c`: Copy
- `<C-h>`: Toggle hidden files

**Configuration**:
```lua
position = "left"
width = 25
follow_current_file = true
hide_dotfiles = true  -- Hide .* files by default
hide_gitignored = true -- Hide git-ignored files
```

#### **Telescope** (Fuzzy Finder)
```lua
Plug 'nvim-telescope/telescope.nvim'
```

**Features**:
- Fast fuzzy search for files, text, history
- Preview panel
- Built on libuv (extremely fast)
- Configurable layouts and themes

**Keybindings**:
```lua
<leader>ff    -- Find files
<leader>fg    -- Live grep (search text)
<leader>fb    -- Search buffers
```

**Usage**:
- Type to filter matches
- `<C-j>/<C-k>`: Previous/next result
- `Enter`: Select
- `<C-v>`: Open in vertical split
- `<C-s>`: Open in horizontal split

---

### **Git Integration**

#### **Fugitive** (Git Commands)
```lua
Plug 'tpope/vim-fugitive'
```
- `:Git` or `:G` to run git commands
- `:Git commit`, `:Git push`, `:Git log`
- `:Gvdiffsplit`: Show diffs side-by-side

#### **Gitsigns** (Git Diff Markers)
```lua
Plug 'lewis6991/gitsigns.nvim'
```
- Shows `+`, `-`, `~` in left margin for changed lines
- Navigate hunks with `]c`, `[c`
- Stage hunks with `:Gitsigns stage_hunk`

#### **Diffview** (Diff Viewer)
```lua
Plug 'sindrets/diffview.nvim'
```
- View file history with `:DiffviewOpen`
- Compare branches with `:DiffviewOpen origin/main`

---

### **Debugging & Testing**

#### **DAP** (Debug Adapter Protocol)
```lua
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
```

**Features**:
- Breakpoints
- Step through code (next, step-into, step-out)
- Variables inspector
- Call stack
- Debug terminal

**Keybindings**:
- `<leader>db`: Toggle breakpoint
- `<leader>dB`: Set conditional breakpoint
- `<leader>dc`: Continue
- `<leader>dn`: Step next
- `<leader>ds`: Step into
- `<leader>do`: Step out
- `<leader>dd`: Disconnect

**Supported Languages**: Python (debugpy), C/C++ (gdb), and more

#### **Neotest** (Testing Framework)
```lua
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-python'
Plug 'nvim-neotest/neotest-plenary'
```

- Run tests from editor
- See results inline
- Keybindings:
  - `<leader>tr`: Run nearest test
  - `<leader>tR`: Run file
  - `<leader>tS`: Run suite

---

### **Code Execution & REPL**

#### **Toggleterm** (Terminal Multiplexing)
```lua
Plug 'akinsho/toggleterm.nvim'
```

**Features**:
- Multiple terminals in editor
- Quick toggle from any mode
- Horizontal/vertical/floating windows
- Persistent terminal state

**Keybindings**:
- `<leader>v`: Toggle terminal
- `<C-\>`: Quick toggle
- `<C-d>`: Close terminal

#### **Run-REPL** (Execute & Interactive Computing)

Custom plugin configuration supporting:

**Python**:
```python
python %:p           # Run current file
python -m pytest %   # Run tests
```

**Julia**:
```julia
julia %:p            # Run current file
julia --project .    # Run in project
```

**R**:
```r
Rscript %:p          # Run current file
```

**Fortran**:
```bash
gfortran %:p -o /tmp/a.out && /tmp/a.out  # Compile & run
```

**LaTeX**:
```bash
latexmk -pdf %:p     # Compile PDF
okular %:r.pdf       # View PDF
```

**Usage**:
- `<leader>e`: Execute current file
- `<leader>E`: Run with debug output
- Results appear in terminal below
- Send region to REPL with visual mode

#### **Jupyter Integration**
```lua
Plug 'kiyoon/jupynium.nvim'
```

- Execute code cells in Jupyter kernel
- Syntax highlighting for cell markers (`# %%`)
- Sync with Jupyter notebook
- Keybindings:
  - `<leader>je`: Execute cell
  - `<leader>ja`: Execute all
  - `<leader>jr`: Run to current cell

---

### **Language-Specific**

#### **LaTeX** (VimTeX)
```lua
Plug 'lervag/vimtex'
```

**Features**:
- Compilation on save
- PDF viewer integration
- Syntax highlighting
- Snippet expansion
- Label/citation navigation

**Keybindings**:
- `<leader>ll`: Compile LaTeX
- `<leader>lv`: View PDF
- `<leader>lc`: Clear build files
- `[[`, `]]`: Navigate sections

**Configuration**:
- XeTeX engine for Unicode support
- PDF viewer: Okular
- Smart indentation

#### **Julia**
- Language server (LanguageServer.jl)
- REPL integration
- Unicode symbol input
- Plot display

#### **Python**
- Pyright language server
- Black formatter
- Flake8 linter
- Pytest integration

#### **R/Rmd/Quarto**
- r-languageserver
- LazyVim R support
- Markdown integration

---

### **UI & Visual Enhancements**

#### **Colorscheme**
```lua
Plug 'https://github.com/rktjmp/pax.vim'  -- Default theme
```
- Minimal, clean theme
- Good for focus
- Customizable highlights

#### **Treesitter Context** (Show current scope)
```lua
Plug 'nvim-treesitter/nvim-treesitter-context'
```
- Display function/class name at top
- Jump to scope with `:TSContext`

#### **Beacon** (Visual cursor feedback)
```lua
Plug 'danilamb/beacon.nvim'
```
- Flash cursor position on large jumps
- Helps track cursor when scrolling

#### **Indent Blankline** (Visual indent guides)
```lua
Plug 'lukas-reineke/indent-blankline.nvim'
```
- Show indentation level with vertical lines
- Helps navigate nested structures

#### **Barbecue** (Winbar with breadcrumb)
```lua
Plug 'utilyre/barbecue.nvim'
```
- Show file path and current symbol at top of window
- Useful for large files

---

### **Additional Utilities**

#### **Autopairs** (Auto-close brackets)
```lua
Plug 'windwp/nvim-autopairs'
```
- Auto-insert closing brackets, quotes
- Smart pairing based on context

#### **Comment** (Toggle comments)
```lua
Plug 'numToStr/Comment.nvim'
```
- `<leader>c<space>`: Toggle comment
- `<leader>cc`: Comment line
- `<leader>cu`: Uncomment line
- Works with Treesitter for language-aware comments

#### **Surround** (Modify surrounding pairs)
```lua
Plug 'kylechui/nvim-surround'
```
- `cs"'`: Change `"hello"` → `'hello'`
- `ds"`: Delete quotes
- `ysiw"`: Add quotes around word
- `yss"`: Add quotes to entire line

#### **Undotree** (Undo history visualization)
```lua
Plug 'mbbill/undotree'
```
- Visualize undo tree as branching graph
- `:UndotreeToggle` to open
- Navigate to any previous state

---

## Keybindings Reference

### **Navigation & Movement**

| Key | Action |
|-----|--------|
| `jk` | Escape from insert mode |
| `j`, `k` | Move with word wrap (gj, gk) |
| `<C-d>`, `<C-u>` | Page down/up + center |
| `n`, `N` | Next/prev search + center |
| `<C-h/j/k/l>` | Navigate between splits |
| `<A-j>`, `<A-k>` | Move line up/down |

### **File & Buffer Operations**

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer (Neo-tree) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | Search buffers |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bl` | List buffers |

### **IDE Features**

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format file |
| `[d`, `]d` | Previous/next diagnostic |
| `<leader>d` | Show diagnostics |

### **Search & Replace**

| Key | Action |
|-----|--------|
| `<leader>h` | Clear search highlight |
| `<leader>s` | Interactive search & replace |
| `v//` | Search selected text |

### **Terminal & REPL**

| Key | Action |
|-----|--------|
| `<localleader>tt` | Open shell (toggleterm) |
| `<Esc>` | Exit terminal mode |
| `<C-d>` | Close terminal |

### **Plugin Management**

| Key | Action |
|-----|--------|
| `<leader>l` | Lazy plugin manager |
| `<leader>a` | Install/update plugins |
| `<leader>u` | Update plugins |
| `<leader>c` | Clean unused plugins |

---

## Language Support

### **Python**

**LSP**: Pyright (auto-installed via Mason)

**Diagnostics**: Full type checking, undefined variable detection

**Linting**: Flake8, Black formatter

**Testing**: Pytest integration with Neotest

**REPL**: Python interactive mode in terminal

**Installation**:
```bash
sudo pacman -S python python-lsp-server flake8 black
```

### **Julia**

**LSP**: LanguageServer.jl (auto-configured)

**Features**: Symbol completion, type information, error checking

**REPL**: Direct Julia interactive mode

**Requirements**:
```bash
sudo pacman -S julia
julia -e 'using Pkg; Pkg.add("LanguageServer")'
```

### **R & Rmd**

**LSP**: r-languageserver

**Markdown**: Quarto support for literate programming

**REPL**: R interactive console

**Installation**:
```bash
sudo pacman -S r
R -e 'install.packages("languageserver")'
```

### **C/C++**

**LSP**: clangd (auto-installed via Mason)

**Debugging**: GDB integration via DAP

**Compiler**: GCC with flags for optimization/warnings

**Installation**:
```bash
sudo pacman -S gcc gdb clang
```

### **Rust**

**LSP**: rust-analyzer (auto-installed via Mason)

**Formatter**: rustfmt (auto-installed)

**Testing**: Integrated cargo test runner

**Installation**:
```bash
sudo pacman -S rust
```

### **LaTeX**

**LSP**: Texlab (auto-installed via Mason)

**Compiler**: XeTeX for Unicode support

**PDF Viewer**: Okular integration

**Features**: Auto-completion, reference jumping, SyncTeX

**Installation**:
```bash
sudo pacman -S texlive-latex texlive-xetex texlive-bibtex-extra okular
```

### **Markdown**

**LSP**: Marksman (auto-installed via Mason)

**Preview**: Markdown preview in browser

**Syntax**: Code block highlighting

**Installation**:
```bash
sudo pacman -S pandoc
```

### **Shell/Bash**

**LSP**: bash-language-server (auto-installed via Mason)

**Linting**: ShellCheck (auto-installed via Mason)

**Formatting**: Shfmt (auto-installed via Mason)

---

## Troubleshooting

### Lazy.nvim Not Installing Plugins

**Problem**: Plugins don't appear after startup

**Solution**:
```bash
# Check Lazy status
nvim +Lazy

# Manually sync
:Lazy sync
```

### Language Servers Not Available

**Problem**: LSP features don't work (no completions, goto definition fails)

**Solution**:
```bash
# Check Mason status
:Mason

# Install language server manually
:MasonInstall pyright  # for Python

# Check if installed
:CocStatus
:LspInfo
```

### Mason Download Fails

**Problem**: "Failed to download language server"

**Solution**:
```bash
# Ensure Node.js is installed
node --version

# Ensure npm is available
npm --version

# Try manual installation
npm install -g pyright  # for Python
```

### Telescope Not Finding Files

**Problem**: FZF shows no results or errors

**Solution**:
```bash
# Install ripgrep
sudo pacman -S ripgrep fd

# Verify it works
rg --files --hidden --follow --glob "!.git/*" .

# Restart Neovim
nvim
```

### Formatters Not Running

**Problem**: Files don't auto-format on save

**Solution**:
1. Check safeformat is enabled: `lua require('config.safeformat')`
2. Verify formatter is installed:
   ```bash
   black --version    # Python
   shfmt -version     # Shell
   ```
3. Check autocmd is enabled: `:autocmd BufWritePost`

### LSP Diagnostics Spam

**Problem**: Too many error/warning highlights

**Solution**:
1. Reduce severity in options.lua:
   ```lua
   vim.diagnostic.config({
     severity_sort = true,
     float = { severity = vim.diagnostic.severity.WARN }
   })
   ```
2. Or suppress specific linters in Mason

### Neo-tree Icons Not Showing

**Problem**: File icons appear as boxes or placeholders

**Solution**:
1. Install a Nerd Font:
   ```bash
   sudo pacman -S nerd-fonts
   ```
2. Configure terminal to use the font (Terminal > Preferences > Font)
3. Restart terminal/Neovim

### Slow Startup

**Problem**: Neovim takes >1 second to start

**Solution**:
1. Check which plugins are slow:
   ```vim
   :profile start profile.log
   :profile func *
   :profile file *
   " ... use Neovim normally ...
   :profile stop
   :vsplit profile.log
   ```
2. Mark slow plugins as lazy in their spec:
   ```lua
   { "plugin-name", lazy = true, ... }
   ```

### Terminal Mode Issues

**Problem**: Terminal doesn't respond to keybindings

**Solution**:
```vim
" Check terminal job ID
:echo b:terminal_job_id

" Exit terminal with Esc
<Esc>

" Or with Ctrl-C
<C-c>
```

### Jupyter Integration Not Working

**Problem**: Jupyter cells don't execute

**Solution**:
1. Ensure Jupyter is installed:
   ```bash
   pip install jupyter ipython notebook
   ```
2. Start Jupyter server:
   ```bash
   jupyter notebook
   ```
3. Connect Neovim to kernel:
   ```vim
   :JupyniumStartSync
   ```

### Julia REPL Slow to Start

**Problem**: Julia takes 5+ seconds to respond

**Solution**:
This is normal for Julia's first run. Use `--startup-file=no` to skip custom startup:
```lua
julials = {
  cmd = { "julia", "--startup-file=no", "--history-file=no" }
}
```

---

## Performance Optimization

1. **Lazy load expensive plugins**:
   ```lua
   {
     "plugin-name",
     lazy = true,
     event = "BufRead *.py"  -- Load on Python files
   }
   ```

2. **Disable unused plugins** in `lua/plugins/disable.lua`:
   ```lua
   { "plugin-name", enabled = false }
   ```

3. **Profile startup** to find slow plugins (see Troubleshooting)

4. **Use built-in Lua features** instead of plugins where possible

5. **Pre-compile with luac** (improves load time slightly)

---

## File Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua        # Bootstrap & plugin setup
│   │   ├── options.lua     # Vim settings
│   │   ├── keymaps.lua     # Keybindings
│   │   ├── autocmds.lua    # Autocommands
│   │   ├── safeformat.lua  # Format logic
│   │   └── utils.lua       # Utilities
│   └── plugins/            # ~30 plugin specs
├── spell/                  # Spell checking (auto-created)
└── undo/                   # Undo history (auto-created)
```

---

## Contributing

Feel free to customize and extend this configuration:

1. Add new plugins to `lua/plugins/`
2. Add language servers in `lua/plugins/lsp.lua`
3. Customize keybindings in `lua/config/keymaps.lua`
4. Add language-specific config in `lua/config/autocmds.lua`

---

## Quick Reference

### First Time Setup
```bash
git clone <repo> ~/.config/nvim
nvim
# Wait for plugins to install (~2-3 minutes)
```

### Daily Commands
```bash
nvim .          # Open project
nvim file.py    # Open specific file

# Common operations:
<leader>e       # File tree
<leader>ff      # Find file
<leader>fg      # Search text
gd              # Go to definition
<leader>f       # Format file
<localleader>tt # Open terminal
<leader>a       # Install/update plugins
```

### Check System Health
```vim
:checkhealth nvim     " Neovim environment check
:Mason                " Language server manager
:Lazy                 " Plugin manager
:LspInfo              " LSP status
```

---

## Credits

- Built with [Neovim 0.9+](https://neovim.io/)
- Plugin manager: [Lazy.nvim](https://github.com/folke/lazy.nvim)
- LazyVim starter: [LazyVim](https://www.lazyvim.org/)
- Language servers: [Mason](https://github.com/williamboman/mason.nvim)
