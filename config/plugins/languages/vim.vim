" Completion source
if g:dynamo_complete_engine ==? 'coc'
  call dynamo#misc#InstallLanguageServer('yarn', 'vim-language-server')
  Plug 'iamcco/coc-vimlsp', g:dynamo_language_plug_param
else
  Plug 'Shougo/neco-vim', g:dynamo_language_plug_param
endif
