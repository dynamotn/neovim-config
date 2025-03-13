return {
  {
    -- Status line
    'nvim-lualine/lualine.nvim',
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
              return icons.treesitter
            end
            return ''
          end,
          color = { fg = Snacks.util.color('String') },
        },
        {
          function(msg)
            msg = msg or icons.lsp .. 'Inactive'
            local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
            if next(buf_clients) == nil then return msg end
            local buf_client_names = {}

            for _, client in pairs(buf_clients) do
              if
                not vim.list_contains({ 'null-ls', 'copilot' }, client.name)
              then
                table.insert(buf_client_names, client.name)
              end
            end
            return icons.lsp .. table.concat(buf_client_names, ', ')
          end,
          color = { fg = Snacks.util.color('Label'), gui = 'bold' },
        },
        {
          function()
            local msg = icons.null_ls
            for _, tool in
              ipairs(
                require('util.languages').get_tools_by_filetype(vim.bo.filetype)
              )
            do
              if vim.list_contains({ 'lua', 'git', 'curl' }, tool) then
              elseif vim.fn.executable(tool) == 1 then
                msg = msg .. tool .. ' '
              else
                msg = msg .. tool .. '! '
              end
            end
            return vim.trim(msg)
          end,
          color = { fg = Snacks.util.color('Statement'), gui = 'bold' },
        },
      }
      opts.special_filetypes = {
        help = 'Help Guide',
        terminal = 'Terminal',
        snacks_picker_list = 'Explorer',
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
    -- Winbar to show context of current position
    'Bekaboo/dropbar.nvim',
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
