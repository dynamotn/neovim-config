return {
  {
    -- Explain Regex when hover
    'bennypowers/nvim-regexplainer',
    -- It and `nui.nvim` together cost about a twentieth of a second of the
    -- first file opened in a session, and on `BufRead` that is paid before
    -- the file is on screen. Nothing it does is wanted that early: `auto`
    -- draws from `CursorMoved`, so the first idle moment is soon enough to
    -- load it and late enough to cost the open nothing. The cursor resting
    -- on a pattern is what loads it, and the explainer follows from the
    -- next move.
    event = 'CursorHold',
    dependencies = { 'MunifTanjim/nui.nvim' },
    keys = {
      {
        '<leader>uR',
        '<cmd>RegexplainerToggle<cr>',
        desc = 'Toggle Regexplainer',
      },
    },
    opts = {
      auto = true,
    },
  },
}
