return {
  {
    '<Space>ed',
    function()
      require('trouble').toggle({ mode = 'document_diagnostics' })
    end,
    desc = 'Show diagnostic of document',
  },
  {
    '<Space>ew',
    function()
      require('trouble').toggle({ mode = 'workspace_diagnostics' })
    end,
    desc = 'Show diagnostic of workspace',
  },
  {
    '<F4>',
    function()
      require('trouble').toggle({ mode = 'workspace_diagnostics' })
    end,
    desc = 'Show diagnostic of workspace',
  },
  {
    '<Space>el',
    function()
      require('trouble').toggle({ mode = 'loclist' })
    end,
    desc = 'Show loclist',
  },
  {
    '<Space>eq',
    function()
      require('trouble').toggle({ mode = 'quickfix' })
    end,
    desc = 'Show quickfix',
  },
}
