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

    it('is false for an invalid buffer', function()
      local bufnr = h.buffer()
      vim.api.nvim_buf_delete(bufnr, { force = true })
      assert.is_false(sensitive.is_sensitive(bufnr))
    end)
  end)
end)
