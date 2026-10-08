local h = require('helpers')

describe('util.gitlab_auth', function()
  local auth, notes, restore_notify

  before_each(function()
    h.unload('util.gitlab_auth')
    auth = require('util.gitlab_auth')
    notes = {}
    restore_notify = h.stub(
      vim,
      'notify',
      function(msg) table.insert(notes, msg) end
    )
  end)
  after_each(function() restore_notify() end)

  it('reads the host off every kind of remote URL', function()
    assert.equals('gitlab.com', auth.host_of('git@gitlab.com:group/repo.git'))
    assert.equals('gitlab.com', auth.host_of('https://gitlab.com/group/repo'))
    assert.equals(
      'git.example.org',
      auth.host_of('https://user@git.example.org/group/sub/repo.git')
    )
    assert.equals(
      'git.example.org',
      auth.host_of('ssh://git@git.example.org:2222/group/repo.git')
    )
    assert.is_nil(auth.host_of('/a/local/path'))
  end)

  describe('auth', function()
    local restores

    before_each(function()
      restores = {
        h.stub(
          auth,
          'remote_url',
          function() return 'git@git.example.org:group/repo.git' end
        ),
      }
    end)
    after_each(function()
      for _, restore in ipairs(restores) do
        restore()
      end
    end)

    it('takes what the plugin found itself', function()
      table.insert(
        restores,
        h.stub(auth, 'glab_token', function() error('asked glab') end)
      )
      local token, url = auth.auth(
        function() return 'from-file', 'https://file.example' end,
        'origin'
      )
      assert.equals('from-file', token)
      assert.equals('https://file.example', url)
    end)

    it('fills the token from glab and the URL from the remote', function()
      local asked
      table.insert(
        restores,
        h.stub(auth, 'glab_token', function(host)
          asked = host
          return 'from-glab'
        end)
      )
      local token, url, err = auth.auth(
        function() return nil, nil end,
        'origin'
      )
      assert.equals('git.example.org', asked)
      assert.equals('from-glab', token)
      assert.equals('https://git.example.org', url)
      assert.is_nil(err)
    end)

    it('keeps a token from the environment and adds the URL', function()
      table.insert(
        restores,
        h.stub(auth, 'glab_token', function() error('asked glab') end)
      )
      local token, url = auth.auth(
        function() return 'from-env', nil end,
        'origin'
      )
      assert.equals('from-env', token)
      assert.equals('https://git.example.org', url)
    end)

    it('says why when there is no token anywhere', function()
      table.insert(
        restores,
        h.stub(auth, 'glab_token', function() return nil end)
      )
      local token, _, err = auth.auth(function() return '', nil end, 'origin')
      assert.is_nil(token)
      assert.is_truthy(err:find('glab auth login', 1, true))
      assert.equals(err, notes[1])
    end)
  end)
end)
