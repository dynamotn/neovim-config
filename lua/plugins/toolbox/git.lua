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
}
