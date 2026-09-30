return {
  -- Create key strokes
  { import = 'lazyvim.plugins.extras.editor.harpoon2' },
  -- Action for surrounding
  { import = 'lazyvim.plugins.extras.coding.mini-surround' },
  {
    -- Interact and manipulate marks
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {
      default_mappings = true,
    },
  },
  {
    -- Match and move between keyword pairs, not only brackets
    --
    -- The built-in `matchit` already teaches `%` about `if`/`end`, but it
    -- stops there: nothing highlights the other half, and a pair whose
    -- opening is scrolled away leaves no clue where it began. Both matter
    -- here, where every language that can take `endwise` gets it.
    'andymass/vim-matchup',
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      -- The offscreen half is normally drawn over the status line, which
      -- lualine and noice already own, so it goes in a popup instead.
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      -- Highlight once the cursor settles. Matching a keyword pair means
      -- walking the buffer, and doing that on every single motion is what
      -- makes matchup feel slow in a large file.
      vim.g.matchup_matchparen_deferred = 1
      -- `nvim-ts-autotag` is the one renaming HTML tag pairs; matchup's own
      -- transmute would be a second writer on the same edit.
      vim.g.matchup_transmute_enabled = 0
    end,
  },
}
