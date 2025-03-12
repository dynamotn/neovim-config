local not_supported_filetypes = {}
local languages_list = vim.tbl_filter(function(config)
  if type(config.test) ~= 'table' then return true end
  local vim_test_supported = false
  for _, adapter in ipairs(config.test) do
    if adapter.test == 'vim-test' then vim_test_supported = true end
  end
  return not vim_test_supported
end, require('config.languages'))
for _, config in pairs(languages_list) do
  vim.list_extend(not_supported_filetypes, config.filetypes)
end
return {
  -- Test integration
  { import = 'lazyvim.plugins.extras.test.core' },
  {
    'nvim-neotest/neotest',
    dependencies = {
      {
        -- Test runner compatibility that support vim-test
        'nvim-neotest/neotest-vim-test',
        dependencies = {
          'vim-test/vim-test',
          keys = {
            {
              '<leader>tf',
              '<cmd>TestFile<cr>',
              desc = 'Run File (Vimtest)',
            },
          },
          config = function(_, opts)
            -- Run zellij floating pane
            if _G.test_strategy == 'zellij' then
              vim.cmd([[
                function! ZellijStrategy(cmd)
                  execute "!zellij run --floating -- " . a:cmd
                endfunction
              ]])
              vim.cmd(
                [[ let g:test#custom_strategies = {'zellij': function('ZellijStrategy')} ]]
              )
            end
            vim.g['test#strategy'] = _G.test_strategy
          end,
        },
      },
    },
    opts = {
      adapters = {
        ['neotest-vim-test'] = {
          ignore_filetypes = not_supported_filetypes,
        },
      },
    },
  },
}
