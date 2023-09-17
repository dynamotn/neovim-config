return {
  {
    '<Space>ga',
    function()
      require('gitsigns').stage_hunk()
    end,
    desc = 'Stage hunk',
  },
  {
    '<Space>gu',
    function()
      require('gitsigns').undo_stage_hunk()
    end,
    desc = 'Undo stage hunk',
  },
  {
    '<Space>gd',
    function()
      require('gitsigns').diffthis('~')
    end,
    desc = 'Diff this file',
  },
  {
    '<Space>gp',
    function()
      require('gitsigns').preview_hunk()
    end,
    desc = 'Preview hunk',
  },
  {
    '<Space>gn',
    function()
      require('gitsigns').next_hunk()
    end,
    desc = 'Go to next hunk',
  },
  {
    '<Space>gN',
    function()
      require('gitsigns').prev_hunk()
    end,
    desc = 'Go to previous hunk',
  },
}
