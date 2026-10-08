-- Every file under `lua/plugins/` is a lazy.nvim spec. lazy.nvim reports a
-- malformed one only once the editor starts, so the shape of each is checked
-- here: loaded on its own, it must hand back a spec whose fields hold the
-- types lazy.nvim accepts.
local h = require('helpers')

h.globals()

local function is_any(value, ...)
  local kind = type(value)
  for _, allowed in ipairs({ ... }) do
    if kind == allowed then return true end
  end
  return false
end

--- Field to the types lazy.nvim accepts for it
---@type table<string, string[]>
local field_types = {
  name = { 'string' },
  dir = { 'string' },
  url = { 'string' },
  import = { 'string', 'function' },
  branch = { 'string' },
  tag = { 'string' },
  commit = { 'string' },
  version = { 'string', 'boolean' },
  pin = { 'boolean' },
  submodules = { 'boolean' },
  main = { 'string' },
  dev = { 'boolean' },
  lazy = { 'boolean' },
  optional = { 'boolean' },
  enabled = { 'boolean', 'function' },
  cond = { 'boolean', 'function' },
  priority = { 'number' },
  opts = { 'table', 'function' },
  config = { 'function', 'boolean' },
  init = { 'function' },
  build = { 'string', 'function', 'table', 'boolean' },
  dependencies = { 'string', 'table' },
  specs = { 'string', 'table' },
  event = { 'string', 'table', 'function' },
  cmd = { 'string', 'table', 'function' },
  ft = { 'string', 'table', 'function' },
  keys = { 'string', 'table', 'function' },
  module = { 'boolean' },
  opts_extend = { 'table' },
}

--- Collect what is wrong with `spec`, a spec or a list of them
---@param spec any
---@param where string
---@param problems string[]
local function check(spec, where, problems)
  if type(spec) == 'string' then return end
  if type(spec) ~= 'table' then
    table.insert(problems, where .. ': spec is a ' .. type(spec))
    return
  end
  local is_plugin = type(spec[1]) == 'string'
    or type(spec.dir) == 'string'
    or type(spec.url) == 'string'
    or spec.import ~= nil
    or type(spec.name) == 'string'
  if not is_plugin then
    -- A list of specs; an empty one is how a file opts out entirely
    for key in pairs(spec) do
      if type(key) ~= 'number' then
        table.insert(
          problems,
          where .. ': field `' .. tostring(key) .. '` outside a plugin spec'
        )
      end
    end
    for i, child in ipairs(spec) do
      check(child, where .. '[' .. i .. ']', problems)
    end
    return
  end
  local label = where
    .. ' ('
    .. tostring(spec[1] or spec.name or spec.dir or spec.import)
    .. ')'
  for field, allowed in pairs(field_types) do
    if spec[field] ~= nil and not is_any(spec[field], unpack(allowed)) then
      table.insert(
        problems,
        label .. ': `' .. field .. '` is a ' .. type(spec[field])
      )
    end
  end
  if type(spec.dependencies) == 'table' then
    check(spec.dependencies, label .. '.dependencies', problems)
  end
  if type(spec.specs) == 'table' then
    check(spec.specs, label .. '.specs', problems)
  end
  if type(spec.keys) == 'table' then
    for i, key in ipairs(spec.keys) do
      if type(key) == 'table' then
        if type(key[1]) ~= 'string' then
          table.insert(problems, label .. '.keys[' .. i .. ']: no lhs')
        end
        -- `false` turns off a mapping another spec set up
        if
          key[2] ~= nil
          and key[2] ~= false
          and not is_any(key[2], 'string', 'function')
        then
          table.insert(problems, label .. '.keys[' .. i .. ']: bad rhs')
        end
      elseif type(key) ~= 'string' then
        table.insert(problems, label .. '.keys[' .. i .. ']: ' .. type(key))
      end
    end
  end
  if type(spec[1]) == 'string' and not spec.dir then
    -- `owner/repo`, or the bare name of a plugin specified elsewhere
    if not spec[1]:match('^[%w%._%-]+/?[%w%._%-]*$') then
      table.insert(problems, label .. ': `' .. spec[1] .. '` is not a plugin')
    end
  end
end

local files = vim.fn.glob(
  vim.fs.joinpath(h.root, 'lua', 'plugins', '**', '*.lua'),
  false,
  true
)
table.sort(files)

describe('plugins', function()
  it('finds the spec files', function() assert.is_true(#files > 50) end)

  for _, file in ipairs(files) do
    local module = file:sub(#h.root + 6):gsub('%.lua$', ''):gsub('/', '.')
    it(module .. ' returns a well-formed lazy.nvim spec', function()
      local ok, spec = pcall(require, module)
      assert(ok, tostring(spec))
      assert.are.equal('table', type(spec))
      local problems = {}
      check(spec, module, problems)
      assert.are.same({}, problems)
    end)
  end
end)
