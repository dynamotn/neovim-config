local bufferline = require('bufferline')
local extras = require('util.extras')

local offsets = {}
for filetype, text in pairs(require('core.defaults').special_filetypes) do
  table.insert(offsets, {
    filetype = filetype,
    text = text,
    highlight = 'Directory',
    text_align = 'left',
  })
end

bufferline.setup({
  highlights = function()
    if require('core.defaults').colorscheme == 'catppuccin' and extras.has_plugin('catppuccin') then
      return require('catppuccin.groups.integrations.bufferline').get()
    end
    return {}
  end,
  options = {
    mode = 'tabs',
    numbers = function(opts)
      return string.format('%s', opts.raise(opts.id))
    end,
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = function(_, _, diag)
      local icons = require('core.defaults').icons.diagnostics
      local ret = (diag.error and icons.Error .. diag.error .. ' ' or '')
        .. (diag.warning and icons.Warn .. diag.warning or '')
      return vim.trim(ret)
    end,
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = 'slant',
    sort_by = 'tabs',
    offsets = offsets,
  },
})
