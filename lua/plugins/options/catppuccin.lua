local catppuccin = require('catppuccin')

catppuccin.setup({
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
  integrations = {
    cmp = true,
    dap = {
      enabled = true,
      enable_ui = true,
    },
    gitsigns = true,
    hop = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    lsp_saga = true,
    lsp_trouble = true,
    markdown = true,
    mason = true,
    mini = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
      },
      underlines = {
        errors = { 'undercurl' },
        hints = { 'undercurl' },
        warnings = { 'undercurl' },
        information = { 'undercurl' },
      },
      inlay_hints = {
        background = true,
      },
    },
    neogit = true,
    neotest = true,
    neotree = true,
    noice = true,
    notify = true,
    overseer = true,
    rainbow_delimiters = true,
    semantic_tokens = true,
    telescope = {
      enabled = true,
    },
    treesitter = true,
    treesitter_context = true,
    which_key = true,
  },
  custom_highlights = function(colors)
    local util = require('catppuccin.utils.colors')
    return {
      CmpItemAbbrMatch = { fg = colors.blue, bg = colors.none, bold = true },
      CmpItemAbbrMatchFuzzy = { fg = colors.blue, bg = colors.none, bold = true },
      CmpItemMenu = { fg = colors.sapphire, bg = colors.none, bold = true },

      CmpItemKindField = { fg = util.lighten(colors.surface0, 0.9, colors.green), bg = colors.green },
      CmpItemKindProperty = { fg = util.lighten(colors.surface0, 0.9, colors.green), bg = colors.green },
      CmpItemKindUnit = { fg = util.lighten(colors.surface0, 0.9, colors.green), bg = colors.green },

      CmpItemKindText = { fg = util.lighten(colors.surface0, 0.9, colors.teal), bg = colors.teal },
      CmpItemKindEnum = { fg = util.lighten(colors.surface0, 0.9, colors.teal), bg = colors.teal },
      CmpItemKindKeyword = { fg = util.lighten(colors.surface0, 0.9, colors.teal), bg = colors.teal },
      CmpItemKindCodeium = { fg = util.lighten(colors.surface0, 0.9, colors.teal), bg = colors.teal },

      CmpItemKindEvent = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindFunction = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindStruct = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindConstructor = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindModule = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindOperator = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindFile = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindFolder = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindTypeParameter = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },
      CmpItemKindMethod = { fg = util.lighten(colors.surface0, 0.9, colors.blue), bg = colors.blue },

      CmpItemKindConstant = { fg = util.lighten(colors.surface0, 0.9, colors.peach), bg = colors.peach },
      CmpItemKindValue = { fg = util.lighten(colors.surface0, 0.9, colors.peach), bg = colors.peach },

      CmpItemKindReference = { fg = util.lighten(colors.surface0, 0.9, colors.red), bg = colors.red },
      CmpItemKindEnumMember = { fg = util.lighten(colors.surface0, 0.9, colors.red), bg = colors.red },
      CmpItemKindColor = { fg = util.lighten(colors.surface0, 0.9, colors.red), bg = colors.red },

      CmpItemKindClass = { fg = util.lighten(colors.surface0, 0.9, colors.yellow), bg = colors.yellow },
      CmpItemKindInterface = { fg = util.lighten(colors.surface0, 0.9, colors.yellow), bg = colors.yellow },
      CmpItemKindVariable = { fg = util.lighten(colors.surface0, 0.9, colors.flamingo), bg = colors.flamingo },
      CmpItemKindSnippet = { fg = util.lighten(colors.surface0, 0.9, colors.mauve), bg = colors.mauve },
    }
  end,
})

catppuccin.load()
