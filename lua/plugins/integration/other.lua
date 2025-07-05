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
  {
    -- Paste image from clipboard
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>p',
        '<cmd>PasteImage<cr>',
        desc = 'Paste image from system clipboard',
      },
    },
  },
}
