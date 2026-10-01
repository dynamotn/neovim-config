local cmp_util = require('util.cmp')

return {
  -- Debug Adapter implementation
  { import = 'lazyvim.plugins.extras.dap.core' },
  { 'rcarriga/nvim-dap-ui', enabled = false }, -- Replaced by nvim-dap-view
  {
    'mfussenegger/nvim-dap',
    dependencies = { 'igorlfs/nvim-dap-view' },
  },
  {
    -- Debugger UI sharing one window between its views
    'igorlfs/nvim-dap-view',
    keys = {
      {
        '<leader>du',
        function() require('dap-view').toggle() end,
        desc = 'Dap View',
      },
      {
        '<leader>de',
        function()
          local expr
          local mode = vim.fn.mode()
          if mode:find('^[vV\22]') then
            expr = table.concat(
              vim.fn.getregion(
                vim.fn.getpos('v'),
                vim.fn.getpos('.'),
                { type = mode }
              ),
              '\n'
            )
          end
          require('dap-view').hover(expr)
        end,
        desc = 'Eval',
        mode = { 'n', 'x' },
      },
    },
    opts = {
      -- Open with a session and close after it, as nvim-dap-ui did
      auto_toggle = true,
    },
  },
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
    -- Print debugging: insert, comment out and delete tagged print lines
    --
    -- Its own `g?` keys add the lines, `[g`/`]g` move between them. It loads
    -- with the first file rather than with the first key, or the lines left
    -- from a previous session go unhighlighted until then.
    'andrewferrier/debugprint.nvim',
    event = 'LazyFile',
    cmd = 'Debugprint',
    dependencies = { 'nvim-mini/mini.hipatterns' },
    keys = {
      -- `refactoring.nvim` had these for its own debug prints, which
      -- debugprint neither finds nor deletes; one kind of print is less
      -- to clean up
      {
        '<leader>rp',
        'g?v',
        remap = true,
        mode = { 'n', 'x' },
        desc = 'Debug Print Variable',
      },
      { '<leader>rP', 'g?p', remap = true, desc = 'Debug Print Location' },
      { '<leader>rc', '<cmd>Debugprint delete<cr>', desc = 'Debug Cleanup' },
      {
        '<leader>rC',
        '<cmd>Debugprint commenttoggle<cr>',
        desc = 'Debug Print Comment Toggle',
      },
      { '<leader>sP', '<cmd>Debugprint search<cr>', desc = 'Debug Prints' },
    },
    opts = {
      picker = 'snacks.picker',
    },
  },
  {
    -- Lualine extensions for DAP
    'lualine.nvim',
    opts = {
      special_filetypes = {
        ['dap-view'] = 'Debug',
        ['dap-repl'] = 'REPL',
        ['dap-view-term'] = 'Console',
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
        },
      },
    },
  },
}
