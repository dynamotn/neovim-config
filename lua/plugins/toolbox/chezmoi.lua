local enabled = require('util.chezmoi').enabled()

return {
  -- Edit chezmoi managed files
  {
    import = 'lazyvim.plugins.extras.util.chezmoi',
    enabled = enabled,
  },
  -- Disable unused plugin
  { 'alker0/chezmoi.vim', enabled = false },
  {
    -- Edit chezmoi source files in place: the target language injected into
    -- `*.tmpl`, managed files typed by their target, `:Chezmoi` commands
    'dpezto/chezmoi-template.nvim',
    enabled = enabled,
    -- Lazy-loads itself from `plugin/`, and its Tree-sitter directive has to
    -- be there before the first `gotmpl` tree is parsed
    lazy = false,
    opts = {
      -- Applying is asked for, never done behind a `:w`
      apply = { on_save = false },
      -- Templates here `decrypt` secrets, and both of these render the
      -- template to do their job: keep that to an explicit `:Chezmoi preview`
      -- rather than every keystroke or every write
      preview = { live = false },
      diagnostics = { enabled = false },
      -- Never decrypt `*.age` files on open
      encryption = { enabled = false },
      completion = {
        mask = {
          'secret',
          'token',
          'passw',
          'key',
          'api',
          'age',
          'private',
          'credential',
        },
      },
      picker = { backend = 'snacks' },
      -- `<localleader>c` in source buffers: preview, apply, diff, target,
      -- source, edit, pick
      keymaps = { enabled = true },
    },
  },
  {
    -- Complete `chezmoi data` keys inside template actions
    'blink.cmp',
    optional = true,
    opts = function(_, opts)
      if not enabled then return end
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        chezmoi = '「CZ」',
      })
      opts.sources.providers.chezmoi = {
        name = 'chezmoi',
        module = 'chezmoi-template.blink',
        score_offset = 21,
      }
      opts.sources.per_filetype.gotmpl =
        vim.list_extend({ 'chezmoi' }, require('util.cmp').sources('*'))
    end,
  },
}
