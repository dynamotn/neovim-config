local language = require('config.languages').clojure
local cmp_util = require('util.cmp')

return vim.list_contains(_G.enabled_languages, 'clojure')
    and {
      {
        -- S-expression editing
        'julienvincent/nvim-paredit',
        ft = language.filetypes,
        opts = {},
      },
      {
        -- Colorize the escape sequences the REPL sends to Conjure's log
        -- buffer, which would otherwise be printed raw.
        'm00qek/baleia.nvim',
        ft = language.filetypes,
        opts = { line_starts_at = 3 },
        config = function(_, opts)
          vim.g.conjure_baleia = require('baleia').setup(opts)
          vim.api.nvim_create_user_command(
            'BaleiaColorize',
            function() vim.g.conjure_baleia.once(vim.api.nvim_get_current_buf()) end,
            { bang = true }
          )
          vim.api.nvim_create_user_command(
            'BaleiaLogs',
            vim.g.conjure_baleia.logger.show,
            { bang = true }
          )
        end,
      },
      {
        -- REPL
        'Olical/conjure',
        ft = language.filetypes,
        dependencies = { 'baleia.nvim' },
        config = function(_, _) require('conjure.main').main() end,
        init = function()
          -- baleia paints the escape sequences, so leave them in the log
          vim.g['conjure#log#strip_ansi_escape_sequences_line_limit'] = 0

          -- the LSP answers `K` and `gd` better than Conjure does, so its
          -- own versions move to the local leader
          vim.g['conjure#mapping#doc_word'] = 'K'
          vim.g['conjure#mapping#def_word'] = 'gd'

          vim.api.nvim_create_autocmd('BufWinEnter', {
            group = vim.api.nvim_create_augroup('dy_conjure_log', {}),
            pattern = 'conjure-log-*',
            callback = function(event)
              vim.diagnostic.enable(false, { bufnr = event.buf })
              if vim.g.conjure_baleia then
                vim.g.conjure_baleia.automatically(event.buf)
              end
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
        -- Completion from the running REPL
        'blink.cmp',
        dependencies = {
          'PaterJason/cmp-conjure',
          ft = language.filetypes,
          init = function()
            _G.completion_sources =
              vim.tbl_extend('force', _G.completion_sources, {
                conjure = '「REPL」',
              })
          end,
        },
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
