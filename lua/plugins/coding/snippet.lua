return {
  -- Use Luasnip for Snipmate Snipmate
  { import = 'lazyvim.plugins.extras.coding.luasnip' },
  {
    'LuaSnip',
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      {
        'honza/vim-snippets',
        config = function()
          require('luasnip.loaders.from_snipmate').lazy_load()
        end,
      },
    },
  },
}
