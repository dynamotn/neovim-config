--- Kubernetes from the manifest being edited
---
--- The round trip from a manifest to the cluster -- does this differ from
--- what runs, would the API server take it, what does the chart render to --
--- is a terminal away, with the file name typed again and the context to
--- remember. Here it starts from the buffer: a plain manifest goes to
--- `kubectl -f`, a `kustomization.yaml` to `kubectl -k`, and a file of a Helm
--- chart is rendered with `helm template` first, the values file being edited
--- taken as its values.
---
--- Applying asks first, naming the context it would apply to. What a render
--- or a diff shows can hold the data of a Secret, so those buffers are kept
--- from every AI integration.
local M = {}

--- Milliseconds a `kubectl` or `helm` command may take
M.TIMEOUT = 2 * 60 * 1000

---@class DyKubeTarget
---@field kind 'manifest'|'kustomize'|'helm'
---@field file string The file the buffer holds
---@field dir string Where the commands run
---@field chart? string The chart directory, for `helm`
---@field values? string The values file being edited, for `helm`
---@field template? string The template being edited, relative to the chart

--- What a file is, as far as getting it to a cluster goes
---@param file string
---@return DyKubeTarget
function M.target(file)
  local dir = vim.fs.dirname(file)
  local name = vim.fs.basename(file)
  if name:match('^[Kk]ustomization%.ya?ml$') then
    return { kind = 'kustomize', file = file, dir = dir }
  end
  local chart = vim.fs.root(file, 'Chart.yaml')
  if chart then
    local target = { kind = 'helm', file = file, dir = chart, chart = chart }
    local relative = file:sub(#chart + 2)
    if name:match('^values.*%.ya?ml$') then
      target.values = file
    elseif relative:match('^templates/') then
      target.template = relative
    end
    return target
  end
  return { kind = 'manifest', file = file, dir = dir }
end

--- The `helm template` that renders `target`
---@param target DyKubeTarget
---@return string[]
function M.render_command(target)
  local command = {
    'helm',
    'template',
    vim.fs.basename(target.chart),
    target.chart,
  }
  if target.values then
    vim.list_extend(command, { '--values', target.values })
  end
  if target.template then
    vim.list_extend(command, { '--show-only', target.template })
  end
  return command
end

--- `kubectl <verb>` for `target`, reading the render from stdin for a chart
---@param verb string[] `{ 'diff' }`, `{ 'apply', '--dry-run=server' }`, ...
---@param target DyKubeTarget
---@return string[]
function M.kubectl_command(verb, target)
  local command = vim.list_extend({ 'kubectl' }, verb)
  if target.kind == 'kustomize' then
    return vim.list_extend(command, { '-k', target.dir })
  elseif target.kind == 'helm' then
    return vim.list_extend(command, { '-f', '-' })
  end
  return vim.list_extend(command, { '-f', target.file })
end

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Kubernetes' })
end

--- Run `command` in `dir`, and hand its result over on the main loop
---@param command string[]
---@param dir string
---@param stdin? string
---@param on_done fun(result: vim.SystemCompleted)
local function run(command, dir, stdin, on_done)
  if vim.fn.executable(command[1]) ~= 1 then
    return notify(command[1] .. ' is not installed', vim.log.levels.ERROR)
  end
  vim.system(
    command,
    { cwd = dir, text = true, stdin = stdin, timeout = M.TIMEOUT },
    function(result)
      vim.schedule(function() on_done(result) end)
    end
  )
end

--- Hand `on_rendered` what `target` sends to the cluster: the rendered
--- chart for `helm`, nothing to send on stdin otherwise
---@param target DyKubeTarget
---@param on_rendered fun(stdin: string?)
local function rendered(target, on_rendered)
  if target.kind ~= 'helm' then return on_rendered(nil) end
  run(M.render_command(target), target.dir, nil, function(result)
    if result.code ~= 0 then
      return notify(
        'helm template failed:\n' .. vim.trim(result.stderr or ''),
        vim.log.levels.ERROR
      )
    end
    on_rendered(result.stdout)
  end)
end

--- Show `text` in a tab of its own, kept from every AI integration
---@param text string
---@param filetype string
---@param name string
local function show(text, filetype, name)
  vim.cmd('tabnew')
  local bufnr = vim.api.nvim_get_current_buf()
  require('util.sensitive').mark(
    bufnr,
    'Kubernetes output, which can hold Secret data'
  )
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  -- A second diff of the same file is open beside the first one
  pcall(vim.api.nvim_buf_set_name, bufnr, name)
  vim.api.nvim_buf_set_lines(
    bufnr,
    0,
    -1,
    false,
    vim.split(text, '\n', { trimempty = true })
  )
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = filetype
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = bufnr, nowait = true })
end

