local language = require('config.languages').haskell

-- `haskell-tools` also drives the project files that sit next to the source
local filetypes = vim.list_extend(vim.deepcopy(language.filetypes), {
  'cabal',
  'cabalproject',
})

return vim.list_contains(DyNeo.enabled_languages, 'haskell')
    and {
      {
        -- Toolbox: REPL, hoogle, codelens, and the Haskell LSP
        'mrcjkb/haskell-tools.nvim',
        -- Follow the branch on either channel, not the newest tag `stable`
        -- would pick. The plugin's README advises a `^10` range instead.
        version = false,
        ft = filetypes,
        keys = {
          {
            '<localleader>e',
            '<cmd>Haskell hls evalAll<cr>',
            ft = language.filetypes,
            desc = 'Evaluate All',
          },
          {
            '<localleader>h',
            function() require('haskell-tools').hoogle.hoogle_signature() end,
            ft = language.filetypes,
            desc = 'Hoogle Signature',
          },
          {
            '<localleader>r',
            function() require('haskell-tools').repl.toggle() end,
            ft = language.filetypes,
            desc = 'REPL (Package)',
          },
          {
            '<localleader>R',
            function()
              require('haskell-tools').repl.toggle(vim.api.nvim_buf_get_name(0))
            end,
            ft = language.filetypes,
            desc = 'REPL (Buffer)',
          },
        },
      },
      {
        -- `haskell-tools` starts `hls` itself, so keep lspconfig from
        -- starting a second one; the entry in `config.languages` is what
        -- installs and documents the server.
        'neovim/nvim-lspconfig',
        opts = {
          setup = {
            hls = function() return true end,
          },
        },
      },
      {
        -- Snippets
        'mrcjkb/haskell-snippets.nvim',
        ft = filetypes,
        dependencies = { 'L3MON4D3/LuaSnip' },
        config = function()
          require('luasnip').add_snippets(
            'haskell',
            require('haskell-snippets').all,
            { key = 'haskell' }
          )
        end,
      },
      {
        -- Test adapter
        'nvim-neotest/neotest',
        dependencies = {
          'mrcjkb/neotest-haskell',
          ft = language.filetypes,
        },
        opts = {
          adapters = {
            ['neotest-haskell'] = {},
          },
        },
      },
    }
  or {}
