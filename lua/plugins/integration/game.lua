return {
  {
    -- Leetcode
    'kawre/leetcode.nvim',
    cmd = 'Leet',
    opts = {
      lang = 'python3',
    },
    enabled = _G.used_full_plugins or _G.enabled_plugins.leetcode,
  },
}
