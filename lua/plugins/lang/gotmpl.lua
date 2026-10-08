---@diagnostic disable-next-line: unused-local
local language = require('config.languages').gotmpl

-- Target languages injected into a template, told by its file name
local injections = {
  ['is-bash-file?'] = {
    '.*%.sh%.tmpl$',
    'executable_.*%.tmpl$',
  },
  ['is-fish-file?'] = '.*%.fish%.tmpl$',
  ['is-yaml-file?'] = '.*%.ya?ml%.tmpl$',
  ['is-toml-file?'] = '.*%.toml%.tmpl$',
  ['is-ini-file?'] = '.*%.ini%.tmpl$',
  ['is-js-file?'] = '.*%.js%.tmpl$',
  ['is-python-file?'] = '.*%.py%.tmpl$',
  ['is-lua-file?'] = '.*%.lua%.tmpl$',
}
-- `chezmoi-template.nvim` injects the target language into every template,
-- asking chezmoi for it rather than guessing from the name. The predicates
-- stay registered, since `after/queries/gotmpl` names them, but match nothing.
if require('util.chezmoi').enabled() then
  injections = vim.tbl_map(function() return false end, injections)
end

return vim.list_contains(DyNeo.enabled_languages, 'gotmpl')
    and {
      {
        -- Filetype icons
        'nvim-mini/mini.icons',
        opts = {
          filetype = {
            gotmpl = { glyph = '󰟓 ', hl = 'MiniIconsGrey' },
          },
        },
      },
      {
        -- Injection another language
        'nvim-treesitter/nvim-treesitter',
        opts = {
          custom_predicates = injections,
        },
      },
      {
        -- Comment
        'folke/ts-comments.nvim',
        opts = {
          lang = {
            gotmpl = { '{{- /* %s */ }}' },
          },
        },
      },
    }
  or {}
