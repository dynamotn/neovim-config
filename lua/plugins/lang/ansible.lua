local language = require('config.languages').ansible

return vim.list_contains(_G.enabled_languages, 'ansible')
    and {
      {
        -- Working with playbook
        'mfussenegger/nvim-ansible',
        ft = language.filetypes,
        keys = {
          {
            '<leader>ta',
            function() require('ansible').run() end,
            ft = language.filetypes,
            desc = 'Ansible Run Playbook/Role',
            silent = true,
          },
        },
      },
    }
  or {}
