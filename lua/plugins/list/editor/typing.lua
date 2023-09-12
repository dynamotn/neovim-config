return {
  {
    -- Automatically insert/delete brackets, parentheses, quotes...
    'windwp/nvim-autopairs',
    name = 'autopairs',
    event = { 'BufRead', 'BufNewFile' },
  },
  {
    -- Increment/decrement number, date...
    'monaqa/dial.nvim',
    name = 'dial',
  },
  {
    -- Change surround character
    'echasnovski/mini.surround',
    name = 'surround',
    lazy = false,
  },
  {
    -- Convert text case
    'johmsalas/text-case.nvim',
    name = 'textcase',
  },
  {
    -- Align text interactively
    'echasnovski/mini.align',
    name = 'align',
    event = 'UIEnter',
  },
  {
    -- Tabbing out
    'abecodes/tabout.nvim',
    name = 'tabout',
    dependencies = { 'treesitter' },
    event = 'InsertEnter',
  },
}
