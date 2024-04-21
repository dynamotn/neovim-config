local neotree = require('neo-tree')
local events = require("neo-tree.events")

local function on_move(data)
  require('util.lsp').on_rename(data.source, data.destination)
end

neotree.setup({
  open_files_do_not_replace_types = {
    'terminal',
    'Trouble',
    'qf',
    'sagaoutline',
    'edgy',
  },
  filesystem = {
    hijack_netrw_behavior = 'open_default',
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
  },
  event_handlers = {
    { event = events.FILE_MOVED, handler = on_move },
    { event = events.FILE_RENAMED, handler = on_move },
  }
})
