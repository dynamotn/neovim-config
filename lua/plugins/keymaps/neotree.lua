return {
  {
    '<F1>',
    function()
      require('neo-tree').float(nil, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>ft',
    function()
      require('neo-tree').float(nil, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>gt',
    function()
      require('neo-tree').float('git_status', true)
    end,
    desc = 'Status explorer',
  },
}
