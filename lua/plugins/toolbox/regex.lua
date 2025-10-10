return {
  {
    -- Explain Regex when hover
    'bennypowers/nvim-regexplainer',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      auto = true,
    },
  },
}
