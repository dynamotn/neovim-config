return {
  {
    'gd',
    function()
      require('lspsaga.definition'):peek_definition(1)
    end,
    desc = 'Go to definition',
  },
  {
    'gi',
    function()
      require('lspsaga.finder'):new('imp')
    end,
    desc = 'Go to implementation',
  },
  {
    'gt',
    function()
      require('lspsaga.definition'):peek_definition(2)
    end,
    desc = 'Go to type definition',
  },
  {
    'gr',
    function()
      require('lspsaga.finder'):new('ref')
    end,
    desc = 'Go to references',
  },
  {
    'K',
    function()
      require('lspsaga.hover'):render_hover_doc({})
    end,
    desc = 'Hover document',
  },
  {
    '<Space>la',
    function()
      require('lspsaga.codeaction'):code_action()
    end,
    desc = 'Code Action',
  },
  {
    '<Space>li',
    function()
      require('lspsaga.callhierarchy'):send_method(2, {})
    end,
    desc = 'Show incoming calls',
  },
  {
    '<Space>lo',
    function()
      require('lspsaga.callhierarchy'):send_method(3, {})
    end,
    desc = 'Show outgoing calls',
  },
  {
    '<Space>lr',
    function()
      require('lspsaga.rename'):lsp_rename({})
    end,
    desc = 'Rename',
  },
  {
    '<F2>',
    function()
      require('lspsaga.symbol'):outline()
    end,
    desc = 'Show outline',
  },
  {
    '<Space>ls',
    function()
      require('lspsaga.symbol'):outline()
    end,
    desc = 'Show outline',
  },
}
