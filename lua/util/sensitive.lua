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

--- The credential formats `lines` hold, one entry per rule that matched
---@param lines string[]
---@param first integer Number of the first line, for the report
---@return { name: string, line: integer }[]
local function secrets_in(lines, first)
  local found = {}
  local seen = {}
  for offset, line in ipairs(lines) do
    for _, rule in ipairs(config.content_patterns) do
      if not seen[rule.name] and line:find(rule.pattern) then
        seen[rule.name] = true
        table.insert(found, { name = rule.name, line = first + offset - 1 })
      end
    end
  end
  return found
end

--- The credential formats a buffer holds, whatever it is called
---
--- Only the text is read: a buffer of a file that was never written, a
--- scratch buffer and a terminal's output are all searched the same way. The
--- guards ask on every cursor move, so the answer is kept in a buffer
--- variable -- gone when the buffer is -- and the text is read once per
--- change rather than once per question.
---@param bufnr integer
---@return { name: string, line: integer }[] found
---@return boolean partial Whether the buffer was only searched in part
local function secrets_in_buffer(bufnr)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local cached = vim.b[bufnr].dy_sensitive_scan
  if cached and cached.tick == tick then return cached.found, cached.partial end

  local lines = vim.api.nvim_buf_line_count(bufnr)
  local bytes = vim.api.nvim_buf_get_offset(bufnr, lines)
  local partial = bytes > config.content_max_bytes
  if partial then
    -- The offset of a line is where it starts, so this is the last line that
    -- begins inside the budget.
    local low, high = 1, lines
    while low < high do
      local middle = math.floor((low + high + 1) / 2)
      if
        vim.api.nvim_buf_get_offset(bufnr, middle) <= config.content_max_bytes
      then
        low = middle
      else
        high = middle - 1
      end
    end
    lines = low
  end

  local found =
    secrets_in(vim.api.nvim_buf_get_lines(bufnr, 0, lines, false), 1)
  vim.b[bufnr].dy_sensitive_scan =
    { tick = tick, found = found, partial = partial }
  return found, partial
end

--- What `betterleaks` found in a buffer, as its diagnostics
---
--- `betterleaks` already runs over every buffer as a linter of its own, with
--- hundreds of rules behind it and the secret redacted out of what it
--- reports. Reading what it left behind costs nothing and asks nothing of it:
--- no second process, and nothing sent anywhere. It only answers once it has
--- run, though -- on a write, a read or leaving insert mode -- which is why
--- the patterns above are there as well, and why they are the ones that can
--- answer the instant a key is pressed.
---@param bufnr integer
---@return { name: string, line: integer }[]
local function leaks_in_buffer(bufnr)
  local found = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    if diagnostic.source == 'betterleaks' then
      table.insert(found, {
        name = ('betterleaks %s'):format(diagnostic.code or 'finding'),
        line = diagnostic.lnum + 1,
      })
    end
  end
  return found
end

--- Let this buffer through the content check for as long as it is open
---
--- The way out of a pattern that matched something that is not a credential.
--- It says nothing about the name rules: a `.env` stays sensitive however
--- often it is allowed, since what that file is for is not in doubt.
---@param bufnr? integer
M.allow = function(bufnr)
  if bufnr == nil or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.b[bufnr].dy_ai_guard_allow = true
  end
end

--- Whether the content check has been waived for a buffer
---@param bufnr integer
---@return boolean
M.is_allowed = function(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.b[bufnr].dy_ai_guard_allow == true
end

--- Why a buffer must not leave the machine, in words, or nothing when it may
---@param bufnr? integer
---@return string[]
M.reasons = function(bufnr)
  if bufnr == nil or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if not vim.api.nvim_buf_is_valid(bufnr) then return {} end

  local reasons = {}
  local filetype = vim.bo[bufnr].filetype
  if vim.list_contains(config.filetypes, filetype) then
    table.insert(reasons, ('filetype %s'):format(filetype))
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if M.is_sensitive_path(name) then
    table.insert(reasons, ('path %s'):format(vim.fn.fnamemodify(name, ':~')))
  end
  if M.is_allowed(bufnr) then return reasons end
  local found, partial = secrets_in_buffer(bufnr)
  vim.list_extend(found, leaks_in_buffer(bufnr))
  for _, secret in ipairs(found) do
    table.insert(reasons, ('%s on line %d'):format(secret.name, secret.line))
  end
  if partial and #found == 0 then
    table.insert(reasons, 'searched only the first part of the buffer')
  end
  return reasons
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
  if M.is_sensitive_path(vim.api.nvim_buf_get_name(bufnr)) then return true end
  if M.is_allowed(bufnr) then return false end
  return #(secrets_in_buffer(bufnr)) > 0 or #(leaks_in_buffer(bufnr)) > 0
end

return M
