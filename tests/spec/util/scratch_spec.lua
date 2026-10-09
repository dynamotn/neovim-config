local h = require('helpers')

describe('util.scratch', function()
  local scratch

  before_each(function()
    h.unload('util.scratch')
    scratch = require('util.scratch')
  end)
  after_each(function()
    vim.cmd('silent! tabonly!')
    vim.cmd('silent! only!')
    vim.cmd('silent! %bwipeout!')
  end)

  it('opens text that is no file, read-only, in a tab', function()
    local tabs = #vim.api.nvim_list_tabpages()
    local bufnr = scratch.open(
      { 'a', 'b' },
      { filetype = 'markdown', name = 'dy://y' }
    )
    assert.equals(tabs + 1, #vim.api.nvim_list_tabpages())
    assert.equals(bufnr, vim.api.nvim_get_current_buf())
    assert.same({ 'a', 'b' }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.equals('nofile', vim.bo[bufnr].buftype)
    assert.equals('wipe', vim.bo[bufnr].bufhidden)
    assert.is_false(vim.bo[bufnr].swapfile)
    assert.is_false(vim.bo[bufnr].modifiable)
    assert.equals('markdown', vim.bo[bufnr].filetype)
    assert.equals('dy://y', vim.api.nvim_buf_get_name(bufnr))
    assert.is_nil(require('util.sensitive').marked(bufnr))
    assert.equals(1, vim.fn.maparg('q', 'n', false, true).buffer)
  end)

  it('marks it sensitive before the text goes in, when asked', function()
    local bufnr = scratch.open(
      { 'secret' },
      { sensitive = 'a reason', split = 'vertical' }
    )
    assert.equals('a reason', require('util.sensitive').marked(bufnr))
  end)

  it('replaces its lines, read-only or not', function()
    local bufnr = scratch.open({ 'a' }, { split = 'horizontal' })
    scratch.set(bufnr, { 'b', 'c' })
    assert.same({ 'b', 'c' }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    assert.is_false(vim.bo[bufnr].modifiable)
    assert.is_false(vim.bo[bufnr].modified)
    local editable = scratch.open({}, { modifiable = true })
    assert.is_true(vim.bo[editable].modifiable)
  end)
end)
