return {
  -- Pin files and jump between them
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
  {
    -- w/e/b/ge by subword, over insignificant punctuation
    'chrisgrieser/nvim-spider',
    -- Ex commands rather than functions, or `.` cannot repeat them
    keys = {
      {
        'w',
        "<cmd>lua require('spider').motion('w')<cr>",
        mode = { 'n', 'o', 'x' },
        desc = 'Next subword',
      },
      {
        'e',
        "<cmd>lua require('spider').motion('e')<cr>",
        mode = { 'n', 'o', 'x' },
        desc = 'End of subword',
      },
      {
        'b',
        "<cmd>lua require('spider').motion('b')<cr>",
        mode = { 'n', 'o', 'x' },
        desc = 'Previous subword',
      },
      {
        'ge',
        "<cmd>lua require('spider').motion('ge')<cr>",
        mode = { 'n', 'o', 'x' },
        desc = 'End of previous subword',
      },
      -- Its `cw` changes up to the next word, as `dw` deletes; keep Vim's
      -- change to the end of the word instead.
      {
        'cw',
        "c<cmd>lua require('spider').motion('e')<cr>",
        desc = 'Change to end of subword',
      },
    },
  },
}
