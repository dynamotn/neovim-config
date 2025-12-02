return {
  {
    -- I want to self-managed LSP by my way
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile', 'BufWritePre' },
    dependencies = {
      {
        -- Auto install LSP servers with needed
        'mason-org/mason-lspconfig.nvim',
        dependencies = { 'mason-org/mason.nvim' },
      },
      {
        -- Workspace diagnostics
        -- NOTE: will be removed in neovim v0.12.0
        'artemave/workspace-diagnostics.nvim',
        keys = {
          {
            '<leader>xw',
            function()
              for _, client in ipairs(vim.lsp.get_clients()) do
                if vim.tbl_get(client.config, 'filetypes') then
                  require('workspace-diagnostics').populate_workspace_diagnostics(
                    client,
                    0
                  )
                end
              end
            end,
            mode = { 'n' },
            desc = 'Workspace Diagnostics',
          },
        },
      },
    },
    opts = function(_, opts)
      opts.servers.sonarlint = {
        filetypes = { '*' },
      }
      opts.setup = {}
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- setup auto format
      LazyVim.format.register(LazyVim.lsp.formatter())

      -- setup keymaps
      for server, server_opts in pairs(opts.servers) do
        if type(server_opts) == 'table' and server_opts.keys then
          require('lazyvim.plugins.lsp.keymaps').set(
            { name = server ~= '*' and server or nil },
            server_opts.keys
          )
        end
      end

      -- inlay hints
      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on(
          { method = 'textDocument/inlayHint' },
          function(buffer)
            if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ''
              and not vim.tbl_contains(
                opts.inlay_hints.exclude,
                vim.bo[buffer].filetype
              )
            then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
          end
        )
      end

      -- folds
      if opts.folds.enabled then
        Snacks.util.lsp.on({ method = 'textDocument/foldingRange' }, function()
          if LazyVim.set_default('foldmethod', 'expr') then
            LazyVim.set_default('foldexpr', 'v:lua.vim.lsp.foldexpr()')
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Snacks.util.lsp.on(
          { method = 'textDocument/codeLens' },
          function(buffer)
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd(
              { 'BufEnter', 'CursorHold', 'InsertLeave' },
              {
                buffer = buffer,
                callback = vim.lsp.codelens.refresh,
              }
            )
          end
        )
      end

      -- diagnostics signs and virtual text
      if type(opts.diagnostics.signs) ~= 'boolean' then
        for severity, icon in pairs(opts.diagnostics.signs.text) do
          local name =
            vim.diagnostic.severity[severity]:lower():gsub('^%l', string.upper)
          name = 'DiagnosticSign' .. name
          vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
        end
      end
      if
        type(opts.diagnostics.virtual_text) == 'table'
        and opts.diagnostics.virtual_text.prefix == 'icons'
      then
        opts.diagnostics.virtual_text.prefix = function(diagnostic)
          local icons = LazyVim.config.icons.diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return '●'
        end
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- default capabilities
      if opts.capabilities then
        opts.servers['*'] =
          vim.tbl_deep_extend('force', opts.servers['*'] or {}, {
            capabilities = opts.capabilities,
          })
      end
      if opts.servers['*'] then vim.lsp.config('*', opts.servers['*']) end

      -- get all the servers that are available through mason-lspconfig
      local mason_configs =
        require('mason-lspconfig').get_mappings().lspconfig_to_package
      local ensure_installed = {} ---@type string[]
      local function configure(server, enabled, name, language)
        if server == '*' then return end
        local server_opts = opts.servers[server] or {}
        server_opts = server_opts == true and {}
          or (not server_opts) and { enabled = false }
          or server_opts--[[@as vim.lsp.Config]]
        if enabled == false then return end

        -- automatic install lsp servers
        if mason_configs[server] then
          -- install server of language in bundle languages
          if vim.list_contains(_G.bundle_languages, name) then
            table.insert(ensure_installed, server)
          end
          -- lazy install server of language not in bundle languages
          if vim.list_contains(_G.enabled_languages, name) then
            vim.api.nvim_create_autocmd({ 'FileType' }, {
              pattern = language.filetypes,
              group = vim.api.nvim_create_augroup(
                'mason_lsp_' .. name .. '_' .. server,
                {}
              ),
              callback = function()
                local server_package = mason_configs[server]
                if
                  server_package ~= nil
                  and not require('mason-registry').is_installed(server_package)
                then
                  require('mason.api.command').MasonInstall({ server_package })
                end
              end,
            })
          end
        end

        local setup = opts.setup[server] or opts.setup['*']
        if setup and setup(server, server_opts) then return end
        vim.lsp.config[server] =
          vim.tbl_deep_extend('force', vim.lsp.config[server], server_opts)

        -- manually enable if this is a server that cannot be installed with mason-lspconfig
        if not mason_configs[server] then
          vim.lsp.enable(server)
          return
        end
      end

      -- get all the servers that are available through my config
      for name, language in pairs(require('config.languages')) do
        for _, lsp_server in ipairs(language.lsp_servers or {}) do
          local server
          if type(lsp_server) == 'table' then
            server = lsp_server[1]
            configure(server, lsp_server.enabled or false, name, language)
          else
            server = lsp_server
            configure(server, true, name, language)
          end
        end
      end

      require('mason-lspconfig').setup({
        automatic_installation = false,
        ensure_installed = vim.tbl_deep_extend(
          'force',
          LazyVim.dedup(ensure_installed),
          LazyVim.opts('mason-lspconfig.nvim').ensure_installed or {}
        ),
      })
    end,
  },
}
