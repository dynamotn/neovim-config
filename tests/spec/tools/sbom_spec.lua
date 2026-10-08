local h = require('helpers')

describe('tools.sbom', function()
  local sbom, dir, cleanup

  before_each(function()
    dir, cleanup = h.tmpdir()
    h.unload('tools.sbom')
    sbom = require('tools.sbom')
  end)
  after_each(function()
    vim.cmd('silent! tabonly!')
    vim.cmd('silent! %bwipeout!')
    cleanup()
  end)

  describe('plugin_purl', function()
    it('names a repository of a forge by its own purl type', function()
      assert.equals(
        'pkg:github/folke/snacks.nvim@abc123',
        sbom.plugin_purl(
          'snacks.nvim',
          'https://github.com/folke/snacks.nvim.git',
          'abc123'
        )
      )
      assert.equals(
        'pkg:gitlab/group/sub/repo@abc123',
        sbom.plugin_purl('repo', 'git@gitlab.com:Group/Sub/Repo.git', 'abc123')
      )
    end)

    it('falls back to a generic purl with the clone URL', function()
      assert.equals(
        'pkg:generic/ci.nvim@abc123?vcs_url='
          .. 'git%2Bhttps%3A%2F%2Fforge.example.org%2Fme%2Fci.nvim%40abc123',
        sbom.plugin_purl(
          'ci.nvim',
          'https://forge.example.org/me/ci.nvim',
          'abc123'
        )
      )
      assert.equals(
        'pkg:generic/local.nvim@abc123',
        sbom.plugin_purl('local.nvim', nil, 'abc123')
      )
    end)
  end)

  it('lists the plugins of a lockfile', function()
    local lockfile = dir .. '/lazy-lock.json'
    h.write(lockfile, {
      vim.json.encode({
        ['snacks.nvim'] = { branch = 'main', commit = 'aaa111' },
        ['broken'] = 'not a table',
      }),
    })
    assert.same(
      {
        {
          name = 'snacks.nvim',
          version = 'aaa111',
          purl = 'pkg:github/folke/snacks.nvim@aaa111',
          source = 'lazy.nvim',
        },
      },
      sbom.plugins(lockfile, {
        ['snacks.nvim'] = 'https://github.com/folke/snacks.nvim',
      })
    )
  end)

  it('lists the packages of the Mason receipts', function()
    h.write(dir .. '/packages/ansible-lint/mason-receipt.json', {
      vim.json.encode({
        name = 'ansible-lint',
        source = { id = 'pkg:pypi/ansible-lint@26.9.0' },
      }),
    })
    h.write(dir .. '/packages/ls/mason-receipt.json', {
      vim.json.encode({
        name = '@ansible/ls',
        source = { id = 'pkg:npm/%40ansible/ls@1.2.3?x=y' },
      }),
    })
    h.write(dir .. '/packages/mine/mason-receipt.json', {
      vim.json.encode({ name = 'mine', source = { id = 'dytoy:mine' } }),
    })
    vim.fn.mkdir(dir .. '/packages/no-receipt', 'p')

    local components = sbom.mason(dir)
    table.sort(components, function(a, b) return a.name < b.name end)
    assert.same({
      {
        name = '@ansible/ls',
        version = '1.2.3',
        purl = 'pkg:npm/%40ansible/ls@1.2.3?x=y',
        source = 'mason',
      },
      {
        name = 'ansible-lint',
        version = '26.9.0',
        purl = 'pkg:pypi/ansible-lint@26.9.0',
        source = 'mason',
      },
      { name = 'mine', version = 'unknown', source = 'mason' },
    }, components)
  end)

  it('writes a CycloneDX document', function()
    local bom = sbom.bom({
      {
        name = 'x',
        version = '1',
        purl = 'pkg:npm/x@1',
        source = 'mason',
      },
      { name = 'mine', version = 'unknown', source = 'mason' },
    }, 0)
    assert.equals('CycloneDX', bom.bomFormat)
    assert.equals('1.5', bom.specVersion)
    assert.is_truthy(
      bom.serialNumber:match(
        '^urn:uuid:%x%x%x%x%x%x%x%x%-%x%x%x%x%-4%x%x%x%-[89ab]%x%x%x%-%x+$'
      )
    )
    assert.equals('1970-01-01T00:00:00Z', bom.metadata.timestamp)
    assert.equals('pkg:npm/x@1', bom.components[1]['bom-ref'])
    assert.equals('mason:mine', bom.components[2]['bom-ref'])
    assert.same(
      { { name = 'dyneo:installed-by', value = 'mason' } },
      bom.components[1].properties
    )
  end)

  describe('osv', function()
    local components = {
      { name = 'a', version = '1', purl = 'pkg:npm/a@1', source = 'mason' },
      {
        name = 'b',
        version = 'v2',
        purl = 'pkg:github/o/b@v2',
        source = 'mason',
      },
      {
        name = 'c.nvim',
        version = 'abc123',
        purl = 'pkg:github/o/c.nvim@abc123',
        source = 'lazy.nvim',
      },
      { name = 'mine', version = 'unknown', source = 'mason' },
    }

    it('asks by purl for a package and by commit for a plugin', function()
      local queries, asked = sbom.osv_queries(components)
      assert.same({
        { package = { purl = 'pkg:npm/a@1' } },
        { commit = 'abc123' },
      }, queries)
      assert.same(
        { 'a', 'c.nvim' },
        vim.tbl_map(function(c) return c.name end, asked)
      )
    end)

    it('reports the components OSV knows a vulnerability of', function()
      local _, asked = sbom.osv_queries(components)
      local findings = sbom.osv_findings(asked, {
        results = {
          { vulns = { { id = 'GHSA-2' }, { id = 'CVE-1' } } },
          {},
        },
      })
      assert.equals(1, #findings)
      assert.equals('a', findings[1].component.name)
      assert.same({ 'CVE-1', 'GHSA-2' }, findings[1].ids)

      local lines = sbom.osv_report(findings, #asked, #components)
      assert.equals('# Known vulnerabilities: 1', lines[1])
      assert.is_truthy(vim.tbl_contains(lines, '## a 1 (mason)'))
      assert.is_truthy(
        vim.tbl_contains(lines, '- CVE-1 https://osv.dev/vulnerability/CVE-1')
      )
    end)
  end)

  it('writes the document to a path, or shows it', function()
    local restore = h.stub(
      sbom,
      'components',
      function()
        return {
          { name = 'x', version = '1', purl = 'pkg:npm/x@1', source = 'mason' },
        }
      end
    )
    local notes = {}
    local restore_notify = h.stub(
      vim,
      'notify',
      function(msg) table.insert(notes, msg) end
    )

    sbom.command({ fargs = { dir .. '/out/sbom.cdx.json' } })
    local written = vim.json.decode(
      table.concat(vim.fn.readfile(dir .. '/out/sbom.cdx.json'), '\n')
    )
    assert.equals('pkg:npm/x@1', written.components[1].purl)
    assert.is_truthy(
      notes[1]:find('1 plugins and packages written to', 1, true)
    )

    sbom.command({ fargs = {} })
    assert.equals('json', vim.bo.filetype)

    restore_notify()
    restore()
  end)
end)
