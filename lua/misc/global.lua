-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--      Useful global functions      --
---------------------------------------

-- Unload neovim module {
_G.dynamo_unload_module = function(module_name, reload)
  reload = reload or false

  for name, _ in pairs(package.loaded) do
    if name:match('^' .. module_name) then
      package.loaded[name] = nil
    end
  end

  if reload then
    require(module_name)
  end
end
-- }

-- Reload neovim configuration {
_G.dynamo_reload_nvim_config = function(has_changed_plugins)
  dynamo_unload_module('core', true)
  dynamo_unload_module('plugins', true)
  dynamo_unload_module('misc', true)
  dynamo_unload_module('languages', true)

  dofile(vim.env.MYVIMRC)
  vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO, { title = 'Reload' })

  if has_changed_plugins then
    require('lazy').sync()
    vim.api.nvim_command('redraw')
  end
end
------------------------------ }
-- Check LSP method textDocument/documentHighlight is supported {
_G.dynamo_lsp_document_highlight = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.documentHighlightProvider
  end)
  if not client_ok or not method_supported then
    return
  end
  vim.lsp.buf.document_highlight()
end
--------------------------------------------------------------- }

-- Check LSP method textDocument/codeLens is supported {
_G.dynamo_lsp_codelens = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.codeLensProvider
  end)
  if not client_ok or not method_supported then
    return
  end
  vim.lsp.codelens.refresh()
  vim.lsp.codelens.display(nil, vim.api.nvim_get_current_buf(), id)
end
------------------------------------------------------ }

-- Check LSP method textDocument/hover is supported {
_G.dynamo_lsp_hover = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.hoverProvider
  end)
  if not client_ok or not method_supported then
    return
  end
  if pcall(require, 'lspsaga') then
    require('lspsaga.hover'):render_hover_doc({})
  else
    vim.lsp.buf.hover()
  end
end
--------------------------------------------------- }

-- Check LSP method textDocument/codeAction is supported {
_G.dynamo_lsp_codeaction = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.codeActionProvider
  end)
  if not client_ok or not method_supported then
    return
  end
end
-------------------------------------------------------- }

-- Check LSP method textDocument/formatting is supported {
_G.dynamo_lsp_formatting = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.documentFormattingProvider
  end)
  if not client_ok or not method_supported then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_client_by_id(id)
  local result, err = client.request_sync('textDocument/formatting', vim.lsp.util.make_formatting_params(), nil, bufnr)
  if result and result.result then
    vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
  elseif err then
    vim.notify('vim.lsp.buf.formatting_sync: ' .. err, vim.log.levels.WARN)
  end
end
--------------------------------------------------------------- }

-- Activate tool with null_ls {
_G.dynamo_nullls_tool = function(name, method, is_external_tool, is_custom_tool, with_config)
  with_config = with_config or {}
  is_external_tool = is_external_tool == nil and true or is_external_tool
  is_custom_tool = is_custom_tool == nil and false or is_custom_tool
  local source
  if is_custom_tool then
    local ok, _ = pcall(require, 'tools.' .. method .. '.' .. name)

    if not ok then
      return
    end
    source = require('tools.' .. method .. '.' .. name).with(with_config)
  else
    source = require('null-ls').builtins[method][name].with(with_config)
  end

  if is_external_tool then
    return vim.fn.executable(name) == 1 and source
  else
    return source
  end
end
------------------------------ }

-- Get dial group from buffer filetype {
_G.dynamo_dial_group = function()
  local present, dial = pcall(require, 'dial.config')
  if not present then
    return 'default'
  end
  local language = require('languages').get_language_from_filetype(vim.bo.filetype)

  if dial.augends:get(language) then
    return language
  end
  return 'default'
end
------------------------------- }

-- Global command sequence when mapping key {
_G.dynamo_cmdcr = function(body)
  return '<cmd>' .. body .. '<CR>'
end
------------------------------------------- }

-- Whichkey mapping for filetypes {
_G.dynamo_whichkey = {}
--------------------------------- }

-- Make directory when saving {
_G.dynamo_mkdir_saving = function()
  local dir = vim.fn.expand('<afile>:p:h')

  if dir:find('%l+://') == 1 then
    return
  end

  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end
----------------------------- }

-- Set filetype for terminal {
_G.dynamo_setft_terminal = function()
  if vim.bo.buftype == 'terminal' then
    vim.bo.filetype = 'terminal'
  end
end
---------------------------- }

-- Install TS parsers for window buffer {
_G.dynamo_ts_install = function(bufnr)
  require('lazy').load({ plugins = { 'treesitter' } })
  local languages = require('languages')

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local parsers = languages.get_parsers_by_filetype(vim.api.nvim_buf_get_option(bufnr, 'ft'))
  for _, parser in ipairs(parsers) do
    if next(vim.api.nvim_get_runtime_file('parser/' .. parser .. '.so', true)) == nil then
      vim.api.nvim_command('TSInstall ' .. parser)
    end
  end
end
--------------------------------------- }

-- Install LSP servers, DAP servers, linter, formatter for window buffer {
_G.dynamo_mason_install = function(bufnr)
  require('lazy').load({ plugins = { 'mason' } })
  local languages = require('languages')
  local registry = require('mason-registry')
  local lsp_mapping = require('mason-lspconfig.mappings.server')
  local dap_mapping = require('mason-nvim-dap.mappings.source')
  local null_ls_mapping = require('mason-null-ls.mappings.source')

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local lsp_servers = languages.get_ls_by_filetype(vim.api.nvim_buf_get_option(bufnr, 'ft'))
  for _, lsp_server in ipairs(lsp_servers) do
    local server = lsp_mapping.lspconfig_to_package[lsp_server]
    if server ~= nil and not registry.is_installed(server) then
      vim.api.nvim_command('MasonInstall ' .. server)
    end
  end

  local dap_servers = languages.get_dap_by_filetype(vim.api.nvim_buf_get_option(bufnr, 'ft'))
  for _, dap_server in ipairs(dap_servers) do
    local server = dap_mapping.nvim_dap_to_package[dap_server]
    if server ~= nil and not registry.is_installed(server) then
      vim.api.nvim_command('MasonInstall ' .. server)
    end
  end

  local null_ls_tools = languages.get_tools_by_filetype(vim.api.nvim_buf_get_option(bufnr, 'ft'))
  if null_ls_tools == nil then
    return
  end
  for null_ls_tool, is_external_tool in pairs(null_ls_tools) do
    if not is_external_tool then
      local tool = null_ls_mapping.getPackageFromNullLs[null_ls_tool]
      if tool ~= nil and not registry.is_installed(tool) then
        vim.api.nvim_command('MasonInstall ' .. tool)
      end
    end
  end
end
--------------------------------------- }

-- Check filetype is gotemplate {
_G.dynamo_gotemplate_detection = function(bufnr)
  local content = function()
    local content = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(0), false)
    return table.concat(content, '\n')
  end
  if content():match('{{.+}}') then
    return 'gotmpl'
  end
end
------------------------------- }

-- Get foreground color from highlight group {
_G.dynamo_fg = function(name)
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  local fg = hl and hl.fg or hl.foreground
  return fg and string.format('#%06x', fg)
end
-------------------------------------------- }

-- Check plugin is declared in spec {
_G.dynamo_list_plugins = {}
_G.dynamo_has_plugin = function(plugin)
  return vim.list_contains(_G.dynamo_list_plugins, plugin)
end
----------------------------------- }
