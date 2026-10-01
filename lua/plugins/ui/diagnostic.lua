return {
  {
    -- Display prettier diagnostic messages
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'VeryLazy',
    priority = 1000,
    config = function()
      require('tiny-inline-diagnostic').setup()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
  {
    -- Act on the rule behind a diagnostic, whichever linter or server it is
    -- from: silence it with that tool's own ignore comment, open its docs
    'chrisgrieser/nvim-rulebook',
    keys = {
      {
        '<leader>ci',
        function() require('rulebook').ignoreRule() end,
        desc = 'Ignore Rule',
      },
      {
        '<leader>cI',
        function() require('rulebook').lookupRule() end,
        desc = 'Rule Docs',
      },
      {
        '<leader>cY',
        function() require('rulebook').yankDiagnosticCode() end,
        desc = 'Yank Rule Code',
      },
      -- The formatter's own "leave this alone" comment, for conform's tools
      {
        '<leader>cZ',
        function() require('rulebook').suppressFormatter() end,
        mode = { 'n', 'x' },
        desc = 'Suppress Formatter',
      },
    },
    opts = function()
      -- `dyshellint` reads one directive for every code it reports, its own
      -- `BSG###` rules and shfmt's `FMT001` alike. The reason for the
      -- exception is typed after the codes by hand: anything trailing the
      -- comment would stop rulebook from merging a second code into it.
      local dyshellint = {
        comment = '# dyshellint disable=%s',
        location = 'prevLine',
        multiRuleIgnore = true,
        multiRuleSeparator = ',',
        docs = 'https://github.com/dynamotn/dyshellint#silence-a-finding-in-place',
      }
      return {
        ignoreComments = {
          dyshellint = dyshellint,
          shfmt = dyshellint,
        },
      }
    end,
  },
}
