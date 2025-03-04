return {
  {
    -- Explain Regex when hover
    'bennypowers/nvim-regexplainer',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'nui.nvim' },
    opts = {
      auto = true,
    },
  },
}
