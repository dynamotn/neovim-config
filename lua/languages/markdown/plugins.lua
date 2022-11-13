return function(register_config, filetypes)
  return {
    { -- Preview markdown
      'iamcco/markdown-preview.nvim',
      run = function()
        vim.fn['mkdp#util#install']()
      end,
      config = register_config('markdown_preview', filetypes),
    },
  }
end
