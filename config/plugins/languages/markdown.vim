" Preview on browser after edit
if has('python') || has('python3')
  if v:version >= 800
    let g:dynamo_language_plug_param.do = 'mkdp#util#install()'
    Plug 'iamcco/markdown-preview.nvim', g:dynamo_language_plug_param
  else
    Plug 'iamcco/markdown-preview.vim', g:dynamo_language_plug_param
  endif
  call dynamo#file#RegisterPlugin('markdown_preview')
endif
