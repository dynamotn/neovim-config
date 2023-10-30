local noice = require('noice')

noice.setup({
  cmdline = { view = 'cmdline_popup' },
  messages = { view = 'notify' },
  popupmenu = {
    backend = 'cmp',
  },
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
    message = {
      view = 'mini',
    },
  },
  presets = {
    lsp_doc_border = true,
    long_message_to_split = true,
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
        event = 'notify',
        find = 'split buf',
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
