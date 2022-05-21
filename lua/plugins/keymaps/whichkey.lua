return {
  -- Space key {
  ['<Space>'] = { name = 'Dynamo Trigger' },
  ['<Space>b'] = { name = 'Buffer' },

  -- E key
  ['<Space>e'] = { name = 'Diagnostic / Error' },
  ['<Space>en'] = { '<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next diagnostic' },
  ['<Space>ep'] = { '<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous diagnostic' },

  ['<Space>f'] = { name = 'File' },

  -- G key
  ['<Space>g'] = { name = 'Git' },
  ['<Space>gc'] = { '/\v^[<|=>]{7}( .*|$ )<CR>', 'Show conflict' },

  ['<Space>p'] = { name = 'Project' },
  ['<Space>s'] = { name = 'Session' },
  ['<Space>l'] = { name = 'Language tool' },
  ['<Space>q'] = { name = 'Debug / Quick fix / Test' },

  -- T key
  ['<Space>t'] = { name = 'Tab' },
  ['<Space>tn'] = { '<cmd>tabnew<CR>', 'Create new tab' },
  ['<Space>to'] = { '<cmd>tabonly<CR>', 'Close other tabs' },
  ['<Space>tc'] = { '<cmd>tabclose<CR>', 'Close tab' },
  ['<Space>th'] = { '<cmd>tabprevious<CR>', 'Previous tab' },
  ['<Space>tl'] = { '<cmd>tabnext<CR>', 'Next tab' },
  ['<Space>te'] = { [[:tabedit <C-r>=expand('%:p:h')<CR>/<CR>]], 'Create new tab in directory of current file' },

  -- W key
  ['<Space>w'] = { name = 'Window' },
  ['<Space>w2'] = { '<cmd>silent only | vs | wincmd w<CR>', 'Layout 2 columns' },
  ['<Space>w3'] = { '<cmd>silent only | vs | vs | wincmd H<CR>', 'Layout 3 columns' },
  ['<Space>w='] = { '<cmd>wincmd =<CR>', 'Balance windows' },

  -- X key
  ['<Space>x'] = { name = 'Text manipulation' },
  ['<Space>xs'] = { name = 'Spacing' },
  ['<Space>xsj'] = { '<cmd>put =repeat(nr2char(10), v:count1)<CR>', 'Insert empty line after one line' },
  ['<Space>xsk'] = { '<cmd>put! =repeat(nr2char(10), v:count1)<CR>', 'Insert empty line before one line' },
  ['<Space>xf'] = { name = 'Manipulation with file' },
  ['<Space>xfn'] = { [[i<C-r>=expand('%:t:n')<CR>]], 'Insert name of file' },
  ['<Space>xfb'] = { [[i<C-r>=expand('%:t:r')<CR>]], 'Insert basename of file' },
  ['<Space>xfe'] = { [[i<C-r>=expand('%:e')<CR>]], 'Insert extension of file' },
  ['<Space>xfa'] = { [[i<C-r>=expand('%:p:h')<CR>]], 'Insert absolute path of folder' },
  ['<Space>xfr'] = { [[i<C-r>=expand('%:h')<CR>]], 'Insert relative path of folder' },

  ------------ }

  -- Leader key {
  ['<leader>'] = { name = 'Secondary Trigger' },
  ------------- }
}
