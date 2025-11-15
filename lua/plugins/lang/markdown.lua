local language = require('config.languages').markdown
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'markdown')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            tailwindcss = {
              filetypes_exclude = { 'markdown' },
            },
            marksman = {},
            vale_ls = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Preview markdown
        'toppair/peek.nvim',
        ft = language.filetypes,
        build = 'deno task --quiet build:fast',
        enabled = _G.used_full_plugins or vim.fn.executable('deno') == 1,
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
        -- Obsidian
        'obsidian-nvim/obsidian.nvim',
        ft = language.filetypes,
        enabled = _G.used_full_plugins or _G.enabled_plugins.obsidian,
        opts = {
          workspaces = _G.obsidian.vaults(),
          ui = { enable = false },
        },
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
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
            -- Not need to have compat for obsidian.nvim, because it is already handled in obsidian.nvim
            -- compat = { 'obsidian' },
            per_filetype = {
              markdown = cmp_util.sources('markdown'),
            },
          },
        },
      },
      {
        -- Todo notes
        'folke/snacks.nvim',
        keys = {
          {
            '<leader>T',
            function()
              ---@diagnostic disable-next-line: missing-fields
              Snacks.scratch({
                icon = ' ',
                name = 'Todo',
                ft = 'markdown',
                file = _G.obsidian.todo_path(),
              })
            end,
            desc = 'Todo List',
          },
        },
      },
      {
        -- Linter config
        'mfussenegger/nvim-lint',
        opts = function()
          local lint = require('lint')
          lint.linters['markdownlint-cli2'].args = {
            '--config',
            '~/.config/markdownlint/config.yaml',
          }
        end,
      },
    }
  or {}
