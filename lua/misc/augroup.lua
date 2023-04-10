---------------------------------------
--      Automatic Group setting      --
---------------------------------------
local M = {}

M.load_default_augroups = function()
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('mkdir_saving', {}),
    callback = function()
      dynamo_mkdir_saving()
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('terminal', {}),
    callback = function()
      dynamo_setft_terminal()
    end,
  })

  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { 'qf,help,man,lspinfo,lsp-installer' },
    group = vim.api.nvim_create_augroup('quick_quit_manual', {}),
    command = 'nnoremap <silent> <buffer> q :close<CR>',
  })

  vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('lastplace', {}),
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
  })

  vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('neotree', {}),
    command = [[if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'lua dynamo_file_explorer()' | wincmd p | ene | exe 'cd '.argv()[0] | endif]],
  })
end

M.enable_highlight_document = function(client_id)
  local id = vim.api.nvim_create_augroup('highlight_lsp', {})

  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    buffer = 0,
    group = id,
    callback = function()
      dynamo_lsp_document_highlight(client_id)
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

M.disable_highlight_document = function()
  vim.api.nvim_del_augroup_by_name('highlight_lsp')
end

M.enable_codelens = function(client_id)
  dynamo_lsp_codelens(client_id)

  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('codelens_lsp', {}),
    callback = function()
      dynamo_lsp_codelens(client_id)
    end,
  })
end

M.disable_codelens = function()
  vim.api.nvim_del_augroup_by_name('codelens_lsp')
end

M.enable_hover = function(client_id)
  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('hover_lsp', {}),
    callback = function()
      dynamo_lsp_hover(client_id)
    end,
  })
end

M.disable_hover = function()
  vim.api.nvim_del_augroup_by_name('hover_lsp')
end

M.enable_codeaction = function(client_id)
  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('codeaction_lsp', {}),
    callback = function()
      dynamo_lsp_codeaction(client_id)
    end,
  })
end

M.disable_codeaction = function()
  vim.api.nvim_del_augroup_by_name('codeaction_lsp')
end

M.enable_formatting = function(client_id)
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('formatting_lsp', {}),
    callback = function()
      dynamo_lsp_formatting(client_id)
    end,
  })
end

M.disable_formatting = function()
  vim.api.nvim_del_augroup_by_name('formatting_lsp')
end

M.auto_install_ts_parser = function()
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('ts_parser_manager', {}),
    callback = function()
      dynamo_ts_install()
    end,
  })
end

M.auto_install_mason_tools = function()
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('mason_tools', {}),
    callback = function()
      dynamo_mason_install()
    end,
  })
end

return M
