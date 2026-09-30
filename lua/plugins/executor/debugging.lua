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
      local dap_util = require('util.dap')
      local registry = require('mason-registry')
      opts.ensure_installed = opts.ensure_installed or {}

      ---@param spec string|DyDapSpec
      ---@param install fun(package: string)
      local function install_missing(spec, install)
        local package = dap_util.package(spec)
        if package and not registry.is_installed(package) then
          install(package)
        end
      end

      local languages = require('config.languages')
      for name, language in pairs(languages) do
        if language.dap then
          -- install server of language in bundle languages: mason-nvim-dap
          -- takes the adapters it knows by name, the rest are installed here
          if vim.list_contains(_G.bundle_languages, name) then
            for _, spec in ipairs(language.dap) do
              if dap_util.is_mapped(spec) then
                table.insert(opts.ensure_installed, spec)
              else
                install_missing(spec, function(package)
                  local ok, pkg = pcall(registry.get_package, package)
                  if ok then pkg:install() end
                end)
              end
            end
          end
          -- lazy install server of language not in bundle languages
          if vim.list_contains(_G.enabled_languages, name) then
            require('util.lazy_install').on_filetype(
              language.filetypes,
              function()
                for _, spec in ipairs(language.dap) do
                  install_missing(
                    spec,
                    function(package)
                      require('mason.api.command').MasonInstall({ package })
                    end
                  )
                end
              end
            )
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
