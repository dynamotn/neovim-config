return {
  vim.fn.executable('npm') == 1
      and {
        -- Preview markdown
        'iamcco/markdown-preview.nvim',
        name = 'markdown_preview',
        build = 'cd app && npm install',
      }
    or {},
  { 'SidOfc/mkdx', name = 'mkdx' }, -- Handle lists, checkboxes, fenced code blocks, shortcuts, headers and links...
  { 'lukas-reineke/headlines.nvim', dependencies = { 'treesitter' }, name = 'headlines' }, -- Highlight for headlines, codeblocks
}
