local noice = require('noice')

noice.setup({
  cmdline = { view = 'cmdline' },
  messages = { view = 'mini' },
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = false,
    },
    message = {
      view = 'mini',
    },
  },
  presets = {
    lsp_doc_border = true,
  },
})
