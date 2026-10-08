-- Write `doc/neovim-config-keymaps.txt`: every mapping this configuration
-- sets, read off the configuration as it loads rather than kept by hand.
--
-- Loaded with `--cmd` by `keymaps-doc.sh`, ahead of `init.lua`, so it can
-- watch `vim.keymap.set` from the first mapping on. Three sources are read:
--
-- - the `keys` of every plugin spec, through lazy.nvim's own resolution, so
--   a later spec overriding a key is what shows;
-- - the `keys` of the language servers, from the merged nvim-lspconfig
--   options, for the buffers a server attaches to;
-- - every other `vim.keymap.set` made from this tree: `config.keymaps` and
--   what plugin `config` functions map themselves.
--
-- Groups come from which-key's `spec`. Mappings a plugin makes on its own,
-- with no `keys` entry here, are left to `:help` of that plugin.

-- The tree as Lua names its files: `stdpath('config')` is the link
-- `keymaps-doc.sh` points at it
local root = vim.uv.fs_realpath(vim.fn.stdpath('config')) --[[@as string]]
local output = vim.fs.joinpath(root, 'doc', 'neovim-config-keymaps.txt')

-- Every plugin, whatever this machine turns off
package.preload['per_machine'] = function() DyNeo.used_full_plugins = true end
-- ... without installing the ones it has not got: their specs are read,
-- never loaded. `config.lazy` asks for `util.plugin` once lazy.nvim is on
-- the runtimepath and before `setup`, which is the moment to step in.
package.preload['util.plugin'] = function()
  package.preload['util.plugin'] = nil
  local lazy = require('lazy')
  local setup = lazy.setup
  lazy.setup = function(spec, opts)
    opts = vim.tbl_deep_extend('force', opts or {}, {
      install = { missing = false },
      checker = { enabled = false },
      change_detection = { enabled = false },
    })
    return setup(spec, opts)
  end
  return assert(loadfile(vim.fs.joinpath(root, 'lua/util/plugin.lua')))()
end

---@class DyKeymap
---@field lhs string
---@field modes string[]
---@field desc string
---@field scope string Where it applies: '' for everywhere

---@type DyKeymap[]
local maps = {}
--- Groups named by a `keys` entry with no right-hand side, `+ai` style
---@type table<string, string>
local key_groups = {}

--- `<Leader>` and friends written one way, so the same key compares equal
---@param lhs string
---@return string
local function normalize(lhs)
  lhs = lhs
    :gsub('<[Ll]eader>', '<leader>')
    :gsub('<[Ll]ocal[Ll]eader>', '<localleader>')
  return (lhs:gsub('^ ', '<leader>'))
end

---@param modes string|string[]|nil
---@return string[]
local function mode_list(modes)
  modes = type(modes) == 'table' and modes or { modes or 'n' }
  local ret = vim.deepcopy(modes)
  table.sort(ret)
  return ret
end

