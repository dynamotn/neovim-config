return {
  { -- Preview markdown
    'iamcco/markdown-preview.nvim',
    name = 'markdown_preview',
    build = 'cd app && npm install',
    enabled = vim.fn.executable('npm') == 1,
  },
  { 'lukas-reineke/headlines.nvim', dependencies = { 'treesitter' }, name = 'headlines' }, -- Highlight for headlines, codeblocks
}
