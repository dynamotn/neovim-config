local cmp_util = require('util.cmp')

return {
  -- Debug Adapter implementation
  { import = 'lazyvim.plugins.extras.dap.core' },
  {
    -- Disable auto install debugger
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      automatic_installation = false,
    },
    config = function(_, opts)
      for name, language in pairs(require('config.languages')) do
        if language.dap then
          -- install server of language in bundle languages
          if vim.list_contains(_G.bundle_languages, name) then
            opts.ensure_installed =
              vim.list_extend(opts.ensure_installed, language.dap)
          end
          -- lazy install server of language not in bundle languages
          if vim.list_contains(_G.enabled_languages, name) then
            vim.api.nvim_create_autocmd({ 'FileType' }, {
              pattern = language.filetypes,
              group = vim.api.nvim_create_augroup('mason_dap_' .. name, {}),
              callback = function()
                local registry = require('mason-registry')
                local dap_mapping = require('mason-nvim-dap.mappings.source')
                for _, dap_server in ipairs(language.dap) do
                  local server = dap_mapping.nvim_dap_to_package[dap_server]
                  if server ~= nil and not registry.is_installed(server) then
                    vim.api.nvim_command('MasonInstall ' .. server)
                  end
                end
              end,
            })
          end
        end
      end
      require('mason-nvim-dap').setup(opts)
    end,
  },
  {
    -- Lualine extensions for DAP
    'lualine.nvim',
    opts = {
      special_filetypes = {
        dapui_scopes = 'Scopes',
        dapui_breakpoints = 'Breakpoints',
        dapui_stacks = 'Stacks',
        dapui_watches = 'Watches',
        ['dap-repl'] = 'REPL',
        dapui_console = 'Console',
      },
    },
  },
  {
    -- Completion for DAP
    'blink.cmp',
    dependencies = {
      {
        'rcarriga/cmp-dap',
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              dap = '「DAP」',
            })
        end,
      },
    },
    opts = {
      sources = {
        compat = { 'dap' },
        per_filetype = {
          ['dap-repl'] = cmp_util.sources('dap'),
          dapui_watches = cmp_util.sources('dap'),
          dapui_hover = cmp_util.sources('dap'),
        },
      },
    },
  },
}
