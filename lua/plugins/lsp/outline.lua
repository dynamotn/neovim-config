-- Symbol kinds the outline lists, per filetype
local kind_filter = {
  default = {
    'Class',
    'Constructor',
    'Enum',
    'Field',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Namespace',
    'Package',
    'Property',
    'Struct',
    'Trait',
  },
  markdown = false,
  help = false,
  lua = {
    'Class',
    'Constructor',
    'Enum',
    'Field',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Namespace',
    -- `Package` is left out: lua_ls uses it for control flow structures
    'Property',
    'Struct',
    'Trait',
  },
}

return {
  {
    -- `<leader>cs` toggles the outline instead
    'folke/trouble.nvim',
    optional = true,
    keys = {
      { '<leader>cs', false },
    },
  },
  {
    -- Code outline sidebar
    'hedyhli/outline.nvim',
    keys = { { '<leader>cs', '<cmd>Outline<cr>', desc = 'Toggle Outline' } },
    cmd = 'Outline',
    opts = function()
      local defaults = require('outline.config').defaults
      local kinds = vim.tbl_extend(
        'keep',
        require('config.defaults').icons.kinds,
        { Key = ' ' }
      )
      local opts = {
        symbols = {
          icons = {},
          filter = vim.deepcopy(kind_filter),
        },
        keymaps = {
          up_and_jump = '<up>',
          down_and_jump = '<down>',
        },
      }

      for kind, symbol in pairs(defaults.symbols.icons) do
        opts.symbols.icons[kind] = {
          icon = kinds[kind] or symbol.icon,
          hl = symbol.hl,
        }
      end
      return opts
    end,
  },
  {
    'folke/edgy.nvim',
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = 'Outline',
        ft = 'Outline',
        pinned = true,
        open = 'Outline',
      })
    end,
  },
  {
    -- Lualine extension for Outline
    'lualine.nvim',
    opts = {
      special_filetypes = {
        Outline = 'Outline',
      },
    },
  },
}
