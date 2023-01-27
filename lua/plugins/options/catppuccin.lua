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
    dap = true,
    gitsigns = true,
    hop = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    mini = true,
    lsp_trouble = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
      },
      underlines = {
        errors = { 'underline' },
        hints = { 'underline' },
        warnings = { 'underline' },
        information = { 'underline' },
      },
    },
    neogit = true,
    neotest = true,
    neotree = true,
    noice = true,
    notify = true,
    overseer = true,
    symbols_outline = true,
    telescope = true,
    treesitter = true,
    treesitter_context = true,
    ts_rainbow = true,
    which_key = true,
  },
})

catppuccin.load()
