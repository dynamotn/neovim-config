local supported_filetypes = {}
local languages_list = vim.tbl_filter(
  function(config) return config.otter end,
  require('config.languages')
)
for _, config in pairs(languages_list) do
  vim.list_extend(supported_filetypes, config.filetypes)
end

--- Whether otter should manage a buffer: a real file of a supported filetype,
--- not yet activated, and not one of otter's own `<path>.otter.<ext>`
--- buffers, which carry the filetype of the embedded code and would otherwise
--- activate otter inside otter.
---@param bufnr integer
---@return boolean
local function should_activate(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buftype == ''
    and name ~= ''
    and not name:find('%.otter%.[^/]*$')
    and vim.tbl_contains(supported_filetypes, vim.bo[bufnr].filetype)
    and require('otter.keeper').rafts[bufnr] == nil
end

--- Deferred past the FileType event that asks for it: otter sets the filetype
--- of each buffer it creates, and the FileType handlers that sets off (parser
--- installs, language servers) fail when nested inside another FileType.
---@param bufnr integer
local function activate(bufnr)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) and should_activate(bufnr) then
      vim.api.nvim_buf_call(bufnr, function() require('otter').activate() end)
    end
  end)
end

return {
  {
    -- LSP for embedded language
    'jmbuhr/otter.nvim',
    enabled = _G.used_full_plugins or _G.enabled_plugins.otter,
    ft = supported_filetypes,
    keys = {
      {
        '<leader>co',
        function() require('otter').activate() end,
        desc = 'Activate Otter',
      },
      {
        '<leader>cO',
        function() require('otter').deactivate() end,
        desc = 'Deactivate Otter',
      },
    },
    opts = {
      lsp = {
        -- Refresh diagnostics of embedded code while editing, not only on save
        diagnostic_update_events = {
          'BufWritePost',
          'InsertLeave',
          'TextChanged',
        },
      },
      buffers = {
        ignore_pattern = {
          -- A GitHub Actions expression is never valid shell, and shellcheck
          -- reports every line holding one
          bash = '%${{',
        },
      },
    },
    config = function(_, opts)
      require('otter').setup(opts)
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('dy_otter_activate', {}),
        pattern = supported_filetypes,
        callback = function(args) activate(args.buf) end,
      })
      -- The FileType event that loaded the plugin has already passed
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        activate(bufnr)
      end
    end,
  },
}
