local languages_list = require('config.languages')
local markview_filetypes = {}
vim.list_extend(markview_filetypes, languages_list.markdown.filetypes)
vim.list_extend(markview_filetypes, languages_list.html.filetypes)
vim.list_extend(markview_filetypes, languages_list.typst.filetypes)
vim.list_extend(markview_filetypes, languages_list.yaml.filetypes)

return {
  -- Highlight patterns (colors)
  { import = 'lazyvim.plugins.extras.util.mini-hipatterns' },
  {
    -- Rainbow parentheses
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    submodules = false,
    opts = function()
      local rainbow = require('rainbow-delimiters')
      return {
        strategy = {
          [''] = rainbow.strategy['global'],
          vim = rainbow.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
        },
      }
    end,
    main = 'rainbow-delimiters.setup',
  },
  {
    -- Syntax highlight
    'OXY2DEV/markview.nvim',
    lazy = false,
    opts = {
      preview = {
        icon_provider = 'devicons',
        enable = true,
      },
      html = {
        enable = true,
      },
      typst = {
        enable = true,
      },
      yaml = {
        enable = true,
      },
    },
    config = function(opts)
      local presets = require('markview.presets')
      require('markview').setup(vim.tbl_deep_extend('force', opts, {
        markdown = {
          headings = presets.headings.glow,
        },
      }))
    end,
  },
}
