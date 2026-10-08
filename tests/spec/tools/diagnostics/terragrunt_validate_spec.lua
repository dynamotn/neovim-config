local h = require('helpers')
local stub = require('spec.tools.null_ls_stub')

describe('tools.diagnostics.terragrunt_validate', function()
  local builtin, opts
  before_each(function()
    stub.install('tools.diagnostics.terragrunt_validate')
    builtin = require('tools.diagnostics.terragrunt_validate')
    opts = builtin.generator_opts
  end)
  after_each(stub.uninstall)

  it('runs `terragrunt hcl validate --json` on save', function()
    assert.are.equal('terragrunt_validate', builtin.name)
    assert.are.equal('NULL_LS_DIAGNOSTICS_ON_SAVE', builtin.method)
    assert.are.equal('terragrunt', opts.command)
    assert.are.same({ 'hcl', 'validate', '--json' }, opts.args)
    assert.is_true(opts.multiple_files)
  end)

  it(
    'runs in the directory of the buffer',
    function()
      assert.are.equal(
        '/repo/live/app',
        opts.cwd({ bufname = '/repo/live/app/terragrunt.hcl' })
      )
    end
  )

  -- none-ls hands stdout to `on_output` only for an exit it was told is fine;
  -- any other, with nothing on stderr, has its stdout taken for the error
  it('reads the output whatever the exit code', function()
    assert.is_true(opts.check_exit_code(0, ''))
    assert.is_true(opts.check_exit_code(1, 'boom'))
  end)

  describe('on_output', function()
    it('places a diagnostic with a range where it points', function()
      local result = opts.on_output({
        bufname = '/repo/a/terragrunt.hcl',
        cwd = '/repo/a',
        output = {
          {
            summary = 'Unsupported argument',
            detail = 'An argument named "foo" is not expected here.',
            severity = 'error',
            range = {
              filename = '/repo/a/child/terragrunt.hcl',
              start = { line = 3, column = 2 },
              ['end'] = { line = 3, column = 5 },
            },
          },
        },
      })
      assert.are.same({
        {
          message = 'Unsupported argument - An argument named "foo" is not expected here.',
          row = 3,
          col = 2,
          end_row = 3,
          end_col = 5,
          source = 'terragrunt validate',
          severity = stub.severities.error,
          filename = '/repo/a/child/terragrunt.hcl',
        },
      }, result)
    end)

    it('puts a diagnostic without a range at the top of the buffer', function()
      local result = opts.on_output({
        bufname = '/repo/a/terragrunt.hcl',
        cwd = '/repo/a',
        output = { { summary = 'Deprecated', severity = 'warning' } },
      })
      assert.are.same({
        {
          message = 'Deprecated',
          row = 0,
          col = 0,
          source = 'terragrunt validate',
          severity = stub.severities.warning,
          filename = '/repo/a/terragrunt.hcl',
        },
      }, result)
    end)

    it('keeps earlier diagnostics of other directories only', function()
      package.loaded['null-ls.diagnostics'] = {
        get_namespace = function(id) return 'ns' .. id end,
      }
      local asked
      local restore = h.stub(vim.diagnostic, 'get', function(bufnr, o)
        asked = { bufnr, o }
        return {
          { filename = '/repo/b/terragrunt.hcl', message = 'kept' },
          { filename = '/repo/a/terragrunt.hcl', message = 'replaced' },
        }
      end)
      local ok, result = pcall(opts.on_output, {
        source_id = 7,
        bufname = '/repo/a/terragrunt.hcl',
        cwd = '/repo/a',
        output = {},
      })
      restore()
      assert.is_true(ok, result)
      assert.are.same({ nil, { namespace = 'ns7' } }, asked)
      assert.are.same(
        { { filename = '/repo/b/terragrunt.hcl', message = 'kept' } },
        result
      )
    end)
  end)
end)
