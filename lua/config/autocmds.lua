local set_ft_terminal = function()
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

local enable_cursorline = function()
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

-- Install LSP servers, DAP servers, linter, formatter for window buffer
local auto_install_mason_tools = function()
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    group = vim.api.nvim_create_augroup('mason_tools', {}),
    callback = function()
      local languages = require('util.languages')
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

enable_cursorline()
set_ft_terminal()
-- auto_install_mason_tools()
