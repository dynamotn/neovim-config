local language = require('config.languages').clojure
local cmp_util = require('util.cmp')

return vim.list_contains(DyNeo.enabled_languages, 'clojure')
    and {
      {
        -- S-expression editing
        'julienvincent/nvim-paredit',
        ft = language.filetypes,
        opts = {},
      },
      {
        -- REPL
        'Olical/conjure',
        ft = language.filetypes,
        config = function(_, _) require('conjure.main').main() end,
        init = function()
          -- Conjure ships a client for a score of languages and, once loaded
          -- by a Clojure buffer, takes every later JavaScript, Python, Lua or
          -- Rust buffer too: it starts a REPL for it and maps the local
          -- leader over it. It is here for Clojure only.
          vim.g['conjure#filetypes'] = language.filetypes

          -- the LSP answers `K` and `gd` better than Conjure does, so its
          -- own versions move to the local leader
          vim.g['conjure#mapping#doc_word'] = 'K'
          vim.g['conjure#mapping#def_word'] = 'gd'

          vim.api.nvim_create_autocmd('BufWinEnter', {
            group = vim.api.nvim_create_augroup('dy_conjure_log', {}),
            pattern = 'conjure-log-*',
            callback = function(event)
              vim.diagnostic.enable(false, { bufnr = event.buf })
              vim.keymap.set(
                { 'n', 'x' },
                '[c',
                [[<Cmd>call search('^; -\+$', 'bw')<CR>]],
                {
                  silent = true,
                  buffer = event.buf,
                  desc = 'Previous evaluation output',
                }
              )
              vim.keymap.set(
                { 'n', 'x' },
                ']c',
                [[<Cmd>call search('^; -\+$', 'w')<CR>]],
                {
                  silent = true,
                  buffer = event.buf,
                  desc = 'Next evaluation output',
                }
              )
            end,
          })
        end,
      },
      {
        -- Completion from the running REPL. Its own spec rather than a
        -- dependency of blink.cmp, which would load it -- and conjure with
        -- it -- on the first `InsertEnter` of any buffer.
        'PaterJason/cmp-conjure',
        ft = language.filetypes,
        init = function()
          DyNeo.completion_sources =
            vim.tbl_extend('force', DyNeo.completion_sources, {
              conjure = '「REPL」',
            })
        end,
      },
      {
        'blink.cmp',
        opts = {
          sources = {
            compat = { 'conjure' },
            per_filetype = {
              clojure = cmp_util.sources('clojure'),
            },
          },
        },
      },
    }
  or {}
