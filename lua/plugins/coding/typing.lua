return {
  { 'echasnovski/mini.pairs', enabled = false }, -- Disable mini.pairs from LazyVim
  {
    -- Automatically insert/delete brackets, parentheses, quotes...
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true, -- Check grammar by TreeSitter
      enable_abbr = true, -- Enable abbreviation
      fast_wrap = {}, -- Use default FastWrap
    },
    config = function(_, plugin_opts)
      local autopairs = require('nvim-autopairs')
      autopairs.setup(plugin_opts)

      local rule = require('nvim-autopairs.rule')
      local cond = require('nvim-autopairs.conds')
      local ts_cond = require('nvim-autopairs.ts-conds')

      -- Auto pair rules per filetype
      for _, language in pairs(require('config.languages')) do
        if language.autopairs then
          autopairs.add_rules(
            language.autopairs(language.filetypes, rule, cond, ts_cond)
          )
        end
      end
    end,
  },
  {
    -- Accept auto brackets from autopairs for completion
    'saghen/blink.cmp',
    opts = { completion = { accept = { auto_brackets = { enabled = true } } } },
  },
  {
    -- Convert text case
    'johmsalas/text-case.nvim',
    event = { 'BufWinEnter' },
    keys = {
      'ga',
    },
    config = function()
      require('textcase').setup({
        prefix = 'ga',
      })
    end,
  },
}
