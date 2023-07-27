return {
  {
    '<Space>lf',
    function()
      require('refactoring').select_refactor()
    end,
    desc = 'Refactor',
    mode = 'v',
  },
}
