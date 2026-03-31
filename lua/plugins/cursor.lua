-- =============================================================================
-- Cursor
-- =============================================================================
return {
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      -- Movement feel
      stiffness = 0.9,  -- How fast it catches
      trailing_stiffness = 0.6,  -- Smooth trailing
      distance_stop_animating = 0.5,

      -- Visual cleanup
      hide_target_hack = true,  -- Prevents ghost lines
      never_draw_over_target = true,

      -- Make it subtle
      time_interval = 5,
    },
  },
}
