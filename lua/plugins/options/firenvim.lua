vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.wrap = 1
vim.opt.linebreak = 1
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
  },
}
