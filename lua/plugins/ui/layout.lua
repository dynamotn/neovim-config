return {
  {
    -- Improve messages, cmdline, popups & LSP
    'folke/noice.nvim',
    opts = {
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
      presets = {
        lsp_doc_border = true,
        long_message_to_split = true,
        bottom_search = false,
      },
    },
  },
  -- Windows layout
  { import = 'lazyvim.plugins.extras.ui.edgy' },
}
