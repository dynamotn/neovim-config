local h = require('helpers')
local sensitive = require('util.sensitive')

describe('util.sensitive', function()
  local dir, cleanup
  before_each(function()
    dir, cleanup = h.tmpdir()
  end)
  after_each(function() cleanup() end)

  describe('is_sensitive_path', function()
    it(
      'is false for an empty path',
      function() assert.is_false(sensitive.is_sensitive_path('')) end
    )

    for _, name in ipairs({
      '.env',
      'prod.env',
      '.env.local',
      '.envrc',
      'token.age',
      'note.gpg',
      'cert.pem',
      'server.key',
      'store.p12',
      'store.pfx',
      'id_rsa',
      'id_ed25519',
      '.netrc',
      '_netrc',
      '.pgpass',
      '.git-credentials',
      '.npmrc',
      '.pypirc',
      '.vault-token',
    }) do
      it(
        'flags a file named ' .. name,
        function()
          assert.is_true(sensitive.is_sensitive_path(dir .. '/' .. name))
        end
      )
    end

    for _, name in ipairs({
      'init.lua',
      'environment.md',
      'id_rsa.pub',
      'keymap.lua',
      'envrc.example',
    }) do
      it(
        'leaves an ordinary file named ' .. name,
        function()
          assert.is_false(sensitive.is_sensitive_path(dir .. '/' .. name))
        end
      )
    end

    for _, sub in ipairs({
      '.ssh',
      '.gnupg',
      '.aws',
      '.kube',
      '.docker',
      'secrets',
    }) do
      it(
        'flags any file below a ' .. sub .. ' directory',
        function()
          assert.is_true(
            sensitive.is_sensitive_path(dir .. '/' .. sub .. '/deep/config')
          )
        end
      )
    end

    it('flags the secrets submodule by its full path', function()
      local path = vim.fs.joinpath(vim.env.HOME, 'Dotfiles', 'secrets', 'data')
      assert.is_true(sensitive.is_sensitive_path(path))
    end)

    it('resolves a relative path against the working directory', function()
      local cwd = vim.fn.getcwd()
      vim.cmd.cd(dir)
      local ok, result = pcall(sensitive.is_sensitive_path, '.env')
      vim.cmd.cd(cwd)
      assert.is_true(ok)
      assert.is_true(result)
    end)

    it('follows a symlink into a sensitive place', function()
      h.write(dir .. '/secrets/token', { 'x' })
      assert(vim.uv.fs_symlink(dir .. '/secrets/token', dir .. '/innocent'))
      assert.is_true(sensitive.is_sensitive_path(dir .. '/innocent'))
    end)

    it('does not flag a symlink to an ordinary file', function()
      h.write(dir .. '/plain.txt', { 'x' })
      assert(vim.uv.fs_symlink(dir .. '/plain.txt', dir .. '/link.txt'))
      assert.is_false(sensitive.is_sensitive_path(dir .. '/link.txt'))
    end)
  end)

  describe('is_sensitive', function()
    it('flags a buffer by its filetype', function()
      local bufnr = h.buffer({ filetype = 'gitcommit' })
      assert.is_true(sensitive.is_sensitive(bufnr))
    end)

    it('flags a buffer by its name', function()
      local bufnr = h.buffer({ name = dir .. '/.env' })
      assert.is_true(sensitive.is_sensitive(bufnr))
    end)

    it('asks about the current buffer for nil and 0', function()
      local bufnr = h.buffer({ name = dir .. '/id_rsa' })
      vim.api.nvim_set_current_buf(bufnr)
      assert.is_true(sensitive.is_sensitive())
      assert.is_true(sensitive.is_sensitive(0))
    end)

    it(
      'is false for an unnamed buffer',
      function() assert.is_false(sensitive.is_sensitive(h.buffer())) end
    )

    for name, line in pairs({
      -- Spelt in pieces: the `detect-private-key` hook reads this file too,
      -- and a header written out whole would fail the commit.
      ['a private key'] = '-----BEGIN OPENSSH ' .. 'PRIVATE KEY' .. '-----',
      ['an AWS key'] = 'aws_access_key_id = AKIAIOSFODNN7EXAMPLE',
      ['a GitHub token'] = 'GH_TOKEN=ghp_0123456789abcdefghijklmnopqrstuvwx',
      ['a GitLab token'] = 'token: glpat-0123456789abcdefghij',
      ['a Slack token'] = 'SLACK=xoxb-123456789012-abcdefghijkl',
      ['an Anthropic key'] = 'key = "sk-ant-api03-abcdefghijklmnop"',
      ['a Google key'] = 'apiKey: AIzaSyA0123456789abcdefghijklmnopqrstu',
      ['a JSON Web Token'] = 'auth: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.sig',
      ['a password in a URL'] = 'url = https://admin:hunter2@example.com/db',
    }) do
      it('flags a buffer holding ' .. name, function()
        local bufnr =
          h.buffer({ name = dir .. '/values.yaml', lines = { line } })
        assert.is_true(sensitive.is_sensitive(bufnr))
      end)
    end

    for name, line in pairs({
      ['an ordinary assignment'] = 'password = get_password()',
      ['a word ending in sk-'] = 'local risk = "risk-free"',
      ['a key name without a value'] = 'aws_access_key_id = ""',
    }) do
      it('leaves a buffer holding ' .. name, function()
        local bufnr = h.buffer({ name = dir .. '/main.lua', lines = { line } })
        assert.is_false(sensitive.is_sensitive(bufnr))
      end)
    end

    it('says what it found and where', function()
      local bufnr = h.buffer({
        name = dir .. '/main.lua',
        lines = { 'local a = 1', 'local token = "ghp_0123456789abcdefghij"' },
      })
      assert.are.same({ 'GitHub token on line 2' }, sensitive.reasons(bufnr))
    end)

    it('reads the buffer again only once it has changed', function()
      local bufnr = h.buffer({ name = dir .. '/main.lua', lines = { 'clean' } })
      assert.is_false(sensitive.is_sensitive(bufnr))
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        'token = "ghp_0123456789abcdefghij"',
      })
      assert.is_true(sensitive.is_sensitive(bufnr))
    end)

    --- Leave a `betterleaks` finding on `bufnr`, as the linter would
    ---@param bufnr integer
    local function leak(bufnr)
      vim.diagnostic.set(vim.api.nvim_create_namespace('dy_spec_lint'), bufnr, {
        {
          lnum = 2,
          col = 0,
          severity = vim.diagnostic.severity.WARN,
          source = 'betterleaks',
          code = 'generic-api-key',
          message = 'Detected a generic API key',
        },
      })
    end

    it('flags a buffer betterleaks has found something in', function()
      local bufnr =
        h.buffer({ name = dir .. '/main.lua', lines = { 'a', 'b', 'c' } })
      assert.is_false(sensitive.is_sensitive(bufnr))
      leak(bufnr)
      assert.is_true(sensitive.is_sensitive(bufnr))
      assert.are.same(
        { 'betterleaks generic-api-key on line 3' },
        sensitive.reasons(bufnr)
      )
    end)

    it('waives a betterleaks finding along with the patterns', function()
      local bufnr =
        h.buffer({ name = dir .. '/main.lua', lines = { 'a', 'b', 'c' } })
      leak(bufnr)
      sensitive.allow(bufnr)
      assert.is_false(sensitive.is_sensitive(bufnr))
    end)

    it('lets a buffer through once it is allowed, but never a .env', function()
      local scratch = h.buffer({
        name = dir .. '/main.lua',
        lines = { 'token = "ghp_0123456789abcdefghij"' },
      })
      sensitive.allow(scratch)
      assert.is_false(sensitive.is_sensitive(scratch))

      local secret = h.buffer({ name = dir .. '/.env', lines = { 'A=1' } })
      sensitive.allow(secret)
      assert.is_true(sensitive.is_sensitive(secret))
    end)

    it('is false for an invalid buffer', function()
      local bufnr = h.buffer()
      vim.api.nvim_buf_delete(bufnr, { force = true })
      assert.is_false(sensitive.is_sensitive(bufnr))
    end)
  end)
end)