-- Mappings this tree makes outside of any `keys`
local set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  for level = 2, 12 do
    local info = debug.getinfo(level, 'S')
    if not info then break end
    local source = info.source:gsub('^@', '')
    local file = source:sub(1, #root) == root and source:sub(#root + 2) or nil
    -- lazy.nvim's own `keys` stubs come through `config.lazy`, and the
    -- wrappers of `util.plugin` pass on what they were given
    if
      file
      and file ~= 'lua/config/lazy.lua'
      and file ~= 'lua/util/plugin.lua'
    then
      if opts.desc and opts.desc ~= '' then
        table.insert(maps, {
          lhs = normalize(lhs),
          modes = mode_list(mode),
          desc = opts.desc,
          scope = opts.buffer and 'buffer' or '',
        })
      end
      break
    end
  end
  return set(mode, lhs, rhs, opts)
end

--- Keys of a lazy.nvim style list
---@param keys table[]
---@param scope fun(key: table): string
local function add_keys(keys, scope)
  local Keys = require('lazy.core.handler.keys')
  for _, key in pairs(Keys.resolve(keys)) do
    if key.rhs == '' and key.desc and vim.startswith(key.desc, '+') then
      key_groups[normalize(key.lhs)] = key.desc:sub(2)
    elseif key.desc and key.desc ~= '' then
      table.insert(maps, {
        lhs = normalize(key.lhs),
        modes = mode_list(key.mode),
        desc = key.desc,
        scope = scope(key),
      })
    end
  end
end

--- Group names by prefix, from which-key's `spec`
---@return table<string, string>
local function groups()
  local ret = {}
  local function walk(spec)
    if type(spec) ~= 'table' then return end
    if type(spec[1]) == 'string' and spec.group then
      local name = type(spec.group) == 'function' and spec.group() or spec.group
      ret[normalize(spec[1])] = name
    end
    for _, child in ipairs(spec) do
      walk(child)
    end
  end
  walk(require('util.plugin').opts('which-key.nvim').spec)
  return ret
end

local function collect()
  local Config = require('lazy.core.config')
  local Plugin = require('lazy.core.plugin')
  local names = vim.tbl_keys(Config.spec.plugins)
  table.sort(names)
  for _, name in ipairs(names) do
    local ok, keys =
      pcall(Plugin.values, Config.spec.plugins[name], 'keys', true)
    if ok and keys then
      add_keys(keys, function(key)
        local ft = key.ft
        if not ft then return '' end
        return 'ft: ' .. (type(ft) == 'table' and table.concat(ft, ', ') or ft)
      end)
    end
  end
  local servers = require('util.plugin').opts('nvim-lspconfig').servers or {}
  local server_names = vim.tbl_keys(servers)
  table.sort(server_names)
  for _, server in ipairs(server_names) do
    local opts = servers[server]
    if type(opts) == 'table' and opts.keys and opts.enabled ~= false then
      add_keys(
        opts.keys,
        function() return server == '*' and 'LSP' or 'LSP: ' .. server end
      )
    end
  end
end

--- One line per key and scope, its modes merged
---@return DyKeymap[]
local function merged()
  local by_key, order = {}, {}
  for _, map in ipairs(maps) do
    local id = map.lhs .. '\0' .. map.scope .. '\0' .. map.desc
    if by_key[id] then
      for _, mode in ipairs(map.modes) do
        if not vim.list_contains(by_key[id].modes, mode) then
          table.insert(by_key[id].modes, mode)
        end
      end
      table.sort(by_key[id].modes)
    else
      by_key[id] = vim.deepcopy(map)
      table.insert(order, id)
    end
  end
  return vim.tbl_map(function(id) return by_key[id] end, order)
end

--- The longest group prefix of `lhs`, other than `lhs` itself
---@param lhs string
---@param names table<string, string>
---@return string
local function section(lhs, names)
  local best = ''
  for prefix in pairs(names) do
    if
      #prefix > #best
      and #prefix < #lhs
      and lhs:sub(1, #prefix) == prefix
      and prefix ~= '<leader>'
    then
      best = prefix
    end
  end
  if best == '' and vim.startswith(lhs, '<leader>') then
    -- A `<leader>` key outside every group: one key on its own goes with the
    -- other single keys, a longer one under its first key
    local rest = lhs:sub(#'<leader>' + 1)
    local key = rest:match('^<[^>]+>') or rest:sub(1, 1)
    best = key == rest and '<leader>' or '<leader>' .. key
  end
  return best
end

---@param names table<string, string>
local function render(names)
  names = vim.tbl_extend('keep', names, key_groups)
  local sections = {} ---@type table<string, DyKeymap[]>
  for _, map in ipairs(merged()) do
    local prefix = section(map.lhs, names)
    sections[prefix] = sections[prefix] or {}
    table.insert(sections[prefix], map)
  end
  local prefixes = vim.tbl_keys(sections)
  table.sort(prefixes, function(a, b)
    if (a == '') ~= (b == '') then return b == '' end
    return a:lower() < b:lower() or (a:lower() == b:lower() and a < b)
  end)

  local lines = {
    '*neovim-config-keymaps.txt*   Every mapping of the configuration',
    '',
    ('%78s'):format('*neovim-config-keymaps*'),
    '',
    'Generated by `scripts/keymaps-doc.sh` from the configuration as it loads,',
    'with every plugin and language turned on; run it again after changing a',
    'mapping.  See |neovim-config-mappings| for the ones worth knowing first.',
    '',
    'Modes are those of |map-modes|.  The last column says where a mapping',
    'applies when it is not everywhere: `ft:` for the filetypes listed, `LSP`',
    'for buffers whose language server supports it, `buffer` for buffers a',
    'plugin sets it up in.  A filetype or server mapping takes over a global',
    'one of the same keys in those buffers.',
    '',
  }
  for _, prefix in ipairs(prefixes) do
    local title = prefix == '' and 'Other keys'
      or prefix == '<leader>' and '<leader>  single keys'
      or ('%s  %s'):format(prefix, names[prefix] or '')
    vim.list_extend(lines, { ('='):rep(78), vim.trim(title), '' })
    local entries = sections[prefix]
    table.sort(entries, function(a, b)
      if a.lhs ~= b.lhs then return a.lhs < b.lhs end
      return a.scope < b.scope
    end)
    for _, map in ipairs(entries) do
      local line = ('%-22s %-6s %s'):format(
        '`' .. map.lhs .. '`',
        table.concat(map.modes, ''),
        map.desc
      )
      if map.scope ~= '' then line = ('%s  (%s)'):format(line, map.scope) end
      table.insert(lines, line)
    end
    table.insert(lines, '')
  end
  table.insert(lines, 'vim:tw=78:ts=8:noet:ft=help:norl:')
  vim.fn.writefile(lines, output)
  io.stdout:write(
    ('keymaps-doc: %d mappings written to %s\n'):format(#merged(), output)
  )
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    -- which-key takes its `spec` apart as it sets up, so the groups are read
    -- before `VeryLazy` loads it
    local names = groups()
    -- Headless there is no UI to enter, so `VeryLazy` is fired by hand: it
    -- is what loads `config.keymaps`
    vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
    vim.defer_fn(function()
      local ok, err = pcall(function()
        collect()
        render(names)
      end)
      if not ok then
        io.stderr:write('keymaps-doc: ' .. tostring(err) .. '\n')
        vim.cmd('cquit')
      end
      vim.cmd('qall!')
    end, 1000)
  end,
})
