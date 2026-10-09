local h = require('helpers')
local stub = require('spec.tools.null_ls_stub')

describe('tools.completion.jira', function()
  local builtin, commands, options, replies, restore, restore_executable
  local installed

  before_each(function()
    stub.install('tools.completion.jira')
    builtin = require('tools.completion.jira')
    commands, options, replies = {}, {}, {}
    installed = true
    -- Answers by the first argument after `jira issue`, or by the JQL
    restore = h.stub(
      vim,
      'system',
      h.system_double(function(cmd, opts)
        table.insert(commands, cmd)
        table.insert(options, opts)
        return replies[cmd[#cmd]] or replies[cmd[3]] or { code = 1 }
      end)
    )
    local executable = vim.fn.executable
    restore_executable = h.stub(vim.fn, 'executable', function(name)
      if name == 'jira' then return installed and 1 or 0 end
      return executable(name)
    end)
  end)
  after_each(function()
    restore()
    restore_executable()
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

  it('answers a word searched before from what it found', function()
    replies['project = AB'] = { code = 0, stdout = 'AB-1\tFix login\tme\n' }
    complete('AB')
    local spawned = #commands
    assert.are.same({ 'AB-1' }, labels(complete('AB')))
    assert.are.equal(spawned, #commands)
  end)

  it('searches only the word the typing settles on', function()
    local first, second
    builtin.generator.fn({ word_to_complete = 'AB' }, function(r) first = r end)
    builtin.generator.fn(
      { word_to_complete = 'ABC' },
      function(r) second = r end
    )
    vim.wait(1000, function() return first ~= nil and second ~= nil end)
    assert.are.same({ { items = {}, isIncomplete = true } }, first)
    for _, cmd in ipairs(commands) do
      assert.is_nil(cmd[#cmd]:find('AB"', 1, true))
      assert.are_not.equal('project = AB', cmd[#cmd])
    end
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

  it('gives a jira that hangs a few seconds, not forever', function()
    complete('AB')
    assert.is_true(#options > 0)
    for _, opts in ipairs(options) do
      assert.is_true(opts.timeout > 0 and opts.timeout <= 10000)
    end
  end)

  it('stops searching for a while once a search hung', function()
    local killed = { code = 124, signal = 15 }
    replies['project = AB'], replies['text ~ "*AB*"'] = killed, killed
    complete('AB')
    local spawned = #commands
    local response = complete('ABC')
    assert.are.same({ { items = {}, isIncomplete = false } }, response)
    assert.are.equal(spawned, #commands)
  end)

  it('keeps searching after a query that merely failed', function()
    complete('AB')
    local spawned = #commands
    complete('ABC')
    assert.is_true(#commands > spawned)
  end)

  it('asks nothing when jira-cli is not installed', function()
    installed = false
    local response = complete('AB')
    assert.are.same({ { items = {}, isIncomplete = false } }, response)
    assert.are.same({}, commands)
  end)
end)
