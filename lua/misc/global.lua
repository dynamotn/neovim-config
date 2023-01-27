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
  vim.notify(
    'Nvim configuration reloaded!',
    vim.log.levels.INFO,
    { title = 'Reload' }
  )

  if has_changed_plugins then
    require('lazy').sync()
    vim.api.nvim_command('redraw')
  end
end
------------------------------ }

-- Mapping for Enter key in edit mode {
_G.dynamo_mapping_enter = function()
  local present, autopairs = pcall(require, 'nvim-autopairs')

  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return present and autopairs.esc('<C-y>') or '<C-y>'
    else
      return present and autopairs.esc('<C-e>') .. autopairs.autopairs_cr()
        or '<C-e><CR>'
    end
  else
    return present and autopairs.autopairs_cr() or '<CR>'
  end
end
------------------------------------- }

-- Mapping for Backspace key in edit mode {
_G.dynamo_mapping_backspace = function()
  local present, autopairs = pcall(require, 'nvim-autopairs')

  local bufnr = vim.api.nvim_get_current_buf()

  if
    vim.fn.pumvisible() ~= 0
    and vim.fn.complete_info({ 'mode' }).mode == 'eval'
  then
    return present and autopairs.esc('<C-e>') .. autopairs.autopairs_bs(bufnr)
      or '<C-e><BS>'
  else
    return present and autopairs.autopairs_bs(bufnr) or '<BS>'
  end
end
----------------------------------------- }

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
  vim.lsp.codelens.display()
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
  vim.lsp.buf.hover()
end
--------------------------------------------------- }

-- Check LSP method textDocument/codeAction
-- is supported and show lightbulb          {
_G.dynamo_lsp_codeaction = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.codeActionProvider
  end)
  if not client_ok or not method_supported then
    return
  end
  local present, lightbulb = pcall(require, 'nvim-lightbulb')
  if present then
    lightbulb.update_lightbulb()
  end
end
------------------------------------------- }

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
  local result, err = client.request_sync(
    'textDocument/formatting',
    vim.lsp.util.make_formatting_params(),
    nil,
    bufnr
  )
  if result and result.result then
    vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
  elseif err then
    vim.notify('vim.lsp.buf.formatting_sync: ' .. err, vim.log.levels.WARN)
  end
end
--------------------------------------------------------------- }

-- Activate tool with null_ls {
_G.dynamo_nullls_tool = function(
  name,
  method,
  is_external_tool,
  is_custom_tool,
  with_config
)
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
  local language =
    require('languages').get_language_from_filetype(vim.bo.filetype)

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
