return {
  {
    -- Browser
    'glacambre/firenvim',
    build = function()
      require('lazy').load({ plugins = 'firenvim', wait = true })
      vim.fn['firenvim#install'](0)
    end,
    enabled = _G.is_gui_machine or _G.used_full_plugins,
    lazy = not vim.g.started_by_firenvim,
    config = function(_, _)
      vim.o.laststatus = 0
      vim.o.showtabline = 0
      vim.g.firenvim_config = {
        globalSettings = {
          alt = 'all',
        },
        localSettings = {
          [ [[.*]] ] = {
            cmdline = 'firenvim',
            content = 'text',
            priority = 0,
            selector = 'textarea:not([readonly]):not([class="handsontableInput"]), div[role="textbox"], div[role="presentation"]',
            takeover = 'always',
          },
          [ [[.*google.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*facebook.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*notion\.so.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*docs\.google\.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*mail\.google\.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*web\.telegram\.org.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*jira\..*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*chat\..*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*cloudflare\..*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*\.sharepoint\.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*\.office\.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*teams\.microsoft\.com.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
          [ [[.*github\.com\/.*\/blob\/.*]] ] = {
            priority = 9,
            takeover = 'never',
          },
        },
      }
    end,
  },
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
    -- Open current word by other tools
    'ofirgall/open.nvim',
    dependencies = { 'plenary.nvim' },
    config = function(_, opts)
      local open = require('open')
      open.setup(opts)

      open.register_opener({
        name = 'Jira',
        open_fn = function(text)
          local urls = {}
          for url in text:gmatch('%w+-%d+') do
            table.insert(urls, (vim.env.JIRA_URL or 'https://jira.atlassian.com/browse/') .. url)
          end

          return urls
        end,
      })

      open.register_opener({
        name = 'Jira',
        open_fn = function(text)
          local urls = {}
          for url in text:gmatch('%w+-%d+') do
            table.insert(urls, (vim.env.JIRA_URL or 'https://jira.atlassian.com/browse/') .. url)
          end

          return urls
        end,
      })
    end,
  },
}
