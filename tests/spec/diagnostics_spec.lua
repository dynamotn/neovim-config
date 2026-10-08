-- Diagnostics are configured in one place, `plugins.lsp.server`. That spec
-- loads on the first file, after tiny-inline-diagnostic's `VeryLazy` when
-- Neovim starts without one, so it must leave the native virtual text off
-- itself whenever tiny-inline draws the messages.
local h = require('helpers')

describe('diagnostics', function()
  local Plugin, restore, has

  --- The resolved options of the nvim-lspconfig spec
  local function lsp_opts()
    for _, spec in ipairs(dofile(h.root .. '/lua/plugins/lsp/server.lua')) do
      if spec[1] == 'neovim/nvim-lspconfig' then return spec.opts(nil, {}) end
    end
  end

  before_each(function()
    h.globals()
    Plugin = require('util.plugin')
    has = {}
    restore = h.stub(Plugin, 'has', function(name) return has[name] == true end)
  end)
  after_each(function() restore() end)

  it('leaves the virtual text to tiny-inline-diagnostic', function()
    has['tiny-inline-diagnostic.nvim'] = true
    assert.is_false(lsp_opts().diagnostics.virtual_text)
  end)

  it(
    'keeps the native virtual text without it',
    function() assert.equals('table', type(lsp_opts().diagnostics.virtual_text)) end
  )

  it('is not configured again by tiny-inline-diagnostic', function()
    local source = table.concat(
      vim.fn.readfile(h.root .. '/lua/plugins/ui/diagnostic.lua'),
      '\n'
    )
    assert.is_nil(source:find('vim.diagnostic.config', 1, true))
  end)
end)
