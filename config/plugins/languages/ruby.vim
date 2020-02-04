if g:dynamo_complete_engine ==? 'coc'
  Plug 'neoclide/coc-solargraph', g:dynamo_language_plug_param
elseif g:dynamo_complete_engine ==? 'deoplete'
  let g:LanguageClient_serverCommands.ruby=['solargraph', 'stdio']
endif
