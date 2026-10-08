return {
  {
    -- Leetcode
    'kawre/leetcode.nvim',
    cmd = 'Leet',
    opts = {
      lang = 'python3',
    },
    enabled = DyNeo.used_full_plugins or DyNeo.enabled_plugins.leetcode,
  },
}
