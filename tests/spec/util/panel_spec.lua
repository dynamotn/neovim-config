local h = require('helpers')

describe('util.panel', function()
  local panel

  before_each(function()
    h.unload('util.panel')
    panel = require('util.panel')
  end)
  after_each(function()
    vim.cmd('silent! only!')
    vim.cmd('silent! %bwipeout!')
  end)

  it('clears the code columns of the windows showing the buffer', function()
    vim.wo.colorcolumn = '80'
    vim.wo.scrolloff = 4
    local bufnr = vim.api.nvim_get_current_buf()
    panel.setup(bufnr)
    assert.equals('', vim.wo.colorcolumn)
    assert.equals('', vim.wo.statuscolumn)
    assert.equals(0, vim.wo.scrolloff)
  end)

  it('styles a window the buffer is shown in later', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    panel.setup(bufnr)
    vim.cmd('vsplit')
    vim.wo.colorcolumn = '80'
    vim.api.nvim_win_set_buf(0, bufnr)
    assert.equals('', vim.wo.colorcolumn)
  end)

  it('adds one autocmd however often the filetype is set', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    panel.setup(bufnr)
    panel.setup(bufnr)
    local autocmds = vim.api.nvim_get_autocmds({
      group = 'dyneo_panel',
      buffer = bufnr,
    })
    assert.equals(1, #autocmds)
  end)
end)
