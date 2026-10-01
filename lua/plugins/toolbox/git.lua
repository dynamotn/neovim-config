return {
  {
    -- VSCode-style diff to review changes, history and merge conflicts
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    keys = {
      { '<leader>gv', '<cmd>CodeDiff<cr>', desc = 'Review Changes (CodeDiff)' },
      {
        '<leader>gH',
        '<cmd>CodeDiff history %<cr>',
        desc = 'File History (CodeDiff)',
      },
      {
        '<leader>gH',
        ':CodeDiff history<cr>',
        desc = 'Line History (CodeDiff)',
        mode = 'x',
      },
    },
    opts = {},
  },
  {
    -- CI checks and job logs of GitHub, GitLab and Forgejo
    -- It leaves GitHub on 2026-10-31 and warns when installed from there.
    url = 'https://forge.barrettruth.com/barrettruth/ci.nvim',
    name = 'ci.nvim',
    -- Needs Neovim 0.13, above what the `stable` channel asks for
    cond = vim.fn.has('nvim-0.13') == 1,
    cmd = 'CI',
    keys = {
      { '<leader>gC', '<cmd>CI<cr>', desc = 'CI Checks' },
    },
  },
  -- Review GitHub pull requests and issues. The extra hands `<leader>gi`,
  -- `gI`, `gp` and `gP` over from Snacks' `gh` pickers to Octo.
  {
    import = 'lazyvim.plugins.extras.util.octo',
    enabled = vim.fn.executable('gh') == 1,
  },
  {
    'pwntester/octo.nvim',
    optional = true,
    keys = {
      -- `<leader>gS` stays Snacks' git stash
      { '<leader>gS', false },
      { '<leader>g/', '<cmd>Octo search<cr>', desc = 'Search (Octo)' },
      -- The blink `git` source already completes `@` and `#` as they are
      -- typed, so the omnifunc popup these open would be a second menu
      { '@', false, mode = 'i', ft = 'octo' },
      { '#', false, mode = 'i', ft = 'octo' },
    },
    opts = {
      -- GitHub is the `gh` remote in my repositories, with `origin` often on
      -- GitLab; Octo takes the first of these that exists
      default_remote = { 'upstream', 'gh', 'github', 'origin' },
    },
  },
  {
    'blink.cmp',
    optional = true,
    dependencies = {
      {
        'petertriho/cmp-git',
        ft = 'octo',
        init = function()
          _G.completion_sources =
            vim.tbl_extend('force', _G.completion_sources, {
              git = '「GIT」',
            })
        end,
      },
    },
    opts = {
      sources = {
        compat = { 'git' },
        per_filetype = {
          octo = require('util.cmp').sources('octo'),
        },
      },
    },
  },
}
