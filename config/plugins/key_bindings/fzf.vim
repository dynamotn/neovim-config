call dynamo#mapping#Define('nnoremap', '<Space>', 'zf', ':' . g:fzf_command_prefix . 'Files<CR>', 'Search file in current folder')
call dynamo#mapping#Define('nnoremap', '<Space>', 'zl', ':' . g:fzf_command_prefix . 'Lines<CR>', 'Search line in files of current folder')
call dynamo#mapping#Define('nnoremap', '<Space>', 'zy', ':FZFNeoyank<CR>', 'Search yank history')
