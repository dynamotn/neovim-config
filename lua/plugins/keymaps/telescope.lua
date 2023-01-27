local telescope = require('telescope.builtin')

return {
  {
    '<Space>fg',
    function()
      telescope.live_grep()
    end,
    desc = 'Grep file',
  },
  {
    '<Space>fq',
    function()
      telescope.find_files()
    end,
    desc = 'Find file',
  },

  {
    '<Space>fq',
    function()
      telescope.buffers()
    end,
    desc = 'Find buffers',
  },
}
