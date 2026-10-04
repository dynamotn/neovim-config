local h = require('helpers')

describe('util.lint_code', function()
  local lint_code

  before_each(function()
    h.unload('util.lint_code')
    lint_code = require('util.lint_code')
  end)

  ---@param name string
  ---@param diagnostic vim.Diagnostic|table
  local function map(name, diagnostic)
    return lint_code.mappers[name](diagnostic)
  end

  describe('mappers', function()
    it('reads the markdownlint rule number', function()
      local d = map('markdownlint-cli2', {
        message = 'MD013/line-length Line length [Expected: 80; Actual: 110]',
      })
      assert.equals('MD013', d.code)
    end)

    it('keeps a code that is already set', function()
      local d = map('markdownlint-cli2', { code = 'X', message = 'MD001/a b' })
      assert.equals('X', d.code)
    end)

    it('leaves the code empty when nothing matches', function()
      assert.is_nil(map('markdownlint-cli2', { message = 'nothing here' }).code)
      assert.is_nil(map('swiftlint', {}).code)
    end)

    it('reads an ansible-lint rule with a sub-rule', function()
      local d = map('ansible_lint', {
        message = 'name[casing] All names should start with an uppercase',
      })
      assert.equals('name[casing]', d.code)
    end)

    it('reads a hyphenated ansible-lint rule', function()
      local d = map('ansible_lint', {
        message = 'risky-file-permissions File permissions unset',
      })
      assert.equals('risky-file-permissions', d.code)
    end)

    it(
      'does not take a plain first word as an ansible-lint rule',
      function()
        assert.is_nil(
          map('ansible_lint', { message = 'syntax error here' }).code
        )
      end
    )

    it('reads the swiftlint rule at the end', function()
      local d = map('swiftlint', {
        message = 'Line Length Violation: too long (line_length)',
      })
      assert.equals('line_length', d.code)
    end)

    it('reads the tflint rule before the reference', function()
      local d = map('tflint', {
        message = '"t1.tiny" is an invalid value (aws_instance_invalid_type)\nReference: https://x',
      })
      assert.equals('aws_instance_invalid_type', d.code)
    end)

    it('reads the perlcritic policy', function()
      local d = map('perlcritic', {
        message = 'Code before strictures [TestingAndDebugging::RequireUseStrict]',
      })
      assert.equals('TestingAndDebugging::RequireUseStrict', d.code)
    end)

    for name, tool in pairs({
      golangcilint = 'golangci-lint',
      buf_lint = 'buf_lint',
    }) do
      it(name .. ' moves the rule out of source', function()
        local d = map(name, { source = 'errcheck', message = 'm' })
        assert.equals('errcheck', d.code)
        assert.equals(tool, d.source)
      end)

      it(name .. ' keeps an existing code', function()
        local d = map(name, { code = 'c', source = 's', message = 'm' })
        assert.equals('c', d.code)
        assert.equals(tool, d.source)
      end)
    end
  end)

  describe('setup', function()
    local loads

    before_each(function()
      loads = {}
      local linters = setmetatable({
        swiftlint = { cmd = 'swiftlint', preloaded = true },
      }, {
        __index = function(t, name)
          loads[name] = (loads[name] or 0) + 1
          if name == 'missing' then return nil end
          local linter = { cmd = name }
          rawset(t, name, linter)
          return linter
        end,
      })
      package.loaded['lint'] = { linters = linters }
      package.loaded['lint.util'] = {
        wrap = function(linter, mapper)
          return { wrapped = linter, mapper = mapper }
        end,
      }
    end)
    after_each(function()
      package.loaded['lint'] = nil
      package.loaded['lint.util'] = nil
    end)

    it('wraps a linter already loaded', function()
      lint_code.setup()
      local linter = rawget(package.loaded['lint'].linters, 'swiftlint')
      assert.is_true(linter.wrapped.preloaded)
      assert.equals(lint_code.mappers.swiftlint, linter.mapper)
    end)

    it('wraps a mapped linter on its first lookup only', function()
      lint_code.setup()
      local linters = package.loaded['lint'].linters
      local first = linters.tflint
      assert.equals('tflint', first.wrapped.cmd)
      assert.equals(first, linters.tflint)
      assert.equals(1, loads.tflint)
    end)

    it('leaves other linters as they are', function()
      lint_code.setup()
      local linters = package.loaded['lint'].linters
      assert.same({ cmd = 'shellcheck' }, linters.shellcheck)
      assert.is_nil(linters.missing)
    end)

    it('does nothing the second time', function()
      lint_code.setup()
      local index = getmetatable(package.loaded['lint'].linters).__index
      lint_code.setup()
      assert.equals(index, getmetatable(package.loaded['lint'].linters).__index)
      assert.is_nil(
        rawget(package.loaded['lint'].linters, 'swiftlint').wrapped.wrapped
      )
    end)
  end)
end)
