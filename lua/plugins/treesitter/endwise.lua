local supported_filetypes = {}
local languages_list = vim.tbl_filter(
  function(config) return config.endwise end,
  require('config.languages')
)
for _, config in pairs(languages_list) do
  vim.list_extend(supported_filetypes, config.filetypes)
end

-- The plugin attaches through a `FileType` autocmd of its own, which lazy.nvim
-- replays for the buffer that loaded it: loading on those filetypes alone is
-- enough. nvim-treesitter's `main` branch has no modules to set up.
return {
  {
    -- Automatically insert end keyword
    'RRethy/nvim-treesitter-endwise',
    ft = supported_filetypes,
  },
}
