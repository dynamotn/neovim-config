return {
  {
    -- Explain Regex when hover
    'bennypowers/nvim-regexplainer',
    name = 'regexplainer',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'nui', 'treesitter' },
  },
  {
    -- Foldtext customization
    'kevinhwang91/nvim-ufo',
    name = 'ufo',
    event = 'BufReadPost',
    dependencies = {
      'kevinhwang91/promise-async',
    },
  },
  {
    -- UI for dadbod
    'kristijanhusak/vim-dadbod-ui',
    name = 'dadbod_ui',
    dependencies = { 'dadbod' },
  },
}
