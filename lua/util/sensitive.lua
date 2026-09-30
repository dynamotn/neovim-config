--- Files whose content must never reach an AI service
---
--- Copilot's language server is enabled for every filetype, and a language
--- server is sent the whole text of each buffer it attaches to -- before a
--- single suggestion is asked for. Opening a `.env` or a private key is enough
--- to upload it. This is the one list of what counts as sensitive, so every
--- integration that sends buffers away asks the same question here instead of
--- keeping a copy of the list that drifts.

local M = {}

--- Lua patterns matched against the file name alone
M.name_patterns = {
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
}

--- Directory names: every file below one of them is sensitive, whatever it is
--- called, because they hold credentials under ordinary names (`config`,
--- `credentials`, `data/...`).
M.dirs = {
  ['.ssh'] = true,
  ['.gnupg'] = true,
  ['.aws'] = true,
  ['.kube'] = true,
  ['.docker'] = true,
  ['secrets'] = true,
}

--- Directories sensitive by where they are, checked by full path so they stay
--- covered whatever becomes of the name rules above. `secrets/data` is the
--- Dotfiles submodule of live credentials, and a clone of it (a worktree, a
--- checkout elsewhere) is caught by the name rules instead.
M.paths = {
  vim.fs.joinpath(vim.env.HOME, 'Dotfiles', 'secrets', 'data'),
}

--- Filetypes sensitive by content rather than by path. A commit message
--- buffer carries the staged diff as well under `git commit --verbose`, and
--- that diff can be the very secret being committed.
M.filetypes = {
  'gitcommit',
}

---@param path string Absolute, normalized path
---@return boolean
local function path_is_sensitive(path)
  local name = vim.fs.basename(path)
  for _, pattern in ipairs(M.name_patterns) do
    if name:match(pattern) then return true end
  end
  for dir in vim.fs.parents(path) do
    if M.dirs[vim.fs.basename(dir)] then return true end
  end
  for _, root in ipairs(M.paths) do
    root = vim.fs.normalize(root)
    if path == root or vim.startswith(path, root .. '/') then return true end
  end
  return false
end

--- Whether a buffer holds a file whose content must not leave the machine
---
--- Both the path as opened and the path it resolves to are checked: in a
--- chezmoi `mode: symlink` home, `~/.config/foo` may be a link into the
--- repository's `secrets/`, and either name alone would miss one of the two.
---@param bufnr? integer Buffer number, the current one when nil or 0
---@return boolean
M.is_sensitive = function(bufnr)
  if bufnr == nil or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if vim.list_contains(M.filetypes, vim.bo[bufnr].filetype) then return true end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then return false end
  local path = vim.fs.normalize(vim.fn.fnamemodify(name, ':p'))
  if path_is_sensitive(path) then return true end

  local real = vim.uv.fs_realpath(path)
  return real ~= nil
    and real ~= path
    and path_is_sensitive(vim.fs.normalize(real))
end

return M
