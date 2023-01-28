local lualine = require('lualine')

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
        symbols = { added = ' ', modified = ' ', removed = ' ' },
      },
      'diagnostics',
    },
    lualine_c = {
      {
        'filename',
        path = 1, -- Relative path
      },
      {
        function()
          local present, noice = pcall(require, 'noice')
          if present then
            return noice.api.statusline.mode.get()
          end
        end,
        cond = function()
          local present, noice = pcall(require, 'noice')
          if present then
            return noice.api.statusline.mode.has()
          end
        end,
        color = { fg = '#f5a97f' },
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
            return ' '
          end
          return ''
        end,
        color = { fg = '#a6da95' },
      },
      {
        function(msg)
          msg = msg or '  Inactive'
          local buf_clients = vim.lsp.buf_get_clients()
          if next(buf_clients) == nil then
            -- TODO: clean up this if statement
            if type(msg) == 'boolean' or #msg == 0 then
              return '  Inactive'
            end
            return msg
          end
          local buf_client_names = {}

          -- add client
          for _, client in pairs(buf_clients) do
            if client.name ~= 'null-ls' then
              table.insert(buf_client_names, client.name)
            end
          end
          return '  ' .. table.concat(buf_client_names, ', ')
        end,
        color = { fg = '#8bd5ca', gui = 'bold' },
      },
      {
        function()
          local msg = ' '
          for tool, _ in
            pairs(require('languages').get_tools_by_filetype(vim.bo.filetype))
          do
            if vim.fn.executable(tool) == 1 then
              msg = msg .. tool .. ' '
            else
              msg = msg .. tool .. '! '
            end
          end
          return msg
        end,
        color = { fg = '#c6a0f6', gui = 'bold' },
      },
      'filetype',
    },
    lualine_y = {
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
    extensions('Outline'),
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
