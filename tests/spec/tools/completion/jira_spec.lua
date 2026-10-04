local h = require('helpers')
local stub = require('spec.tools.null_ls_stub')

describe('tools.completion.jira', function()
  local builtin, commands, replies, restore

  before_each(function()
    stub.install('tools.completion.jira')
    builtin = require('tools.completion.jira')
    commands, replies = {}, {}
    -- Answers by the first argument after `jira issue`, or by the JQL
    restore = h.stub(vim, 'system', function(cmd, _, on_exit)
      table.insert(commands, cmd)
      local reply = replies[cmd[#cmd]] or replies[cmd[3]] or { code = 1 }
      on_exit(reply)
      return {}
    end)
  end)
  after_each(function()
    restore()
    stub.uninstall()
  end)

  ---@param word string
  ---@return table? response
  local function complete(word)
    local response
    builtin.generator.fn(
      { word_to_complete = word },
      function(r) response = r end
    )
    vim.wait(1000, function() return response ~= nil end)
    return response
  end

  ---@param response table
  local function labels(response)
    local result = vim.tbl_map(
      function(i) return i.label end,
      response[1].items
    )
    table.sort(result)
    return result
  end

  it('completes in git commit messages, asynchronously', function()
    assert.are.equal('jira', builtin.name)
    assert.are.equal('NULL_LS_COMPLETION', builtin.method)
    assert.are.same({ 'gitcommit' }, builtin.filetypes)
    assert.is_true(builtin.generator.async)
  end)

  it('answers nothing for a word under two characters', function()
    local response = complete('A')
    assert.are.same({ { items = {}, isIncomplete = false } }, response)
    assert.are.same({}, commands)
  end)

  it('searches by project and by text', function()
    complete('AB')
    local queries = {}
    for _, cmd in ipairs(commands) do
      if cmd[3] == 'list' then table.insert(queries, cmd[#cmd]) end
    end
    table.sort(queries)
    assert.are.same({ 'project = AB', 'text ~ "*AB*"' }, queries)
    assert.are.same({
      'jira',
      'issue',
      'list',
      '--plain',
      '--columns',
      'KEY,SUMMARY,ASSIGNEE',
    }, vim.list_slice(commands[1], 1, 6))
  end)

  it('completes keys and summaries, documented by the issue', function()
    replies['project = AB'] = { code = 0, stdout = 'AB-1\tFix login\tme\n' }
    replies['text ~ "*AB*"'] =
      { code = 0, stdout = 'AB-1\tFix login\tme\nAB-2\tAdd AB test\tyou\n' }
    replies['AB-1'] = { code = 0, stdout = 'Body of one\n' }
    replies['AB-2'] = { code = 1 }
    local response = complete('AB')

    assert.are.same({ 'AB-1', 'Add AB test', 'Fix login' }, labels(response))
    assert.is_false(response[1].isIncomplete)
    for _, item in ipairs(response[1].items) do
      assert.are.equal(vim.lsp.protocol.CompletionItemKind.Reference, item.kind)
      if vim.startswith(item.detail, 'AB-1') then
        assert.are.equal('Body of one', item.documentation.value)
      else
        -- An issue that cannot be read keeps its row as documentation
        assert.are.equal(item.detail, item.documentation.value)
      end
    end

    local views = vim.tbl_filter(
      function(c) return c[3] == 'view' end,
      commands
    )
    assert.are.equal(2, #views, 'each issue is read once')
  end)

  it('drops rows missing a column', function()
    replies['project = AB'] = { code = 0, stdout = 'AB-1\n\nAB-2\tTwo\tx\n' }
    replies['AB-2'] = { code = 0, stdout = '' }
    local response = complete('AB')
    assert.are.same({ 'AB-2' }, labels(response))
  end)

  it('answers incomplete when every search fails', function()
    local response = complete('AB')
    assert.are.same({ { items = {}, isIncomplete = true } }, response)
  end)
end)
