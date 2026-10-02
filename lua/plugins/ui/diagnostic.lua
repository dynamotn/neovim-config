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
        -- Rulebook keys this table on `diagnostic.source`, spelled exactly as
        -- the tool reports it, and only offers the sources it has an entry
        -- for. Several of ours had none, so `<leader>ci` did nothing on a
        -- Dockerfile, a Ruby file or a Terraform plan.
        --
        -- Left out on purpose: a tool whose nvim-lint parser reports no code
        -- (`tflint`, `clj-kondo`, `golangcilint`, `phpcs`, `perlcritic`,
        -- `credo`, `gitlint`) has nothing to put in the comment, and a tool
        -- with no per-line directive at all (`jsonlint`, `htmlhint`,
        -- `statix`, `twigcs`, `cue vet`, the `fish`/`gawk`/`zsh` syntax
        -- checks) has nowhere to put one.
        ignoreComments = {
          dyshellint = dyshellint,
          shfmt = dyshellint,

          -- Tools rulebook already knows, under the name nvim-lint gives the
          -- binary rather than the one their language server reports.
          ruff = {
            comment = '# noqa: %s',
            location = 'sameLine',
            spacesBeforeCommentWhenSameLine = 2, -- what the formatter wants
            multiRuleIgnore = true,
            multiRuleSeparator = ', ',
            docs = 'https://docs.astral.sh/ruff/linter/#error-suppression',
          },
          biomejs = {
            comment = function(diagnostic)
              local ignore = ('biome-ignore %s: explanation'):format(
                diagnostic.code
              )
              return vim.bo.commentstring:format(ignore)
            end,
            location = 'prevLine',
            multiRuleIgnore = false,
            docs = 'https://biomejs.dev/analyzer/suppressions/',
          },

          -- A finding is a secret, not a rule worth arguing with, so the
          -- directive carries no code: it marks this one line as a false
          -- positive. `gitleaks:allow` is read the same way.
          betterleaks = {
            comment = function(_)
              return vim.bo.commentstring:format('betterleaks:allow')
            end,
            location = 'sameLine',
            doesNotUseCodes = true,
            multiRuleIgnore = false,
            docs = 'https://github.com/betterleaks/betterleaks#additional-configuration',
          },
          hadolint = {
            comment = '# hadolint ignore=%s',
            location = 'prevLine',
            multiRuleIgnore = true,
            multiRuleSeparator = ',',
            docs = 'https://github.com/hadolint/hadolint#inline-ignores',
          },
          -- One directive per check, on the line above the block it belongs
          -- to. The marker follows the file, which is Helm, Terraform or
          -- YAML; JSON has no comment to hang it off and is out of reach.
          trivy = {
            comment = function(diagnostic)
              return vim.bo.commentstring:format(
                'trivy:ignore:' .. diagnostic.code
              )
            end,
            location = 'prevLine',
            multiRuleIgnore = false,
            docs = 'https://trivy.dev/latest/docs/configuration/filtering/#by-inline-comments',
          },
          rubocop = {
            comment = '# rubocop:disable %s',
            location = 'sameLine',
            multiRuleIgnore = true,
            multiRuleSeparator = ', ',
            docs = 'https://docs.rubocop.org/rubocop/configuration.html#disabling-cops-within-source-code',
          },
          sqlfluff = {
            comment = '-- noqa: %s',
            location = 'sameLine',
            multiRuleIgnore = true,
            multiRuleSeparator = ',',
            docs = 'https://docs.sqlfluff.com/en/stable/perma/noqa.html',
          },
        },
      }
    end,
  },
}
