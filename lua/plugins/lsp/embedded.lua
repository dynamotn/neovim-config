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
      -- `otter.lsp` asks `require('blink.cmp')` for client capabilities as it
      -- loads, and lazy.nvim answers that by loading blink.cmp with every
      -- source it depends on -- ~400ms on opening any YAML or Markdown file,
      -- for a completion engine that is meant to wait for `InsertEnter`. The
      -- answer is wasted besides: otter's server is in-process and replies to
      -- `initialize` with a fixed set of capabilities, never reading the
      -- client's. So the lookup is made to fail while otter loads, and otter
      -- falls back to Neovim's own capabilities. A blink.cmp that is already
      -- loaded is left alone.
      if not package.loaded['blink.cmp'] then
        package.preload['blink.cmp'] = function()
          error('blink.cmp is not loaded yet')
        end
        local ok, err = pcall(require, 'otter.lsp')
        package.preload['blink.cmp'] = nil
        -- LuaJIT leaves a sentinel behind for a module whose loader failed,
        -- and every later `require` would get that back instead of blink.cmp
        package.loaded['blink.cmp'] = nil
        if not ok then error(err, 0) end
      end
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
