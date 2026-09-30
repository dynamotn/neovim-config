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
    keys = {
      {
        '<leader>ct',
        function() vim.api.nvim_command('Pantran') end,
        desc = 'Translate',
        mode = { 'n', 'x' },
      },
    },
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
      command = {
        default_mode = 'hover',
      },
    },
  },
  {
    -- Paste image from clipboard
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = '[Image]($FILE_PATH)',
          use_absolute_path = true,
        },
      },
    },
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
    -- im-switch turns a platform on by the mere presence of its table (an
    -- `enabled` field is ignored), and on Linux it then runs the command on
    -- every `InsertLeave`. Without fcitx5 -- Termux, a container, an IBus
    -- desktop -- `vim.system` throws each time, so that table is only handed
    -- over when the command is there.
    opts = function()
      local opts = {
        macos = {
          default_im = 'com.apple.keylayout.USExtended',
        },
      }
      if vim.fn.executable('fcitx5-remote') == 1 then
        opts.linux = {
          default_im = 'keyboard-us',
          get_im_command = { 'fcitx5-remote', '-n' },
          set_im_command = { 'fcitx5-remote', '-g', 'English' },
        }
      end
      return opts
    end,
  },
}
