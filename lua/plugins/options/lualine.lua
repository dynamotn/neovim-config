local present, lualine = pcall(require, 'lualine')

if not present then
  return
end

local special_filetypes = {
  Outline = 'Outline',
  dapui_scopes = 'Scopes',
  dapui_breakpoints = 'Breakpoints',
  dapui_stacks = 'Stacks',
  dapui_watches = 'Watches',
  ['dap-repl'] = 'REPL',
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
    theme = 'onedark',
    disabled_filetypes = {
      'NvimTree',
    },
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
          local present, gps = pcall(require, 'nvim-gps')
          if not present or not gps.is_available() then
            return ''
          end
          return gps.get_location()
        end,
        color = { fg = '#6cbdc2' },
      },
    },
    lualine_x = {
      {
        function()
          local b = vim.api.nvim_get_current_buf()
          if next(vim.treesitter.highlighter.active[b]) then
            return ' '
          end
          return ''
        end,
        color = { fg = '#98be65' },
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
        color = { fg = '#008080', gui = 'bold' },
      },
      {
        function()
          local msg = ' '
          for tool, _ in pairs(require('languages').get_tools_by_filetype(vim.bo.filetype)) do
            if vim.fn.executable(tool) == 1 then
              msg = msg .. tool .. ' '
            else
              msg = msg .. tool .. '! '
            end
          end
          return msg
        end,
        color = { fg = '#8080f0', gui = 'bold' },
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
    'chadtree',
    extensions('Outline'),
    extensions('dapui_scopes'),
    extensions('dapui_breakpoints'),
    extensions('dapui_stacks'),
    extensions('dapui_watches'),
    extensions('dap-repl'),
  },
})
