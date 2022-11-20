---------------------------------------
--      Automatic Group setting      --
---------------------------------------
local ex_cmd = vim.api.nvim_command -- Execute Vim ex commands
local M = {}

M.create_augroups = function(definitions, is_buffer, client_id)
  for group_name, definition in pairs(definitions) do
    if client_id then
      ex_cmd('augroup ' .. group_name .. client_id)
    else
      ex_cmd('augroup ' .. group_name)
    end
    if is_buffer then
      ex_cmd('autocmd! * <buffer>')
    else
      ex_cmd('autocmd!')
    end
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten({ 'autocmd', def }), ' ')
      ex_cmd(command)
    end
    ex_cmd('augroup END')
  end
end

M.delete_augroups = function(name)
  vim.schedule(function()
    if vim.fn.exists('#' .. name) == 1 then
      vim.cmd('augroup ' .. name)
      vim.cmd('autocmd!')
      vim.cmd('augroup END')
    end
  end)
end

M.load_default_augroups = function()
  local present, path = pcall(require, 'plenary.path')

  if not present then
    return
  end

  local config_path = path:new():absolute()

  M.create_augroups({
    sync_plugin_list = {
      { 'BufWritePost', config_path .. 'lua/plugins/list.lua', 'lua dynamo_reload_nvim_config(true)' },
      { 'BufWritePost', config_path .. 'lua/languages/*/plugins.lua', 'lua dynamo_reload_nvim_config(true)' },
    },
    reload_nvim_config = {
      { 'User', 'PackerComplete', [[lua require('plugins')]] },
      { 'User', 'PackerComplete', 'UpdateRemotePlugins' },
    },
    mkdir_saving = {
      { 'BufWritePre', '*', 'lua dynamo_mkdir_saving()' },
    },
    terminal = {
      { 'BufEnter', '*', 'lua dynamo_setft_terminal()' },
    },
    quick_quit_manual = {
      { 'FileType', 'qf,help,man,lspinfo,lsp-installer', 'nnoremap <silent> <buffer> q :close<CR>' },
      { 'StdinReadPre', '*', 'let s:std_in=1' },
      {
        'VimEnter',
        '*',
        [[if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'Neotree' | wincmd p | ene | exe 'cd '.argv()[0] | endif]],
      },
      {
        'VimEnter',
        '*',
        [[if argc() == 0 && !exists('s:std_in') | exe 'Neotree' | endif]],
      },
    },
  })
end

M.enable_highlight_document = function(client_id)
  M.create_augroups({
    highlight_lsp = {
      { 'CursorHold', '<buffer>', string.format('lua dynamo_lsp_document_highlight(%d)', client_id) },
      { 'CursorMoved', '<buffer>', 'lua vim.lsp.buf.clear_references()' },
    },
  }, true, client_id)
end

M.disable_highlight_document = function()
  M.delete_augroups('highlight_lsp')
end

M.enable_codelens = function(client_id)
  M.create_augroups({
    codelens_lsp = {
      { 'InsertLeave', '<buffer>', string.format('lua dynamo_lsp_codelens(%d)', client_id) },
    },
  }, true, client_id)
end

M.disable_codelens = function()
  M.delete_augroups('codelens_lsp')
end

M.enable_hover = function(client_id)
  M.create_augroups({
    hover_lsp = {
      { 'CursorHold', '<buffer>', string.format('lua dynamo_lsp_hover(%d)', client_id) },
    },
  }, true, client_id)
end

M.disable_hover = function()
  M.delete_augroups('hover_lsp')
end

M.enable_codeaction = function(client_id)
  M.create_augroups({
    codeaction_lsp = {
      { 'CursorHold,CursorHoldI', '<buffer>', string.format('lua dynamo_lsp_codeaction(%d)', client_id) },
    },
  }, true, client_id)
end

M.disable_codeaction = function()
  M.delete_augroups('codeaction_lsp')
end

M.enable_formatting = function(client_id)
  M.create_augroups({
    formatting_lsp = {
      { 'BufWritePre', '<buffer>', string.format('lua dynamo_lsp_formatting(%d)', client_id) },
    },
  }, true, client_id)
end

M.disable_formatting = function()
  M.delete_augroups('formatting_lsp')
end

return M
