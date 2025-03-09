return {
  { 'folke/tokyonight.nvim', enabled = false }, -- Disable tokyonight
  {
    -- Catppuccin for both Dark (Macchiato) and Light (Latte) colorscheme
    'catppuccin/nvim',
    name = 'catppuccin',
    event = 'UIEnter',
    opts = {
      flavour = 'macchiato',
      background = {
        light = 'latte',
        dark = 'macchiato',
      },
      transparent_background = true,
      dim_inactive = {
        enabled = true,
        shade = 'dark',
        percentage = 0.15,
      },
      styles = {
        keywords = { 'italic', 'bold' },
        functions = { 'bold' },
      },
      custom_highlights = function(colors)
        local util = require('catppuccin.utils.colors')
        return {
          CmpItemAbbrMatch = { fg = colors.blue, bg = colors.none, bold = true },
          CmpItemAbbrMatchFuzzy = {
            fg = colors.blue,
            bg = colors.none,
            bold = true,
          },
          CmpItemMenu = { fg = colors.sapphire, bg = colors.none, bold = true },

          CmpItemKindField = {
            fg = util.lighten(colors.surface0, 0.9, colors.green),
            bg = colors.green,
          },
          CmpItemKindProperty = {
            fg = util.lighten(colors.surface0, 0.9, colors.green),
            bg = colors.green,
          },
          CmpItemKindUnit = {
            fg = util.lighten(colors.surface0, 0.9, colors.green),
            bg = colors.green,
          },

          CmpItemKindText = {
            fg = util.lighten(colors.surface0, 0.9, colors.teal),
            bg = colors.teal,
          },
          CmpItemKindEnum = {
            fg = util.lighten(colors.surface0, 0.9, colors.teal),
            bg = colors.teal,
          },
          CmpItemKindKeyword = {
            fg = util.lighten(colors.surface0, 0.9, colors.teal),
            bg = colors.teal,
          },
          CmpItemKindCodeium = {
            fg = util.lighten(colors.surface0, 0.9, colors.teal),
            bg = colors.teal,
          },

          CmpItemKindEvent = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindFunction = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindStruct = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindConstructor = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindModule = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindOperator = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindFile = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindFolder = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindTypeParameter = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },
          CmpItemKindMethod = {
            fg = util.lighten(colors.surface0, 0.9, colors.blue),
            bg = colors.blue,
          },

          CmpItemKindConstant = {
            fg = util.lighten(colors.surface0, 0.9, colors.peach),
            bg = colors.peach,
          },
          CmpItemKindValue = {
            fg = util.lighten(colors.surface0, 0.9, colors.peach),
            bg = colors.peach,
          },

          CmpItemKindReference = {
            fg = util.lighten(colors.surface0, 0.9, colors.red),
            bg = colors.red,
          },
          CmpItemKindEnumMember = {
            fg = util.lighten(colors.surface0, 0.9, colors.red),
            bg = colors.red,
          },
          CmpItemKindColor = {
            fg = util.lighten(colors.surface0, 0.9, colors.red),
            bg = colors.red,
          },

          CmpItemKindClass = {
            fg = util.lighten(colors.surface0, 0.9, colors.yellow),
            bg = colors.yellow,
          },
          CmpItemKindInterface = {
            fg = util.lighten(colors.surface0, 0.9, colors.yellow),
            bg = colors.yellow,
          },
          CmpItemKindVariable = {
            fg = util.lighten(colors.surface0, 0.9, colors.flamingo),
            bg = colors.flamingo,
          },
          CmpItemKindSnippet = {
            fg = util.lighten(colors.surface0, 0.9, colors.mauve),
            bg = colors.mauve,
          },
        }
      end,
    },
  },
}
