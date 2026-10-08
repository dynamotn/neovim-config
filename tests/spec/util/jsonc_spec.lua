local h = require('helpers')

describe('util.jsonc', function()
  local jsonc
  before_each(function()
    h.unload('util.jsonc')
    jsonc = require('util.jsonc')
  end)

  it('reads trailing commas and comments, as VS Code writes them', function()
    local text = table.concat({
      '{',
      '  // launch targets',
      '  "configurations": [',
      '    { "name": "a", "args": [1, 2,], }, /* last */',
      '  ],',
      '}',
    }, '\n')
    assert.are.same(
      { configurations = { { name = 'a', args = { 1, 2 } } } },
      jsonc.decode(text)
    )
  end)

  it('leaves commas inside strings and comments alone', function()
    local text = '{"a": "x,]", "b": "q\\",}", // c,}\n "c": 1}'
    assert.are.equal(text, jsonc.strip_trailing_commas(text))
    assert.are.same({ a = 'x,]', b = 'q",}', c = 1 }, jsonc.decode(text))
  end)
end)
