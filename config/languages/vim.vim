" Completion source
if g:dynamo_complete_engine ==? 'coc'
  call dynamo#plugin#InstallLanguageServer('yarn', 'vim-language-server')
  Plug 'iamcco/coc-vimlsp', g:dynamo_language_plug_param
  call dynamo#plugin#Register('coc/vim')
else
  Plug 'Shougo/neco-vim', g:dynamo_language_plug_param
endif
