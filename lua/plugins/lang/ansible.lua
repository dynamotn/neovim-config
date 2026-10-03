local language = require('config.languages').ansible

--- The Python of Mason's ansible-lint, when ansible itself is not on `$PATH`
---
--- The server runs `ansible-config dump` as it starts and reports a failure
--- for every file it opens when that is missing. Mason installs ansible-lint
--- into a virtualenv that carries ansible-core along with it, but links only
--- `ansible-lint` into `$MASON/bin`. Naming that virtualenv's interpreter
--- makes the server put its `bin/` ahead of `$PATH`, the same as activating
--- it would.
---@return string?
local function mason_ansible_python()
  if vim.fn.executable('ansible-config') == 1 then return nil end
  local python = vim.fn.stdpath('data')
    .. '/mason/packages/ansible-lint/venv/bin/python'
  return vim.uv.fs_stat(python) and python or nil
end

return vim.list_contains(_G.enabled_languages, 'ansible')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            ansiblels = {
              settings = {
                ansible = {
                  python = { interpreterPath = mason_ansible_python() },
                },
              },
            },
          },
        },
      },
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
