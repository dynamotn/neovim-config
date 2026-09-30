return {
  {
    'mason-org/mason.nvim',
    opts = {
      -- Disable default tools
      ensure_installed = {},
      -- Add custom registries
      registries = {
        -- 'file:' .. vim.fn.stdpath('config') .. '/mason-registry',
        -- HACK: I can't use file method because it's lazy load and slow to
        -- append to mason registry and affect to initialize
        -- my custom LSP servers
        'lua:tools.mason-registry',
        'github:mason-org/mason-registry',
      },
    },
    keys = {
      {
        '<leader>m',
        '<cmd>Mason<cr>',
        desc = 'Mason',
      },
    },
    init = function()
      -- `vale` ships without any style: until `vale sync` has pulled the
      -- packages its config asks for, every run dies on a missing StylesPath,
      -- so the sync follows the install straight away.
      require('lazyvim.util').on_load('mason.nvim', function()
        require('mason-registry'):on('package:install:success', function(pkg)
          if pkg.name ~= 'vale' then return end
          vim.schedule(function()
            local vale = vim.fn.exepath('vale')
            if vale == '' then return end
            local command = { vale }
            if vim.env.VALE_CONFIG_PATH then
              vim.list_extend(command, { '--config', vim.env.VALE_CONFIG_PATH })
            end
            table.insert(command, 'sync')
            vim.notify('Syncing vale styles', vim.log.levels.INFO, {
              title = 'mason.nvim',
            })
            vim.system(command, { text = true }, function(result)
              vim.schedule(function()
                if result.code == 0 then
                  vim.notify('Synced vale styles', vim.log.levels.INFO, {
                    title = 'mason.nvim',
                  })
                else
                  vim.notify(
                    'vale sync failed:\n' .. (result.stderr or result.stdout),
                    vim.log.levels.ERROR,
                    { title = 'mason.nvim' }
                  )
                end
              end)
            end)
          end)
        end)
      end)
    end,
  },
}
