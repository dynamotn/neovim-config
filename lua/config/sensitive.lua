--- What counts as sensitive: files whose content must never reach an AI
--- service. The checks that read these lists live in `util.sensitive`.
---@class DySensitiveConfig
return {
  --- Lua patterns matched against the file name alone
  ---@type string[]
  name_patterns = {
    '%.env$', -- dotenv: `.env`, `prod.env`, and `.env.local`, `.env.test`, ...
    '^%.env%.',
    '^%.envrc$', -- direnv
    '%.age$', -- age-encrypted secrets
    '%.gpg$',
    '%.pem$', -- keys and certificates
    '%.key$',
    '%.p12$',
    '%.pfx$',
    '^id_[%w_-]+$', -- ssh keys (`id_rsa`, `id_ed25519`, ...)
    '^%.netrc$',
    '^_netrc$',
    '^%.pgpass$',
    '^%.git%-credentials$',
    '^%.npmrc$', -- package registry tokens
    '^%.pypirc$',
    '^%.vault%-token$',
  },
  --- Directory names: every file below one of them is sensitive, whatever it
  --- is called, because they hold credentials under ordinary names (`config`,
  --- `credentials`, `data/...`).
  ---@type table<string, boolean>
  dirs = {
    ['.ssh'] = true,
    ['.gnupg'] = true,
    ['.aws'] = true,
    ['.kube'] = true,
    ['.docker'] = true,
    ['secrets'] = true,
  },
  --- Directories sensitive by where they are, checked by full path so they
  --- stay covered whatever becomes of the name rules above. `secrets/data` is
  --- the Dotfiles submodule of live credentials, and a clone of it (a
  --- worktree, a checkout elsewhere) is caught by the name rules instead.
  ---@type string[]
  paths = {
    vim.fs.joinpath(vim.env.HOME, 'Dotfiles', 'secrets', 'data'),
  },
  --- Filetypes sensitive by content rather than by path. A commit message
  --- buffer carries the staged diff as well under `git commit --verbose`, and
  --- that diff can be the very secret being committed.
  ---@type string[]
  filetypes = {
    'gitcommit',
  },
}
