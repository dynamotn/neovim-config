local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

--- Run `jira` and hand back the lines it printed
---
--- `vim.system` rather than `plenary.job`: plenary calls `on_exit` as soon as
--- the process is gone and stops reading, so output still sitting in the pipe
--- was lost and a query dropped its rows every few runs.
---@param args string[]
---@param on_output fun(lines: string[])
local function jira(args, on_output)
  vim.system(
    vim.list_extend({ 'jira' }, args),
    { text = true },
    function(result)
      if result.code ~= 0 then return on_output({}) end
      on_output(vim.split(result.stdout or '', '\n', { trimempty = true }))
    end
  )
end

--- Split one `--plain` row into the two columns the candidate is built from
---@param row string A `KEY\tSUMMARY\tASSIGNEE` line
---@return string? key
---@return string? summary
local function columns(row)
  local key, summary
  for column in string.gmatch(row, '[^\t]+') do
    if not key then
      key = column
    elseif not summary then
      summary = column
    end
  end
  return key, summary
end

--- Turn one row into a completion item
---@param kind string `key` completes the issue key, anything else its summary
---@param row string
---@return table? candidate
---@return string? key The issue the candidate stands for
local function candidate_of(kind, row)
  local key, summary = columns(row)
  -- A row missing either column cannot make a label, and an item without one
  -- is not a completion item
  if not key or not summary then return nil, nil end
  return {
    label = kind == 'key' and key or summary,
    detail = row,
    kind = vim.lsp.protocol.CompletionItemKind['Reference'],
    documentation = {
      kind = vim.lsp.protocol.MarkupKind.Markdown,
      -- Replaced by the body of the issue once it has been read
      value = row,
    },
  },
    key
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

      local queries = {
        key = 'project = ' .. word,
        text = [[text ~ "*]] .. word .. [[*"]],
      }

      --- Hand the items over, once
      ---
      --- The callback arrives straight off the libuv loop, which is a fast
      --- event context. `done` leads into null-ls and from there into the API,
      --- so it waits for the loop.
      ---@param items table[]
      local function finish(items)
        vim.schedule(
          function() done({ { items = items, isIncomplete = #items == 0 } }) end
        )
      end

      --- Read the body of each issue and fill it into the items standing for
      --- it, then hand everything over
      ---
      --- One read per issue, not per row: the two queries overlap, and an
      --- issue found by both used to be read twice.
      ---@param items table[]
      ---@param by_key table<string, table[]> Issue key to the items using it
      local function describe(items, by_key)
        local keys = vim.tbl_keys(by_key)
        -- Nothing to read still has to answer, or the request never completes
        if #keys == 0 then return finish(items) end

        local pending = #keys
        for _, key in ipairs(keys) do
          jira({ 'issue', 'view', '--plain', key }, function(lines)
            if #lines > 0 then
              local body = table.concat(
                vim.lsp.util.convert_input_to_markdown_lines(lines),
                '\n'
              )
              for _, item in ipairs(by_key[key]) do
                item.documentation.value = body
              end
            end
            pending = pending - 1
            -- Every item is settled before anything is handed over, so
            -- nothing is still being written to afterwards
            if pending == 0 then finish(items) end
          end)
        end
      end

      local rows = {}
      local pending_searches = vim.tbl_count(queries)

      for kind, query in pairs(queries) do
        local args = {
          'issue',
          'list',
          '--plain',
          '--columns',
          'KEY,SUMMARY,ASSIGNEE',
          '--paginate',
          '10',
          '--no-headers',
          '--jql',
          query,
        }
        jira(args, function(lines)
          -- A query that fails contributes nothing, rather than holding the
          -- whole request back
          rows[kind] = lines
          pending_searches = pending_searches - 1
          if pending_searches > 0 then return end

          local items, by_key = {}, {}
          for row_kind, list in pairs(rows) do
            for _, row in ipairs(list) do
              local candidate, key = candidate_of(row_kind, row)
              if candidate then
                table.insert(items, candidate)
                by_key[key] = by_key[key] or {}
                table.insert(by_key[key], candidate)
              end
            end
          end
          describe(items, by_key)
        end)
      end
    end,
    async = true,
  },
})
