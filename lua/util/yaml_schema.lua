-- Schema detection and selection for yaml-language-server.
--
-- SchemaStore globs are handed to the server as schema associations, one
-- priority below `yaml.schemas`. That leaves `yaml.schemas` free for a schema
-- chosen for a single buffer, which then wins over whatever glob matched the
-- file instead of being merged with it through `allOf`.
--
-- On top of that, buffers the server finds no schema for are matched on their
-- content (Kubernetes manifests, cloud-init), and a picker sets a schema for
-- the buffer or writes it as a `# yaml-language-server: $schema=` modeline.
local M = {}

local CRDS_CATALOG =
  'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main'
local CRDS_TREE =
  'https://api.github.com/repos/datreeio/CRDs-catalog/git/trees/main?recursive=1'
local KUBERNETES_SCHEMAS =
  'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master'
local CLOUD_INIT =
  'https://raw.githubusercontent.com/canonical/cloud-init/main/cloudinit/config/schemas/schema-cloud-config-v1.json'
-- The keyword yamlls expands into the schema of every built-in kind, and then
-- narrows down per document by `apiVersion`/`kind`, CRDs included
local KUBERNETES = 'kubernetes'
local CRDS_CACHE = vim.fn.stdpath('cache') .. '/yaml-schema/crds-catalog.json'
local CRDS_TTL = 7 * 24 * 60 * 60
local MODELINE = '# yaml-language-server: $schema='

---@class util.yaml_schema.Schema
---@field uri string URL, path, or the `kubernetes` keyword
---@field name string
---@field description? string
---@field source string where the schema comes from, shown in the picker
---@field file_match? string[]

---@class util.yaml_schema.Choice
---@field uri string
---@field name string
---@field auto boolean set by content detection, not by the user
---@field pattern string glob added to `yaml.schemas[uri]` for this buffer

---@type string[]?
local crds
---@type table<string, string>? SchemaStore names by URL
local names

local function get_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr, name = 'yamlls' })[1]
end

--- Lines of the buffer, up to `max`
local function get_lines(bufnr, max)
  return vim.api.nvim_buf_get_lines(bufnr, 0, max or -1, false)
end

local function is_separator(line)
  return line:match('^%-%-%-') and (#line == 3 or line:sub(4, 4):match('%s'))
end

--- A path turned into a glob that only matches itself
local function to_pattern(path) return (path:gsub('[%[%]{}()*?!+@\\]', '\\%0')) end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'YAML schema' })
end

--- SchemaStore catalog, when the plugin is loaded
---@return {name: string, description?: string, url: string, fileMatch?: string[]}[]
local function schemastore()
  local ok, store = pcall(require, 'schemastore')
  return ok and store.json.load().schemas or {}
end

-- CRDs catalog ---------------------------------------------------------------

local function read_crds_cache()
  local stat = vim.uv.fs_stat(CRDS_CACHE)
  if not stat then return nil, true end
  local fd = io.open(CRDS_CACHE, 'r')
  if not fd then return nil, true end
  local ok, paths = pcall(vim.json.decode, fd:read('*a'))
  fd:close()
  if not ok or type(paths) ~= 'table' then return nil, true end
  return paths, os.time() - stat.mtime.sec > CRDS_TTL
end

