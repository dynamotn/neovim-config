return {
  -- Project setting
  {
    'mrjones2014/codesettings.nvim',
    lazy = false,
    keys = {
      {
        '<leader>pss',
        '<cmd>Codesettings show<cr>',
        desc = 'LSP settings of the clients',
      },
      {
        '<leader>psl',
        '<cmd>Codesettings local<cr>',
        desc = 'Project settings',
      },
      {
        '<leader>psf',
        '<cmd>Codesettings files<cr>',
        desc = 'Project settings files',
      },
      {
        '<leader>pse',
        '<cmd>Codesettings edit<cr>',
        desc = 'Edit project settings',
      },
    },
  },
  {
    -- Integrate project management with which-key
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>p', group = 'project' },
        { '<leader>ps', group = 'settings (codesettings)' },
      },
    },
  },
  {
    -- Open alternative files in the project
    'rgroli/other.nvim',
    main = 'other-nvim',
    cmd = { 'Other', 'OtherTabNew', 'OtherSplit', 'OtherVSplit', 'OtherClear' },
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
        -- Not in a terminal: `<leader>` is a space there, typed all the time
      },
    },
  },
  {
    -- Devcontainer
    'esensar/nvim-dev-container',
    -- The commands only exist once `setup` has run
    cmd = {
      'DevcontainerStart',
      'DevcontainerAttach',
      'DevcontainerExec',
      'DevcontainerStop',
      'DevcontainerStopAll',
      'DevcontainerRemoveAll',
      'DevcontainerLogs',
      'DevcontainerEditNearestConfig',
    },
    opts = {},
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      opts = function(_, opts)
        opts.ensure_installed = vim.list_extend(opts.ensure_installed, {
          'json', -- for devcontainer.json
        })
      end,
    },
  },
}
