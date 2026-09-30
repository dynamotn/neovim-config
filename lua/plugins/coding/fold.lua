return {
  {
    -- Fold with h/l, and show what a fold hides
    'chrisgrieser/nvim-origami',
    event = 'VeryLazy',
    opts = {
      -- LSP folds are off here (`lsp/server.lua`) for misbehaving on exit, and
      -- this would bring them back; treesitter folds from LazyVim stay.
      useLspFoldsWithTreesitterFallback = { enabled = false },
      -- It closes comments and imports through the LSP folds just turned off.
      autoFold = { enabled = false },
    },
  },
}
