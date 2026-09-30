return {
  {
    -- Swap a block between one line and several
    --
    -- `gS` is what `splitjoin.vim` used, and the toggle covers both halves:
    -- the node under the cursor decides which way it goes, so there is no
    -- second mapping to remember. The split respects the grammar, which is
    -- why this sits with the rest of the treesitter features rather than
    -- with the plain text ones.
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      {
        'gS',
        function() require('treesj').toggle() end,
        desc = 'Split or join block',
      },
    },
    opts = {
      -- The defaults are `<leader>m`, `<leader>j` and `<leader>s`, and all
      -- three are LazyVim groups already.
      use_default_keymaps = false,
      -- A join that ends up past the text width is not the shorter form of
      -- anything, so it is left split.
      max_join_length = 120,
    },
  },
}
