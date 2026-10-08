-- GitHub is the `gh` remote in my repositories, with `origin` often on GitLab,
-- so plugins asking a forge take the first of these that exists
local remotes = { 'upstream', 'gh', 'github', 'origin' }

return {
  {
    -- Signs for the lines changed since the last commit, and staging hunk
    -- by hunk
    'lewis6991/gitsigns.nvim',
    event = 'LazyFile',
    opts = function()
      Snacks.toggle({
        name = 'Git Signs',
        get = function() return require('gitsigns.config').config.signcolumn end,
        set = function(state) require('gitsigns').toggle_signs(state) end,
      }):map('<leader>uG')

      return {
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
          untracked = { text = '▎' },
        },
        signs_staged = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(
              mode,
              l,
              r,
              { buffer = buffer, desc = desc, silent = true }
            )
          end

          -- stylua: ignore start
          map('n', ']h', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gs.nav_hunk('next')
            end
          end, 'Next Hunk')
          map('n', '[h', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gs.nav_hunk('prev')
            end
          end, 'Prev Hunk')
          map('n', ']H', function() gs.nav_hunk('last') end, 'Last Hunk')
          map('n', '[H', function() gs.nav_hunk('first') end, 'First Hunk')
          map({ 'n', 'x' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
          map({ 'n', 'x' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
          map('n', '<leader>ghS', gs.stage_buffer, 'Stage Buffer')
          map('n', '<leader>ghu', gs.undo_stage_hunk, 'Undo Stage Hunk')
          map('n', '<leader>ghR', gs.reset_buffer, 'Reset Buffer')
          map('n', '<leader>ghp', gs.preview_hunk_inline, 'Preview Hunk Inline')
          map('n', '<leader>ghb', function() gs.blame_line({ full = true }) end, 'Blame Line')
          map('n', '<leader>ghB', function() gs.blame() end, 'Blame Buffer')
          map('n', '<leader>ghd', gs.diffthis, 'Diff This')
          map('n', '<leader>ghD', function() gs.diffthis('~') end, 'Diff This ~')
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
          -- stylua: ignore end
        end,
      }
    end,
  },
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
    config = function()
      -- It picks the forge from `upstream`, else `origin`, and has no option
      -- to say otherwise: with `origin` on GitLab, `:CI` asked a project that
      -- runs no pipelines for the checks GitHub runs. `gh` finds the GitHub
      -- remote by itself once it is the CLI asked.
      local forge = require('ci.forge')
      local host = forge.host
      forge.host = function()
        for _, name in ipairs(remotes) do
          local r = vim
            .system({ 'git', 'remote', 'get-url', name }, { text = true })
            :wait(2000)
          local url = r.code == 0 and vim.trim(r.stdout or '') or ''
          if url ~= '' then return forge.host_of(url) or host() end
        end
        return host()
      end
    end,
  },
  -- Review GitHub pull requests and issues, when the `gh` CLI is there.
  -- `<leader>gi`, `gI`, `gp` and `gP` are Octo's then, and Snacks' `gh`
  -- pickers otherwise (`plugins.toolbox.picker`).
  vim.fn.executable('gh') == 1
      and {
        {
          'pwntester/octo.nvim',
          cmd = 'Octo',
          event = { { event = 'BufReadCmd', pattern = 'octo://*' } },
          opts = function()
            vim.treesitter.language.register('markdown', 'octo')

            -- Keep the Octo windows of a session, empty as they are
            vim.api.nvim_create_autocmd('ExitPre', {
              group = vim.api.nvim_create_augroup(
                'octo_exit_pre',
                { clear = true }
              ),
              callback = function()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.bo[buf].filetype == 'octo' then
                    vim.bo[buf].buftype = ''
                  end
                end
              end,
            })

            return {
              enable_builtin = true,
              default_to_projects_v2 = true,
              default_merge_method = 'squash',
              picker = 'snacks',
              default_remote = remotes,
            }
          end,
          -- `<leader>gS` stays Snacks' git stash. `@` and `#` complete
          -- through the blink `git` source as they are typed, so they are not
          -- mapped to the omnifunc popup, a second menu.
          -- stylua: ignore
          keys = {
            { '<leader>gi', '<cmd>Octo issue list<CR>', desc = 'List Issues (Octo)' },
            { '<leader>gI', '<cmd>Octo issue search<CR>', desc = 'Search Issues (Octo)' },
            { '<leader>gp', '<cmd>Octo pr list<CR>', desc = 'List PRs (Octo)' },
            { '<leader>gP', '<cmd>Octo pr search<CR>', desc = 'Search PRs (Octo)' },
            { '<leader>gr', '<cmd>Octo repo list<CR>', desc = 'List Repos (Octo)' },
            { '<leader>g/', '<cmd>Octo search<cr>', desc = 'Search (Octo)' },

            { '<localleader>a', '', desc = '+assignee (Octo)', ft = 'octo' },
            { '<localleader>c', '', desc = '+comment/code (Octo)', ft = 'octo' },
            { '<localleader>l', '', desc = '+label (Octo)', ft = 'octo' },
            { '<localleader>i', '', desc = '+issue (Octo)', ft = 'octo' },
            { '<localleader>r', '', desc = '+react (Octo)', ft = 'octo' },
            { '<localleader>p', '', desc = '+pr (Octo)', ft = 'octo' },
            { '<localleader>pr', '', desc = '+rebase (Octo)', ft = 'octo' },
            { '<localleader>ps', '', desc = '+squash (Octo)', ft = 'octo' },
            { '<localleader>v', '', desc = '+review (Octo)', ft = 'octo' },
            { '<localleader>g', '', desc = '+goto_issue (Octo)', ft = 'octo' },
          },
        },
        {
          -- Git parsers, for the issues and PRs Octo shows
          'nvim-treesitter/nvim-treesitter',
          opts = {
            ensure_installed = {
              'git_config',
              'gitcommit',
              'git_rebase',
              'gitignore',
              'gitattributes',
            },
          },
        },
      }
    or {},
  {
    -- Completion source. Its own spec rather than a dependency of blink.cmp,
    -- which would load it on the first `InsertEnter` of any buffer.
    'petertriho/cmp-git',
    ft = 'octo',
    -- `setup` is what registers the source, and lazy.nvim only calls it for
    -- a spec with `opts`; `gitrebase` is not among its default filetypes
    opts = {
      filetypes = { 'gitcommit', 'gitrebase', 'octo', 'NeogitCommitMessage' },
    },
    init = function()
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        git = '「GIT」',
      })
    end,
  },
  {
    'blink.cmp',
    optional = true,
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
