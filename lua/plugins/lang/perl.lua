return vim.list_contains(DyNeo.enabled_languages, 'perl')
    and {
      {
        -- Debug adapter & configurations. mason-nvim-dap does not know
        -- `perl-debug-adapter`, so it neither maps it to its package nor sets
        -- it up once installed; `config.languages` names the package, and the
        -- adapter is registered here. It needs `PadWalker` from CPAN.
        'mfussenegger/nvim-dap',
        optional = true,
        opts = function()
          local dap = require('dap')
          dap.adapters.perl = {
            type = 'executable',
            command = 'perl-debug-adapter',
            args = {},
          }
          dap.configurations.perl = {
            {
              type = 'perl',
              request = 'launch',
              name = 'Launch file',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
          }
        end,
      },
    }
  or {}
