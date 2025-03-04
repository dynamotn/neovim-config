return {
  {
    -- Leetcode
    'kawre/leetcode.nvim',
    cmd = 'Leet',
    opts = {
      lang = 'python3',
    },
    cond = _G.enabled_plugins.leetcode or _G.used_full_plugins,
  },
}
