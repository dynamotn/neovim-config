return function(register_config)
  return {
    { -- Preview markdown
      'iamcco/markdown-preview.nvim',
      run = 'call mkdp#util#install()',
      config = register_config('markdown_preview'),
    },
  }
end
