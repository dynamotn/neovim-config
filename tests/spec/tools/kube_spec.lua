local h = require('helpers')

describe('tools.kube', function()
  local kube, dir, cleanup

  before_each(function()
    h.unload('tools.kube')
    kube = require('tools.kube')
    dir, cleanup = h.tmpdir()
    h.write(dir .. '/app/deploy.yaml', {
      'apiVersion: apps/v1',
      'kind: Deployment',
      'metadata:',
      '  name: web',
    })
    h.write(dir .. '/app/kustomization.yaml', { 'resources: [deploy.yaml]' })
    h.write(dir .. '/chart/Chart.yaml', { 'name: web' })
    h.write(dir .. '/chart/values-prod.yaml', { 'replicas: 3' })
    h.write(dir .. '/chart/templates/svc.yaml', { 'kind: Service' })
    h.write(dir .. '/ci.yaml', { 'jobs:', '  build: {}' })
  end)
  after_each(function()
    vim.cmd('silent! tabonly!')
    vim.cmd('silent! %bwipeout!')
    cleanup()
  end)

  describe('target', function()
    it('sends a manifest as it is, a kustomization as a directory', function()
      assert.same({
        kind = 'manifest',
        file = dir .. '/app/deploy.yaml',
        dir = dir .. '/app',
      }, kube.target(dir .. '/app/deploy.yaml'))
      assert.equals(
        'kustomize',
        kube.target(dir .. '/app/kustomization.yaml').kind
      )
      assert.same(
        { 'kubectl', 'diff', '-k', dir .. '/app' },
        kube.kubectl_command(
          { 'diff' },
          kube.target(dir .. '/app/kustomization.yaml')
        )
      )
    end)

    it(
      'renders a chart, with the values file or the template edited',
      function()
        local values = kube.target(dir .. '/chart/values-prod.yaml')
        assert.same({
          'helm',
          'template',
          'chart',
          dir .. '/chart',
          '--values',
          dir .. '/chart/values-prod.yaml',
        }, kube.render_command(values))
        local template = kube.target(dir .. '/chart/templates/svc.yaml')
        assert.same({
          'helm',
          'template',
          'chart',
          dir .. '/chart',
          '--show-only',
          'templates/svc.yaml',
        }, kube.render_command(template))
        assert.same(
          { 'kubectl', 'apply', '--dry-run=server', '-f', '-' },
          kube.kubectl_command({ 'apply', '--dry-run=server' }, values)
        )
      end
    )
  end)

  it('maps only a buffer a cluster would take', function()
    local function has_maps(file)
      vim.cmd.edit(file)
      local bufnr = vim.api.nvim_get_current_buf()
      kube.attach(bufnr)
      for _, map in ipairs(vim.api.nvim_buf_get_keymap(bufnr, 'n')) do
        if map.desc == 'Diff With Cluster' then return true end
      end
      return false
    end
    assert.is_true(has_maps(dir .. '/app/deploy.yaml'))
    assert.is_true(has_maps(dir .. '/chart/values-prod.yaml'))
    assert.is_false(has_maps(dir .. '/ci.yaml'))
  end)

  describe('with a cluster', function()
    local path, notes, restore_notify, log

    --- A command that logs its arguments and stdin, prints `out`, exits `code`
    local function fake(name, out, code)
      h.write(dir .. '/bin/' .. name, {
        '#!/bin/sh',
        'echo "' .. name .. ' $*" >> "' .. log .. '"',
        'for last; do :; done',
        'if [ "$last" = "-" ]; then sed "s/^/stdin: /" >> "' .. log .. '"; fi',
        "printf '%s\\n' '" .. out .. "'",
        'exit ' .. code,
      })
      vim.fn.setfperm(dir .. '/bin/' .. name, 'rwxr-xr-x')
    end

    local function logged() return vim.fn.readfile(log) end

    local function settle(n)
      assert.is_true(
        vim.wait(
          10000,
          function() return #notes >= n or vim.bo.filetype == 'diff' end,
          20
        )
      )
    end

    before_each(function()
      log = dir .. '/calls.log'
      vim.fn.mkdir(dir .. '/bin', 'p')
      path = vim.env.PATH
      vim.env.PATH = dir .. '/bin:' .. path
      notes = {}
      restore_notify = h.stub(
        vim,
        'notify',
        function(msg) table.insert(notes, msg) end
      )
    end)
    after_each(function()
      vim.env.PATH = path
      restore_notify()
    end)

    it('shows a diff, kept from every AI', function()
      fake('kubectl', '+  replicas: 3', 1)
      vim.cmd.edit(dir .. '/app/deploy.yaml')
      kube.diff()
      settle(1)
      assert.equals('diff', vim.bo.filetype)
      assert.same(
        { '+  replicas: 3' },
        vim.api.nvim_buf_get_lines(0, 0, -1, false)
      )
      assert.is_true(require('util.sensitive').is_sensitive(0))
      assert.same({ 'kubectl diff -f ' .. dir .. '/app/deploy.yaml' }, logged())
    end)

    it('says so when nothing differs', function()
      fake('kubectl', '', 0)
      vim.cmd.edit(dir .. '/app/deploy.yaml')
      kube.diff()
      settle(1)
      assert.equals('No differences with the cluster', notes[1])
    end)

    it('validates a chart by rendering it into kubectl', function()
      fake('helm', 'kind: Service', 0)
      fake('kubectl', 'service/web created (server dry run)', 0)
      vim.cmd.edit(dir .. '/chart/values-prod.yaml')
      kube.dry_run()
      settle(1)
      assert.equals('service/web created (server dry run)', notes[1])
      local calls = logged()
      assert.equals(
        'helm template chart '
          .. dir
          .. '/chart --values '
          .. dir
          .. '/chart/values-prod.yaml',
        calls[1]
      )
      assert.equals('kubectl apply --dry-run=server -f -', calls[2])
      assert.equals('stdin: kind: Service', calls[3])
    end)

    --- A kubectl whose context is `prod-cluster`, namespace `web`
    local function kubectl()
      h.write(dir .. '/bin/kubectl', {
        '#!/bin/sh',
        'echo "kubectl $*" >> "' .. log .. '"',
        'case "$*" in',
        '  *current-context*) echo prod-cluster ;;',
        '  *jsonpath*) echo web ;;',
        '  *) echo applied ;;',
        'esac',
      })
      vim.fn.setfperm(dir .. '/bin/kubectl', 'rwxr-xr-x')
    end

    it('applies only once told to, naming the context', function()
      kubectl()
      vim.cmd.edit(dir .. '/app/deploy.yaml')
      local asked
      local restore = h.stub(vim.fn, 'confirm', function(msg)
        asked = msg
        return 2
      end)
      kube.apply()
      restore()
      assert.equals(
        'Apply deploy.yaml to context prod-cluster, namespace web by default?',
        asked
      )
      assert.is_nil(
        vim
          .iter(logged())
          :find(function(l) return l:find(' apply', 1, true) end)
      )
    end)

    it('applies to the context it named, whatever comes after', function()
      kubectl()
      vim.cmd.edit(dir .. '/app/deploy.yaml')
      local restore = h.stub(vim.fn, 'confirm', function() return 1 end)
      kube.apply()
      restore()
      settle(1)
      assert.equals(
        'kubectl --context=prod-cluster apply -f ' .. dir .. '/app/deploy.yaml',
        logged()[#logged()]
      )
    end)

    it('applies no chart with kubectl', function()
      kubectl()
      vim.cmd.edit(dir .. '/chart/templates/svc.yaml')
      kube.apply()
      assert.is_truthy(notes[1]:find('helm upgrade', 1, true))
      assert.equals(0, vim.fn.filereadable(log))
    end)

    it('acts on no buffer with changes not written', function()
      kubectl()
      vim.cmd.edit(dir .. '/app/deploy.yaml')
      vim.api.nvim_buf_set_lines(0, 0, 1, false, { 'kind: Changed' })
      kube.diff()
      kube.apply()
      assert.is_truthy(notes[1]:find('Write the buffer first', 1, true))
      assert.equals(0, vim.fn.filereadable(log))
    end)
  end)
end)
