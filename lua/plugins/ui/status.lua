return {
  {
    -- Status line
    'nvim-lualine/lualine.nvim',
    keys = {
      {
        '<leader>cL',
        function() require('util.statusline').pick_lsp() end,
        desc = 'Language servers of buffer',
      },
      {
        '<leader>cT',
        function() require('util.statusline').pick_tools() end,
        desc = 'Formatters and linters of buffer',
      },
    },
    opts = function(_, opts)
      local icons = require('config.defaults').icons

      opts.sections.lualine_z = {
        { 'progress', separator = '', padding = { left = 1, right = 0 } },
        { 'location', separator = '', padding = { left = 1, right = 0 } },
      }
      opts.sections.lualine_y = {
        {
          function()
            local b = vim.api.nvim_get_current_buf()
            if next(vim.treesitter.highlighter.active[b]) then
              return icons.treesitter.core
            end
            return ''
          end,
          color = { fg = Snacks.util.color('String') },
        },
        {
          -- Counts only; a click lists every server with its state
          function() return require('util.statusline').lsp_status(icons.lsp) end,
          on_click = function() require('util.statusline').pick_lsp() end,
          color = { fg = Snacks.util.color('Label'), gui = 'bold' },
        },
        {
          function()
            return require('util.statusline').tools_status(icons.null_ls)
          end,
          on_click = function() require('util.statusline').pick_tools() end,
          color = { fg = Snacks.util.color('Statement'), gui = 'bold' },
        },
      }
      opts.special_filetypes = {
        help = 'Help Guide',
        terminal = 'Terminal',
        snacks_picker_list = 'Explorer',
        Avante = 'Avante',
        AvanteInput = 'Avante',
        AvanteSelectedFiles = 'Avante',
        AvanteSelectedCode = 'Avante',
        AvanteTodos = 'Avante',
      }
    end,
    config = function(_, opts)
      for filetype, name in pairs(opts.special_filetypes) do
        vim.list_extend(opts.extensions, {
          {
            filetypes = { filetype },
            sections = {
              lualine_a = {
                function() return name or 'N/A' end,
              },
            },
          },
        })
      end
      require('lualine').setup(opts)
    end,
  },
  {
    -- Buffer and tab line
    'akinsho/bufferline.nvim',
    opts = {
      options = {
        mode = 'tabs',
        numbers = function(number_opts)
          return string.format('%s', number_opts.raise(number_opts.id))
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = 'slant',
        sort_by = 'tabs',
      },
    },
    cond = not vim.g.started_by_firenvim,
  },
  {
    -- Scrollbar marking the cursor, search results, diagnostics, git hunks,
    -- marks and quickfix entries across the whole buffer
    'lewis6991/satellite.nvim',
    event = 'LazyFile',
    cond = not vim.g.started_by_firenvim,
    opts = {
      -- Side panels and pickers have nothing to scroll through worth marking
      excluded_filetypes = {
        'dap-view',
        'dap-repl',
        'Outline',
        'trouble',
        'qf',
        'snacks_dashboard',
        'snacks_picker_list',
        'snacks_picker_input',
        'snacks_terminal',
        'codecompanion',
        'lazy',
        'mason',
      },
      handlers = {
        -- `marks.nvim` sets the marks, with its own `m` mappings
        marks = { enable = true, show_builtins = false, key = 'm' },
      },
    },
    config = function(_, opts)
      require('satellite').setup(opts)
      local enabled = true
      Snacks.toggle({
        name = 'Scrollbar',
        get = function() return enabled end,
        set = function(state)
          enabled = state
          vim.cmd(state and 'SatelliteEnable' or 'SatelliteDisable')
        end,
      }):map('<leader>uB')
    end,
  },
  {
    -- Winbar to show context of current position
    -- 'Bekaboo/dropbar.nvim',
    'cubewhy/dropbar.nvim',
    branch = 'fix-event',
    event = 'UIEnter',
    opts = {
      icons = {
        kinds = {
          symbol = require('config.defaults').icons.kinds,
        },
      },
    },
  },
}
