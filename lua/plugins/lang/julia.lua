local language = require('config.languages').julia
local cmp_util = require('util.cmp')

return vim.list_contains(DyNeo.enabled_languages, 'julia')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            julials = {
              settings = {
                -- the defaults the Julia VS Code extension uses
                julia = {
                  completionmode = 'qualify',
                  lint = { missingrefs = 'none' },
                },
              },
            },
          },
        },
      },
      {
        -- Julia writes `α` and `∈` as source, and they are typed as `\alpha`
        -- and `\in`, so the completion menu has to know the LaTeX names. Its
        -- own spec rather than a dependency of blink.cmp, which would load
        -- its symbol tables on the first `InsertEnter` of any buffer.
        'kdheepak/cmp-latex-symbols',
        ft = language.filetypes,
        init = function()
          DyNeo.completion_sources =
            vim.tbl_extend('force', DyNeo.completion_sources, {
              latex_symbols = '「TEX」',
            })
        end,
      },
      {
        'blink.cmp',
        opts = {
          sources = {
            compat = { 'latex_symbols' },
            per_filetype = {
              julia = cmp_util.sources('julia'),
            },
            providers = {
              latex_symbols = {
                kind = 'LatexSymbols',
                async = true,
                -- 0: offer both the LaTeX name and the symbol itself
                opts = { strategy = 0 },
              },
            },
          },
        },
      },
    }
  or {}
