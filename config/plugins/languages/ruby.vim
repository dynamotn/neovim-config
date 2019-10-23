if g:dynamo_complete_engine ==? 'coc'
  let solar_param = g:dynamo_language_plug_param
  let solar_param.do = 'yarn install --frozen-lockfile'
  Plug 'neoclide/coc-solargraph', solar_param
elseif g:dynamo_complete_engine ==? 'deoplete'
  let g:LanguageClient_serverCommands.ruby = ['solargraph', 'stdio']
end
