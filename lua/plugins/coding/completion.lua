return {
  {
    -- Fuzzy path source for cmdline
    'tzachar/cmp-fuzzy-path',
    dependencies = {
      'tzachar/fuzzy.nvim',
      dependencies = {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        enabled = vim.fn.executable('make') == 1 or _G.used_full_plugins,
      },
    },
  },
  'mikavilpas/blink-ripgrep.nvim', -- Ripgrep
  'Kaiser-Yang/blink-cmp-dictionary', -- Dictionary source
  'hrsh7th/cmp-calc', -- Math calculation
  'andersevenrud/cmp-tmux', -- Tmux buffer source
  {
    -- Dynamic source
    'uga-rosa/cmp-dynamic',
    config = function()
      require('cmp_dynamic').register({
        {
          label = 'today',
          insertText = function() return os.date('%d/%m/%Y') end,
        },
        {
          label = 'today',
          insertText = function() return os.date('%Y/%m/%d') end,
        },
        {
          label = 'now',
          insertText = function() return os.date('%H:%M:%S %d/%m/%Y') end,
        },
        {
          label = 'now',
          insertText = function() return os.date('%Y_%m_%d_%H_%M') end,
        },
        {
          label = 'timestamp',
          insertText = function() return os.date('%s') end,
        },
      })
    end,
  },
  {
    -- Engine for completion
    'saghen/blink.cmp',
    dependencies = {
      'saghen/blink.compat',
      'onsails/lspkind.nvim', -- pictograms
      'cmp-fuzzy-path',
      'blink-cmp-dictionary',
      'cmp-calc',
      'cmp-tmux',
      'cmp-dynamic',
      'blink-ripgrep.nvim',
    },
    opts = {
      sources = {
        -- compatible sources from nvim-cmp
        compat = { 'fuzzy_path', 'calc', 'tmux', 'dynamic' },
        providers = {
          -- self download dictionaries
          dictionary = {
            module = 'blink-cmp-dictionary',
            name = 'dictionary',
            min_keyword_length = 3,
            score_offset = -20,
            opts = {
              dictionary_directories = {
                vim.fn.expand('~/.config/dictionaries'),
              },
            },
          },
          -- ripgrep all files in folder
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'ripgrep',
          },
          -- text from all buffers
          buffer = {
            opts = {
              get_bufnrs = function()
                return vim.tbl_filter(
                  function(bufnr) return vim.bo[bufnr].buftype == '' end,
                  vim.api.nvim_list_bufs()
                )
              end,
            },
            score_offset = 18,
          },
          -- path with start point from root of project, not current folder
          project_path = {
            module = 'blink.cmp.sources.path',
            name = 'project_path',
            opts = {
              get_cwd = function(_) return require('lazyvim.util.root').get() end,
            },
          },
          lsp = {
            score_offset = 20,
          },
          snippets = {
            score_offset = 19,
          },
          cmdline = {
            score_offset = 20,
          },
          fuzzy_path = {
            min_keyword_length = 3,
            score_offset = -20,
          },
        },
        default = function() return require('util.cmp').setup_default_sources() end,
        per_filetype = {},
      },
      -- enable fuzzy for input words with every length
      fuzzy = {
        max_typos = function() return 0 end,
      },
      -- show signature of LSP function...
      signature = { enabled = true },
      -- completion for command line
      cmdline = {
        enabled = true,
        keymap = {
          -- tab for only select
          ['<Tab>'] = {
            'show_and_insert',
            'select_next',
          },
          -- auto accept ghost text by Right key
          ['<Right>'] = {
            function(cmp)
              if cmp.is_ghost_text_visible() then return cmp.accept() end
            end,
            'fallback',
          },
          -- only use Left for move cursor
          ['<Left>'] = {
            'fallback',
          },
        },
        -- need to auto show completion menu
        completion = { menu = { auto_show = true } },
        sources = function()
          local type = vim.fn.getcmdtype()
          -- Search forward and backward
          if type == '/' or type == '?' then return { 'buffer' } end
          -- Commands
          if type == ':' or type == '@' then
            return { 'cmdline', 'path', 'fuzzy_path', 'buffer' }
          end
          return {}
        end,
      },
      completion = {
        documentation = { window = { border = 'rounded' } },
        menu = {
          border = 'rounded',
          draw = {
            columns = {
              { 'source_name', 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local icon = ctx.kind_icon
                  -- Show icon of file when source is Path
                  if
                    vim.tbl_contains(
                      { 'Path', 'fuzzy_path', 'project_path' },
                      ctx.source_name
                    )
                  then
                    local dev_icon, _ =
                      require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then icon = dev_icon end
                  else
                    local kind_icons = require('config.defaults').icons.kinds
                    if kind_icons[ctx.source_name] then
                      icon = kind_icons[ctx.source_name]
                    else
                      icon = require('lspkind').symbolic(ctx.kind, {
                        mode = 'symbol',
                      })
                    end
                  end

                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from nvim-web-devicons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  local hl = 'BlinkCmpKind' .. ctx.kind
                    or require('blink.cmp.completion.windows.render.tailwind').get_hl(
                      ctx
                    )
                  if
                    vim.tbl_contains(
                      { 'Path', 'fuzzy_path', 'project_path' },
                      ctx.source_name
                    )
                  then
                    local dev_icon, dev_hl =
                      require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then hl = dev_hl end
                  end
                  return hl
                end,
              },
              source_name = {
                text = function(ctx)
                  if
                    vim.tbl_contains({ 'Path', 'fuzzy_path' }, ctx.source_name)
                  then
                    return _G.completion_sources['Path']
                  end
                  return _G.completion_sources[ctx.source_name]
                    or ctx.source_name
                end,
              },
            },
          },
        },
      },
    },
    init = function()
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        Path = '「PATH」',
        project_path = '「PROJ」',
        Snippets = '「SNIP」',
        LSP = '「LSP」',
        Buffer = '「BUF」',
        ripgrep = '「FILE」',
        dictionary = '「DICT」',
        calc = '「CALC」',
        tmux = '「MUX」',
        dynamic = '「MISC」',
        Cmdline = '「CMD」',
      })
    end,
  },
}
