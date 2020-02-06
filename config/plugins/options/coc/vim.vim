let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]
call coc#config('languageserver.vimls', {
      \   'command': 'vim-language-server',
      \   'args': ['--stdio'],
      \   'initializationOptions': {
      \     'iskeyword': '@,48-57,_,192-255,-#',
      \     'vimruntime': '',
      \     'runtimepath': '',
      \     'diagnostic': {
      \       'enable': 'true'
      \     },
      \     'indexes': {
      \       'runtimepath': 'true',
      \       'gap': 100,
      \       'count': 3,
      \       'projectRootPatterns' : ['autoload', 'config']
      \     },
      \     'suggest': {
      \       'fromVimruntime': 'true',
      \       'fromRuntimepath': 'true'
      \     }
      \   },
      \   'filetypes': [ 'vim' ]
      \ })
