-- Retry the schema downloads jsonls gives up on.
--
-- `vscode-json-language-server` fetches every remote `$schema` itself, keeps
-- the result in memory, and never asks again: one connection reset while the
-- buffer opens leaves `Unable to load schema from '<url>'` on the file, with
-- no validation and no completion, for the rest of the session. The server
-- does take a `json/schemaContent` notification, which drops its cached copy
-- of a URL and revalidates every open document, so a download that failed can
-- be taken up again from here.
local M = {}

local MAX_ATTEMPTS = 3
--- Backoff before each attempt, in milliseconds
local DELAYS = { 1000, 3000, 9000 }
--- Reasons the server would report again however often the URL is fetched.
--- `request-light` turns these HTTP statuses into the message text below.
local PERMANENT = {
  'Bad request',
  'Unauthorized',
  'Forbidden',
  'Not Found',
  'Method not allowed',
}

local group = vim.api.nvim_create_augroup('util.json_schema', { clear = true })

---@type table<string, integer> attempts already spent on a schema URL
local attempts = {}
---@type table<string, true> URLs whose next attempt is already scheduled
local pending = {}
---@type table<integer, table<string, true>> URLs a buffer last reported
local reported = {}

--- The schema URL of an `Unable to load schema` diagnostic, when fetching it
--- again could plausibly succeed
---@param message string
---@return string?
local function failed_url(message)
  local url = message:match("Unable to load schema from '(.-)'")
  if not url then return nil end
  for _, reason in ipairs(PERMANENT) do
    if message:find(reason, 1, true) then return nil end
  end
  return url
end

--- Have the server drop its cached copy of `url` and fetch it again
---@param client vim.lsp.Client
---@param url string
local function retry(client, url)
  local spent = attempts[url] or 0
  if spent >= MAX_ATTEMPTS or pending[url] then return end
  attempts[url] = spent + 1
  pending[url] = true
  vim.defer_fn(function()
    pending[url] = nil
    if client:is_stopped() then return end
    client:notify('json/schemaContent', url)
  end, DELAYS[spent + 1])
end

--- Take up the schema downloads the diagnostics of `bufnr` report as failed.
--- A URL that stops failing gets its budget back, so a later outage is retried
--- again rather than being written off for the session.
---@param client vim.lsp.Client
---@param bufnr integer
---@return table<string, true> failed URLs the buffer reports
function M.retry_failed(client, bufnr)
  local failed = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    local url = failed_url(diagnostic.message or '')
    if url then failed[url] = true end
  end
  for url in pairs(reported[bufnr] or {}) do
    if not failed[url] then attempts[url] = nil end
  end
  reported[bufnr] = next(failed) and failed or nil
  for url in pairs(failed) do
    retry(client, url)
  end
  return failed
end

--- Watch the diagnostics of the buffers `client` is attached to, and fetch
--- again every schema it reports as unreachable
---@param client vim.lsp.Client
function M.on_init(client)
  vim.api.nvim_clear_autocmds({ group = group })
  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = group,
    callback = function(ev)
      if client:is_stopped() then return end
      if not vim.lsp.buf_is_attached(ev.buf, client.id) then return end
      M.retry_failed(client, ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd('BufDelete', {
    group = group,
    callback = function(ev) reported[ev.buf] = nil end,
  })
end

return M
