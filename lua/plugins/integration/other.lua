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
    -- Open files from a terminal inside Neovim in this Neovim, not a nested one
    --
    -- `git commit`, `$EDITOR` from an AI CLI or `kubectl edit` in a toggleterm
    -- or Snacks terminal hand their file over here and wait until it is
    -- written. A plain `nvim` with no file still starts a nested one.
    'willothy/flatten.nvim',
    -- Has to run before anything else to hand the files over and quit
    lazy = false,
    priority = 1001,
    -- A headless run (scripts, `check-startup`, Mason) from a terminal in
    -- Neovim would otherwise send its files here and quit before doing its job
    cond = not vim.list_contains(vim.v.argv, '--headless'),
    opts = function()
      -- The terminal the files came from, taken while it still has the focus
      ---@type { term: any, win: integer }?
      local origin

      --- Whether `path` sits in a temporary directory
      ---@param path string
      ---@return boolean
      local function is_temporary(path)
        path = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
        for _, dir in ipairs({
          vim.uv.os_tmpdir() or '',
          -- macOS gives either side of its `/private` symlinks
          '/tmp',
          '/private/tmp',
          '/var/folders',
          '/private/var/folders',
        }) do
          dir = vim.fs.normalize(dir)
          if dir ~= '' and vim.startswith(path, dir .. '/') then return true end
        end
        return false
      end

      return {
        hooks = {
          -- A program handing a temporary file to `$EDITOR` reads it back
          -- once the editor exits, so it has to wait too
          should_block = function(argv)
            if require('flatten').hooks.should_block(argv) then return true end
            for _, arg in ipairs(argv) do
              if not vim.startswith(arg, '-') and is_temporary(arg) then
                return true
              end
            end
            return false
          end,
          pre_open = function()
            local ok, terminal = pcall(require, 'toggleterm.terminal')
            local id = ok and terminal.get_focused_id()
            origin = {
              term = id and terminal.get(id) or nil,
              win = vim.api.nvim_get_current_win(),
            }
          end,
          post_open = function(opts)
            -- Get a floating terminal out of the way of the file; a split
            -- one, like an AI CLI's, can stay next to it
            if origin and origin.term then
              origin.term:close()
            elseif
              origin
              and vim.api.nvim_win_is_valid(origin.win)
              and vim.api.nvim_win_get_config(origin.win).relative ~= ''
            then
              vim.api.nvim_win_hide(origin.win)
            end
            if opts.winnr and vim.api.nvim_win_is_valid(opts.winnr) then
              vim.api.nvim_set_current_win(opts.winnr)
            end
            if not opts.is_blocking then
              origin = nil
              return
            end
            -- `:w` is enough to finish: the buffer goes, its window stays
            vim.api.nvim_create_autocmd('BufWritePost', {
              buffer = opts.bufnr,
              once = true,
              callback = vim.schedule_wrap(
                function() Snacks.bufdelete({ buf = opts.bufnr }) end
              ),
            })
          end,
          -- Bring a toggleterm back once the program it runs carries on
          block_end = vim.schedule_wrap(function()
            if origin and origin.term then origin.term:open() end
            origin = nil
          end),
        },
        nest_if_no_args = true,
        window = {
          -- The terminal is the current window; open next to it, not in it
          open = 'alternate',
        },
      }
    end,
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
        -- Avante pastes through img-clip itself, and sends the file it saved
        AvanteInput = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
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
