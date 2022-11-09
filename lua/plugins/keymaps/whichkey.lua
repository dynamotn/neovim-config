return {
  -- Space key {
  ['<Space>'] = { name = 'Dynamo Trigger' },

  -- B key
  ['<Space>b'] = { name = 'Buffer & Tab' },
  ['<Space>bn'] = { dynamo_cmdcr('tabnew'), 'Create new tab' },
  ['<Space>bo'] = { dynamo_cmdcr('tabonly'), 'Close other tabs' },
  ['<Space>bc'] = { dynamo_cmdcr('tabclose'), 'Close tab' },
  ['<Space>bh'] = { dynamo_cmdcr('tabprevious'), 'Previous tab' },
  ['<Space>bl'] = { dynamo_cmdcr('tabnext'), 'Next tab' },
  ['<Space>be'] = { [[:tabedit <C-r>=expand('%:p:h')<CR>/<CR>]], 'Create new tab in directory of current file' },

  -- E key
  ['<Space>e'] = { name = 'Error / Diagnostic / Quickfix' },
  ['<Space>en'] = { dynamo_cmdcr('lua vim.diagnostic.goto_next()'), 'Next diagnostic' },
  ['<Space>ep'] = { dynamo_cmdcr('lua vim.diagnostic.goto_prev()'), 'Previous diagnostic' },

  ['<Space>f'] = { name = 'File' },

  -- G key
  ['<Space>g'] = { name = 'Git' },
  ['<Space>gc'] = { '/\v^[<|=>]{7}( .*|$ )<CR>', 'Show conflict' },

  ['<Space>l'] = { name = 'Language tool' },
  ['<Space>p'] = { name = 'Project' },
  ['<Space>s'] = { name = 'Session' },

  -- W key
  ['<Space>w'] = { name = 'Window' },
  ['<Space>w2'] = { dynamo_cmdcr('silent only | vs | wincmd w'), 'Layout 2 columns' },
  ['<Space>w3'] = { dynamo_cmdcr('silent only | vs | vs | wincmd H'), 'Layout 3 columns' },
  ['<Space>w='] = { dynamo_cmdcr('wincmd ='), 'Balance windows' },

  -- X key
  ['<Space>x'] = { name = 'Text manipulation' },
  ['<Space>xs'] = { name = 'Spacing' },
  ['<Space>xsj'] = { dynamo_cmdcr('put =repeat(nr2char(10), v:count1)'), 'Insert empty line after one line' },
  ['<Space>xsk'] = { dynamo_cmdcr('put! =repeat(nr2char(10), v:count1)'), 'Insert empty line before one line' },
  ['<Space>xf'] = { name = 'Manipulation with file' },
  ['<Space>xfn'] = { [[i<C-r>=expand('%:t:n')<CR>]], 'Insert name of file' },
  ['<Space>xfb'] = { [[i<C-r>=expand('%:t:r')<CR>]], 'Insert basename of file' },
  ['<Space>xfe'] = { [[i<C-r>=expand('%:e')<CR>]], 'Insert extension of file' },
  ['<Space>xfa'] = { [[i<C-r>=expand('%:p:h')<CR>]], 'Insert absolute path of folder' },
  ['<Space>xfr'] = { [[i<C-r>=expand('%:h')<CR>]], 'Insert relative path of folder' },

  ------------ }

  -- Leader key {
  ['<leader>'] = { name = 'Secondary Trigger' },

  -- D key
  ['<leader>d'] = { name = 'Debug' },

  -- T key
  ['<leader>t'] = { name = 'Test' },
  ------------- }
}
