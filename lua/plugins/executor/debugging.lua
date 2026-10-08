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
    -- Debug adapters from Mason. Its `setup` is LazyVim's to call, from
    -- nvim-dap's own `config`; a second call here would run every handler
    -- twice and list each of their configurations twice.
    'jay-babu/mason-nvim-dap.nvim',
    -- The adapters of a language are installed with its first buffer, from a
    -- handler registered at startup: nvim-dap itself only loads with the
    -- first `<leader>d` key, so one registered from there would miss the
    -- buffer that was already open and leave that first session without its
    -- debugger.
    init = function()
      local dap_util = require('util.dap')
      for name, language in pairs(require('config.languages')) do
        if language.dap and vim.list_contains(_G.enabled_languages, name) then
          require('util.lazy_install').on_filetype(
            language.filetypes,
            function()
              for _, spec in ipairs(language.dap) do
                local package = dap_util.package(spec)
                if package then
                  require('util.lazy_install').install_once(package)
                end
              end
            end
          )
        end
      end
    end,
    -- Install the adapters of bundle languages up front: mason-nvim-dap takes
    -- the adapters it knows by name, the rest are installed here
    opts = function(_, opts)
      local dap_util = require('util.dap')
      opts.automatic_installation = false
      opts.ensure_installed = opts.ensure_installed or {}
      for name, language in pairs(require('config.languages')) do
        if language.dap and vim.list_contains(_G.bundle_languages, name) then
          for _, spec in ipairs(language.dap) do
            if dap_util.is_mapped(spec) then
              table.insert(opts.ensure_installed, spec)
            else
              local package = dap_util.package(spec)
              if package then
                require('util.lazy_install').install_once(package)
              end
            end
          end
        end
      end
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
    -- Completion for DAP, only ever used in the REPL. Its own spec rather than
    -- a dependency of blink.cmp, which would load it -- and nvim-dap with all
    -- its adapters -- on the first `InsertEnter` of any buffer.
    'rcarriga/cmp-dap',
    ft = 'dap-repl',
    init = function()
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        dap = '「DAP」',
      })
    end,
  },
  {
    'blink.cmp',
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
