-- =============================================================================
-- Neotree
-- =============================================================================
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",

    opts = function(_, opts)
-- ----------------------------------------------------------------
-- Window
-- ----------------------------------------------------------------
      opts.window = opts.window or {}
      opts.window.position = "left"
      opts.window.width = 25
      opts.window.mappings = opts.window.mappings or {}

      -- Ctrl+h toggles hidden files
      opts.window.mappings["<C-h>"] = "toggle_hidden"

-- ----------------------------------------------------------------
-- Filesystem
-- ----------------------------------------------------------------
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.follow_current_file = { enabled = true }
      opts.filesystem.hijack_netrw_behavior = "open_current"

      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}

      -- Important: dotfiles must be otherwise
      opts.filesystem.filtered_items.hide_dotfiles = true

      -- Start with hidden files
      opts.filesystem.filtered_items.visible = false

      -- Optional
      if opts.filesystem.filtered_items.hide_gitignored == nil then
        opts.filesystem.filtered_items.hide_gitignored = true
      end

      opts.filesystem.filtered_items.show_hidden_count = false

-- ----------------------------------------------------------------
-- Sorting
-- ----------------------------------------------------------------
      opts.sort_case_insensitive = true
      opts.sort_function = function(a, b)
        local function get_name(x)
        return tostring(
        x.name
        or (x.extra and x.extra.name)
        or x.path
        or x.id
        or ""
      )
    end

    local function get_type(x)
    return x.type or x.kind or ""
  end

  local at = get_type(a)
  local bt = get_type(b)

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


-- -----------------------------------------------------------------------------
-- Icons / git
-- -----------------------------------------------------------------------------
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
}
