local languages_list = require('config.languages')
local markview_filetypes = { 'codecompanion' }
vim.list_extend(markview_filetypes, languages_list.markdown.filetypes)
vim.list_extend(markview_filetypes, languages_list.html.filetypes)
vim.list_extend(markview_filetypes, languages_list.typst.filetypes)
vim.list_extend(markview_filetypes, languages_list.yaml.filetypes)

return {
  -- Highlight patterns (colors)
  { import = 'lazyvim.plugins.extras.util.mini-hipatterns' },
  {
    -- Trailing whitespace, in red
    --
    -- `listchars` already marks it with a `\u00b7`, and that is easy to read past
    -- in a diff full of them. A background colour is not. The extra above
    -- brings the plugin in, so only the one highlighter is added here.
    'nvim-mini/mini.hipatterns',
    init = function()
      vim.api.nvim_create_autocmd('InsertLeave', {
        group = vim.api.nvim_create_augroup(
          'dy_trailing_whitespace',
          { clear = true }
        ),
        desc = 'Re-check the line just left for trailing whitespace',
        callback = function()
          -- Nothing edits the line on the way out of insert mode, so the
          -- match held back below is never asked for again on its own. The
          -- lookup stays in `package.loaded`: this must not be what loads
          -- the plugin.
          local hipatterns = package.loaded['mini.hipatterns']
          if not hipatterns then return end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          pcall(hipatterns.update, 0, line, line)
        end,
      })
    end,
    opts = function(_, opts)
      opts.highlighters = opts.highlighters or {}
      opts.highlighters.trailing_whitespace = {
        pattern = '%f[%s]%s+$',
        group = function(buf_id, _, data)
          -- The space after the word being typed is the cursor's own wake,
          -- not something left behind, so the line being edited is spared
          -- until insert mode is over.
          if
            vim.startswith(vim.api.nvim_get_mode().mode, 'i')
            and buf_id == vim.api.nvim_get_current_buf()
            and data.line == vim.api.nvim_win_get_cursor(0)[1]
          then
            return nil
          end
          return 'DyTrailingWhitespace'
        end,
      }
      return opts
    end,
  },
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
        filetypes = markview_filetypes,
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
