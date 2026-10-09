local Plugin = require('util.plugin')

local M = {}

---@type table<string, boolean>?
M._installed = nil
---@type table<string, boolean>
M._queries = {}

--- Installed parsers, read again from nvim-treesitter with `update`
---@param update boolean?
---@return table<string, boolean>
function M.get_installed(update)
  if update then
    M._installed, M._queries = {}, {}
    for _, lang in ipairs(require('nvim-treesitter').get_installed('parsers')) do
      M._installed[lang] = true
    end
  end
  return M._installed or {}
end

--- Whether `lang` has a `query` file (`folds`, `indents`, …)
---@param lang string
---@param query string
---@return boolean
function M.have_query(lang, query)
  local key = lang .. ':' .. query
  if M._queries[key] == nil then
    -- The files, not the parsed query: parsing `indents` or `textobjects`
    -- only to see that they exist costs as much as using them, and on
    -- every filetype opened
    M._queries[key] = #vim.treesitter.query.get_files(lang, query) > 0
  end
  return M._queries[key]
end

--- Whether the parser for a buffer or filetype is installed, and has
--- `query` when one is given
---@param what string|number|nil
---@param query? string
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == 'number' and vim.bo[what].filetype or what --[[@as string]]
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then return false end
  if query and not M.have_query(lang, query) then return false end
  return true
end

function M.foldexpr()
  return M.have(nil, 'folds') and vim.treesitter.foldexpr() or '0'
end

function M.indentexpr()
  return M.have(nil, 'indents') and require('nvim-treesitter').indentexpr()
    or -1
end

--- What nvim-treesitter `main` needs to build parsers, and whether all of
--- it is there
---@return boolean ok, table<string, boolean> health
function M.check()
  local function have(tool) return vim.fn.executable(tool) == 1 end
  local ret = {
    ['tree-sitter (CLI)'] = have('tree-sitter'),
    ['C compiler'] = vim.env.CC ~= nil or have('cc'),
    tar = have('tar'),
    curl = have('curl'),
  }
  local ok = true
  for _, v in pairs(ret) do
    ok = ok and v
  end
  return ok, ret
end

--- Run `cb` once the requirements are met, installing the tree-sitter CLI
--- through Mason when it is missing
---@param cb fun()
function M.build(cb)
  M.ensure_treesitter_cli(function(_, err)
    local ok, health = M.check()
    if ok then return cb() end
    local lines = { 'Unmet requirements for **nvim-treesitter** `main`:' }
    local keys = vim.tbl_keys(health) ---@type string[]
    table.sort(keys)
    for _, k in pairs(keys) do
      lines[#lines + 1] = ('- %s `%s`'):format(health[k] and '✅' or '❌', k)
    end
    vim.list_extend(lines, {
      '',
      'Run `:checkhealth nvim-treesitter` for more information.',
    })
    vim.list_extend(lines, err and { '', err } or {})
    Plugin.error(lines, { title = 'DyNeo Treesitter' })
  end)
end

---@param cb fun(ok: boolean, err?: string)
function M.ensure_treesitter_cli(cb)
  if vim.fn.executable('tree-sitter') == 1 then return cb(true) end
  if not pcall(require, 'mason') then
    return cb(false, '`mason.nvim` is not available to install it with.')
  end
  -- Loading mason puts its bin directory on PATH
  if vim.fn.executable('tree-sitter') == 1 then return cb(true) end

  local mr = require('mason-registry')
  mr.refresh(function()
    local ok, p = pcall(mr.get_package, 'tree-sitter-cli')
    if not ok then
      return cb(false, 'The Mason registry has no `tree-sitter-cli`.')
    end
    -- Installed, yet not found above: say so rather than leave the caller
    -- waiting on an answer that never comes
    if p:is_installed() then
      return cb(
        false,
        '`tree-sitter-cli` is installed by Mason but `tree-sitter` is not on PATH.'
      )
    end
    Plugin.info('Installing `tree-sitter-cli` with `mason.nvim`...')
    p:install(
      nil,
      vim.schedule_wrap(function(success)
        if success then
          Plugin.info('Installed `tree-sitter-cli` with `mason.nvim`.')
          cb(true)
        else
          cb(false, 'Failed to install `tree-sitter-cli` with `mason.nvim`.')
        end
      end)
    )
  end)
end

return M
