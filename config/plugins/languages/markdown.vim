" Preview on browser after edit
if (has('nvim') || v:version >= 801) && executable('yarn')
  let g:dynamo_language_plug_param.do = 'cd app && yarn install'
  Plug 'iamcco/markdown-preview.nvim', g:dynamo_language_plug_param
  call dynamo#file#RegisterPlugin('markdown_preview')
elseif has('python') || has('python3')
  Plug 'iamcco/markdown-preview.vim', g:dynamo_language_plug_param | Plug 'iamcco/mathjax-support-for-mkdp', g:dynamo_language_plug_param
  call dynamo#file#RegisterPlugin('markdown_preview')
endif
