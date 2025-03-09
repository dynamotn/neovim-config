return {
  {
    -- I want to self-managed LSP by my way
    'neovim/nvim-lspconfig',
    event = 'LazyFile',
    dependencies = {
      'mason.nvim',
      { 'williamboman/mason-lspconfig.nvim', config = function() end },
    },
    opts = function()
      ---@class PluginLspOpts
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
        ---@type lspconfig.options
        servers = {},
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {},
        -- you can add not officially supported servers here
        ---@type table<string, string>
        configs = {},
      }
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- setup autoformat
      LazyVim.format.register(LazyVim.lsp.formatter())

      -- setup keymaps
      LazyVim.lsp.on_attach(
        function(client, buffer)
          require('lazyvim.plugins.lsp.keymaps').on_attach(client, buffer)
        end
      )

      LazyVim.lsp.setup()
      LazyVim.lsp.on_dynamic_capability(
        require('lazyvim.plugins.lsp.keymaps').on_attach
      )

      -- inlay hints
      if opts.inlay_hints.enabled then
        LazyVim.lsp.on_supports_method(
          'textDocument/inlayHint',
          function(client, buffer)
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
          function(client, buffer)
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
        if server_opts.enabled == false then return end

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup['*'] then
          if opts.setup['*'](server, server_opts) then return end
        end

        -- add not supported officially server
        if opts.module[server] then
          require('lspconfig.configs')[server] = require(opts.module[server])
        end
        require('lspconfig')[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, 'mason-lspconfig')
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(
          require('mason-lspconfig.mappings.server').lspconfig_to_package
        )
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            -- run manual setup if
            -- mason=false
            -- or if this is a server that cannot be installed with mason-lspconfig
            if
              server_opts.mason == false
              or not vim.tbl_contains(all_mslp_servers, server)
            then
              setup(server)
            -- install server of language in bundle languages
            elseif
              require('util.languages').check_lsp_is_for_bundled_language(
                server
              )
            then
              ensure_installed[#ensure_installed + 1] = server
            end
          end
        end
      end

      if have_mason then
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend(
            'force',
            ensure_installed,
            LazyVim.opts('mason-lspconfig.nvim').ensure_installed or {}
          ),
          handlers = { setup },
        })
      end
    end,
  },
}
