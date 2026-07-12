-- =============================================================================
-- Editor
-- =============================================================================
return {
  {
    "artcodespace/pax",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "dark"
      vim.cmd.colorscheme("pax")
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "pax",
    },
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "folke/persistence.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = { dashboard = { enabled = false } },
  },

  {
    "danilamihailov/beacon.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local base = {
        enabled = true,
        min_jump = 5,
        width = 30,
        winblend = 40,
        speed = 1,
        fps = 60,
        cursor_events = { "CursorMoved", "CursorMovedI" },
        window_events = { "WinEnter", "FocusGained" },
        highlight = { bg = "#63686d" },
        ignore_filetypes = {
          "help", "lazy", "mason", "qf",
          "TelescopePrompt", "Trouble", "neo-tree", "NvimTree",
          "dashboard", "alpha",
        },
        ignore_buftypes = { "terminal", "nofile", "prompt" },
      }
      require("beacon").setup(base)
      vim.g.beacon_enabled = true
      vim.keymap.set("n", "<leader>b", function()
        local ok, beacon = pcall(require, "beacon")
        if not ok then
          return
        end
        vim.g.beacon_enabled = not vim.g.beacon_enabled
        beacon.setup(vim.tbl_extend("force", base, { enabled = vim.g.beacon_enabled }))
      end, { desc = "Toggle Beacon" })
    end,
  },

  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.9,
      trailing_stiffness = 0.6,
      distance_stop_animating = 0.5,
      hide_target_hack = true,
      never_draw_over_target = true,
      time_interval = 5,
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle left<CR>", desc = "Explorer" },
    },
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.position = "left"
      opts.window.width = 50
      opts.window.mappings = opts.window.mappings or {}
      opts.window.mappings["<C-h>"] = "toggle_hidden"

      opts.filesystem = opts.filesystem or {}
      opts.filesystem.follow_current_file = { enabled = true }
      opts.filesystem.hijack_netrw_behavior = "open_current"
      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
      opts.filesystem.filtered_items.hide_dotfiles = true
      opts.filesystem.filtered_items.visible = false
      if opts.filesystem.filtered_items.hide_gitignored == nil then
        opts.filesystem.filtered_items.hide_gitignored = true
      end
      opts.filesystem.filtered_items.show_hidden_count = false

      opts.sort_case_insensitive = true
      opts.sort_function = function(a, b)
        local function get_name(x)
          return tostring(x.name or (x.extra and x.extra.name) or x.path or x.id or "")
        end
        local function get_type(x)
          return x.type or x.kind or ""
        end
        local at, bt = get_type(a), get_type(b)
        if at ~= bt then
          if at == "directory" then
            return true
          end
          if bt == "directory" then
            return false
          end
        end
        return get_name(a):lower() < get_name(b):lower()
      end

      opts.default_component_configs = opts.default_component_configs or {}
      opts.default_component_configs.icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
      }
      opts.default_component_configs.git_status = {
        symbols = {
          added = "✚",
          modified = "",
          deleted = "✖",
          renamed = "󰁕",
          untracked = "",
          ignored = "",
          unstaged = "󰄱",
          staged = "",
          conflict = "",
        },
      }
      opts.default_component_configs.indent = {
        indent_size = 2,
        padding = 2,
      }
      return opts
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        layout_strategy = "center",
        layout_config = { width = 0.8, height = 0.7 },
        border = true,
        winblend = 0,
      },
    },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
    },
  },
}
