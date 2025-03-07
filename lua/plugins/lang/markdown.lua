local language = require('config.languages').markdown
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'markdown')
    and {
      {
        -- Custom dial
        'monaqa/dial.nvim',
        opts = {
          groups = {
            markdown = language.dial(),
          },
        },
      },
      {
        -- Preview markdown
        'toppair/peek.nvim',
        ft = language.filetypes,
        build = 'deno task --quiet build:fast',
        enabled = vim.fn.executable('deno') == 1 or _G.used_full_plugins,
        keys = {
          {
            '<leader>cp',
            function() require('peek').open() end,
            ft = language.filetypes,
            desc = 'Markdown Preview',
          },
        },
        opts = {
          app = 'browser',
        },
      },
      {
        -- Highlight for headlines, codeblocks
        'MeanderingProgrammer/render-markdown.nvim',
        ft = language.filetypes,
        opts = {
          code = {
            sign = false,
            width = 'block',
            right_pad = 1,
          },
          heading = {
            sign = false,
            icons = {},
          },
          checkbox = {
            enabled = false,
          },
        },
        config = function(_, opts)
          require('render-markdown').setup(opts)
          Snacks.toggle({
            name = 'Render Markdown',
            get = function() return require('render-markdown.state').enabled end,
            set = function(enabled)
              local m = require('render-markdown')
              if enabled then
                m.enable()
              else
                m.disable()
              end
            end,
          }):map('<leader>um')
        end,
      },
      {
        -- Obsidian
        'epwalsh/obsidian.nvim',
        ft = language.filetypes,
        enabled = _G.enabled_plugins.obsidian or _G.used_full_plugins,
        opts = {
          workspaces = _G.obsidian_vaults,
        },
        init = function()
          _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
            obsidian = '「NOTE」',
          })
        end,
      },
      {
        -- Completion
        'blink.cmp',
        dependencies = { 'obsidian.nvim' },
        opts = {
          sources = {
            compat = { 'obsidian' },
            per_filetype = {
              markdown = cmp_util.per_filetype_with_predefined_sources({ 'obsidian' }),
            },
          },
        },
      },
    }
  or {}
