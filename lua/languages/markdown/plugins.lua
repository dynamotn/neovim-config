return {
  { -- Preview markdown
    'Saimo/peek.nvim',
    name = 'peek',
    build = 'deno task --quiet build:fast',
    enabled = vim.fn.executable('deno') == 1,
  },
  { 'lukas-reineke/headlines.nvim', dependencies = { 'treesitter' }, name = 'headlines' }, -- Highlight for headlines, codeblocks
  {
    -- Obsidian
    'epwalsh/obsidian.nvim',
    name = 'obsidian',
    dependencies = { 'plenary' },
  },
  {
    -- LSP for codeblocks
    'jmbuhr/otter.nvim',
    name = 'otter',
    dependencies = { 'cmp', 'lsp' },
  },
}
