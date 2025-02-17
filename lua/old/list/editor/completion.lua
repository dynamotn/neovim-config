return {
  {
    -- Engine
    'hrsh7th/nvim-cmp',
    name = 'cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'luasnip',
      { 'hrsh7th/cmp-cmdline' }, -- CMD
      { 'onsails/lspkind.nvim' }, -- LSP completion pictograms

      -- Sources
      { 'hrsh7th/cmp-nvim-lsp' }, -- LSP completion source
      {
        -- Snippet completion source
        'saadparwaiz1/cmp_luasnip',
        dependencies = { 'luasnip' },
      },
      {
        -- Buffer completion source with fuzzy
        'tzachar/cmp-fuzzy-buffer',
        dependencies = { 'fuzzy' },
      },
      { 'hrsh7th/cmp-calc' }, -- Math calculation
      { 'FelipeLema/cmp-async-path' }, -- Path completion source
      {
        -- Path completion source with fuzzy
        'tzachar/cmp-fuzzy-path',
        dependencies = { 'fuzzy' },
      },
      { 'andersevenrud/cmp-tmux' }, -- Tmux completion source
      {
        -- DAP completion source
        'rcarriga/cmp-dap',
        dependencies = { 'dap' },
      },
      {
        -- Dynamic completion source
        'uga-rosa/cmp-dynamic',
        name = 'cmp_dynamic',
      },
      {
        -- Codeium completion source
        'Exafunction/codeium.nvim',
        name = 'codeium',
        build = ':Codeium Auth',
        cmd = 'Codeium',
        dependencies = { 'plenary' },
      },
    },
  },
}