--- Load the list of CRD schemas of the datreeio CRDs catalog, from the cache
--- or, once a week, from GitHub
---@param callback fun(paths: string[]?)
local function load_crds(callback)
  if crds then return callback(crds) end
  local cached, stale = read_crds_cache()
  if not stale then
    crds = cached
    return callback(crds)
  end
  if vim.fn.executable('curl') == 0 then return callback(cached) end
  notify('Fetching the CRDs catalog…')
  vim.system(
    {
      'curl',
      '-fsSL',
      '--max-time',
      '20',
      '-H',
      'Accept: application/vnd.github+json',
      CRDS_TREE,
    },
    { text = true },
    vim.schedule_wrap(function(out)
      local ok, tree = pcall(vim.json.decode, out.stdout or '')
      if out.code ~= 0 or not ok or type(tree.tree) ~= 'table' then
        notify('Cannot fetch the CRDs catalog', vim.log.levels.WARN)
        crds = cached
        return callback(crds)
      end
      local paths = {}
      for _, node in ipairs(tree.tree) do
        if node.path:match('^[^/]+/[^/]+%.json$') then
          table.insert(paths, node.path)
        end
      end
      vim.fn.mkdir(vim.fs.dirname(CRDS_CACHE), 'p')
      local fd = io.open(CRDS_CACHE, 'w')
      if fd then
        fd:write(vim.json.encode(paths))
        fd:close()
      end
      crds = paths
      callback(crds)
    end)
  )
end

-- Kubernetes -----------------------------------------------------------------

--- `apiVersion` and `kind` of the YAML document at `row` (1-based)
---@return {group: string, version: string, kind: string}?
local function get_gvk(bufnr, row)
  local lines = get_lines(bufnr)
  local first, last = 1, #lines
  for i = row, 1, -1 do
    if is_separator(lines[i]) then
      first = i + 1
      break
    end
  end
  for i = row + 1, #lines do
    if is_separator(lines[i]) then
      last = i - 1
      break
    end
  end
  local api_version, kind
  for i = first, last do
    api_version = api_version
      or lines[i]:match('^apiVersion:%s*["\']?([^"\'%s#]+)')
    kind = kind or lines[i]:match('^kind:%s*["\']?([^"\'%s#]+)')
  end
  if not api_version or not kind then return nil end
  local group, version = api_version:match('^(.*)/(.*)$')
  return { group = group or '', version = version or api_version, kind = kind }
end

--- Schema URL of a single Kubernetes kind: from the CRDs catalog when it
--- holds the kind, from kubernetes-json-schema otherwise
local function kubernetes_uri(client, gvk)
  local crd = ('%s/%s_%s.json'):format(
    gvk.group:lower(),
    gvk.kind:lower(),
    gvk.version:lower()
  )
  local builtin = gvk.group == ''
    or not gvk.group:find('.', 1, true)
    or vim.endswith(gvk.group, '.k8s.io')
  if
    gvk.group ~= ''
    and (crds and vim.list_contains(crds, crd) or not crds and not builtin)
  then
    return CRDS_CATALOG .. '/' .. crd
  end
  local version = vim.tbl_get(client.settings, 'yaml', 'kubernetesVersion')
  local dir = (version and 'v' .. version:gsub('^v', '') or 'master')
    .. '-standalone-strict'
  local group = gvk.group == '' and '' or '-' .. gvk.group:match('^[^.]+')
  return ('%s/%s/%s%s-%s.json'):format(
    KUBERNETES_SCHEMAS,
    dir,
    gvk.kind:lower(),
    group,
    gvk.version:lower()
  )
end

-- Detection ------------------------------------------------------------------

--- Content matchers, tried in order on buffers of the plain `yaml` filetype
---@type {name: string, uri: string, match: fun(lines: string[]): boolean}[]
M.matchers = {
  {
    name = 'cloud-init',
    uri = CLOUD_INIT,
    match = function(lines) return (lines[1] or ''):match('^#cloud%-config') end,
  },
  {
    name = 'Kubernetes',
    uri = KUBERNETES,
    match = function(lines)
      local api_version, kind = false, false
      for _, line in ipairs(lines) do
        api_version = api_version or line:match('^apiVersion:%s*%S') ~= nil
        kind = kind or line:match('^kind:%s*%S') ~= nil
        if api_version and kind then return true end
      end
      return false
    end,
  },
}

local function match(bufnr)
  if vim.bo[bufnr].filetype ~= 'yaml' then return nil end
  local lines = get_lines(bufnr, 500)
  for _, matcher in ipairs(M.matchers) do
    if matcher.match(lines) then return matcher end
  end
