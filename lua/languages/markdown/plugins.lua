return function(register_config, filetypes)
  return {
    { -- Preview markdown
      'iamcco/markdown-preview.nvim',
      build = function()
        vim.fn['mkdp#util#install']()
      end,
      name = 'markdown_preview',
      config = register_config,
    },
  }
end
