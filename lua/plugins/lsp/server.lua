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
      {
        -- Route npm and pip through bun and uv
        'dynamotn/swapson.nvim',
        opts = {
          npm = {
            enabled = true,
            tool = 'bun',
            patch_version_lookup = true,
          },
          pip = {
            enabled = true,
            tool = 'uv',
          },
        },
      },
    },
    opts = function(_, opts)
      opts.setup = opts.setup or {}
      opts.folds.enabled = false
      opts.servers['*'].before_init = function(_, config)
        local codesettings = require('codesettings')
        codesettings.with_local_settings(config.name, config)
      end
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

      -- get all the servers that are available through my config
      local languages = require('config.languages')

      -- Every filetype whose language declares a server, keyed by server. A
      -- language entry naming a server is the only place that says the server
      -- belongs to those filetypes, so without this a bare `harper_ls = {}` in
      -- a language's plugin spec attaches nothing, and the one spec that does
      -- set `filetypes` narrows the server down to its own language.
      local declared_filetypes = {} ---@type table<string, string[]>
      for _, language in pairs(languages) do
        -- '*' and '_' are pseudo filetypes, not something a server attaches to
        if
          not vim.list_contains(language.filetypes, '*')
          and not vim.list_contains(language.filetypes, '_')
        then
          for _, lsp_server in ipairs(language.lsp_servers or {}) do
            local server = type(lsp_server) == 'table' and lsp_server[1]
              or lsp_server--[[@as string]]
            declared_filetypes[server] = vim.list_extend(
              declared_filetypes[server] or {},
              language.filetypes
            )
          end
        end
      end

      ---@param server string
      ---@param enabled? fun(bufnr: integer): boolean
      ---@param name string
      ---@param language DyLangSpec
      local function configure(server, enabled, name, language)
        if server == '*' then return end
        local server_opts = opts.servers[server] or {}
        server_opts = server_opts == true and {}
          or (not server_opts) and { enabled = false }
          or server_opts--[[@as vim.lsp.Config]]

        -- Widen the server to every filetype that declares it, starting from
        -- whatever its plugin spec asked for, or its shipped default when the
        -- spec is silent. Copied, because `opts.servers` is shared between the
        -- calls this function gets for each language.
        if declared_filetypes[server] then
          local filetypes = vim.deepcopy(
            server_opts.filetypes
              or (vim.lsp.config[server] or {}).filetypes
              or {}
          )
          server_opts = vim.tbl_extend('force', server_opts, {
            filetypes = LazyVim.dedup(
              vim.list_extend(filetypes, declared_filetypes[server])
            ),
          })
        end

        -- A server that only suits some buffers is still configured up front,
        -- and decides per buffer instead: `vim.lsp` only attaches once
        -- `root_dir` hands a directory to `on_dir`, so withholding the call is
        -- how a buffer is turned down. Deciding once at startup would pin the
        -- answer to whatever directory Neovim was launched from.
        if enabled then
          local base = vim.lsp.config[server] or {}
          local root_dir = server_opts.root_dir or base.root_dir
          local root_markers = server_opts.root_markers or base.root_markers
          server_opts = vim.tbl_extend('force', server_opts, {
            root_dir = function(bufnr, on_dir)
              if not enabled(bufnr) then return end
              if type(root_dir) == 'function' then
                return root_dir(bufnr, on_dir)
              end
              -- A custom `root_dir` makes `vim.lsp` skip `root_markers`, so
              -- they are resolved here in its place.
              on_dir(
                root_dir
                  or (root_markers and vim.fs.root(bufnr, root_markers))
                  or nil
              )
            end,
          })
        end

        -- automatic install lsp servers
        if mason_configs[server] then
          -- install server of language in bundle languages
          if vim.list_contains(_G.bundle_languages, name) then
            table.insert(ensure_installed, server)
          end
          -- lazy install server of language not in bundle languages
          if vim.list_contains(_G.enabled_languages, name) then
            require('util.lazy_install').on_filetype(
              language.filetypes,
              function(args)
                local lsp_config = vim.lsp.config[server]
                if lsp_config == nil then return end
                if enabled and not enabled(args.buf) then return end
                if
                  lsp_config.filetypes == nil
                  or vim.tbl_contains(lsp_config.filetypes, args.match)
                then
                  local server_package = mason_configs[server]
                  if
                    server_package ~= nil
                    and not require('mason-registry').is_installed(
                      server_package
                    )
                  then
                    require('mason.api.command').MasonInstall({ server_package })
                  end
                end
              end
            )
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

      for name, language in pairs(languages) do
        for _, lsp_server in ipairs(language.lsp_servers or {}) do
          local server
          if type(lsp_server) == 'table' then
            server = lsp_server[1]
            configure(server, lsp_server.enabled, name, language)
          else
            server = lsp_server
            configure(server, nil, name, language)
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
