local language = require('config.languages').typst

return vim.list_contains(_G.enabled_languages, 'typst')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            tinymist = {
              keys = {
                {
                  '<leader>cP',
                  function()
                    local buf_name = vim.api.nvim_buf_get_name(0)
                    LazyVim.lsp.execute({
                      command = 'tinymist.pinMain',
                      arguments = { buf_name },
                    })
                  end,
                  ft = language.filetypes,
                  desc = 'Pin main file',
                },
              },
              single_file_support = true, -- Fixes LSP attachment in non-Git directories
              settings = {
                formatterMode = 'typstyle',
              },
            },
          },
        },
      },
      {
        -- Typst preview
        'chomosuke/typst-preview.nvim',
        ft = language.filetypes,
        cmd = { 'TypstPreview', 'TypstPreviewToggle', 'TypstPreviewUpdate' },
        keys = {
          {
            '<leader>cp',
            ft = language.filetypes,
            '<cmd>TypstPreviewToggle<cr>',
            desc = 'Toggle Typst Preview',
          },
        },
        opts = {
          dependencies_bin = {
            tinymist = 'tinymist',
          },
        },
      },
      {
        -- Comment
        'folke/ts-comments.nvim',
        opts = {
          lang = {
            typst = { '// %s', '/* %s */' },
          },
        },
      },
    }
  or {}
