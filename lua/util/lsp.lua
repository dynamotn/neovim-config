local M = {}

-- Format file on save
M.formatting = function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.buf_request(bufnr, 'textDocument/formatting', vim.lsp.util.make_formatting_params(), function(err, res, ctx)
    if err then
      local err_msg = type(err) == 'string' and err or err.message
      vim.notify('formatting: ' .. err_msg, vim.log.levels.WARN)
      return
    end

    if res then
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or 'utf-16')
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd('silent noautocmd update')
      end)
    end
  end)
end

return M
