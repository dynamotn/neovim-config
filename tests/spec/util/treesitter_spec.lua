local h = require('helpers')

describe('util.treesitter', function()
  local ts, restores
  before_each(function()
    h.unload('util.treesitter')
    ts = require('util.treesitter')
    ts._installed = { lua = true }
    restores = {
      h.stub(vim.treesitter.query, 'get_files', function(lang, query)
        if lang == 'lua' and query == 'folds' then return { 'folds.scm' } end
        return {}
      end),
      -- Parsing a query only to see whether it is there is what is avoided
      h.stub(
        vim.treesitter.query,
        'get',
        function() error('parsed a query to check it exists') end
      ),
    }
  end)
  after_each(function()
    for i = #restores, 1, -1 do
      restores[i]()
    end
    vim.cmd('silent! %bwipeout!')
  end)

  it('knows the installed parsers by filetype', function()
    assert.is_true(ts.have('lua'))
    assert.is_false(ts.have('python'))
  end)

  it('asks the buffer for its filetype', function()
    local bufnr = h.buffer({ filetype = 'lua' })
    assert.is_true(ts.have(bufnr))
  end)

  it('checks a query when one is named', function()
    assert.is_true(ts.have('lua', 'folds'))
    assert.is_false(ts.have('lua', 'indents'))
  end)
end)
