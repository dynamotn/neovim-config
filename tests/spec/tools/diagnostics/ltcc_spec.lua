local stub = require('spec.tools.null_ls_stub')

describe('tools.diagnostics.ltcc', function()
  local builtin
  before_each(function()
    stub.install('tools.diagnostics.ltcc')
    builtin = require('tools.diagnostics.ltcc')
  end)
  after_each(stub.uninstall)

  it('is a diagnostics source running ltcc', function()
    assert.are.equal('ltcc', builtin.name)
    assert.are.equal('NULL_LS_DIAGNOSTICS', builtin.method)
    assert.are.equal('ltcc', builtin.generator_opts.command)
    assert.is_true(builtin.generator_opts.check_exit_code(1))
    assert.is_false(builtin.generator_opts.check_exit_code(2))
  end)

  it(
    'returns nothing without output',
    function()
      assert.are.same({}, builtin.generator_opts.on_output({ output = nil }))
    end
  )

  it('turns each match into an offense spanning it', function()
    local result = builtin.generator_opts.on_output({
      output = {
        {
          message = 'Possible spelling mistake.',
          rule = { id = 'MORFOLOGIK_RULE_EN_US' },
          moreContext = { line_number = 4, line_offset = 7 },
          length = 3,
          replacements = { { value = 'the' }, { value = 'tea' } },
        },
      },
    })
    assert.are.same({ ERROR = stub.severities.error }, result.severities)
    assert.are.same({
      {
        message = 'Possible spelling mistake. Try: “the”, “tea”',
        ruleId = 'MORFOLOGIK_RULE_EN_US',
        level = 'ERROR',
        line = 4,
        column = 8,
        endLine = 4,
        endColumn = 11,
      },
    }, result.offenses)
  end)

  it('keeps a match without replacements', function()
    local result = builtin.generator_opts.on_output({
      output = {
        {
          message = 'Odd.',
          rule = { id = 'X' },
          moreContext = { line_number = 1, line_offset = 0 },
          length = 1,
          replacements = {},
        },
      },
    })
    assert.are.equal('Odd. Try: ', result.offenses[1].message)
  end)
end)
