local M = {}

M.set_ft_terminal = function()
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('terminal', {}),
    callback = function()
      if vim.bo.buftype == 'terminal' then
        vim.bo.filetype = 'terminal'
      end
    end,
  })
end

M.enable_highlight_document = function(client_id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(client_id).server_capabilities.documentHighlightProvider
  end)
  if not client_ok or not method_supported then
    return
  end

  local id = vim.api.nvim_create_augroup('highlight_lsp', {})

  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    buffer = 0,
    group = id,
    callback = function()
      vim.lsp.buf.document_highlight()
    end,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
    buffer = 0,
    group = id,
    callback = function()
      vim.lsp.buf.clear_references()
    end,
  })
end

M.enable_codelens = function(client_id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(client_id).server_capabilities.codeLensProvider
  end)
  if not client_ok or not method_supported then
    return
  end

  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'BufReadPost' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('codelens_lsp', {}),
    callback = function()
      vim.lsp.codelens.refresh()
      vim.lsp.codelens.display(nil, vim.api.nvim_get_current_buf(), client_id)
    end,
  })
end

M.enable_hover = function(client_id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(client_id).server_capabilities.hoverProvider
  end)
  if not client_ok or not method_supported then
    return
  end

  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('hover_lsp', {}),
    callback = function()
      if pcall(require, 'lspsaga') then
        require('lspsaga.hover'):render_hover_doc({})
      else
        vim.lsp.buf.hover()
      end
    end,
  })
end

M.enable_codeaction = function(client_id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(client_id).server_capabilities.codeActionProvider
  end)
  if not client_ok or not method_supported then
    return
  end

  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('codeaction_lsp', {}),
    callback = function()
      vim.lsp.buf.code_action()
    end,
  })
end

M.enable_inlayhint = function(client_id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(client_id).server_capabilities.inlayHintProvider
  end)
  if not client_ok or not method_supported then
    return
  end

  vim.lsp.inlay_hint.enable(true)
end

-- Install TS parsers for window buffer
M.auto_install_ts_parser = function()
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('ts_parser_manager', {}),
    callback = function()
      require('lazy').load({ plugins = { 'treesitter' } })
      local languages = require('languages')

      local parsers = languages.get_parsers_by_filetype(vim.bo.filetype)
      for _, parser in ipairs(parsers) do
        if next(vim.api.nvim_get_runtime_file('parser/' .. parser .. '.so', true)) == nil then
          vim.api.nvim_command('TSInstall ' .. parser)
        end
      end
    end,
  })
end

-- Install LSP servers, DAP servers, linter, formatter for window buffer
M.auto_install_mason_tools = function()
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('mason_tools', {}),
    callback = function()
      require('lazy').load({ plugins = { 'mason' } })
      local languages = require('languages')
      local registry = require('mason-registry')
      local lsp_mapping = require('mason-lspconfig.mappings.server')
      local dap_mapping = require('mason-nvim-dap.mappings.source')

      local lsp_servers = languages.get_ls_by_filetype(vim.bo.filetype)
      for _, lsp_server in ipairs(lsp_servers) do
        local server = lsp_mapping.lspconfig_to_package[lsp_server]
        if server ~= nil and not registry.is_installed(server) then
          vim.api.nvim_command('MasonInstall ' .. server)
        end
      end

      local dap_servers = languages.get_dap_by_filetype(vim.bo.filetype)
      for _, dap_server in ipairs(dap_servers) do
        local server = dap_mapping.nvim_dap_to_package[dap_server]
        if server ~= nil and not registry.is_installed(server) then
          vim.api.nvim_command('MasonInstall ' .. server)
        end
      end

      local tools = languages.get_tools_by_filetype(vim.bo.filetype)
      if tools == nil then
        return
      end
      for tool, is_mason_tool in pairs(tools) do
        if is_mason_tool and not registry.is_installed(tool) then
          vim.api.nvim_command('MasonInstall ' .. tool)
        end
      end
    end,
  })
end

M.enable_cursorline = function()
  vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
    group = vim.api.nvim_create_augroup('cursor_active_window', {}),
    callback = function()
      local ok, cl = pcall(vim.api.nvim_win_get_var, 0, 'auto-cursorline')
      if ok and cl then
        vim.wo.cursorline = true
        vim.api.nvim_win_del_var(0, 'auto-cursorline')
      end
    end,
  })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
    group = vim.api.nvim_create_augroup('cursor_inactive_window', {}),
    callback = function()
      local cl = vim.wo.cursorline
      if cl then
        vim.api.nvim_win_set_var(0, 'auto-cursorline', cl)
        vim.wo.cursorline = false
      end
    end,
  })
end

M.enable_cursorline()
M.set_ft_terminal()
require('config.filetype')
local extras = require('util.extras')
-- if extras.has_plugin("treesitter") then
--   M.auto_install_ts_parser()
-- end
-- if extras.has_plugin("mason") then
--   M.auto_install_mason_tools()
-- end

-- Abbreviations
for abbr, full_text in pairs(require('config.defaults').abbreviations) do
  vim.cmd({ cmd = 'inoreabbrev', args = { abbr, full_text } })
end

local root = require('util.root')
vim.opt.rtp:append(root.get() .. '/.nvim')
