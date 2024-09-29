return {
  { -- Preview markdown
    'Saimo/peek.nvim',
    name = 'peek',
    build = 'deno task --quiet build:fast',
    enabled = vim.fn.executable('deno') == 1,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim', -- Highlight for headlines, codeblocks
    dependencies = { 'treesitter', 'icon' },
    name = 'render_markdown',
  },
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
