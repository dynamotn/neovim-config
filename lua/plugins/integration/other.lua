return {
  {
    -- Terminal
    'akinsho/nvim-toggleterm.lua',
    event = 'VeryLazy',
    opts = {
      open_mapping = '<F3>',
    },
  },
  {
    -- Translate
    'potamides/pantran.nvim',
    cmd = 'Pantran',
    opts = {
      default_engine = 'google',
      engines = {
        google = {
          fallback = {
            default_source = 'en',
            default_target = 'vi',
          },
        },
      },
    },
  },
}
