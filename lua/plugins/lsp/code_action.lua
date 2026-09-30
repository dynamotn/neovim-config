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
    -- LazyVim maps `<leader>ca` per buffer on attach, so it is replaced there;
    -- a later entry for the same key wins. Appended rather than merged in
    -- through `opts = {...}`, which would overwrite the list by index.
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      table.insert(opts.servers['*'].keys, {
        '<leader>ca',
        function() require('tiny-code-action').code_action() end,
        desc = 'Code Action',
        mode = { 'n', 'x' },
        has = 'codeAction',
      })
    end,
  },
}
