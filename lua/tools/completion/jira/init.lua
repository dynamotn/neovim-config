local h = require('null-ls.helpers')
local methods = require('null-ls.methods')
local j = require('plenary.job')

-- Generate completion items by parse result of command
local generate_candidates = function(kind, candidates, entries, callback)
  local exited_view_jobs_count = 0
  for _, v in ipairs(entries) do
    local issue_key
    local issue_summary
    for column_text in string.gmatch(v, '[^\t]+') do
      if not issue_key then
        issue_key = column_text
      elseif not issue_summary then
        issue_summary = column_text
      end
    end

    local candidate = {
      label = kind == 'key' and issue_key or issue_summary,
      detail = v,
      kind = vim.lsp.protocol.CompletionItemKind['Reference'],
      documentation = {
        kind = vim.lsp.protocol.MarkupKind.Markdown,
        value = v,
      },
    }
    local candidate_index = #candidates + 1
    local job = j:new({
      command = 'jira',
      args = {
        'issue',
        'view',
        '--plain',
        issue_key,
      },
      on_start = function() table.insert(candidates, candidate) end,
      on_exit = function(self, exit_code)
        exited_view_jobs_count = exited_view_jobs_count + 1
        if exit_code == 0 then
          candidates[candidate_index].documentation.value = table.concat(
            require('vim.lsp.util').convert_input_to_markdown_lines(
              self:result()
            ),
            '\n'
          )
        end
        if
          exited_view_jobs_count == #entries
          and type(callback) == 'function'
        then
          callback()
        end
      end,
      detached = true,
    })
    job:start()
  end
end

return h.make_builtin({
  name = 'jira',
  meta = {
    description = 'My custom sources to complete JIRA issue ',
    url = 'https://github.com/ankitpokhrel/jira-cli',
  },
  method = methods.internal.COMPLETION,
  filetypes = { 'gitcommit' },
  generator = {
    fn = function(params, done)
      -- Must enable completion for word with >= 2 chars
      local word = params.word_to_complete
      if #word < 2 then
        done({ { items = {}, isIncomplete = false } })
        return
      end

      local candidates = {}
      local jira_queries = {
        key = 'project = ' .. word,
        text = [[text ~ "*]] .. word .. [[*"]],
      }

      local exited_search_jobs_count = 0
      local search_jobs_count = 0
      for _, _ in pairs(jira_queries) do
        search_jobs_count = search_jobs_count + 1
      end
      for kind, query in pairs(jira_queries) do
        local job = j:new({
          command = 'jira',
          args = {
            'issue',
            'list',
            '--plain',
            '--columns',
            'KEY,SUMMARY,ASSIGNEE',
            '--paginate',
            10,
            '--no-headers',
            '--jql',
            query,
          },
          on_exit = function(self, exit_code)
            exited_search_jobs_count = exited_search_jobs_count + 1
            if exit_code == 0 then
              generate_candidates(
                kind,
                candidates,
                self:result(),
                exited_search_jobs_count == search_jobs_count
                    and function()
                      if exited_search_jobs_count == search_jobs_count then
                        done({
                          {
                            items = candidates,
                            isIncomplete = #candidates == 0,
                          },
                        })
                      end
                    end
                  or nil
              )
            end
          end,
          detached = true,
        })
        job:start()
      end
    end,
    async = true,
  },
})
