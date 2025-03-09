local supported_filetypes = {}
local languages_list = vim.tbl_filter(
  function(config) return config.endwise end,
  require('config.languages')
)
for _, config in pairs(languages_list) do
  vim.list_extend(supported_filetypes, config.filetypes)
end

return {
  {
    'nvim-treesitter',
    opts = {
      endwise = {
        enable = true,
      },
    },
  },
  {
    -- Automatically insert end keyword
    'RRethy/nvim-treesitter-endwise',
    event = { 'BufReadPost', 'BufNewFile' },
    ft = supported_filetypes,
    config = function()
      if LazyVim.is_loaded('nvim-treesitter') then
        local opts = LazyVim.opts('nvim-treesitter')
        require('nvim-treesitter.configs').setup({ endwise = opts.endwise })
      end
    end,
  },
}
