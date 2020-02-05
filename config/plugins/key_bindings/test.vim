call dynamo#mapping#Group('<Space>', 'pt', 'Run tests')
call dynamo#mapping#Define('nnoremap', '<Space>', 'ptc', ':TestNearest<CR>', 'Test only test case nearest to the cursor')
call dynamo#mapping#Define('nnoremap', '<Space>', 'ptf', ':TestFile<CR>', 'Test all test cases in current file')
call dynamo#mapping#Define('nnoremap', '<Space>', 'pts', ':TestSuite<CR>', 'Test whole test suite')
