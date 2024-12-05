return {
  {
    -- Explain Regex when hover
    'bennypowers/nvim-regexplainer',
    name = 'regexplainer',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'nui' },
  },
  {
    -- Foldtext customization
    'kevinhwang91/nvim-ufo',
    name = 'ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    lazy = false,
  },
  {
    -- UI for dadbod
    'kristijanhusak/vim-dadbod-ui',
    name = 'dadbod_ui',
    dependencies = { 'dadbod' },
    cmd = 'DBUI',
  },
}
