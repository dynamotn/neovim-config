local bufferline = require('bufferline')

local special_filetypes = {
  help = 'Help Guide',
  Outline = 'Outline',
  dapui_scopes = 'Scopes',
  dapui_breakpoints = 'Breakpoints',
  dapui_stacks = 'Stacks',
  dapui_watches = 'Watches',
  ['dap-repl'] = 'REPL',
  dapui_console = 'Console',
  dbui = 'Database',
  dbout = 'Query Result',
  ['neo-tree'] = 'File Explorer',
  GoogleKeepMenu = 'Google Keep Menu',
  GoogleKeepList = 'Google Keep Notes',
  OverseerList = 'List tasks',
  terminal = 'Terminal',
  Regexplainer = 'Regex',
  tsplayground = 'TSPlayground',
}

local offsets = {}
for filetype, text in pairs(special_filetypes) do
  table.insert(offsets, {
    filetype = filetype,
    text = text,
    highlight = 'Directory',
    text_align = 'left',
  })
end

bufferline.setup({
  highlights = require('catppuccin.groups.integrations.bufferline').get(),
  options = {
    mode = 'tabs',
    numbers = function(opts)
      return string.format('%s', opts.raise(opts.id))
    end,
    diagnostics = 'nvim_lsp',
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = 'slant',
    sort_by = 'tabs',
    offsets = offsets,
  },
})