--- The target of the current buffer, or nil when it holds no file
---
--- kubectl and helm read the file on disk: a buffer with changes not yet
--- written would be judged, or applied, by what it no longer says.
---@return DyKubeTarget?
local function current()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    notify('This buffer holds no file', vim.log.levels.WARN)
    return nil
  end
  if vim.bo.modified then
    notify(
      'Write the buffer first: kubectl reads the file on disk',
      vim.log.levels.WARN
    )
    return nil
  end
  return M.target(file)
end

--- What would change in the cluster
function M.diff()
  local target = current()
  if not target then return end
  rendered(target, function(stdin)
    run(
      M.kubectl_command({ 'diff' }, target),
      target.dir,
      stdin,
      function(result)
        -- `kubectl diff` exits 1 when there are differences, above it on error
        if result.code == 0 then
          return notify('No differences with the cluster')
        end
        if result.code ~= 1 then
          return notify(
            'kubectl diff failed:\n' .. vim.trim(result.stderr or ''),
            vim.log.levels.ERROR
          )
        end
        show(
          result.stdout or '',
          'diff',
          'kube://diff/' .. vim.fs.basename(target.file)
        )
      end
    )
  end)
end

--- Whether the API server would take it, without changing anything
function M.dry_run()
  local target = current()
  if not target then return end
  rendered(target, function(stdin)
    run(
      M.kubectl_command({ 'apply', '--dry-run=server' }, target),
      target.dir,
      stdin,
      function(result)
        local out =
          vim.trim((result.stdout or '') .. '\n' .. (result.stderr or ''))
        notify(
          out,
          result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        )
      end
    )
  end)
end

--- The current context, or nil
---@return string?
function M.current_context()
  if vim.fn.executable('kubectl') ~= 1 then return nil end
  local result = vim
    .system({ 'kubectl', 'config', 'current-context' }, { text = true })
    :wait(5000)
  local context = result.code == 0 and vim.trim(result.stdout or '') or ''
  return context ~= '' and context or nil
end

--- The namespace the current context puts an object without one in
---@return string
function M.current_namespace()
  local result = vim
    .system({
      'kubectl',
      'config',
      'view',
      '--minify',
      '-o',
      'jsonpath={..namespace}',
    }, { text = true })
    :wait(5000)
  local namespace = result.code == 0 and vim.trim(result.stdout or '') or ''
  return namespace ~= '' and namespace or 'default'
end

--- Apply it, once told to, to the context named -- and to that one only,
--- however the current context changes in the meantime
function M.apply()
  local target = current()
  if not target then return end
  if target.kind == 'helm' then
    -- `kubectl apply` of a render creates the objects outside of Helm, under
    -- a release name guessed from the directory: the next `helm upgrade`
    -- then fails on their ownership
    return notify(
      'A chart is applied with `helm upgrade`, not kubectl',
      vim.log.levels.WARN
    )
  end
  local context = M.current_context()
  if not context then
    return notify('No current kubectl context', vim.log.levels.ERROR)
  end
  local answer = vim.fn.confirm(
    ('Apply %s to context %s, namespace %s by default?'):format(
      vim.fs.basename(target.file),
      context,
      M.current_namespace()
    ),
    '&Apply\n&Cancel',
    2
  )
  if answer ~= 1 then return end
  rendered(target, function(stdin)
    run(
      M.kubectl_command({ '--context=' .. context, 'apply' }, target),
      target.dir,
      stdin,
      function(result)
        local out =
          vim.trim((result.stdout or '') .. '\n' .. (result.stderr or ''))
        notify(
          out,
          result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        )
      end
    )
  end)
end

