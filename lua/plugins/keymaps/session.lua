return {
  {
    '<Space>sl',
    function()
      require('mini.sessions').select()
    end,
    desc = 'List all session',
  },
  {
    '<Space>ss',
    function()
      vim.ui.input({
        prompt = 'Session name',
      }, function(input)
        if input then
          require('mini.sessions').write(input)
        end
      end)
    end,
    desc = 'Save current session',
  },
}
