local h = require('helpers')

describe('util.copy_path', function()
  local copy_path, dir, cleanup, restores, messages, root, root_module

  before_each(function()
    dir, cleanup = h.tmpdir()
    messages, root = {}, dir
    root_module = {
      get = function() return root end,
      git = function() return root end,
    }
    local plugin = {
      norm = function(path) return vim.fs.normalize(path) end,
      warn = function(msg, opts)
        table.insert(
          messages,
          { level = 'warn', msg = msg, title = opts.title }
        )
      end,
      info = function(msg, opts)
        table.insert(
          messages,
          { level = 'info', msg = msg, title = opts.title }
        )
      end,
    }
    -- The `+` register needs a clipboard provider, which a runner with no
    -- display lacks: one kept in memory stands in for it
    local clipboard = { lines = { '' }, regtype = 'v' }
    restores = {
      h.stub(package.loaded, 'util.root', root_module),
      h.stub(package.loaded, 'util.plugin', plugin),
      h.stub(vim.g, 'clipboard', {
        name = 'dyneo-spec',
        copy = {
          ['+'] = function(lines, regtype)
            clipboard = { lines = lines, regtype = regtype }
          end,
          ['*'] = function() end,
        },
        paste = {
          ['+'] = function() return { clipboard.lines, clipboard.regtype } end,
          ['*'] = function() return { {}, 'v' } end,
        },
      }),
    }
    -- The provider is picked once, when the clipboard is first used
    vim.g.loaded_clipboard_provider = nil
    vim.cmd('runtime autoload/provider/clipboard.vim')
    h.unload('util.copy_path')
    copy_path = require('util.copy_path')
  end)
  after_each(function()
    for i = #restores, 1, -1 do
      restores[i]()
    end
    vim.g.loaded_clipboard_provider = nil
    vim.cmd('runtime autoload/provider/clipboard.vim')
    vim.cmd('silent! %bwipeout!')
    cleanup()
  end)

  ---@param name? string
  ---@param lines? string[]
  local function open(name, lines)
    local bufnr = h.buffer({
      name = name,
      lines = lines or { 'one', 'two', 'three words' },
    })
    vim.api.nvim_set_current_buf(bufnr)
    return bufnr
  end

  describe('without a file', function()
    before_each(function() open() end)

    for _, fn in ipairs({
      'bufpath',
      'absolute',
      'directory',
      'relative',
      'filename',
      'filename_no_ext',
    }) do
      it(fn .. ' is nil', function() assert.is_nil(copy_path[fn]()) end)
    end

    it('copy warns instead of copying', function()
      vim.fn.setreg('+', 'before')
      copy_path.copy_relative()
      assert.equals('warn', messages[1].level)
      assert.equals('Copy Path', messages[1].title)
    end)

    for _, fn in ipairs({
      'copy_relative_with_line',
      'copy_relative_with_line_column',
      'copy_absolute_with_line',
      'copy_absolute_with_line_column',
    }) do
      it(fn .. ' warns instead of copying', function()
        vim.fn.setreg('+', 'before')
        copy_path[fn]()
        assert.equals('warn', messages[1].level)
        assert.equals('Copy Path', messages[1].title)
        assert.equals('before', vim.fn.getreg('+'))
      end)
    end

    it('with_line and with_column pass a missing path through', function()
      assert.is_nil(copy_path.with_line(nil))
      assert.is_nil(copy_path.with_column(nil))
    end)
  end)

  describe('with a file', function()
    local path
    before_each(function()
      path = dir .. '/src/main.test.lua'
      open(path)
    end)

    it('gives its absolute path and directory', function()
      assert.equals(path, copy_path.bufpath())
      assert.equals(path, copy_path.absolute())
      assert.equals(dir .. '/src/', copy_path.directory())
    end)

    it('gives its name with and without the extension', function()
      assert.equals('main.test.lua', copy_path.filename())
      assert.equals('main.test', copy_path.filename_no_ext())
    end)

    it('keeps a name without an extension', function()
      open(dir .. '/Makefile')
      assert.equals('Makefile', copy_path.filename_no_ext())
    end)

    it('gives the path relative to the project root', function()
      assert.equals('src/main.test.lua', copy_path.relative())
      root = dir .. '/'
      assert.equals('src/main.test.lua', copy_path.relative())
    end)

    it('falls back to the absolute path outside the root', function()
      root = dir .. '/elsewhere'
      assert.equals(path, copy_path.relative())
    end)

    it('falls back to the absolute path when the root fails', function()
      root_module.get = function() error('headless') end
      assert.equals(path, copy_path.relative())
    end)

    it('gives the cursor position 1-based', function()
      vim.api.nvim_win_set_cursor(0, { 3, 4 })
      assert.equals(3, copy_path.line_number())
      assert.equals(5, copy_path.column_number())
      assert.equals('x:3', copy_path.with_line('x'))
      assert.equals('x:5', copy_path.with_column('x'))
    end)

    it('gives the git root, or the cwd when that fails', function()
      assert.equals(dir .. '/', copy_path.project_root())
      root_module.git = function() error('no git') end
      assert.equals(vim.uv.cwd() .. '/', copy_path.project_root())
    end)

    describe('copies to the clipboard register', function()
      local registers, restore_setreg
      before_each(function()
        registers = {}
        restore_setreg = h.stub(
          vim.fn,
          'setreg',
          function(reg, text, mode) registers[reg] = { text, mode } end
        )
        vim.api.nvim_win_set_cursor(0, { 2, 1 })
      end)
      after_each(function() restore_setreg() end)

      for fn, expected in pairs({
        copy_relative_with_line_column = 'src/main.test.lua:2:2',
        copy_relative_with_line = 'src/main.test.lua:2',
        copy_relative = 'src/main.test.lua',
        copy_relative_directory = 'src/',
        copy_absolute_with_line_column = '<abs>:2:2',
        copy_absolute_with_line = '<abs>:2',
        copy_absolute = '<abs>',
        copy_absolute_directory = '<dir>/src/',
        copy_project = '<dir>/',
        copy_filename = 'main.test.lua',
        copy_filename_no_ext = 'main.test',
      }) do
        it(fn, function()
          expected = expected:gsub('<abs>', path):gsub('<dir>', dir)
          copy_path[fn]()
          assert.same({ expected, 'c' }, registers['+'])
          assert.equals('info', messages[1].level)
          assert.equals('Copied: ' .. expected, messages[1].msg)
        end)
      end
    end)
  end)
end)
