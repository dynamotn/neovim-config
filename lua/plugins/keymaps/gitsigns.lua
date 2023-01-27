local gitsigns = require('gitsigns')

return {
  {
    '<Space>ga',
    function()
      gitsigns.stage_hunk()
    end,
    desc = 'Stage hunk',
  },
  {
    '<Space>gu',
    function()
      gitsigns.undo_stage_hunk()
    end,
    desc = 'Undo stage hunk',
  },
  {
    '<Space>gd',
    function()
      gitsigns.diffthis('~')
    end,
    desc = 'Diff this file',
  },
  {
    '<Space>gp',
    function()
      gitsigns.preview_hunk()
    end,
    desc = 'Preview hunk',
  },
  {
    '<Space>gn',
    function()
      gitsigns.next_hunk()
    end,
    desc = 'Go to next hunk',
  },
  {
    '<Space>gN',
    function()
      gitsigns.prev_hunk()
    end,
    desc = 'Go to previous hunk',
  },
}
