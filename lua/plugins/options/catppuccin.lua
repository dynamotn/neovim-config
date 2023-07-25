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
})

catppuccin.load()
