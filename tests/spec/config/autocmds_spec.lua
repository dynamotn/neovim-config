local h = require('helpers')

describe('config.autocmds', function()
  before_each(function()
    h.globals()
    dofile(h.root .. '/lua/config/autocmds.lua')
  end)

  it('creates its autocommand groups', function()
    for _, group in ipairs({
      'dyneo_terminal',
      'dyneo_cursor_active_window',
      'dyneo_cursor_inactive_window',
      'dyneo_auto_relative_number',
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
    vim.api.nvim_exec_autocmds('CmdlineEnter', { pattern = '/' })
    assert.is_true(vim.wo.relativenumber)
    vim.api.nvim_exec_autocmds('CmdlineEnter', { pattern = ':' })
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

  describe('sensitive files', function()
    local dir, cleanup
    before_each(function()
      dir, cleanup = h.tmpdir()
      dofile(h.root .. '/plugin/sensitive.lua')
    end)
    after_each(function() cleanup() end)

    it('keeps no undo or swap file of a sensitive file', function()
      local path = dir .. '/.env'
      vim.fn.writefile({ 'TOKEN=x' }, path)
      vim.cmd.edit(path)
      assert.is_false(vim.bo.undofile)
      assert.is_false(vim.bo.swapfile)
      vim.cmd('bwipeout!')
    end)

    it('turns backups off for the write only', function()
      local saved = vim.o.backup
      vim.o.backup = true
      local path = dir .. '/.env'
      vim.cmd.edit(path)
      local during
      vim.api.nvim_create_autocmd('BufWritePre', {
        once = true,
        callback = function() during = vim.o.backup end,
      })
      vim.cmd.write()
      assert.is_false(during)
      assert.is_true(vim.o.backup)
      vim.cmd('bwipeout!')
      vim.o.backup = saved
    end)
  end)

  describe('close with q', function()
    it('leaves `q` alone in a help file open for editing', function()
      local bufnr = h.buffer({ lines = { 'text' } })
      vim.api.nvim_set_current_buf(bufnr)
      vim.bo[bufnr].filetype = 'help'
      vim.wait(50)
      assert.same({}, vim.fn.maparg('q', 'n', false, true))
    end)

    it('copes with a buffer wiped before `q` is mapped', function()
      local bufnr = h.buffer({ lines = { 'text' } })
      vim.bo[bufnr].filetype = 'qf'
      vim.api.nvim_buf_delete(bufnr, { force = true })
      vim.v.errmsg = ''
      vim.wait(50)
      assert.are.equal('', vim.v.errmsg)
    end)
  end)
end)
