return {
  { -- Preview markdown
    'iamcco/markdown-preview.nvim',
    name = 'markdown_preview',
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
}
