local supported_filetypes = {}
local languages_list = vim.tbl_filter(
  function(config) return config.otter end,
  require('config.languages')
)
for _, config in pairs(languages_list) do
  vim.list_extend(supported_filetypes, config.filetypes)
end
return {
  {
    -- LSP for embedded language
    'jmbuhr/otter.nvim',
    enabled = _G.enabled_plugins.otter or _G.used_full_plugins,
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
  },
}
