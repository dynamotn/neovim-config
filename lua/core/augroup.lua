---------------------------------------
--      Automatic Group setting      --
---------------------------------------
local lsp = require('util.lsp')
local M = {}

M.enable_mkdir_when_save = function()
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('mkdir_saving', {}),
    callback = function()
      local dir = vim.fn.expand('<afile>:p:h')

      if dir:find('%l+://') == 1 then
        return
      end

      if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
      end
    end,
  })
end

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

M.enable_quick_quit = function()
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
    group = vim.api.nvim_create_augroup('quick_quit_manual', {}),
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
  })
end

M.load_lastplace = function()
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
end

M.auto_reload_file = function()
  vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = vim.api.nvim_create_augroup('checktime', {}),
    command = 'checktime',
  })
end

M.enable_highlight_on_yank = function()
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_when_copy', {}),
    callback = function()
      vim.highlight.on_yank()
    end,
  })
end

M.auto_resize_split = function()
  vim.api.nvim_create_autocmd({ 'VimResized' }, {
    group = vim.api.nvim_create_augroup('resize_windows', {}),
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
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

M.enable_highlight_document = function(client_id)
  local id = vim.api.nvim_create_augroup('highlight_lsp', {})

  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    buffer = 0,
    group = id,
    callback = function()
      lsp.document_highlight(client_id)
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
  lsp.codelens(client_id)

  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    buffer = 0,
    group = vim.api.nvim_create_augroup('codelens_lsp', {}),
    callback = function()
      lsp.codelens(client_id)
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
      lsp.hover(client_id)
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
      lsp.codeaction(client_id)
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
      lsp.formatting(client_id)
    end,
  })
end

M.disable_formatting = function()
  vim.api.nvim_del_augroup_by_name('formatting_lsp')
end

-- Install TS parsers for window buffer
M.auto_install_ts_parser = function()
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('ts_parser_manager', {}),
    callback = function()
      require('lazy').load({ plugins = { 'treesitter' } })
      local languages = require('languages')

      local bufnr = vim.api.nvim_get_current_buf()
      local parsers = languages.get_parsers_by_filetype(vim.api.nvim_buf_get_option(bufnr, 'ft'))
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
      local null_ls_mapping = require('mason-null-ls.mappings.source')

      local bufnr = vim.api.nvim_get_current_buf()

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
    end,
  })
end

M.setup = function()
  M.enable_mkdir_when_save()
  M.set_ft_terminal()
  M.enable_quick_quit()
  M.load_lastplace()
  M.auto_reload_file()
  M.enable_highlight_on_yank()
  M.auto_resize_split()
  M.enable_cursorline()
  M.auto_install_ts_parser()
  M.auto_install_mason_tools()

  local root = require('util.root')
  vim.opt.rtp:append(root.get() .. '/.nvim')
end

return M