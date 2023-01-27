local trouble = require('trouble')

return {
  {
    '<Space>ed',
    function()
      trouble.toggle({ mode = 'document_diagnostics' })
    end,
    desc = 'Show diagnostic of document',
  },
  {
    '<Space>ew',
    function()
      trouble.toggle({ mode = 'workspace_diagnostics' })
    end,
    desc = 'Show diagnostic of workspace',
  },
  {
    '<F4>',
    function()
      trouble.toggle({ mode = 'workspace_diagnostics' })
    end,
    desc = 'Show diagnostic of workspace',
  },
  {
    '<Space>el',
    function()
      trouble.toggle({ mode = 'loclist' })
    end,
    desc = 'Show loclist',
  },
  {
    '<Space>eq',
    function()
      trouble.toggle({ mode = 'quickfix' })
    end,
    desc = 'Show quickfix',
  },
}
