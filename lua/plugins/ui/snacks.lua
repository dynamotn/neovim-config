-- In a terminal, `<C-hjkl>` leaves a split terminal for the next window and
-- goes through to the program in a floating one
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and '<c-' .. dir .. '>'
      or vim.schedule(function() vim.cmd.wincmd(dir) end)
  end
end

return {
  {
    -- Collection of small QoL plugins. Loaded first, so `Snacks` is there for
    -- every other spec, and for `config.globals`.
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- `config.options` sets it
      toggle = { map = require('util.plugin').safe_keymap_set },
      words = { enabled = true },
      terminal = {
        win = {
          keys = {
            nav_h = {
              '<C-h>',
              term_nav('h'),
              desc = 'Go to Left Window',
              expr = true,
              mode = 't',
            },
            nav_j = {
              '<C-j>',
              term_nav('j'),
              desc = 'Go to Lower Window',
              expr = true,
              mode = 't',
            },
            nav_k = {
              '<C-k>',
              term_nav('k'),
              desc = 'Go to Upper Window',
              expr = true,
              mode = 't',
            },
            nav_l = {
              '<C-l>',
              term_nav('l'),
              desc = 'Go to Right Window',
              expr = true,
              mode = 't',
            },
            hide_slash = {
              '<C-/>',
              'hide',
              desc = 'Hide Terminal',
              mode = 't',
            },
            hide_underscore = {
              '<c-_>',
              'hide',
              desc = 'which_key_ignore',
              mode = 't',
            },
          },
        },
      },
      dashboard = {
        preset = {
          pick = function(cmd, opts) return require('util.pick')(cmd, opts)() end,
          header = [[
╔━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╗
┃  $$$$$$$\            $$\   $$\                       ┃
┃  $$  __$$\           $$$\  $$ |                      ┃
┃  $$ |  $$ |$$\   $$\ $$$$\ $$ | $$$$$$\   $$$$$$\    ┃
┃  $$ |  $$ |$$ |  $$ |$$ $$\$$ |$$  __$$\ $$  __$$\   ┃
┃  $$ |  $$ |$$ |  $$ |$$ \$$$$ |$$$$$$$$ |$$ /  $$ |  ┃
┃  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$   ____|$$ |  $$ |  ┃
┃  $$$$$$$  |\$$$$$$$ |$$ | \$$ |\$$$$$$$\ \$$$$$$  |  ┃
┃  \_______/  \____$$ |\__|  \__| \_______| \______/   ┃
┃            $$\   $$ |                                ┃
┃            \$$$$$$  |                                ┃
┃             \______/                                 ┃
╚━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╝
]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'p', desc = 'Projects', action = ':lua Snacks.picker.projects()' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader>n', function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end, desc = 'Notification History' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
      { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
      { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
      { '<leader>dps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Buffer' },
    },
    config = function(_, opts)
      local notify = vim.notify
      require('snacks').setup(opts)
      -- Hand `vim.notify` back for noice.nvim to take over, so notifications
      -- sent before it loads still reach its history
      if require('util.plugin').has('noice.nvim') then vim.notify = notify end
      -- Render d2 diagrams through `Snacks.image`
      require('tools.diagram.d2.snacks')
    end,
  },
}
