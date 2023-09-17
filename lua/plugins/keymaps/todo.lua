return {
  {
    '<Space>pt',
    function()
      require('trouble').toggle({ mode = 'todo' })
    end,
    desc = 'Show TODO',
  },
}
