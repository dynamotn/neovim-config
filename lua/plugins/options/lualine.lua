-- PERF: we don't need this lualine require madness 🤷
local lualine_require = require('lualine_require')
lualine_require.require = require

vim.o.laststatus = vim.g.lualine_laststatus

local lualine = require('lualine')
local icons = require('core.defaults').icons
local extras = require('util.extras')

local extensions = function(filetype)
  return {
    filetypes = { filetype },
    sections = {
      lualine_a = {
        function()
          return require('core.defaults').special_filetypes[filetype] or 'N/A'
        end,
      },
    },
  }
end

lualine.setup({
  options = {
    theme = require('core.defaults').colorscheme,
    globalstatus = true,
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
        function()
          local root = require('util.root').get()
          local cwd = vim.uv.cwd()
          local result = ''
          if root:find(cwd, 1, true) == 1 then
            result = cwd
          else
            result = root
          end
          return require('core.defaults').icons.projekt .. result
        end,
        color = { fg = extras.fg('Constant') },
      },
      {
        function()
          local root = require('util.root').get()
          local cwd = vim.uv.cwd()
          local result = ''

          if root == cwd then
            result = ''
          elseif cwd:find(root, 1, true) == 1 then
            result = string.gsub(cwd, root .. '/', '')
          end

          return result
        end,
        color = { fg = extras.fg('Constant') },
      },
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
          return require('noice').api.status.command.get()
        end,
        cond = function()
          return package.loaded['noice'] and require('noice').api.status.command.has()
        end,
        color = { fg = extras.fg('Statement') },
      },
      {
        function()
          return require('noice').api.status.mode.get()
        end,
        cond = function()
          return package.loaded['noice'] and require('noice').api.status.mode.has()
        end,
        color = { fg = extras.fg('Constant') },
      },
      {
        function()
          return require('core.defaults').icons.dap.Status .. require('dap').status()
        end,
        cond = function()
          return package.loaded['dap'] and require('dap').status() ~= ''
        end,
        color = { fg = extras.fg('Debug') },
      },
    },
    lualine_x = {
      {
        function()
          local b = vim.api.nvim_get_current_buf()
          if next(vim.treesitter.highlighter.active[b]) then
            return icons.treesitter
          end
          return ''
        end,
        color = { fg = extras.fg('String') },
      },
      {
        function(msg)
          msg = msg or icons.lsp .. 'Inactive'
          local b = vim.api.nvim_get_current_buf()
          local buf_clients = vim.lsp.get_clients({ bufnr = b })
          if next(buf_clients) == nil then
            return msg
          end
          local buf_client_names = {}

          -- add client
          for _, client in pairs(buf_clients) do
            if not vim.list_contains({ 'null-ls', 'copilot' }, client.name) then
              table.insert(buf_client_names, client.name)
            end
          end
          return icons.lsp .. table.concat(buf_client_names, ', ')
        end,
        color = { fg = extras.fg('Label'), gui = 'bold' },
      },
      {
        function()
          local msg = icons.null_ls
          local b = vim.api.nvim_get_current_buf()
          for tool, _ in pairs(require('languages').get_tools_by_filetype(vim.api.nvim_buf_get_option(b, 'ft'))) do
            if vim.fn.executable(tool) == 1 then
              msg = msg .. tool .. ' '
            else
              msg = msg .. tool .. '! '
            end
          end
          return vim.trim(msg)
        end,
        color = { fg = extras.fg('Statement'), gui = 'bold' },
      },
    },
    lualine_y = {
      { 'filetype', separator = '', padding = { left = 1, right = 0 } },
      { 'encoding', separator = '', padding = { left = 1, right = 0 } },
      'fileformat',
    },
    lualine_z = {
      { 'progress', separator = '', padding = { left = 1, right = 0 } },
      { 'location', separator = '', padding = { left = 1, right = 0 } },
    },
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
