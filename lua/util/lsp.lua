local M = {}

-- Check LSP method textDocument/documentHighlight is supported
M.document_highlight = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.documentHighlightProvider
  end)
  if not client_ok or not method_supported then
    return
  end
  vim.lsp.buf.document_highlight()
end

-- Check LSP method textDocument/codeLens is supported
M.codelens = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.codeLensProvider
  end)
  if not client_ok or not method_supported then
    return
  end
  vim.lsp.codelens.refresh()
  vim.lsp.codelens.display(nil, vim.api.nvim_get_current_buf(), id)
end

-- Check LSP method textDocument/hover is supported
M.hover = function(id)
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

-- Check LSP method textDocument/codeAction is supported
M.codeaction = function(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).server_capabilities.codeActionProvider
  end)
  if not client_ok or not method_supported then
    return
  end
end

-- Check LSP method textDocument/formatting is supported
M.formatting = function(id)
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

return M
