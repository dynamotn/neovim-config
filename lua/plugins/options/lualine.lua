local lualine = require('lualine')
local icons = require('core.defaults').icons

local special_filetypes = {
  help = 'Help Guide',
  sagaoutline = 'Outline',
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

local extensions = function(filetype)
  return {
    filetypes = { filetype },
    sections = {
      lualine_a = {
        function()
          return special_filetypes[filetype] or 'N/A'
        end,
      },
    },
  }
end

lualine.setup({
  options = {
    theme = 'catppuccin',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      {
        'diff',
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          removed = icons.git.removed,
        },
      },
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
    },
    lualine_c = {
      {
        'filename',
        path = 1, -- Relative path
        symbols = {
          modified = icons.file_attributes.draft,
          readonly = icons.file_attributes.readonly,
          unnamed = icons.file_attributes.unnamed,
        },
      },
      {
        function()
          return require('noice').api.statusline.mode.get()
        end,
        cond = function()
          return package.loaded['noice']
            and require('noice').api.statusline.mode.has()
        end,
        color = { fg = dynamo_fg('Constant') },
      },
      {
        function()
          return '  ' .. require('dap').status()
        end,
        cond = function()
          return package.loaded['dap'] and require('dap').status() ~= ''
        end,
        color = { fg = dynamo_fg('Debug') },
      },
    },
    lualine_x = {
      {
        'overseer',
      },
      {
        function()
          local b = vim.api.nvim_get_current_buf()
          if next(vim.treesitter.highlighter.active[b]) then
            return icons.treesitter
          end
          return ''
        end,
        color = { fg = dynamo_fg('String') },
      },
      {
        function(msg)
          msg = msg or icons.lsp .. 'Inactive'
          local buf_clients = vim.lsp.buf_get_clients()
          if next(buf_clients) == nil then
            return msg
          end
          local buf_client_names = {}

          -- add client
          for _, client in pairs(buf_clients) do
            if client.name ~= 'null-ls' then
              table.insert(buf_client_names, client.name)
            end
          end
          return icons.lsp .. table.concat(buf_client_names, ', ')
        end,
        color = { fg = dynamo_fg('Label'), gui = 'bold' },
      },
      {
        function()
          local msg = icons.null_ls
          for tool, _ in
            pairs(require('languages').get_tools_by_filetype(vim.bo.filetype))
          do
            if vim.fn.executable(tool) == 1 then
              msg = msg .. tool .. ' '
            else
              msg = msg .. tool .. '! '
            end
          end
          return vim.trim(msg)
        end,
        color = { fg = dynamo_fg('Statement'), gui = 'bold' },
      },
    },
    lualine_y = {
      'filetype',
      {
        'encoding',
        separator = { left = '', right = '' }, -- Not use powerline between encoding and file format
      },
      'fileformat',
    },
    lualine_z = { 'progress', 'location' },
  },
  extensions = {
    'quickfix',
    'toggleterm',
    'man',
    extensions('help'),
    extensions('sagaoutline'),
    extensions('dapui_scopes'),
    extensions('dapui_breakpoints'),
    extensions('dapui_stacks'),
    extensions('dapui_watches'),
    extensions('dap-repl'),
    extensions('dapui_console'),
    extensions('dbui'),
    extensions('dbout'),
    extensions('neo-tree'),
    extensions('GoogleKeepMenu'),
    extensions('GoogleKeepList'),
    extensions('OverseerList'),
    extensions('terminal'),
    extensions('Regexplainer'),
    extensions('tsplayground'),
  },
})
