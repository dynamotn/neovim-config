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
    init = function()
      -- chezmoi templates everything under `.chezmoitemplates/` whatever the
      -- extension, so the plugin forces those partials to `gotmpl`. Plenty of
      -- them hold no action at all -- `dytoy` package data, `ssh` snippets --
      -- and as `gotmpl` they lose their schema, linter and formatter. Hand
      -- those back their own filetype; a partial that really templates stays
      -- `gotmpl`.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('chezmoi_plain_partials', {}),
        pattern = 'gotmpl',
        callback = function(ctx)
          local file = vim.api.nvim_buf_get_name(ctx.buf)
          if
            not file:find('/.chezmoitemplates/', 1, true)
            or file:match('%.tmpl$')
          then
            return
          end
          for _, line in
            ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false))
          do
            if line:find('{{', 1, true) then return end
          end
          -- Seeded by the plugin from the attribute-stripped basename
          local ft = vim.b[ctx.buf].chezmoi_target_lang
            or vim.filetype.match({ filename = vim.fs.basename(file) })
          if ft and ft ~= '' and ft ~= 'gotmpl' then
            vim.bo[ctx.buf].filetype = ft
          end
        end,
      })
    end,
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
