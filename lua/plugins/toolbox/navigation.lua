return {
  {
    -- Smoothly navigate between neovim and tmux/zellij
    'dynamotn/Navigator.nvim',
    event = 'UIEnter',
    config = function(_, opts) require('Navigator').setup(opts) end,
    keys = {
      {
        '<S-Left>',
        function() require('Navigator').left() end,
        desc = 'Navigate to left window',
        mode = { 'n', 't' },
      },
      {
        '<S-Down>',
        function() require('Navigator').down() end,
        desc = 'Navigate to down window',
        mode = { 'n', 't' },
        noremap = true,
      },
      {
        '<S-Up>',
        function() require('Navigator').up() end,
        desc = 'Navigate to up window',
        mode = { 'n', 't' },
        noremap = true,
      },
      {
        '<S-Right>',
        function() require('Navigator').right() end,
        desc = 'Navigate to right window',
        mode = { 'n', 't' },
        noremap = true,
      },
      {
        '<C-\\>',
        function() require('Navigator').previous() end,
        desc = 'Navigate to previous window',
        mode = { 'n', 't' },
        noremap = true,
      },
    },
  },
  {
    -- Editable quickfix with context lines
    'stevearc/quicker.nvim',
    ft = 'qf',
    -- Take over LazyVim's own toggles, which focus the list as these do.
    keys = {
      {
        '<leader>xq',
        function() require('quicker').toggle({ focus = true }) end,
        desc = 'Quickfix List',
      },
      {
        '<leader>xl',
        function() require('quicker').toggle({ focus = true, loclist = true }) end,
        desc = 'Location List',
      },
    },
    opts = {
      keys = {
        {
          '>',
          function()
            require('quicker').expand({
              before = 2,
              after = 2,
              add_to_existing = true,
            })
          end,
          desc = 'Expand quickfix context',
        },
        {
          '<',
          function() require('quicker').collapse() end,
          desc = 'Collapse quickfix context',
        },
      },
    },
  },
}
