local language = require('config.languages').r
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'r')
    and {
      {
        -- R console in a split, and everything that talks to it
        'R-nvim/R.nvim',
        -- the plugin sets its own filetype hooks up, so it loads eagerly
        lazy = false,
        -- Every R buffer asks R for its `nvimcom` version, and fails when
        -- there is no R to ask.
        cond = function() return vim.fn.executable('R') == 1 end,
        opts = {
          R_args = { '--quiet', '--no-save' },
          pdfviewer = '',
          hook = {
            on_filetype = function()
              vim.keymap.set(
                'n',
                '<Enter>',
                '<Plug>RDSendLine',
                { buffer = true, desc = 'Send line to R' }
              )
              vim.keymap.set(
                'x',
                '<Enter>',
                '<Plug>RSendSelection',
                { buffer = true, desc = 'Send selection to R' }
              )
              require('which-key').add({
                buffer = true,
                mode = { 'n', 'x' },
                { '<localleader>a', group = 'all' },
                { '<localleader>b', group = 'between marks' },
                { '<localleader>c', group = 'chunks' },
                { '<localleader>f', group = 'functions' },
                { '<localleader>g', group = 'goto' },
                { '<localleader>i', group = 'install' },
                { '<localleader>k', group = 'knit' },
                { '<localleader>p', group = 'paragraph' },
                { '<localleader>q', group = 'quarto' },
                { '<localleader>r', group = 'r general' },
                { '<localleader>s', group = 'split or send' },
                { '<localleader>t', group = 'terminal' },
                { '<localleader>v', group = 'view' },
              })
            end,
          },
        },
        config = function(_, opts)
          vim.g.rout_follow_colorscheme = true
          require('r').setup(opts)
          require('r.pdf.generic').open = vim.ui.open
        end,
      },
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            r_language_server = {
              root_markers = { 'DESCRIPTION', 'NAMESPACE', '.Rbuildignore' },
            },
          },
        },
      },
      {
        -- Completion out of the running R session. Its own spec rather than a
        -- dependency of blink.cmp, which would load it on the first
        -- `InsertEnter` of any buffer.
        'R-nvim/cmp-r',
        ft = language.filetypes,
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              cmp_r = '「R」',
            })
        end,
      },
      {
        'blink.cmp',
        opts = {
          sources = {
            compat = { 'cmp_r' },
            per_filetype = {
              r = cmp_util.sources('r'),
            },
          },
        },
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'shunsambongi/neotest-testthat',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-testthat'] = {},
          },
        },
      },
    }
  or {}
