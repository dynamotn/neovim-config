local languages = require('config.languages')
local not_supported_filetypes = {}
for _, language in pairs(languages) do
  if type(language.test) ~= 'table' then
    vim.list_extend(not_supported_filetypes, language.filetypes)
  else
    local vim_test_supported = false
    for _, adapter in ipairs(language.test) do
      if adapter == 'vim-test' then vim_test_supported = true end
    end
    if not vim_test_supported then
      vim.list_extend(not_supported_filetypes, language.filetypes)
    end
  end
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
          config = function(_, _)
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
