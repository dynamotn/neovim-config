local h = require('helpers')
local stub = require('spec.tools.null_ls_stub')

describe('tools.code_actions.shellcheck', function()
  local builtin, on_output
  before_each(function()
    stub.install('tools.code_actions.shellcheck')
    package.loaded.open = nil
    builtin = require('tools.code_actions.shellcheck')
    on_output = builtin.generator_opts.on_output
  end)
  after_each(function()
    stub.uninstall()
    package.loaded.open = nil
  end)

  --- Ask for the actions of `row` in a buffer holding `lines`, with
  --- ShellCheck reporting `code` on that row
  ---@param lines string[]
  ---@param row integer 1-based
  ---@param code? integer
  ---@return integer bufnr
  ---@return table[] actions
  local function actions_for(lines, row, code)
    local bufnr = h.buffer({ lines = lines })
    local actions = on_output({
      bufnr = bufnr,
      row = row,
      content = lines,
      output = { comments = { { line = row, code = code or 2086 } } },
    })
    return bufnr, actions
  end

  ---@param bufnr integer
  local function lines_of(bufnr)
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end

  ---@param actions table[]
  ---@param suffix string
  local function find(actions, suffix)
    for _, action in ipairs(actions) do
      if vim.endswith(action.title, suffix) then return action end
    end
  end

  it('runs ShellCheck with JSON output on stdin', function()
    assert.are.equal('shellcheck', builtin.name)
    assert.are.equal('NULL_LS_CODE_ACTION', builtin.method)
    assert.are.same('json1', builtin.generator_opts.args[2])
    assert.are.equal(
      '-',
      builtin.generator_opts.args[#builtin.generator_opts.args]
    )
    assert.is_true(builtin.generator_opts.check_exit_code(1))
    assert.is_false(builtin.generator_opts.check_exit_code(2))
  end)

  it('offers nothing without comments', function()
    assert.is_nil(on_output({ output = nil }))
    assert.is_nil(on_output({ output = {} }))
  end)

  it('offers nothing for a comment on another row', function()
    local lines = { 'true', 'echo $foo' }
    local actions = on_output({
      bufnr = h.buffer({ lines = lines }),
      row = 1,
      content = lines,
      output = { comments = { { line = 2, code = 2086 } } },
    })
    assert.are.same({}, actions)
  end)

  it('offers to disable a rule for the file and for the line', function()
    local _, actions = actions_for({ '#!/bin/bash', 'true', 'echo $foo' }, 3)
    assert.are.same({
      'Disable ShellCheck rule 2086 for the entire file',
      'Disable ShellCheck rule 2086 for this line',
    }, vim.tbl_map(function(a) return a.title end, actions))
  end)

  it('adds a wiki link when open.nvim is there', function()
    local opened
    package.loaded.open = { open = function(url) opened = url end }
    local _, actions = actions_for({ 'true', 'echo $foo' }, 2)
    local wiki = find(actions, 'of code SC2086')
    assert.is_not_nil(wiki)
    wiki.action()
    assert.are.equal('https://www.shellcheck.net/wiki/SC2086', opened)
  end)

  describe('file directive', function()
    it('goes below the shebang', function()
      local bufnr, actions =
        actions_for({ '#!/bin/bash', '# comment', 'true', 'echo $foo' }, 4)
      find(actions, 'entire file').action()
      assert.are.same({
        '#!/bin/bash',
        '# shellcheck disable=2086',
        '# comment',
        'true',
        'echo $foo',
      }, lines_of(bufnr))
    end)

    it('goes on the first line without a shebang', function()
      local bufnr, actions = actions_for({ 'true', 'echo $foo' }, 2)
      find(actions, 'entire file').action()
      assert.are.same(
        { '# shellcheck disable=2086', 'true', 'echo $foo' },
        lines_of(bufnr)
      )
    end)

    it('extends an existing one', function()
      local bufnr, actions = actions_for(
        { '#!/bin/bash', '# shellcheck disable=SC1090', 'true', 'echo $foo' },
        4
      )
      find(actions, 'entire file').action()
      assert.are.same({
        '#!/bin/bash',
        '# shellcheck disable=SC1090,2086',
        'true',
        'echo $foo',
      }, lines_of(bufnr))
    end)
  end)

  describe('file directive, already listing the code', function()
    it('leaves it alone', function()
      local bufnr, actions = actions_for(
        { '#!/bin/bash', '# shellcheck disable=SC2086', 'true', 'echo $foo' },
        4
      )
      find(actions, 'entire file').action()
      assert.are.same({
        '#!/bin/bash',
        '# shellcheck disable=SC2086',
        'true',
        'echo $foo',
      }, lines_of(bufnr))
    end)
  end)

  describe('line directive', function()
    it('goes above the line', function()
      local bufnr, actions =
        actions_for({ '#!/bin/bash', '# comment', 'true', 'echo $foo' }, 4)
      find(actions, 'this line').action()
      assert.are.same({
        '#!/bin/bash',
        '# comment',
        'true',
        '# shellcheck disable=2086',
        'echo $foo',
      }, lines_of(bufnr))
    end)

    it('keeps the indentation of the line', function()
      local bufnr, actions =
        actions_for({ 'f() {', '  true', '  echo $foo', '}' }, 3)
      find(actions, 'this line').action()
      assert.are.equal('  # shellcheck disable=2086', lines_of(bufnr)[3])
    end)

    it('extends an existing one above the line', function()
      local bufnr, actions = actions_for({
        '#!/bin/bash',
        'true',
        '# shellcheck disable=SC2034',
        'echo $foo',
      }, 4)
      find(actions, 'this line').action()
      assert.are.same({
        '#!/bin/bash',
        'true',
        '# shellcheck disable=SC2034,2086',
        'echo $foo',
      }, lines_of(bufnr))
    end)

    it('goes above the start of a continued command', function()
      local bufnr, actions = actions_for({ 'true', 'echo a \\', '  b $foo' }, 3)
      find(actions, 'this line').action()
      assert.are.same({
        'true',
        '# shellcheck disable=2086',
        'echo a \\',
        '  b $foo',
      }, lines_of(bufnr))
    end)

    it('is not offered on the first command of the script', function()
      local _, actions = actions_for({ '#!/bin/bash', '# c', 'echo $foo' }, 3)
      assert.is_nil(find(actions, 'this line'))
      assert.is_not_nil(find(actions, 'entire file'))
    end)
  end)
end)
