local h = require('helpers')

describe('util.lazy_install', function()
  local lazy_install

  before_each(function()
    h.unload('util.lazy_install')
    lazy_install = require('util.lazy_install')
  end)

  describe('on_filetype', function()
    it('runs handlers for the matching filetype and for *', function()
      local seen = {}
      lazy_install.on_filetype(
        { 'lua', 'vim' },
        function(args) table.insert(seen, 'lua/vim:' .. args.match) end
      )
      lazy_install.on_filetype(
        { '*' },
        function(args) table.insert(seen, 'any:' .. args.match) end
      )
      lazy_install.on_filetype(
        { 'python' },
        function() table.insert(seen, 'python') end
      )

      h.buffer({ filetype = 'lua' })
      h.buffer({ filetype = 'rust' })
      assert.same({ 'lua/vim:lua', 'any:lua', 'any:rust' }, seen)
    end)

    it('registers a single autocmd however many handlers there are', function()
      for _ = 1, 5 do
        lazy_install.on_filetype({ 'a', 'b' }, function() end)
      end
      local autocmds = vim.api.nvim_get_autocmds({
        group = 'dy_lazy_install',
        event = 'FileType',
      })
      assert.equals(1, #autocmds)
    end)

    it('keeps running later handlers after one fails', function()
      local notified, ran = nil, false
      local restore = h.stub(vim, 'notify', function(msg) notified = msg end)
      lazy_install.on_filetype({ 'toml' }, function() error('boom') end)
      lazy_install.on_filetype({ 'toml' }, function() ran = true end)
      h.buffer({ filetype = 'toml' })
      restore()
      assert.is_true(ran)
      assert.matches('boom', notified)
    end)

    it('runs a handler again on every matching event', function()
      local count = 0
      lazy_install.on_filetype({ 'make' }, function() count = count + 1 end)
      h.buffer({ filetype = 'make' })
      h.buffer({ filetype = 'make' })
      assert.equals(2, count)
    end)
  end)

  describe('install_once', function()
    local installed, installs

    before_each(function()
      installed, installs = {}, {}
      package.loaded['mason-registry'] = {
        is_installed = function(name) return installed[name] == true end,
      }
      package.loaded['mason.api.command'] = {
        MasonInstall = function(args) table.insert(installs, args[1]) end,
      }
    end)
    after_each(function()
      package.loaded['mason-registry'] = nil
      package.loaded['mason.api.command'] = nil
    end)

    it('installs a missing package only once', function()
      lazy_install.install_once('stylua')
      lazy_install.install_once('stylua')
      assert.same({ 'stylua' }, installs)
    end)

    it('skips a package already installed', function()
      installed.stylua = true
      lazy_install.install_once('stylua')
      assert.same({}, installs)
    end)

    it('checks the name without its version', function()
      installed.ruff = true
      lazy_install.install_once('ruff@0.1.0')
      assert.same({}, installs)
      lazy_install.install_once('black@1.0')
      assert.same({ 'black@1.0' }, installs)
    end)
  end)
end)
