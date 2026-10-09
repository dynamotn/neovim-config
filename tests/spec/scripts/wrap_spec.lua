local h = require('helpers')

describe('scripts/lib/wrap.lua', function()
  local wrap = dofile(h.root .. '/scripts/lib/wrap.lua').wrap

  it(
    'fills a paragraph to the width',
    function()
      assert.same(
        { 'one two', 'three four', 'five' },
        wrap('one two three four five', 10)
      )
    end
  )

  it('keeps to 80 columns unless told otherwise', function()
    for _, line in ipairs(wrap(('word '):rep(60))) do
      assert.is_true(#line <= 80)
    end
  end)

  it(
    'counts the columns of a character, not its bytes',
    function() assert.same({ 'Mean ± σ', 'ms' }, wrap('Mean ± σ ms', 8)) end
  )

  it(
    'leaves a word too long for the width on its own line',
    function()
      assert.same({ 'a', 'abcdefghijkl', 'b' }, wrap('a abcdefghijkl b', 5))
    end
  )

  it('fills the prose of Markdown, and only the prose', function()
    local prose = dofile(h.root .. '/scripts/lib/wrap.lua').prose
    local row = '| a very long table row | that cannot be broken | at all |'
    assert.same(
      {
        '<!-- a comment that is long -->',
        '',
        'one two',
        'three',
        '',
        row,
        '```',
        'step  one two three',
        '```',
      },
      prose({
        '<!-- a comment that is long -->',
        '',
        'one two three',
        '',
        row,
        '```',
        'step  one two three',
        '```',
      }, 10)
    )
  end)

  it(
    'hands back no line for empty text',
    function() assert.same({}, wrap('  ')) end
  )
end)
