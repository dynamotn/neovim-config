return {
  {
    '<Space>uc',
    function()
      require('notify').dismiss({ silent = true, pending = true })
    end,
    desc = 'Clear all notifications',
  },
}
