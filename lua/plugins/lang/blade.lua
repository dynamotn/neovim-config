local language = require('config.languages').blade
local cmp_util = require('util.cmp')

-- Laravel's tooling reaches across the whole project, not just the templates
local filetypes = vim.list_extend(vim.deepcopy(language.filetypes), { 'php' })

return vim.list_contains(_G.enabled_languages, 'blade')
    and {
      {
        -- Artisan, routes, views and the rest of the project, as pickers
        'adalessa/laravel.nvim',
        ft = filetypes,
        cmd = 'Laravel',
        dependencies = {
          'MunifTanjim/nui.nvim',
          'nvim-lua/plenary.nvim',
          'nvim-neotest/nvim-nio',
        },
        opts = {
          features = {
            pickers = { provider = 'snacks' },
          },
        },
        keys = {
          {
            '<localleader>ll',
            function() Laravel.pickers.laravel() end,
            desc = 'Laravel picker',
          },
          {
            '<localleader>la',
            function() Laravel.pickers.artisan() end,
            desc = 'Artisan picker',
          },
          {
            '<localleader>lr',
            function() Laravel.pickers.routes() end,
            desc = 'Routes picker',
          },
          {
            '<localleader>lm',
            function() Laravel.pickers.make() end,
            desc = 'Make picker',
          },
          {
            '<localleader>lc',
            function() Laravel.pickers.commands() end,
            desc = 'Commands picker',
          },
          {
            '<localleader>lo',
            function() Laravel.pickers.resources() end,
            desc = 'Resources picker',
          },
          {
            '<localleader>lh',
            function() Laravel.run('artisan docs') end,
            desc = 'Laravel documentation',
          },
        },
      },
      {
        -- `gf` on a view name, a route or a component
        'ricardoramirezr/blade-nav.nvim',
        ft = filetypes,
        -- Kept off the `blink.cmp` spec: lazy.nvim keeps a single `init` per
        -- plugin, and this one would replace the labels set in completion.lua
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              ['blade-nav'] = '「BLADE」',
              laravel = '「LARAVEL」',
            })
        end,
      },
      {
        -- Completion for view names and Laravel's own symbols
        'blink.cmp',
        dependencies = { 'laravel.nvim', 'blade-nav.nvim' },
        opts = {
          sources = {
            compat = { 'laravel' },
            per_filetype = {
              blade = cmp_util.sources('blade'),
            },
            providers = {
              ['blade-nav'] = {
                name = 'blade-nav',
                -- ships a blink source of its own, so no compat shim
                module = 'blade-nav.blink',
              },
              laravel = {
                name = 'laravel',
                module = 'blink.compat.source',
                score_offset = 95,
              },
            },
          },
        },
      },
    }
  or {}
