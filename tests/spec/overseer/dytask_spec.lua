local h = require('helpers')

describe('overseer.template.dytask', function()
  it('puts every template on the runtimepath', function()
    for _, name in ipairs({ 'lang', 'ansible' }) do
      assert.is_not_nil(
        vim.api.nvim_get_runtime_file(
          'lua/overseer/template/dytask/' .. name .. '.lua',
          false
        )[1],
        name
      )
    end
  end)

  it('ansible is a well-formed template', function()
    local template = require('overseer.template.dytask.ansible')
    assert.are.equal('string', type(template.name))
    assert.are.equal('string', type(template.desc))
    assert.are.equal('function', type(template.builder))
    assert.are.equal(-1, template.priority)
    assert.is_not_nil(template.condition.filetype)
  end)

  it('lang is a template provider', function()
    local provider = require('overseer.template.dytask.lang')
    assert.are.equal('function', type(provider.generator))
  end)

  describe('config.tasks', function()
    local languages = require('config.languages')
    local tasks = require('config.tasks')

    for lang, runners in pairs(tasks) do
      it(lang .. ' is a language with well-formed runners', function()
        assert.is_not_nil(languages[lang], lang)
        assert.is_true(#runners > 0)
        for _, runner in ipairs(runners) do
          assert.are.equal('string', type(runner.name))
          assert.are.equal('string', type(runner.desc))
          assert.are.equal('function', type(runner.cmd))
          assert.is_not_nil(runner.exe, runner.name)
          for _, ft in ipairs(runner.filetypes or {}) do
            assert.is_true(
              vim.list_contains(languages[lang].filetypes, ft),
              runner.name .. ': ' .. ft
            )
          end
        end
      end)
    end

    it('names each task of a filetype once', function()
      local seen = {}
      for lang, runners in pairs(tasks) do
        for _, runner in ipairs(runners) do
          for _, ft in ipairs(runner.filetypes or languages[lang].filetypes) do
            local key = ft .. '/' .. runner.name
            assert.is_nil(seen[key], key)
            seen[key] = true
          end
        end
      end
    end)
  end)

  describe('builders', function()
    local dir, cleanup, restore
    local lang = require('overseer.template.dytask.lang')

    before_each(function()
      dir, cleanup = h.tmpdir()
      restore = {
        h.stub(
          DyNeo,
          'enabled_languages',
          vim.tbl_keys(require('config.languages'))
        ),
        h.stub(vim.fn, 'executable', function() return 1 end),
      }
    end)
    after_each(function()
      for _, fn in ipairs(restore) do
        fn()
      end
      vim.cmd('silent! %bwipeout!')
      cleanup()
    end)

    --- Templates offered for `file` under the scratch directory, by name
    ---@param file string
    ---@param filetype string
    ---@return table<string, overseer.TemplateDefinition>
    local function templates(file, filetype)
      local ret = {}
      for _, template in ipairs(lang.templates(dir .. '/' .. file, filetype)) do
        ret[template.name] = template
      end
      return ret
    end

    it('runs a shell script with bash', function()
      local task = templates('run.sh', 'sh')['bash run'].builder()
      assert.are.same({ 'bash', dir .. '/run.sh' }, task.cmd)
      assert.are.same({ 'default', 'output' }, task.components)
    end)

    it(
      'matches a compound filetype',
      function()
        assert.is_not_nil(templates('PKGBUILD', 'sh.PKGBUILD')['bash run'])
      end
    )

    it('runs a bats file with bats, not bash', function()
      local list = templates('x.bats', 'bats')
      assert.is_nil(list['bash run'])
      assert.are.same(
        { 'bats', dir .. '/x.bats' },
        list['bats test'].builder().cmd
      )
    end)

    it('runs a go file with go run', function()
      local list = templates('main.go', 'go')
      assert.are.same(
        { 'go', 'run', dir .. '/main.go' },
        list['go run'].builder().cmd
      )
      assert.is_nil(list['go build'])
    end)

    it('builds a go module from its root', function()
      h.write(dir .. '/go.mod', { 'module x' })
      local task = templates('cmd/x/main.go', 'go')['go test'].builder()
      assert.are.same({ 'go', 'test', './...' }, task.cmd)
      assert.are.equal(dir, task.cwd)
    end)

    it('compiles C with cc and C++ with g++ before running', function()
      local c = templates('main.c', 'c')
      assert.is_nil(c['g++ build and run'])
      local task = c['c build and run'].builder()
      assert.are.same({ dir .. '/main' }, task.cmd)
      assert.are.equal('default', task.components[1])
      assert.are.same({
        'dependencies',
        tasks = { { cmd = { 'cc', dir .. '/main.c', '-o', dir .. '/main' } } },
      }, task.components[2])
      assert.are.equal('output', task.components[3])

      local cpp = templates('main.cpp', 'cpp')['g++ build and run'].builder()
      assert.are.same(
        { 'g++', dir .. '/main.cpp', '-o', dir .. '/main' },
        cpp.components[2].tasks[1].cmd
      )
    end)

    it('falls back to the next executable', function()
      restore[#restore + 1] = h.stub(
        vim.fn,
        'executable',
        function(name) return name == 'python3' and 0 or 1 end
      )
      local task = templates('x.py', 'python')['python run'].builder()
      assert.are.same({ 'python', dir .. '/x.py' }, task.cmd)
    end)

    it('offers nothing when no executable is found', function()
      restore[#restore + 1] = h.stub(
        vim.fn,
        'executable',
        function() return 0 end
      )
      assert.are.same({}, lang.templates(dir .. '/x.py', 'python'))
    end)

    it('offers nothing for a disabled language', function()
      restore[#restore + 1] = h.stub(DyNeo, 'enabled_languages', { 'go' })
      assert.are.same({}, lang.templates(dir .. '/x.py', 'python'))
    end)

    it('tells a kotlin script from a kotlin file', function()
      local script = templates('x.kts', 'kotlin')
      assert.is_not_nil(script['kotlin script run'])
      assert.is_nil(script['kotlin build and run'])
      local file = templates('x.kt', 'kotlin')
      assert.is_nil(file['kotlin script run'])
      assert.are.same(
        { 'java', '-jar', dir .. '/x.jar' },
        file['kotlin build and run'].builder().cmd
      )
    end)

    it('leaves a file of a cargo project to cargo', function()
      assert.is_not_nil(templates('x.rs', 'rust')['rustc build and run'])
      h.write(dir .. '/Cargo.toml', { '[package]' })
      assert.is_nil(templates('src/main.rs', 'rust')['rustc build and run'])
    end)

    it('prefers the gradle wrapper of the project', function()
      h.write(dir .. '/settings.gradle', {})
      h.write(dir .. '/gradlew', {})
      local task = templates('src/X.java', 'java')['gradle test'].builder()
      assert.are.same({ dir .. '/gradlew', 'test' }, task.cmd)
      assert.are.equal(dir, task.cwd)
    end)

    it('finds a .NET project by its project file', function()
      h.write(dir .. '/app.csproj', { '<Project />' })
      local task = templates('Program.cs', 'cs')['dotnet build'].builder()
      assert.are.equal(dir, task.cwd)
    end)

    it('plans terraform from the directory of the file', function()
      local task =
        templates('envs/prod/main.tf', 'terraform')['terraform plan'].builder()
      assert.are.same({ 'tofu', 'plan' }, task.cmd)
      assert.are.equal(dir .. '/envs/prod', task.cwd)
    end)

    it('runs a playbook with ansible-playbook', function()
      vim.cmd.edit(dir .. '/playbooks/site.yml')
      local task = require('overseer.template.dytask.ansible').builder()
      assert.are.same(
        { 'ansible-playbook', dir .. '/playbooks/site.yml' },
        task.cmd
      )
    end)

    it('runs a task file as its role, against this machine', function()
      h.write(dir .. '/roles/web-app/tasks/main.yml', { '- become: true' })
      vim.cmd.edit(dir .. '/roles/web-app/tasks/main.yml')
      local task = require('overseer.template.dytask.ansible').builder()
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

    it('runs ansible from the directory holding ansible.cfg', function()
      h.write(dir .. '/ansible.cfg', { '[defaults]' })
      vim.cmd.edit(dir .. '/playbooks/site.yml')
      local task = require('overseer.template.dytask.ansible').builder()
      assert.are.equal(dir, task.cwd)
    end)
  end)
end)
