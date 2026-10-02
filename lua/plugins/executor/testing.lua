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
  {
    -- Coverage from LCOV, Cobertura, Go, tarpaulin and LLVM reports
    'mr-u0b0dy/crazy-coverage.nvim',
    -- Upstream ships doc/ as Markdown only, so lazy.nvim's helptags step dies
    -- with "E151: No match: .../doc/**/*.txt". Lay down a stub vimdoc that
    -- points at the Markdown, so the directory has something to index.
    build = function(plugin)
      local doc = plugin.dir .. '/doc'
      local help = doc .. '/crazy-coverage.txt'
      if not vim.uv.fs_stat(help) then
        vim.fn.writefile({
          '*crazy-coverage.txt*	Coverage from LCOV, Cobertura, Go and LLVM reports',
          '',
          'CRAZY-COVERAGE					*crazy-coverage*',
          '',
          'Upstream documents this plugin in Markdown instead of vimdoc. Start at',
          'doc/index.md under: >',
          '	' .. plugin.dir,
          '<',
          ' vim:tw=78:ts=8:ft=help:norl:',
        }, help)
      end
      vim.cmd.helptags(doc)
    end,
    cmd = {
      'CoverageToggle',
      'CoverageLoad',
      'CoverageSummary',
      'CoverageNextUncovered',
      'CoveragePrevUncovered',
    },
    keys = {
      { '<leader>tc', '<cmd>CoverageToggle<cr>', desc = 'Toggle Coverage' },
      { '<leader>tC', '<cmd>CoverageSummary<cr>', desc = 'Coverage Summary' },
      { ']u', '<cmd>CoverageNextUncovered<cr>', desc = 'Next Uncovered Line' },
      { '[u', '<cmd>CoveragePrevUncovered<cr>', desc = 'Prev Uncovered Line' },
    },
    opts = {
      -- Root is excluded on purpose: the plugin falls back to scanning every
      -- file of a search dir, and treats any stray JSON/XML there as a report.
      coverage_dirs = {
        'coverage/bats', -- kcov output of scripts/test.sh --coverage
        'target/tarpaulin',
        'target/coverage',
        'build/coverage',
        'coverage',
        'build',
      },
      coverage_patterns = {
        shell = { 'cobertura.xml', 'coverage.xml', '*.lcov', '*.info' },
        c = {
          '*.lcov',
          '*.info',
          'coverage.json',
          'coverage.xml',
          '*.profdata',
        },
        cpp = {
          '*.lcov',
          '*.info',
          'coverage.json',
          'coverage.xml',
          '*.profdata',
        },
        python = {
          '.coverage',
          'coverage.json',
          'coverage.xml',
          'coverage.lcov',
        },
        rust = {
          '*.lcov',
          '*.info',
          'coverage.json',
          'coverage.xml',
          'coverage-tarpaulin.lcov',
          'coverage-tarpaulin.json',
          'coverage-tarpaulin.xml',
        },
        go = {
          'coverage.out',
          '*.lcov',
          '*.info',
          'coverage.json',
          'coverage.xml',
        },
      },
    },
  },
}
