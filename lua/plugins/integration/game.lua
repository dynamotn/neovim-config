return {
  {
    'kawre/leetcode.nvim',
    cmd = 'Leet',
    dependencies = {
      'plenary.nvim',
      'nui.nvim',
    },
    opts = {
      lang = 'python3',
    },
    cond = _G.enabled_leetcode or _G.used_full_plugins,
  },
}
