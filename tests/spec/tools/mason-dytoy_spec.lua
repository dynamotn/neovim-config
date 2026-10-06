local h = require('helpers')

--- mason.nvim, when the configuration has been started on this machine
local mason = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'mason.nvim')
local has_mason = vim.uv.fs_stat(mason) ~= nil

---@param path string
---@param lines? string[]
local function executable(path, lines)
  h.write(path, lines or { '#!/bin/sh' })
  vim.uv.fs_chmod(path, tonumber('755', 8))
end

---@return table
local function dytoy()
  h.unload('tools.mason-dytoy')
  return require('tools.mason-dytoy')
end

describe('tools.mason-dytoy', function()
  describe('normalize', function()
    it('rewrites a dytoy id into the purl mason reads', function()
      local spec = { source = { id = 'dytoy:opentofu' } }
      assert.are.equal(spec, dytoy().normalize(spec))
      assert.are.equal('pkg:dytoy/opentofu@latest', spec.source.id)
    end)

    it('leaves any other id alone', function()
      for _, id in ipairs({
        'pkg:github/a/b@v1',
        'dytoy:a/b',
        'dytoy:a@1',
        'dytoy:',
      }) do
        local spec = { source = { id = id } }
        dytoy().normalize(spec)
        assert.are.equal(id, spec.source.id)
      end
    end)

    it(
      'leaves a spec without a source alone',
      function() assert.are.same({}, dytoy().normalize({})) end
    )
  end)

  describe('resolve', function()
    local dir, cleanup
    before_each(function()
      dir, cleanup = h.tmpdir()
    end)
    after_each(function() cleanup() end)

    it('skips the directories it is told to', function()
      executable(dir .. '/mason/bin/tool')
      executable(dir .. '/system/tool')
      assert.are.equal(
        dir .. '/system/tool',
        dytoy().resolve('tool', {
          path = dir .. '/mason/bin:' .. dir .. '/system',
          skip = { dir .. '/mason/bin' },
          mise_dir = dir .. '/mise',
        })
      )
    end)

    it('ignores what is not executable', function()
      h.write(dir .. '/first/tool')
      executable(dir .. '/second/tool')
      assert.are.equal(
        dir .. '/second/tool',
        dytoy().resolve('tool', {
          path = dir .. '/first:' .. dir .. '/second',
          mise_dir = dir .. '/mise',
        })
      )
    end)

    it('swaps a versioned mise directory for its shim', function()
      executable(dir .. '/mise/installs/tool/1.0/bin/tool')
      executable(dir .. '/mise/shims/tool')
      assert.are.equal(
        dir .. '/mise/shims/tool',
        dytoy().resolve('tool', {
          path = dir .. '/mise/installs/tool/1.0/bin',
          mise_dir = dir .. '/mise',
        })
      )
    end)

    it('keeps the versioned directory when there is no shim', function()
      executable(dir .. '/mise/installs/tool/1.0/bin/tool')
      assert.are.equal(
        dir .. '/mise/installs/tool/1.0/bin/tool',
        dytoy().resolve('tool', {
          path = dir .. '/mise/installs/tool/1.0/bin',
          mise_dir = dir .. '/mise',
        })
      )
    end)

    it('finds a mise tool PATH does not reach yet', function()
      executable(dir .. '/mise/shims/tool')
      assert.are.equal(
        dir .. '/mise/shims/tool',
        dytoy().resolve('tool', { path = '', mise_dir = dir .. '/mise' })
      )
    end)

    it(
      'answers nothing when the command is nowhere',
      function()
        assert.is_nil(
          dytoy().resolve('tool', { path = dir, mise_dir = dir .. '/mise' })
        )
      end
    )
  end)

  describe('askpass', function()
    local restore
    after_each(function()
      if restore then restore() end
      restore = nil
    end)

    it('does not prompt for a token it never handed out', function()
      local module = dytoy()
      restore = h.stub(vim.fn, 'inputsecret', function() error('prompted') end)
      assert.are.equal('', module.askpass('unknown'))
    end)

    it('asks for the tool the token was handed out for', function()
      local module = dytoy()
      module.pending.token = 'fish'
      local asked
      restore = h.stub(vim.fn, 'inputsecret', function(prompt)
        asked = prompt
        return 'hunter2'
      end)
      assert.are.equal('hunter2', module.askpass('token'))
      assert.is_truthy(asked:find('fish', 1, true))
    end)

    it('answers nothing when the prompt is cancelled', function()
      local module = dytoy()
      module.pending.token = 'fish'
      restore = h.stub(
        vim.fn,
        'inputsecret',
        function() error('Keyboard interrupt') end
      )
      assert.are.equal('', module.askpass('token'))
    end)
  end)

  describe('write_helpers', function()
    local dir, cleanup, askpass
    before_each(function()
      dir, cleanup = h.tmpdir()
      -- A `sudo` that prints what it was given, one argument a line
      executable(dir .. '/real-sudo', {
        '#!/bin/sh',
        'printf \'%s\\n\' "$@"',
      })
      askpass = dytoy().write_helpers(dir, {
        sudo = dir .. '/real-sudo',
        nvim = vim.v.progpath,
        server = vim.v.servername ~= '' and vim.v.servername
          or vim.fn.serverstart(),
        token = 'token',
      })
    end)
    after_each(function() cleanup() end)

    ---@param args string[]
    ---@return string[]
    local function sudo(args)
      local result = vim
        .system(vim.list_extend({ dir .. '/sudo' }, args), { text = true })
        :wait()
      assert.are.equal(0, result.code, result.stderr)
      return vim.split(vim.trim(result.stdout), '\n')
    end

    it(
      'makes sudo ask through the helper',
      function()
        assert.are.same(
          { '-A', '-n', 'pacman', '-S', 'fish' },
          sudo({ '-n', 'pacman', '-S', 'fish' })
        )
      end
    )

    it(
      'leaves sudo alone when it reads the password from stdin',
      function() assert.are.same({ '-S', '-v' }, sudo({ '-S', '-v' })) end
    )

    it("reads -S of the command as the command's, not sudo's", function()
      assert.are.same(
        { '-A', 'pacman', '-S', 'fish' },
        sudo({ 'pacman', '-S', 'fish' })
      )
      assert.are.same(
        { '-A', '--', 'pacman', '-S', 'fish' },
        sudo({ '--', 'pacman', '-S', 'fish' })
      )
    end)

    it(
      'reads -S as a value when an option takes it',
      function()
        assert.are.same({ '-A', '-u', '-S', 'id' }, sudo({ '-u', '-S', 'id' }))
      end
    )

    it(
      'finds -S among other short options',
      function() assert.are.same({ '-nS', 'id' }, sudo({ '-nS', 'id' })) end
    )

    it('keeps the helpers to their owner', function()
      for _, name in ipairs({ 'sudo', 'askpass' }) do
        local stat = assert(vim.uv.fs_stat(vim.fs.joinpath(dir, name)))
        assert.are.equal(tonumber('700', 8), bit.band(stat.mode, 511), name)
      end
    end)

    ---@return vim.SystemCompleted
    local function run_askpass()
      local done
      vim.system(
        { askpass },
        { text = true },
        function(result) done = result end
      )
      vim.wait(10000, function() return done ~= nil end, 20)
      return assert(done, 'askpass did not finish')
    end

    it('hands the password from this Neovim to sudo', function()
      local module = require('tools.mason-dytoy')
      module.pending.token = 'fish'
      local restore = h.stub(
        vim.fn,
        'inputsecret',
        function() return 'hunter2' end
      )
      local result = run_askpass()
      restore()
      module.pending.token = nil
      assert.are.equal(0, result.code, result.stderr)
      assert.are.equal('hunter2\n', result.stdout)
    end)

    it('fails when there is no password to hand over', function()
      local result = run_askpass()
      assert.are_not.equal(0, result.code)
      assert.are.equal('', result.stdout)
    end)
  end)

  describe('with mason', function()
    if not has_mason then
      pending('mason.nvim is not installed on this machine')
      return
    end
    before_each(function()
      if not vim.tbl_contains(vim.opt.runtimepath:get(), mason) then
        vim.opt.runtimepath:append(mason)
      end
    end)

    it('names the tool after the purl', function()
      local purl = require('mason-core.purl')
        .parse('pkg:dytoy/opentofu@latest')
        :get_or_throw()
      assert.are.same(
        { tool = 'opentofu' },
        dytoy().parse({}, purl):get_or_throw()
      )
    end)

    it('refuses a namespace', function()
      local purl =
        require('mason-core.purl').parse('pkg:dytoy/a/b@latest'):get_or_throw()
      assert.is_true(dytoy().parse({}, purl):is_failure())
    end)

    it(
      'refuses to pick a version',
      function() assert.is_true(dytoy().get_versions():is_failure()) end
    )

    it('is the compiler for pkg:dytoy once registered', function()
      local module = dytoy()
      module.register()
      local purl =
        require('mason-core.purl').parse('pkg:dytoy/fish@latest'):get_or_throw()
      assert.are.equal(
        module,
        require('mason-core.installer.compiler')
          .get_compiler(purl)
          :get_or_throw()
      )
    end)
  end)
end)
