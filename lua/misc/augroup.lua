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
    pattern = {
      'help',
      'lspinfo',
      'man',
      'notify',
      'qf',
      'startuptime',
      'tsplayground',
      'neotest-output',
      'checkhealth',
      'neotest-summary',
      'neotest-output-panel',
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
    group = vim.api.nvim_create_augroup('quick_quit_manual', {}),
  })

  vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('lastplace', {}),
    callback = function()
      local exclude = { 'gitcommit' }
      local buf = vim.api.nvim_get_current_buf()
      if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
        return
      end
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('neotree', {}),
    command = [[if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'lua dynamo_file_explorer()' | wincmd p | ene | exe 'cd '.argv()[0] | endif]],
  })

  vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = vim.api.nvim_create_augroup('checktime', {}),
    command = 'checktime',
  })

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_when_copy', {}),
    callback = function()
      vim.highlight.on_yank()
    end,
  })

  vim.api.nvim_create_autocmd({ 'VimResized' }, {
    group = vim.api.nvim_create_augroup('resize_windows', {}),
    callback = function()
      vim.cmd('tabdo wincmd =')
    end,
  })

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
