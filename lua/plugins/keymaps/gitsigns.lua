return {
  ['<Space>ga'] = { dynamo_cmdcr('lua require("gitsigns").stage_hunk()'), 'Stage hunk' },
  ['<Space>gu'] = { dynamo_cmdcr('lua require("gitsigns").undo_stage_hunk()'), 'Undo stage hunk' },
  ['<Space>gd'] = { dynamo_cmdcr('lua require("gitsigns").diffthis("~")'), 'Diff this file' },
  ['<Space>gp'] = { dynamo_cmdcr('lua require("gitsigns").preview_hunk()'), 'Preview hunk' },
  ['<Space>gn'] = { dynamo_cmdcr('lua require("gitsigns").next_hunk()'), 'Go to next hunk' },
  ['<Space>gN'] = { dynamo_cmdcr('lua require("gitsigns").prev_hunk()'), 'Go to previous hunk' },
}
