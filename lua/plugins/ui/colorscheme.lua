return {
  {
    -- Catppuccin for both Dark (Macchiato) and Light (Latte) colorscheme
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    event = 'UIEnter',
    opts = {
      -- `auto` drops the fixed flavour and reads `background` instead, so
      -- the pair below is what actually decides. `util.day_night` owns that
      -- option, and re-running `:colorscheme` is all a switch takes.
      flavour = 'auto',
      background = {
        light = 'latte',
        dark = 'macchiato',
      },
      lsp_styles = {
        underlines = {
          errors = { 'undercurl' },
          hints = { 'undercurl' },
          warnings = { 'undercurl' },
          information = { 'undercurl' },
        },
      },
      -- Detecting integrations walks every installed plugin and loads
      -- catppuccin's whole mapping table on each startup, about a tenth of
      -- it. So they are named here instead, and a plugin added later with a
      -- catppuccin integration goes here too.
      auto_integrations = false,
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dadbod_ui = true,
        dap = true,
        dashboard = true,
        dropbar = { enabled = true },
        flash = true,
        fzf = true,
        gitsigns = true,
        grug_far = true,
        harpoon = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        markview = true,
        mason = true,
        mini = true,
        navic = { enabled = true, custom_bg = 'lualine' },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        rainbow_delimiters = true,
        snacks = true,
        telescope = true,
        treesitter_context = true,
        which_key = true,
      },
      transparent_background = false,
      dim_inactive = {
        enabled = true,
        shade = 'light',
        percentage = 0.5,
      },
      styles = {
        keywords = { 'italic', 'bold' },
        functions = { 'bold' },
      },
      custom_highlights = function(colors)
        local util = require('catppuccin.utils.colors')
        return {
          Type = { fg = colors.sapphire },
          -- Whitespace left at the end of a line, marked by `mini.hipatterns`
          DyTrailingWhitespace = { bg = colors.red },
          CurSearch = { fg = colors.mantle, bg = colors.peach },
          Search = { fg = colors.text, bg = colors.blue },
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
    specs = {
      {
        -- Bufferline in catppuccin's colours
        'akinsho/bufferline.nvim',
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ''):find('catppuccin') then
            opts.highlights =
              require('catppuccin.special.bufferline').get_theme()
          end
        end,
      },
    },
  },
}
