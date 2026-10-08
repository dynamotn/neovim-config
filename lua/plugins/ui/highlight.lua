local languages_list = require('config.languages')
local markview_filetypes = { 'Avante' }
vim.list_extend(markview_filetypes, languages_list.markdown.filetypes)
vim.list_extend(markview_filetypes, languages_list.html.filetypes)
vim.list_extend(markview_filetypes, languages_list.typst.filetypes)
vim.list_extend(markview_filetypes, languages_list.yaml.filetypes)

return {
  {
    -- Highlight patterns: hex colours, Tailwind classes and trailing
    -- whitespace
    --
    -- `listchars` already marks trailing whitespace with a `\u00b7`, and that
    -- is easy to read past in a diff full of them. A red background is not.
    'nvim-mini/mini.hipatterns',
    event = 'LazyFile',
    keys = {
      {
        '<leader>uH',
        function() require('mini.hipatterns').toggle() end,
        desc = 'Toggle Color Highlights',
      },
    },
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
    opts = function()
      local hi = require('mini.hipatterns')
      local opts = {
        -- Not an option of mini.hipatterns: `config` below turns it into the
        -- Tailwind highlighter
        tailwind = {
          enabled = true,
          ft = {
            'astro',
            'css',
            'heex',
            'html',
            'html-eex',
            'javascript',
            'javascriptreact',
            'rust',
            'svelte',
            'typescript',
            'typescriptreact',
            'vue',
          },
          -- `full` paints the whole class, `compact` only its colour
          style = 'full',
        },
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
          shorthand = {
            pattern = '()#%x%x%x()%f[^%x%w]',
            group = function(_, _, data)
              ---@type string
              local match = data.full_match
              if match == '#add' then return end
              local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
              local hex_color = '#' .. r .. r .. g .. g .. b .. b

              return MiniHipatterns.compute_hex_color_group(hex_color, 'bg')
            end,
            extmark_opts = { priority = 2000 },
          },
        },
      }
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
    config = function(_, opts)
      if type(opts.tailwind) == 'table' and opts.tailwind.enabled then
        opts.highlighters.tailwind =
          require('util.mini').tailwind_highlighter(opts.tailwind)
      end
      require('mini.hipatterns').setup(opts)
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
    keys = {
      { '<leader>uM', '<cmd>Markview toggle<cr>', desc = 'Toggle Markview' },
    },
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
    config = function(_, opts)
      local presets = require('markview.presets')
      require('markview').setup(vim.tbl_deep_extend('force', opts, {
        markdown = {
          headings = presets.headings.glow,
        },
      }))

      -- Parsers are installed the first time their filetype opens, so on that
      -- first open there is none yet, and markview fails to start treesitter
      -- on the buffer. `preview.condition` cannot say no: markview turns a
      -- `false` from it into `nil`. So the buffer is left alone here instead,
      -- and markview attaches when it is reloaded once the parser lands.
      local actions = require('markview.actions')
      local attach = actions.attach
      actions.attach = function(buffer, ...)
        local buf = (buffer == nil or buffer == 0)
            and vim.api.nvim_get_current_buf()
          or buffer
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        local ok, added = pcall(vim.treesitter.language.add, lang or '')
        if not (lang and ok and added) then return end
        return attach(buffer, ...)
      end
    end,
  },
}
