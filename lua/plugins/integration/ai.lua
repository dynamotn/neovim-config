return {
  -- AI Engine
  {
    import = 'lazyvim.plugins.extras.ai.copilot-native',
    enabled = vim.fn.has('nvim-0.12.0') == 1,
  },
  -- AI CLI
  { import = 'lazyvim.plugins.extras.ai.sidekick' },
}
