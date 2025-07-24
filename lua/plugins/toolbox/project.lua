return {
  -- Project setting
  { import = 'lazyvim.plugins.extras.lsp.neoconf' },
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
