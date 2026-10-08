local Plugin = require('util.plugin')

local M = {}

---@alias BlinkAction fun(): boolean?

--- Named actions for completion keys, filled in by the snippet and AI
--- plugins as they load. An action returns true when it handled the key.
---@type table<string, BlinkAction>
M.actions = {
  snippet_forward = function()
    if vim.snippet.active({ direction = 1 }) then
      vim.schedule(function() vim.snippet.jump(1) end)
      return true
    end
  end,
  snippet_stop = function()
    if vim.snippet then vim.snippet.stop() end
  end,
}

--- Key handler running `actions` in turn until one handles the key, then
--- `fallback`
---@param actions string[]
---@param fallback? string|fun()
function M.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if M.actions[name] and M.actions[name]() then return true end
    end
    return type(fallback) == 'function' and fallback() or fallback
  end
end

---@alias Placeholder { n: number, text: string }

---@param snippet string
---@param fn fun(placeholder: Placeholder): string
---@return string
function M.snippet_replace(snippet, fn)
  return snippet:gsub('%$%b{}', function(m)
    local n, name = m:match('^%${(%d+):(.+)}$')
    return n and fn({ n = n, text = name }) or m
  end) or snippet
end

--- Snippet text with its nested placeholders resolved
---@param snippet string
---@return string
function M.snippet_preview(snippet)
  local ok, parsed = pcall(
    function() return vim.lsp._snippet_grammar.parse(snippet) end
  )
  return ok and tostring(parsed)
    or M.snippet_replace(
      snippet,
      function(placeholder) return M.snippet_preview(placeholder.text) end
    ):gsub('%$0', '')
end

--- Snippet with nested placeholders flattened, which `vim.snippet` can
--- expand
---@param snippet string
---@return string
function M.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return M.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n]
      or M.snippet_preview(placeholder.text)
    return '${' .. placeholder.n .. ':' .. texts[placeholder.n] .. '}'
  end)
end

--- `vim.snippet.expand` that falls back to the flattened snippet, and keeps
--- the top-level session: native sessions do not nest
---@param snippet string
function M.expand(snippet)
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = M.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)
    local msg = ok
        and 'Failed to parse snippet,\nbut was able to fix it automatically.'
      or ('Failed to parse snippet.\n' .. err)
    Plugin[ok and 'warn' or 'error'](
      ('%s\n```%s\n%s\n```'):format(msg, vim.bo.filetype, snippet),
      { title = 'vim.snippet' }
    )
  end

  if session then vim.snippet._session = session end
end

return M
