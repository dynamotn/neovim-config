return {
  {
    -- I want to self-managed LSP by my way
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile', 'BufWritePre' },
    dependencies = {
      -- Workspace diagnostics
      -- NOTE: will be removed in neovim v0.12.0
      'artemave/workspace-diagnostics.nvim',
    },
    opts = function()
      ---@class DyLspOpts: PluginLspOpts
      ---@field servers table<string, table>
      ---@field setup table<string, fun(server:string, opts:table):boolean?>
      return {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = 'if_many',
            prefix = '●',
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
            },
          },
        },
        -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the inlay hints.
        inlay_hints = {
          enabled = true,
          exclude = { 'vue' }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the code lenses.
        codelens = {
          enabled = false,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the LazyVim formatter,
        -- but can be also overridden when specified
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        servers = {
          sonarlint = {},
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        setup = {},
      }
    end,
    ---@param opts DyLspOpts
    config = function(_, opts)
      -- setup autoformat
      LazyVim.format.register(LazyVim.lsp.formatter())

      -- setup keymaps
      LazyVim.lsp.on_attach(function(client, buffer)
        require('lazyvim.plugins.lsp.keymaps').on_attach(client, buffer)
        require('workspace-diagnostics').populate_workspace_diagnostics(
          client,
          buffer
        )
      end)

      LazyVim.lsp.setup()
      LazyVim.lsp.on_dynamic_capability(
        require('lazyvim.plugins.lsp.keymaps').on_attach
      )

      -- diagnostics signs
      if type(opts.diagnostics.signs) ~= 'boolean' then
        for severity, icon in pairs(opts.diagnostics.signs.text) do
          local name =
            vim.diagnostic.severity[severity]:lower():gsub('^%l', string.upper)
          name = 'DiagnosticSign' .. name
          vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
        end
      end

      -- inlay hints
      if opts.inlay_hints.enabled then
        LazyVim.lsp.on_supports_method(
          'textDocument/inlayHint',
          function(_, buffer)
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

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        LazyVim.lsp.on_supports_method(
          'textDocument/codeLens',
          function(_, buffer)
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

      -- virtual text
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
          return ''
        end
      end

      -- config for diagnostic
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- completion for LSP
      local blink = require('blink.cmp')
      local capabilities = vim.tbl_deep_extend(
        'force',
        {},
        vim.lsp.protocol.make_client_capabilities(),
        blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      ---setup LSP server
      local servers = opts.servers
      local function setup(server)
        local server_opts = vim.tbl_deep_extend('force', {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup['*'] then
          if opts.setup['*'](server, server_opts) then return end
        end
        vim.lsp.config[server] =
          vim.tbl_deep_extend('force', vim.lsp.config[server], server_opts)
      end

      -- get all the servers that are available through my config
      for _, language in pairs(require('config.languages')) do
        if not language.lsp_servers then goto continue end
        for _, lsp_server in ipairs(language.lsp_servers) do
          if type(lsp_server) == 'table' then
            local lsp_server_name = lsp_server[1]
            lsp_server = lsp_server_name
            ---@diagnostic disable-next-line: undefined-field
            if lsp_server.enabled ~= nil and not lsp_server.enabled then
              goto inner_continue
            end
          end
          setup(lsp_server)
          ::inner_continue::
        end
        ::continue::
      end
    end,
  },
  {
    -- Auto install LSP servers with needed
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      {
        -- Disable default tools
        'mason-org/mason.nvim',
        version = false,
        opts = {
          ensure_installed = {},
          registries = {
            -- 'file:' .. vim.fn.stdpath('config') .. '/mason-registry',
            -- HACK: I can't use file method because it's lazy load and slow to
            -- append to mason registry and affect to initialize
            -- my custom LSP servers
            'lua:tools.mason-registry',
            'github:mason-org/mason-registry',
          },
        },
      },
    },
    version = false,
    config = function()
      local ensure_installed = {} ---@type string[]
      local mlsp = require('mason-lspconfig')
      local all_mslp_servers =
        vim.tbl_keys(mlsp.get_mappings().lspconfig_to_package)
      for name, language in pairs(require('config.languages')) do
        if not language.lsp_servers then goto continue end
        for _, lsp_server in ipairs(language.lsp_servers) do
          if type(lsp_server) == 'table' then
            local lsp_server_name = lsp_server[1]
            lsp_server = lsp_server_name
          end
          if vim.tbl_contains(all_mslp_servers, lsp_server) then
            -- install server of language in bundle languages
            if vim.list_contains(_G.bundle_languages, name) then
              table.insert(ensure_installed, lsp_server)
            end
            -- lazy install server of language not in bundle languages
            if vim.list_contains(_G.enabled_languages, name) then
              vim.api.nvim_create_autocmd({ 'FileType' }, {
                pattern = language.filetypes,
                group = vim.api.nvim_create_augroup(
                  'mason_lsp_' .. name .. '_' .. lsp_server,
                  {}
                ),
                callback = function()
                  local registry = require('mason-registry')
                  local server =
                    require('mason-lspconfig').get_mappings().lspconfig_to_package[lsp_server]
                  if server ~= nil and not registry.is_installed(server) then
                    vim.api.nvim_command('MasonInstall ' .. server)
                  end
                end,
              })
            end
          end
        end
        ::continue::
      end

      ---@diagnostic disable-next-line: missing-fields
      mlsp.setup({
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
