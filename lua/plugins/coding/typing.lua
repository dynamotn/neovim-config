return {
  { 'nvim-mini/mini.pairs', enabled = false }, -- Disable mini.pairs from LazyVim
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
      local languages = require('config.languages')
      for _, language in pairs(languages) do
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
    -- Align text on a delimiter
    --
    -- `ga` is already the text-case operator, so the pair moves to `gl`,
    -- which nothing else claims.
    'nvim-mini/mini.align',
    keys = {
      { 'gl', mode = { 'n', 'x' }, desc = 'Align' },
      { 'gL', mode = { 'n', 'x' }, desc = 'Align with preview' },
    },
    opts = {
      mappings = {
        start = 'gl',
        start_with_preview = 'gL',
      },
    },
  },
  {
    -- Convert text case
    'johmsalas/text-case.nvim',
    -- Only its commands and `ga` mappings are needed, and nothing can reach
    -- them before the first screen is drawn: loading on `BufWinEnter` put the
    -- plugin, and which-key with it, in front of every file being opened.
    event = 'VeryLazy',
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
