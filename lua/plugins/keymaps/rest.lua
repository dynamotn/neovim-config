return {
  ['<Space>lc'] = {
    dynamo_cmdcr('lua require("rest-nvim").run()'),
    'Run current HTTP request',
  },
}
