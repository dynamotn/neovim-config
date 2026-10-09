local h = require('helpers')

describe('util.forge', function()
  local forge, dir, cleanup

  before_each(function()
    h.unload('util.forge')
    forge = require('util.forge')
    dir, cleanup = h.tmpdir()
  end)
  after_each(function() cleanup() end)

  it('reads the host and path of every kind of clone URL', function()
    local cases = {
      ['https://github.com/o/r.git'] = { 'github.com', 'o/r' },
      ['https://user@GitLab.com/g/sub/p'] = { 'gitlab.com', 'g/sub/p' },
      ['ssh://git@gitlab.example.org:2222/g/p.git'] = {
        'gitlab.example.org',
        'g/p',
      },
      ['git@github.com:o/r.git'] = { 'github.com', 'o/r' },
      ['git@github.com:o/r/'] = { 'github.com', 'o/r' },
    }
    for url, expected in pairs(cases) do
      assert.same(expected, { forge.parse_url(url) }, url)
    end
    assert.is_nil(forge.parse_url('/local/path'))
  end)

  it('tells the forge by its host', function()
    assert.equals('github', forge.kind_of('github.com'))
    assert.equals('github', forge.kind_of('github.example.com'))
    assert.equals('gitlab', forge.kind_of('gitlab.com'))
    assert.equals('gitlab', forge.kind_of('gitlab.internal'))
    assert.is_nil(forge.kind_of('codeberg.org'))
  end)

  it('takes the first remote on a known forge, in order', function()
    local function git(...)
      vim.system(vim.list_extend({ 'git' }, { ... }), { cwd = dir }):wait()
    end
    git('init', '-q', '-b', 'trunk')
    git('remote', 'add', 'origin', 'git@gitlab.com:g/p.git')
    git('remote', 'add', 'upstream', 'https://codeberg.org/x/y')
    git('remote', 'add', 'gh', 'https://github.com/o/r')
    assert.same(
      { name = 'gh', host = 'github.com', slug = 'o/r', kind = 'github' },
      forge.remote(dir)
    )
    assert.equals('trunk', forge.branch(dir))
    assert.is_nil(forge.remote(dir .. '/nowhere'))
  end)

  it(
    'percent-encodes a path segment',
    function() assert.equals('g%2Fsub%2Fp', forge.encode('g/sub/p')) end
  )

  describe('api', function()
    local path

    before_each(function()
      vim.fn.mkdir(dir .. '/bin', 'p')
      path = vim.env.PATH
      vim.env.PATH = dir .. '/bin:' .. path
    end)
    after_each(function() vim.env.PATH = path end)

    local function cli(name, lines)
      h.write(dir .. '/bin/' .. name, vim.list_extend({ '#!/bin/sh' }, lines))
      vim.fn.setfperm(dir .. '/bin/' .. name, 'rwxr-xr-x')
    end

    local function call(remote, endpoint)
      local done, data, err = false, nil, nil
      forge.api(remote, endpoint, function(d, e)
        done, data, err = true, d, e
      end)
      assert.is_true(vim.wait(5000, function() return done end, 10))
      return data, err
    end

    it('asks gh for GitHub and glab for GitLab, on the right host', function()
      cli(
        'gh',
        { 'echo "$@" > "' .. dir .. '/gh.args"', [[echo '{"a":null,"b":[1]}']] }
      )
      cli('glab', { 'echo "$@" > "' .. dir .. '/glab.args"', 'echo "[]"' })
      local data = call(
        { kind = 'github', host = 'github.com', slug = 'o/r', name = 'gh' },
        'repos/o/r'
      )
      assert.same({ b = { 1 } }, data)
      assert.same(
        { 'api --hostname github.com repos/o/r' },
        vim.fn.readfile(dir .. '/gh.args')
      )
      assert.same(
        {},
        call(
          { kind = 'gitlab', host = 'gitlab.x', slug = 'g/p', name = 'origin' },
          'projects'
        )
      )
      assert.same(
        { 'api --hostname gitlab.x projects' },
        vim.fn.readfile(dir .. '/glab.args')
      )
    end)

    it('says why there is no answer', function()
      cli('gh', { 'echo "HTTP 404" >&2', 'exit 1' })
      local remote =
        { kind = 'github', host = 'github.com', slug = 'o/r', name = 'gh' }
      local data, err = call(remote, 'x')
      assert.is_nil(data)
      assert.equals('HTTP 404', err)
      cli('gh', { 'echo "<html>"' })
      _, err = call(remote, 'x')
      assert.equals('gh api answered with something not JSON', err)
    end)
  end)
end)
