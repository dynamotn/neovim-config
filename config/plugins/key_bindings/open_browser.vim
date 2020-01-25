call dynamo#mapping#Define('xnoremap', '<Space>',  'gh', ':<C-u>call dynamo#misc#GetTextVisualBlock()<CR><Esc>:OpenGithubProject <C-R>=@/<CR><CR>', 'Open Github Project')
call dynamo#mapping#Define('nnoremap', '<Space>',  'gh', ':OpenGithubProject<CR>', 'Open Github Project')
