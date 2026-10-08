local defaults = require('config.defaults')

describe('config.defaults', function()
  it(
    'picks catppuccin',
    function() assert.are.equal('catppuccin', defaults.colorscheme) end
  )

  it('gives every diagnostic severity an icon', function()
    for _, severity in ipairs({ 'Error', 'Warn', 'Hint', 'Info' }) do
      assert.are.equal('string', type(defaults.icons.diagnostics[severity]))
    end
  end)

  it('gives every LSP completion kind an icon', function()
    for kind in pairs(vim.lsp.protocol.CompletionItemKind) do
      if type(kind) == 'string' then
        assert.is_not_nil(defaults.icons.kinds[kind], kind)
      end
    end
  end)

  it('shapes the DAP signs as the nvim-dap spec expects', function()
    for name, sign in pairs(defaults.icons.dap) do
      assert(type(sign) == 'string' or type(sign[1]) == 'string', name)
    end
  end)

  it('maps abbreviations to their expansion', function()
    for abbr, text in pairs(defaults.abbreviations) do
      assert.is_truthy(abbr:match('^%w+$'))
      assert.are.equal('string', type(text))
    end
    assert.are.equal('https://github.com/', defaults.abbreviations.gh)
  end)
end)
