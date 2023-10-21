return {
  {
    'gitlint',
    'diagnostics',
    with_config = {
      cwd = function()
        -- Change runtime directory of gitlint to root of Git directory
        local job = require('plenary.job'):new({
          command = 'git',
          args = { 'rev-parse', '--show-toplevel' },
        })
        job:sync()
        return table.concat(job:result(), '\n')
      end,
    },
  },
  { 'jira', 'completion', is_custom_tool = true },
  { 'ltrs', 'code_actions' },
  { 'ltrs', 'diagnostics' },
  { 'dictionary', 'hover', is_external_tool = false },
}