end

--- Point `yaml.schemas` of the server at `uri` for this buffer only
---@param bufnr integer
---@param schema {uri: string, name: string}
---@param auto? boolean
function M.set(bufnr, schema, auto)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  local client = get_client(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if not client or path == '' then
    return notify('No yamlls attached to a file here', vim.log.levels.WARN)
  end
  M.reset(bufnr, true)
  local pattern = to_pattern(path)
  local yaml = client.settings.yaml or {}
  client.settings.yaml = yaml
  yaml.schemas = yaml.schemas or {}
  local patterns = yaml.schemas[schema.uri] or {}
  if type(patterns) == 'string' then patterns = { patterns } end
  table.insert(patterns, pattern)
  yaml.schemas[schema.uri] = patterns
  vim.b[bufnr].yaml_schema_choice = {
    uri = schema.uri,
    name = schema.name,
    auto = auto or false,
    pattern = pattern,
  }
  client:notify(
    'workspace/didChangeConfiguration',
    { settings = client.settings }
  )
end

--- Drop the schema set for this buffer, and let detection run again
---@param bufnr integer
---@param silent? boolean do not tell the server
function M.reset(bufnr, silent)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  ---@type util.yaml_schema.Choice?
  local choice = vim.b[bufnr].yaml_schema_choice
  if not choice then return end
  vim.b[bufnr].yaml_schema_choice = nil
  for _, client in ipairs(vim.lsp.get_clients({ name = 'yamlls' })) do
    local schemas = vim.tbl_get(client.settings, 'yaml', 'schemas') or {}
    local patterns = schemas[choice.uri]
    if type(patterns) == 'table' then
      patterns = vim.tbl_filter(
        function(p) return p ~= choice.pattern end,
        patterns
      )
      schemas[choice.uri] = #patterns > 0 and patterns or nil
    elseif patterns == choice.pattern then
      schemas[choice.uri] = nil
    end
    if not silent then
      client:notify(
        'workspace/didChangeConfiguration',
        { settings = client.settings }
      )
    end
  end
end

--- Match the buffer on its content when the server has no schema for it
---@param bufnr integer
function M.detect(bufnr)
  local client = get_client(bufnr)
  ---@type util.yaml_schema.Choice?
  local choice = vim.b[bufnr].yaml_schema_choice
  if not client or choice and not choice.auto then return end
  local matched = match(bufnr)
  if choice and matched and choice.uri == matched.uri then return end
  if choice then M.reset(bufnr) end
  if not matched then return end
  client:request(
    ---@diagnostic disable-next-line: param-type-mismatch
    'yaml/get/jsonSchema',
    { vim.uri_from_bufnr(bufnr) },
    function(err, result)
      if err or (result and #result > 0) then return end
      if vim.api.nvim_buf_is_valid(bufnr) then M.set(bufnr, matched, true) end
    end,
    bufnr
  )
end

-- Modeline -------------------------------------------------------------------

--- Write `schema` as a modeline at the top of the YAML document under the
--- cursor, replacing the one already there
---@param bufnr integer
---@param schema {uri: string}
function M.insert_modeline(bufnr, schema)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local uri = schema.uri
  if uri == KUBERNETES then
    local gvk = get_gvk(bufnr, row)
    local client = get_client(bufnr)
    if not gvk or not client then
      return notify(
        'No `apiVersion` and `kind` in this document',
        vim.log.levels.WARN
      )
    end
    uri = kubernetes_uri(client, gvk)
  end
  local lines = get_lines(bufnr)
  local first = 1
  for i = row, 1, -1 do
    if is_separator(lines[i]) then
      first = i + 1
      break
    end
  end
  -- An existing modeline in the comments that open the document
  for i = first, #lines do
    if not lines[i]:match('^%s*#') then break end
    if lines[i]:match('^%s*#%s*yaml%-language%-server:') then
      vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { MODELINE .. uri })
      return
    end
  end
  vim.api.nvim_buf_set_lines(bufnr, first - 1, first - 1, false, {
    MODELINE .. uri,
  })
end

-- Picker ---------------------------------------------------------------------

local function preview(schema)
  local text = { '# ' .. schema.name, '', '`' .. schema.uri .. '`', '' }
  if schema.description then
    vim.list_extend(text, vim.split(schema.description, '\n'))
    table.insert(text, '')
  end
  if schema.file_match and #schema.file_match > 0 then
    table.insert(text, '## Files')
    table.insert(text, '')
    for _, glob in ipairs(schema.file_match) do
      table.insert(text, '- `' .. glob .. '`')
    end
  end
  return { text = table.concat(text, '\n'), ft = 'markdown' }
end

--- Every schema to choose from, the ones in use first
---@param in_use {uri: string, name?: string, description?: string}[]
---@param known {uri: string, name?: string, description?: string}[]
---@return util.yaml_schema.Schema[]
local function collect(in_use, known)
  local schemas, seen = {}, {}
  local function add(schema)
    if seen[schema.uri] then return end
    seen[schema.uri] = true
    schema.name = schema.name or M.get_name(schema.uri)
    table.insert(schemas, schema)
  end
  for _, s in ipairs(in_use) do
    add({
      uri = s.uri,
      name = s.name,
      description = s.description,
      source = 'in use',
    })
  end
  add({
    uri = KUBERNETES,
    name = 'Kubernetes',
    description = 'Built-in kinds and CRDs, picked per document by `apiVersion` and `kind`',
    source = 'kubernetes',
  })
  add({ uri = CLOUD_INIT, name = 'cloud-init', source = 'cloud-init' })
  for _, s in ipairs(schemastore()) do
    local file_match = s.fileMatch
    add({
      uri = s.url,
      name = s.name,
      description = s.description,
      source = 'schemastore',
      file_match = type(file_match) == 'string' and { file_match }
        or file_match,
    })
  end
  -- Schemas the server knows of besides SchemaStore: `yaml.schemas`
  for _, s in ipairs(known) do
    add({
      uri = s.uri,
      name = s.name,
      description = s.description,
      source = 'yamlls',
    })
  end
  for _, path in ipairs(crds or {}) do
    local group, kind, version = path:match('^([^/]+)/([^_]+)_(.+)%.json$')
    if group then
      add({
        uri = CRDS_CATALOG .. '/' .. path,
        name = ('%s (%s/%s)'):format(kind, group, version),
        source = 'crds-catalog',
      })
    end
  end
  return schemas
end

local function open(bufnr, schemas, modeline)
  ---@type util.yaml_schema.Choice?
  local choice = vim.b[bufnr].yaml_schema_choice
  local function apply(schema)
    if not schema then return end
    if schema.reset then return M.reset(bufnr) end
    if modeline then return M.insert_modeline(bufnr, schema) end
    M.set(bufnr, schema)
  end
  if choice and not modeline then
    table.insert(schemas, 1, {
      uri = '',
      name = 'Reset to auto-detection',
      description = 'Currently: ' .. choice.name,
      source = 'reset',
      reset = true,
      preview = {
        text = 'Drop `' .. choice.name .. '` and detect the schema again',
        ft = 'markdown',
      },
    })
  end
  local title = modeline and 'YAML schema modeline' or 'YAML schema'
  if not package.loaded['snacks'] then
    return vim.ui.select(schemas, {
      prompt = title,
      format_item = function(s) return ('%s [%s]'):format(s.name, s.source) end,
    }, apply)
  end
  local width = 0
  for _, s in ipairs(schemas) do
    width = math.max(width, vim.api.nvim_strwidth(s.name))
  end
  Snacks.picker.pick({
    title = title,
    items = vim.tbl_map(
      function(s)
        return vim.tbl_extend('force', s, {
          text = s.name .. ' ' .. s.source .. ' ' .. s.uri,
          preview = s.preview or preview(s),
        })
      end,
      schemas
    ),
    format = function(item)
      local active = choice and item.uri == choice.uri
      return {
        { active and '● ' or '  ', 'SnacksPickerSpecial' },
        {
          item.name .. (' '):rep(width - vim.api.nvim_strwidth(item.name)),
          'SnacksPickerLabel',
        },
        { '  ' },
        { item.source, 'SnacksPickerComment' },
      }
    end,
    preview = 'preview',
    confirm = function(picker, item)
      picker:close()
      apply(item)
    end,
    actions = {
      yaml_modeline = function(picker, item)
        picker:close()
        if item and not item.reset then M.insert_modeline(bufnr, item) end
      end,
    },
    win = {
      input = {
        keys = {
          ['<M-m>'] = {
            'yaml_modeline',
            mode = { 'n', 'i' },
            desc = 'Insert as modeline',
          },
        },
      },
    },
  })
end

--- Pick a schema for the buffer, or with `modeline`, one to write as a
--- modeline in the document under the cursor
---@param bufnr? integer
---@param modeline? boolean
function M.select(bufnr, modeline)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf()
    or bufnr
  local client = get_client(bufnr)
  if not client then
    return notify('No yamlls attached to this buffer', vim.log.levels.WARN)
  end
  local uri = vim.uri_from_bufnr(bufnr)
  load_crds(function()
    client:request(
      ---@diagnostic disable-next-line: param-type-mismatch
      'yaml/get/all/jsonSchemas',
      { uri },
      function(_, result)
        local in_use, known = {}, {}
        for _, s in ipairs(result or {}) do
          table.insert(s.usedForCurrentFile and in_use or known, s)
        end
        open(bufnr, collect(in_use, known), modeline)
      end,
      bufnr
    )
  end)
end

-- Server ---------------------------------------------------------------------

--- Human name of a schema URI
---@param uri string
---@return string
function M.get_name(uri)
  if uri == KUBERNETES then return 'Kubernetes' end
  if uri == CLOUD_INIT then return 'cloud-init' end
  if not names then
    names = {}
    for _, schema in ipairs(schemastore()) do
      names[schema.url] = schema.name
    end
  end
  if names[uri] then return names[uri] end
  if vim.startswith(uri, KUBERNETES_SCHEMAS) then
    local file = uri:match('([^/]+)%.json$')
    return file == 'all' and 'Kubernetes' or 'Kubernetes ' .. file
  end
  local group, kind, version =
    uri:match('/CRDs%-catalog/[^/]+/([^/]+)/([^_/]+)_([^/]+)%.json$')
  if group then return ('%s (%s/%s)'):format(kind, group, version) end
  return 'Custom'
end

local group = vim.api.nvim_create_augroup('util.yaml_schema', { clear = true })

--- `on_init` of yamlls: hand SchemaStore to the server and start detection
---@param client vim.lsp.Client
function M.on_init(client)
  local ok, store = pcall(require, 'schemastore')
  if ok then client:notify('json/schemaAssociations', store.yaml.schemas()) end
  vim.api.nvim_clear_autocmds({ group = group })
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(ev)
      local attached = vim.lsp.get_client_by_id(ev.data.client_id)
      if not attached or attached.name ~= 'yamlls' then return end
      vim.api.nvim_buf_create_user_command(ev.buf, 'YamlSchema', function(cmd)
        if cmd.args == 'reset' then return M.reset(ev.buf) end
        M.select(ev.buf, cmd.args == 'modeline')
      end, {
        nargs = '?',
        complete = function() return { 'modeline', 'reset' } end,
        desc = 'Pick a YAML schema for the buffer',
      })
      M.detect(ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = function(ev) M.detect(ev.buf) end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev) M.reset(ev.buf) end,
  })
end

return M
