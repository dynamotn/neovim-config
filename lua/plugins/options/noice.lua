local noice = require('noice')

noice.setup({
  cmdline = { view = 'cmdline' },
  messages = { view = 'notify' },
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
  routes = {
    {
      filter = {
        event = 'notify',
        find = 'No information available',
      },
      opts = {
        skip = true,
      },
    },
    {
      filter = {
        event = 'msg_show',
        any = {
          { find = '%d+L, %d+B' },
          { find = '; after #%d+' },
          { find = '; before #%d+' },
        },
      },
      view = 'mini',
    },
  },
})
