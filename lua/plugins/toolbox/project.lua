return {
  -- Project setting
  { import = 'lazyvim.plugins.extras.lsp.neoconf' },
  {
    -- Integrate project management with which-key
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>p', group = 'project' },
      },
    },
  },
  {
    -- Open alternative files in the project
    'rgroli/other.nvim',
    main = 'other-nvim',
    lazy = false,
    opts = {
      mappings = {
        'angular',
        'laravel',
        'rails',
        'golang',
        'python',
        'react',
        'rust',
        {
          pattern = '/src/(.*).sh$',
          target = '/test/%1.bats',
          context = 'test',
        },
      },
    },
    keys = {
      {
        '<leader>pa',
        function() require('other-nvim').openVSplit() end,
        desc = 'Open alternative file',
        mode = { 'n', 't' },
      },
    },
  },
  {
    -- Devcontainer
    'https://codeberg.org/esensar/nvim-dev-container',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      opts = function(_, opts)
        opts.ensure_installed = {
          'jsonc', -- for devcontainer.json
        }
      end,
    },
  },
}
