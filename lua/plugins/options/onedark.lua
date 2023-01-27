local onedark = require('onedark')

onedark.setup({
  style = 'cool',
  term_colors = false,
  code_style = {
    comments = 'italic',
    keywords = 'italic',
    functions = 'bold',
    strings = 'none',
    variables = 'none',
  },
  colors = {
    black = '#2d3c46',
    bg0 = '#242b38',
    bg1 = '#2d3343',
    bg2 = '#343e4f',
    bg3 = '#363c51',
    bg_d = '#1e242e',
    bg_blue = '#3182bd',
    bg_yellow = '#f0d197',
    fg = '#dcdfe4',
    purple = '#756bb1',
    green = '#31a354',
    orange = '#dca060',
    blue = '#4596d1',
    yellow = '#f0b474',
    cyan = '#94c5e7',
    red = '#f72e30',
    grey = '#b7b8b9',
    light_grey = '#fcfdfe',
    dark_cyan = '#80b1d3',
    dark_red = '#e31a1c',
    dark_yellow = '#dca060',
    dark_purple = '#897fc5',
  },
  highlights = {
    ['@text.diff.add'] = { fg = '$green' },
    ['@text.diff.delete'] = { fg = '$dark_red' },
  },
})

onedark.load()
