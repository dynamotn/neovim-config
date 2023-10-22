local extras = require('util.extras')

return {
  -- Space key {
  { '<Space>', nil, desc = 'Dynamo Trigger' },

  -- B key
  { '<Space>b', nil, desc = 'Buffer & Tab' },
  { '<Space>bn', extras.cmdcr('tabnew'), desc = 'Create new tab' },
  { '<Space>bo', extras.cmdcr('tabonly'), desc = 'Close other tabs' },
  { '<Space>bc', extras.cmdcr('tabclose'), desc = 'Close tab' },
  { '<Space>bh', extras.cmdcr('tabprevious'), desc = 'Previous tab' },
  { '<Space>bl', extras.cmdcr('tabnext'), desc = 'Next tab' },
  {
    '<Space>be',
    [[:tabedit <C-r>=expand('%:p:h')<CR>/<CR>]],
    desc = 'Create new tab in directory of current file',
  },

  -- E key
  { '<Space>e', nil, desc = 'Error / Diagnostic / Quickfix' },
  {
    '<Space>en',
    extras.cmdcr('lua vim.diagnostic.goto_next()'),
    desc = 'Next diagnostic',
  },
  {
    '<Space>ep',
    extras.cmdcr('lua vim.diagnostic.goto_prev()'),
    desc = 'Previous diagnostic',
  },

  { '<Space>f', nil, desc = 'File' },

  -- G key
  { '<Space>g', nil, desc = 'Git' },
  { '<Space>gc', '/\v^[<|=>]{7}( .*|$ )<CR>', desc = 'Show conflict' },

  { '<Space>l', nil, desc = 'Language tool' },
  { '<Space>p', nil, desc = 'Project' },
  { '<Space>r', nil, desc = 'Run' },
  { '<Space>s', nil, desc = 'Session' },
  { '<Space>u', nil, desc = 'Utilities' },
  { '<Space>up', extras.cmdcr('Lazy'), desc = 'Package manager' },

  -- W key
  { '<Space>w', nil, desc = 'Window' },
  {
    '<Space>w2',
    extras.cmdcr('silent only | vs | wincmd w'),
    desc = 'Layout 2 columns',
  },
  {
    '<Space>w3',
    extras.cmdcr('silent only | vs | vs | wincmd H'),
    desc = 'Layout 3 columns',
  },
  { '<Space>w=', extras.cmdcr('wincmd ='), desc = 'Balance windows' },

  -- X key
  { '<Space>x', nil, desc = 'Text manipulation' },
  { '<Space>xc', nil, desc = 'Text case' },
  { '<Space>xs', nil, desc = 'Spacing' },
  {
    '<Space>xsj',
    extras.cmdcr('put =repeat(nr2char(10), v:count1)'),
    desc = 'Insert empty line after one line',
  },
  {
    '<Space>xsk',
    extras.cmdcr('put! =repeat(nr2char(10), v:count1)'),
    desc = 'Insert empty line before one line',
  },
  { '<Space>xf', nil, desc = 'Manipulation with file' },
  {
    '<Space>xfn',
    [[i<C-r>=expand('%:t:n')<CR>]],
    desc = 'Insert name of file',
  },
  {
    '<Space>xfb',
    [[i<C-r>=expand('%:t:r')<CR>]],
    desc = 'Insert basename of file',
  },
  {
    '<Space>xfe',
    [[i<C-r>=expand('%:e')<CR>]],
    desc = 'Insert extension of file',
  },
  {
    '<Space>xfa',
    [[i<C-r>=expand('%:p:h')<CR>]],
    desc = 'Insert absolute path of folder',
  },
  {
    '<Space>xfr',
    [[i<C-r>=expand('%:h')<CR>]],
    desc = 'Insert relative path of folder',
  },
  ------------ }

  -- Leader key {
  { '<leader>', nil, desc = 'Secondary Trigger' },

  { '<leader>d', nil, desc = 'Debug' },
  { '<leader>t', nil, desc = 'Test' },
  { '<leader>s', nil, desc = 'Swap' },
  ------------- }
}
