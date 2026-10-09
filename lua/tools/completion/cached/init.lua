--- A blink.cmp source that keeps the items of another one for a while.
---
--- `blink-cmp-tmux` and `blink-cmp-zellij` capture every pane with
--- `vim.system():wait()`, on the main loop, and mark their answer incomplete,
--- so blink asks again on every key: each one typed stalled the editor for a
--- `list-panes` plus a capture per pane. Their words do not depend on what is
--- being typed, so they are kept here, handed to blink as complete -- it then
--- filters them itself -- and captured again only once they are `ttl` old,
--- when the editor next sits idle, rather than in the middle of a word.
---
--- Provider options:
---   source  module of the wrapped source
---   ttl     milliseconds before its items are captured again
---   opts    options of the wrapped source
---@class tools.completion.cached: blink.cmp.Source
---@field inner blink.cmp.Source
---@field ttl integer
---@field items? blink.cmp.CompletionItem[]
---@field captured integer `vim.uv.now()` of the last capture
---@field capturing? boolean The wrapped source is being asked
---@field waiting fun()[] Called once the capture under way is done
---@field pending boolean A capture is already waiting for `CursorHold`
local source = {}

---@param opts { source: string, ttl?: integer, opts?: table }
---@param config blink.cmp.SourceProviderConfig
function source.new(opts, config)
  local self = setmetatable({}, { __index = source })
  self.inner = require(opts.source).new(opts.opts or {}, config)
  self.ttl = opts.ttl or 10000
  self.captured = 0
  self.waiting = {}
  self.pending = false
  return self
end

function source:enabled()
  return self.inner.enabled == nil or self.inner:enabled()
end

function source:get_trigger_characters()
  return self.inner.get_trigger_characters
      and self.inner:get_trigger_characters()
    or {}
end

--- Ask the wrapped source again, and keep what it answers
---@param context blink.cmp.Context
---@param on_done? fun()
function source:capture(context, on_done)
  if on_done then table.insert(self.waiting, on_done) end
  -- One capture at a time; whoever asks meanwhile gets its answer
  if self.capturing then return end
  self.capturing = true
  local function answered(response)
    self.capturing = false
    self.items = response and response.items or {}
    self.captured = vim.uv.now()
    local waiting = self.waiting
    self.waiting = {}
    for _, done in ipairs(waiting) do
      done()
    end
  end
  -- A source that throws would leave `capturing` set, and every later
  -- request waiting for an answer that never comes
  local ok = pcall(self.inner.get_completions, self.inner, context, answered)
  if not ok and self.capturing then answered({ items = {} }) end
end

--- Fresh tables each time: blink writes its own fields into the items it is
--- given, and these ones are handed out again and again.
---@param callback fun(response: blink.cmp.CompletionResponse)
function source:answer(callback)
  callback({
    items = vim.tbl_map(
      function(item) return vim.tbl_extend('force', {}, item) end,
      self.items
    ),
    is_incomplete_forward = false,
    is_incomplete_backward = false,
  })
end

---@param context blink.cmp.Context
---@param callback fun(response: blink.cmp.CompletionResponse)
function source:get_completions(context, callback)
  if not self.items then
    -- Nothing captured yet: this first one has to be waited for
    self:capture(context, function() self:answer(callback) end)
    return
  end
  self:answer(callback)
  if vim.uv.now() - self.captured > self.ttl and not self.pending then
    self.pending = true
    vim.api.nvim_create_autocmd('CursorHold', {
      once = true,
      callback = function()
        self.pending = false
        self:capture(context)
      end,
    })
  end
end

return source
