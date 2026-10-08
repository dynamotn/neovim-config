return {
  {
    'mason-org/mason.nvim',
    opts = {
      -- Disable default tools
      ensure_installed = {},
      -- Hold a freshly published package back for a week before it may be
      -- installed, the same quarantine `~/.npmrc`, the bun and pnpm
      -- configurations and `uv.toml` apply. mason has no setting for it, so
      -- `tools.mason-quarantine` ages the registry snapshot every package
      -- version is pinned in; see the comment at the top of that module. It
      -- stands alone, asking mason's own providers itself: any provider
      -- listed after it would answer whenever the quarantine fails.
      providers = {
        'tools.mason-quarantine',
      },
      -- Socket Firewall stands between every npm and PyPI install and the
      -- registry, and turns down a package known to be malicious -- the half
      -- of the problem a week of quarantine cannot answer, since a package
      -- can be caught after that week as easily as within it. `sfw` is
      -- installed and updated by Mason itself; swapson already hands it the
      -- installs it routes through bun and uv.
      --
      -- Worth knowing what it does: `sfw` is a local proxy, and the installer
      -- it wraps runs with `NODE_TLS_REJECT_UNAUTHORIZED=0`, trusting the
      -- proxy's certificate instead of the registry's. The verification moves
      -- to `sfw` rather than disappearing, but it does move.
      firewall = {
        enabled = true,
        auto_managed = true,
      },
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
