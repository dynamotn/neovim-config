" Completion source
if g:dynamo_complete_engine ==? 'coc'
  call dynamo#plugin#InstallLanguageServer('bin', 'terraform-ls')
  call dynamo#plugin#Register('coc/terraform')
endif
