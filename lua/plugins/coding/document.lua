return {
  {
    -- Generate annotation
    'danymat/neogen',
    cmd = 'Neogen',
    keys = {
      {
        '<leader>cn',
        function() require('neogen').generate() end,
        desc = 'Generate Annotations (Neogen)',
      },
    },
    opts = {
      -- Expand through LuaSnip, the snippet engine of this config
      snippet_engine = 'luasnip',
    },
  },
}
