return {
  {
    -- Code actions picked with a preview of their diff
    'rachartier/tiny-code-action.nvim',
    event = 'LspAttach',
    opts = {
      picker = 'snacks',
    },
  },
  {
    -- `plugins.lsp.server` maps `<leader>ca` per buffer on attach, so it is
    -- replaced there: a later entry for the same key wins, and the server
    -- spec puts its defaults ahead of the keys added before it.
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      require('util.plugin').extend(opts, 'servers.*.keys', {
        {
          '<leader>ca',
          function() require('tiny-code-action').code_action() end,
          desc = 'Code Action',
          mode = { 'n', 'x' },
          has = 'codeAction',
        },
      })
    end,
  },
}
