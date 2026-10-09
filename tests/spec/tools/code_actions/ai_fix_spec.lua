local h = require('helpers')
local stub = require('spec.tools.null_ls_stub')

describe('tools.code_actions.ai_fix', function()
  local builtin, runs, restore, ns

  before_each(function()
    stub.install('tools.code_actions.ai_fix')
    runs = {}
    restore = h.stub(package.loaded, 'tools.ai', {
      run = function(name, range) table.insert(runs, { name, range }) end,
    })
    builtin = require('tools.code_actions.ai_fix')
    ns = vim.api.nvim_create_namespace('dy_ai_fix_spec')
  end)
  after_each(function()
    restore()
    stub.uninstall()
    vim.cmd('silent! %bwipeout!')
  end)

  --- A buffer with a diagnostic on each of `rows` (1-based)
  local function buffer(rows, message)
    local bufnr = h.buffer({ lines = { 'a', 'b', 'c' } })
    vim.diagnostic.set(
      ns,
      bufnr,
      vim.tbl_map(
        function(row)
          return { lnum = row - 1, col = 0, message = message or 'bad thing' }
        end,
        rows
      )
    )
    return bufnr
  end

  it('is a code action of every filetype', function()
    assert.equals('ai_fix', builtin.name)
    assert.equals('NULL_LS_CODE_ACTION', builtin.method)
    assert.same({}, builtin.filetypes)
  end)

  it('offers nothing on a line without diagnostics', function()
    local bufnr = buffer({ 1 })
    assert.is_nil(builtin.generator.fn({ bufnr = bufnr, row = 2 }))
  end)

  it('runs the fix prompt over the line of the diagnostic', function()
    local bufnr = buffer({ 2 })
    local actions = builtin.generator.fn({ bufnr = bufnr, row = 2 })
    assert.equals('Fix with AI: bad thing', actions[1].title)
    actions[1].action()
    assert.same({ { 'fix', { 2, 2 } } }, runs)
  end)

  it('covers a selection, counting its diagnostics', function()
    local bufnr = buffer({ 1, 3 })
    local actions = builtin.generator.fn({
      bufnr = bufnr,
      row = 1,
      range = { row = 1, end_row = 3 },
    })
    assert.equals('Fix with AI: 2 diagnostics', actions[1].title)
    actions[1].action()
    assert.same({ { 'fix', { 1, 3 } } }, runs)
  end)

  it('shortens a long message to its first line', function()
    local bufnr = buffer({ 1 }, ('x'):rep(100) .. '\nmore')
    local title = builtin.generator.fn({ bufnr = bufnr, row = 1 })[1].title
    assert.equals('Fix with AI: ' .. ('x'):rep(59) .. '…', title)
  end)
end)
