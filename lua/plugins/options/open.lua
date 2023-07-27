local open = require('open')

open.setup({})

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
