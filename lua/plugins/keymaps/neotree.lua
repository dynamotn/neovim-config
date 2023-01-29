local neotree = require('neo-tree')

return {
  {
    '<F1>',
    function()
      neotree.show(nil, true, true, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>ft',
    function()
      neotree.show(nil, true, true, true)
    end,
    desc = 'File explorer',
  },
  {
    '<Space>gt',
    function()
      neotree.show('git_status', true, true, true)
    end,
    desc = 'Status explorer',
  },
}