--- What the chart or the kustomization renders to
function M.render()
  local target = current()
  if not target then return end
  local command = target.kind == 'helm' and M.render_command(target)
    or target.kind == 'kustomize' and { 'kubectl', 'kustomize', target.dir }
  if not command then
    return notify('A plain manifest renders to itself', vim.log.levels.WARN)
  end
  run(command, target.dir, nil, function(result)
    if result.code ~= 0 then
      return notify(
        command[1] .. ' failed:\n' .. vim.trim(result.stderr or ''),
        vim.log.levels.ERROR
      )
    end
    show(
      result.stdout or '',
      'yaml',
      'kube://render/' .. vim.fs.basename(target.file)
    )
  end)
end

--- Pick among the lines `list` prints, then run `apply` with the one picked
---@param list string[]
---@param prompt string
---@param apply fun(choice: string): string[]
---@param done string What to say once it is done, `%s` the choice
local function pick(list, prompt, apply, done)
  run(list, vim.uv.cwd() --[[@as string]], nil, function(result)
    if result.code ~= 0 then
      return notify(vim.trim(result.stderr or ''), vim.log.levels.ERROR)
    end
    local choices = vim.split(result.stdout or '', '\n', { trimempty = true })
    choices = vim.tbl_map(
      function(c) return (c:gsub('^namespace/', '')) end,
      choices
    )
    vim.ui.select(choices, { prompt = prompt }, function(choice)
      if not choice then return end
      run(apply(choice), vim.uv.cwd() --[[@as string]], nil, function(set)
        if set.code ~= 0 then
          return notify(vim.trim(set.stderr or ''), vim.log.levels.ERROR)
        end
        notify(done:format(choice))
      end)
    end)
  end)
end

--- Switch the current context
function M.context()
  pick(
    { 'kubectl', 'config', 'get-contexts', '-o', 'name' },
    'Context',
    function(choice) return { 'kubectl', 'config', 'use-context', choice } end,
    'Context is now %s'
  )
end

--- Switch the namespace of the current context
function M.namespace()
  pick(
    { 'kubectl', 'get', 'namespaces', '-o', 'name' },
    'Namespace',
    function(choice)
      return {
        'kubectl',
        'config',
        'set-context',
        '--current',
        '--namespace=' .. choice,
      }
    end,
    'Namespace is now %s'
  )
end

M.SUBCOMMANDS = {
  diff = M.diff,
  dryrun = M.dry_run,
  apply = M.apply,
  render = M.render,
  context = M.context,
  namespace = M.namespace,
}

--- `:DyKube {subcommand}`
---@param args { fargs: string[] }
function M.command(args)
  local sub = args.fargs[1] or 'diff'
  local fn = M.SUBCOMMANDS[sub]
  if not fn then
    return notify('Unknown subcommand: ' .. sub, vim.log.levels.ERROR)
  end
  fn()
end

--- Whether `bufnr` holds something a cluster would take: a manifest with an
--- `apiVersion` and a `kind`, a kustomization, or a file of a chart
---@param bufnr integer
---@return boolean
function M.is_kube(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == '' then return false end
  local target = M.target(file)
  if target.kind ~= 'manifest' then return true end
  return M.is_manifest(bufnr)
end

--- Whether `bufnr` holds a Kubernetes object itself, `apiVersion` and
--- `kind` at the top level -- not a chart's values or a kustomization
---@param bufnr integer
---@return boolean
function M.is_manifest(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local api, kind = false, false
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
    api = api or line:match('^apiVersion:') ~= nil
    kind = kind or line:match('^kind:') ~= nil
    if api and kind then return true end
  end
  return false
end

--- The mappings of a buffer that holds something for a cluster
---@param bufnr integer
function M.attach(bufnr)
  if not M.is_kube(bufnr) then return end
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
  end
  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<localleader>k', group = 'kubernetes', buffer = bufnr } })
  end
  map('<localleader>kd', M.diff, 'Diff With Cluster')
  map('<localleader>kv', M.dry_run, 'Validate (Server Dry Run)')
  map('<localleader>ka', M.apply, 'Apply')
  map('<localleader>kr', M.render, 'Render (Helm, Kustomize)')
  map('<localleader>kc', M.context, 'Switch Context')
  map('<localleader>kn', M.namespace, 'Switch Namespace')
end

return M
