return {
  -- Minimal HTTP client interface
  { import = 'lazyvim.plugins.extras.util.rest' },
  {
    'mistweaverco/kulala.nvim',
    -- Its own spec loads it on `VimLeavePre` to save session state, so every
    -- `:q` pulls it in on the way out, and its setup then stops for a
    -- kulala-core license prompt. A Kulala that never loaded has no state
    -- to save.
    event = function(_, events)
      return vim.tbl_filter(
        function(event) return event ~= 'VimLeavePre' end,
        events or {}
      )
    end,
  },
  -- Startup event timing
  { import = 'lazyvim.plugins.extras.util.startuptime' },
}
