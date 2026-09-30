-- Check that every tool named in `config.languages` actually exists.
--
-- A tool carries up to three different names: the module conform or nvim-lint
-- knows it by, the binary it runs, and the Mason package that installs it.
-- When they drift apart nothing breaks loudly -- the linter simply never runs,
-- or Mason is asked for a package that is not there -- so they are checked
-- here instead.
--
--   nvim --clean --headless -l scripts/validate-tools.lua
--
-- Exits non-zero, and prints one line per problem, when something is off.

local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local data = vim.fn.stdpath('data')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(data .. '/lazy/conform.nvim')
vim.opt.runtimepath:append(data .. '/lazy/nvim-lint')
vim.opt.runtimepath:append(data .. '/lazy/nvim-lspconfig')

---@return table<string, true>
local function mason_packages()
  local packages = {}
  local registry = data
    .. '/mason/registries/github/mason-org/mason-registry/registry.json'
  if vim.fn.filereadable(registry) == 1 then
    for _, package in
      ipairs(vim.json.decode(table.concat(vim.fn.readfile(registry), '\n')))
    do
      packages[package.name] = true
    end
  end
  -- the repo's own `lua:tools.mason-registry`, wired up in tool_manager.lua
  for name in pairs(require('tools.mason-registry')) do
    packages[name] = true
  end
  return packages
end

local packages = mason_packages()
local languages = require('config.languages')
local names = vim.tbl_keys(languages)
table.sort(names)

local problems = {}
---@param language string
---@param kind string
---@param tool string
---@param message string
local function report(language, kind, tool, message)
  table.insert(
    problems,
    string.format('%-14s %-10s %-24s %s', language, kind, tool, message)
  )
end

-- Some formatters conform does not ship are defined by the config itself.
-- Rather than keep a second list of them here, run the conform spec the way
-- lazy.nvim would and ask it what it defined.
---@return table<string, true>
local function config_formatters()
  local defined = {}
  local ok, spec = pcall(dofile, root .. '/lua/plugins/executor/formatting.lua')
  if not ok then return defined end
  package.loaded['lazyvim.util'] = { on_load = function() end }
  local opts = { formatters = {}, formatters_by_ft = {} }
  if pcall(spec[1].opts, nil, opts) then
    for formatter in pairs(opts.formatters) do
      defined[formatter] = true
    end
  end
  return defined
end

local local_formatters = config_formatters()

local modules = {
  formatters = 'conform.formatters.',
  linters = 'lint.linters.',
}

for _, name in ipairs(names) do
  local language = languages[name]
  for kind, module in pairs(modules) do
    for _, tool in ipairs(language[kind] or {}) do
      local tool_name = type(tool) == 'string' and tool or tool[1]
      local mason = type(tool) == 'table' and tool.mason or nil
      if
        not local_formatters[tool_name]
        and not pcall(require, module .. tool_name)
      then
        report(name, kind, tool_name, 'no such ' .. kind:sub(1, -2))
      end
      if not (mason and mason.enabled == false) then
        local package = (mason and mason.package)
          or (type(tool) == 'table' and tool.command)
          or tool_name
        if not packages[package] then
          report(
            name,
            kind,
            tool_name,
            string.format('no Mason package `%s`', package)
          )
        end
      end
    end
  end

  for _, server in ipairs(language.lsp_servers or {}) do
    local server_name = type(server) == 'string' and server or server[1]
    -- a server the repo configures itself lives in `lsp/`
    if
      vim.fn.filereadable(string.format('%s/lsp/%s.lua', root, server_name))
        == 0
      and #vim.api.nvim_get_runtime_file(
          'lsp/' .. server_name .. '.lua',
          false
        )
        == 0
    then
      report(name, 'lsp', server_name, 'no such server config')
    end
  end
end

if vim.tbl_isempty(problems) then
  print('config.languages: every tool resolves')
  os.exit(0)
end

for _, problem in ipairs(problems) do
  print(problem)
end
os.exit(1)
