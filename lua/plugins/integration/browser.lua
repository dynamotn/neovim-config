local site_settings = vim.tbl_extend('force', {
  [ [[.*]] ] = {
    cmdline = 'firenvim',
    content = 'text',
    priority = 0,
    selector = 'textarea:not([readonly]):not([class="handsontableInput"]), div[role="textbox"], div[role="presentation"]',
    takeover = 'always',
  },
}, _G.firenvim_site_settings)
vim.g.firenvim_config = {
  globalSettings = { alt = 'all' },
  localSettings = site_settings,
}

return {
  {
    -- Edit on browser by neovim
    'glacambre/firenvim',
    build = function()
      require('lazy').load({ plugins = { 'firenvim' }, wait = true })
      vim.fn['firenvim#install'](0)
    end,
    enabled = _G.enabled_plugins.firenvim or _G.used_full_plugins,
    lazy = not vim.g.started_by_firenvim,
    config = function(_, _)
      vim.o.laststatus = 0
      vim.o.showtabline = 0
    end,
  },
  {
    -- Open current word by other tools
    'ofirgall/open.nvim',
    opts = {
      self_defined_openers = {
        {
          name = 'jira',
          open_fn = function(text)
            local urls = {}
            for url in text:gmatch('%w+-%d+') do
              table.insert(urls, (vim.env.JIRA_URL or 'https://jira.atlassian.com/browse/') .. url)
            end
            return urls
          end,
        },
      },
    },
    keys = {
      {
        'gx',
        function()
          require('open').open_cword()
        end,
        desc = 'Open with system app',
        mode = { 'n', 'v' },
      },
    },
    config = function(_, opts)
      local open = require('open')
      open.setup(opts)

      for _, opener in ipairs(opts.self_defined_openers) do
        open.register_opener(opener)
      end
    end,
  },
}
