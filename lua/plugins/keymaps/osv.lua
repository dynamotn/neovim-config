return {
  {
    '<leader>daL',
    function()
      require('osv').launch({ port = 8086 })
    end,
    desc = 'Adapter Lua Server',
  },
  {
    '<leader>dal',
    function()
      require('osv').run_this()
    end,
    desc = 'Adapter Lua',
  },
}
