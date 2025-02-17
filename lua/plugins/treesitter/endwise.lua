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
    ft = { 'sh', 'ruby', 'elixir', 'fish', 'julia', 'lua' },
    config = function()
      if LazyVim.is_loaded('nvim-treesitter') then
        local opts = LazyVim.opts('nvim-treesitter')
        require('nvim-treesitter.configs').setup({ endwise = opts.endwise })
      end
    end,
  },
}
