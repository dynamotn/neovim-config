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
  {
    -- Input method switcher
    'drop-stones/im-switch.nvim',
    event = 'VeryLazy',
    opts = {
      macos = {
        enabled = vim.loop.os_uname().sysname == 'Darwin',
        default_im = 'com.apple.keylayout.USExtended',
      },
      linux = {
        enabled = vim.loop.os_uname().sysname == 'Linux',
        default_im = 'keyboard-us',
        get_im_command = { 'fcitx5-remote', '-n' },
        set_im_command = { 'fcitx5-remote', '-g', 'English' },
      },
    },
  },
}
