--- Files whose content must never reach an AI service
---
--- Copilot's language server is enabled for every filetype, and a language
--- server is sent the whole text of each buffer it attaches to -- before a
--- single suggestion is asked for. Opening a `.env` or a private key is enough
--- to upload it. What counts as sensitive is listed once, in
--- `config.sensitive`, and every integration that sends buffers away asks the
--- same question here instead of keeping a copy of the list that drifts.

local config = require('config.sensitive')

local M = {}

---@param path string Absolute, normalized path
---@return boolean
local function path_is_sensitive(path)
  local name = vim.fs.basename(path)
  for _, pattern in ipairs(config.name_patterns) do
    if name:match(pattern) then return true end
  end
  for dir in vim.fs.parents(path) do
    if config.dirs[vim.fs.basename(dir)] then return true end
  end
  for _, root in ipairs(config.paths) do
    root = vim.fs.normalize(root)
    if path == root or vim.startswith(path, root .. '/') then return true end
  end
  return false
end

--- Whether a file's content must not leave the machine
---
--- Both the path as given and the path it resolves to are checked: in a
--- chezmoi `mode: symlink` home, `~/.config/foo` may be a link into the
--- repository's `secrets/`, and either name alone would miss one of the two.
---@param path string File path, relative to the working directory or absolute
---@return boolean
M.is_sensitive_path = function(path)
  if path == '' then return false end
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
  if path_is_sensitive(path) then return true end

  local real = vim.uv.fs_realpath(path)
  return real ~= nil
    and real ~= path
    and path_is_sensitive(vim.fs.normalize(real))
end

--- Whether a buffer holds a file whose content must not leave the machine
---@param bufnr? integer Buffer number, the current one when nil or 0
---@return boolean
M.is_sensitive = function(bufnr)
  if bufnr == nil or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end
  if vim.list_contains(config.filetypes, vim.bo[bufnr].filetype) then
    return true
  end
  return M.is_sensitive_path(vim.api.nvim_buf_get_name(bufnr))
end

return M
