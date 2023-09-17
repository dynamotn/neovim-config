return {
  {
    '<Space>fg',
    function()
      require('telescope.builtin').live_grep()
    end,
    desc = 'Grep file',
  },
  {
    '<Space>fq',
    function()
      require('telescope.builtin').find_files()
    end,
    desc = 'Find file',
  },

  {
    '<Space>fq',
    function()
      require('telescope.builtin').buffers()
    end,
    desc = 'Find buffers',
  },
}
