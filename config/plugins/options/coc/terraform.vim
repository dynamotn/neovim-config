call coc#config('languageserver.terraform', {
      \   'command': 'terraform-ls',
      \   'args': ['serve'],
      \   'initializationOptions': {},
      \   'filetypes': [ 'terraform' ]
      \ })

