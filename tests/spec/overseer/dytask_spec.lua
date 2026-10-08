local h = require('helpers')

describe('overseer.template.dytask', function()
  it('lists every template of the bundle', function()
    local list = require('overseer.template.dytask')
    assert.are.same(
      { 'dytask.bash', 'dytask.go', 'dytask.cpp', 'dytask.ansible' },
      list
    )
    for _, name in ipairs(list) do
      assert.is_not_nil(
        vim.api.nvim_get_runtime_file(
          'lua/overseer/template/' .. name:gsub('%.', '/') .. '.lua',
          false
        )[1],
        name
      )
    end
  end)

  for _, name in ipairs({ 'bash', 'go', 'cpp', 'ansible' }) do
    it(name .. ' is a well-formed template', function()
      local template = require('overseer.template.dytask.' .. name)
      assert.are.equal('string', type(template.name))
      assert.are.equal('string', type(template.desc))
      assert.are.equal('function', type(template.builder))
      assert.are.equal(-1, template.priority)
      assert.is_not_nil(template.condition.filetype)
    end)
  end

  describe('builders', function()
    local dir, cleanup
    before_each(function()
      dir, cleanup = h.tmpdir()
    end)
    after_each(function()
      vim.cmd('silent! %bwipeout!')
      cleanup()
    end)

    local function build(name, file)
      vim.cmd.edit(dir .. '/' .. file)
      return require('overseer.template.dytask.' .. name).builder()
    end

    it('runs a shell script with bash', function()
      local task = build('bash', 'run.sh')
      assert.are.same({ 'bash', dir .. '/run.sh' }, task.cmd)
      assert.are.same({ 'output' }, task.components)
    end)

    it('runs a go file with go run', function()
      local task = build('go', 'main.go')
      assert.are.same({ 'go', 'run', dir .. '/main.go' }, task.cmd)
    end)

    it('compiles C++ before running the executable', function()
      local task = build('cpp', 'main.cpp')
      assert.are.equal(dir .. '/main', task.cmd)
      local deps = task.components[1]
      assert.are.equal('dependencies', deps[1])
      assert.are.same(
        { cmd = 'g++', args = { dir .. '/main.cpp', '-o', dir .. '/main' } },
        deps.task_names[1]
      )
      assert.are.equal('output', task.components[2])
    end)

    it('runs a playbook with ansible-playbook', function()
      local task = build('ansible', 'playbooks/site.yml')
      assert.are.same(
        { 'ansible-playbook', dir .. '/playbooks/site.yml' },
        task.cmd
      )
    end)

    it('runs a task file as its role, against this machine', function()
      h.write(dir .. '/roles/web-app/tasks/main.yml', { '- become: true' })
      local task = build('ansible', 'roles/web-app/tasks/main.yml')
      assert.are.same({
        'ansible',
        'localhost',
        '--playbook-dir',
        dir,
        '-m',
        'import_role',
        '-a',
        'name=web-app',
        '--ask-become-pass',
      }, task.cmd)
    end)

    it('runs from the directory holding ansible.cfg', function()
      h.write(dir .. '/ansible.cfg', { '[defaults]' })
      local task = build('ansible', 'playbooks/site.yml')
      assert.are.equal(dir, task.cwd)
    end)
  end)

  it(
    'offers C++ for every filetype of the cpp language',
    function()
      assert.are.same(
        require('config.languages').cpp.filetypes,
        require('overseer.template.dytask.cpp').condition.filetype
      )
    end
  )
end)
