return {
  {
    'gd',
    function()
      require('lspsaga.command').load_command('peek_definition')
    end,
    desc = 'Go to definition',
  },
  {
    'gi',
    function()
      require('lspsaga.command').load_command('finder', 'imp')
    end,
    desc = 'Go to implementation',
  },
  {
    'gt',
    function()
      require('lspsaga.definition').load_command('peek_type_definition')
    end,
    desc = 'Go to type definition',
  },
  {
    'gr',
    function()
      require('lspsaga.command').load_command('finder', 'ref')
    end,
    desc = 'Go to references',
  },
  {
    'K',
    function()
      require('lspsaga.command').load_command('hover_doc')
    end,
    desc = 'Hover document',
  },
  {
    '<Space>la',
    function()
      require('lspsaga.command').load_command('code_action')
    end,
    desc = 'Code Action',
  },
  {
    '<Space>li',
    function()
      require('lspsaga.command').load_command('incoming_calls')
    end,
    desc = 'Show incoming calls',
  },
  {
    '<Space>lo',
    function()
      require('lspsaga.command').load_command('outgoing_calls')
    end,
    desc = 'Show outgoing calls',
  },
  {
    '<Space>lr',
    function()
      require('lspsaga.command').load_command('rename')
    end,
    desc = 'Rename',
  },
  {
    '<F2>',
    function()
      require('lspsaga.command').load_command('outline')
    end,
    desc = 'Show outline',
  },
  {
    '<Space>ls',
    function()
      require('lspsaga.command').load_command('outline')
    end,
    desc = 'Show outline',
  },
}
