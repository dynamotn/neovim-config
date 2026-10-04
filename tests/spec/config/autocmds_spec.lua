local h = require('helpers')

describe('config.autocmds', function()
  before_each(function()
    h.globals()
    dofile(h.root .. '/lua/config/autocmds.lua')
  end)

  it('creates its autocommand groups', function()
    for _, group in ipairs({
      'terminal',
      'cursor_active_window',
      'cursor_inactive_window',
      'auto_relative_number',
    }) do
      assert.is_true(#vim.api.nvim_get_autocmds({ group = group }) > 0, group)
    end
  end)

  it('hides the cursorline while inserting and brings it back', function()
    vim.wo.cursorline = true
    vim.api.nvim_exec_autocmds('InsertEnter', {})
    assert.is_false(vim.wo.cursorline)
    vim.api.nvim_exec_autocmds('InsertLeave', {})
    assert.is_true(vim.wo.cursorline)
  end)

  it('leaves the cursorline off when it was off', function()
    vim.wo.cursorline = false
    vim.api.nvim_exec_autocmds('InsertEnter', {})
    vim.api.nvim_exec_autocmds('InsertLeave', {})
    assert.is_false(vim.wo.cursorline)
  end)

  it('drops relative numbers on the command line only', function()
    vim.wo.relativenumber = true
    vim.api.nvim_exec_autocmds('CmdlineEnter', {})
    assert.is_false(vim.wo.relativenumber)
    vim.api.nvim_exec_autocmds('CmdlineLeave', {})
    assert.is_true(vim.wo.relativenumber)
  end)

  it(
    'watches the clock only when day_night is enabled',
    function()
      assert.are.same({}, vim.api.nvim_get_autocmds({ event = 'VimResume' }))
    end
  )
end)
