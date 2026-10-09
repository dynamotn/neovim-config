--- `:DyAi`: prompts sent with the code they are about, and one picker over
--- every AI action of the configuration
---
--- A prompt goes to `DyNeo.ai.target`, Avante or the CLI in sidekick. Both
--- are wrapped by `util.ai_guard`, and the buffer is checked here as well
--- before its text is put into a prompt, since what is sent is that text
--- rather than the buffer itself.
local M = {}

--- Subcommands other than the names of prompts
M.SUBCOMMANDS = { 'pick', 'prompts', 'commit', 'model' }

local notify = require('util.notify').titled('AI')

--- Hand `text` to the AI of `DyNeo.ai.target`, unless `bufnr`, the buffer
--- it was taken from, is kept from AI
---@param text string
---@param bufnr integer
---@param detail? string What was taken, for the audit log
---@return boolean sent
function M.send(text, bufnr, detail)
  local sensitive = require('util.sensitive')
  local audit = require('util.ai_audit')
  if sensitive.is_sensitive(bufnr) then
    audit.record_buffer('dyai', 'refused', bufnr, detail)
    notify(
      'Kept from AI: '
        .. table.concat(sensitive.reasons(bufnr), '; ')
        .. '. See :DyAiGuardCheck.',
      vim.log.levels.WARN
    )
    return false
  end
  local target = DyNeo.ai and DyNeo.ai.target or 'avante'
  if target == 'sidekick' then
    local lines = vim.tbl_map(
      function(line) return { { line } } end,
      vim.split(text, '\n', { plain = true })
    )
    -- `text` rather than `msg`, which sidekick would read as a template
    require('sidekick.cli').send({ text = lines, submit = true })
  elseif target == 'avante' then
    -- The prompt carries the code itself, so Avante's own copy of the
    -- selection is left out
    require('avante.api').ask({ question = text, without_selection = true })
  else
    notify(
      ('DyNeo.ai.target is %q, not avante or sidekick'):format(target),
      vim.log.levels.ERROR
    )
    return false
  end
  audit.record_buffer('dyai', 'sent', bufnr, detail)
  return true
end

--- Expand prompt `name` for the current buffer and send it
---@param name string
---@param range? integer[] First and last line of the selection
---@return boolean found
function M.run(name, range)
  local prompts = require('tools.ai.prompts')
  local prompt = prompts.get(name)
  if not prompt then
    notify(('No prompt named %q'):format(name), vim.log.levels.WARN)
    return false
  end
  ---@type DyAiContext
  local ctx = { bufnr = vim.api.nvim_get_current_buf(), range = range }
  local function go()
    local text, cut = prompts.expand(prompt, ctx)
    if cut then
      notify(
        ('The code was cut at %d KiB'):format(prompts.MAX_BYTES / 1024),
        vim.log.levels.WARN
      )
    end
    local detail = prompt.name
      .. (range and (' %d-%d'):format(range[1], range[2]) or '')
    M.send(text, ctx.bufnr, detail)
  end
  if not prompts.wants_input(prompt) then
    go()
    return true
  end
  vim.ui.input({ prompt = prompt.description .. ': ' }, function(input)
    if not input or input == '' then return end
    ctx.input = input
    go()
  end)
  return true
end

--- Pick a model for Avante's current provider. An ACP agent lists its models
--- only once the sidebar has connected to it, so the sidebar is opened first
--- and the list waited for.
function M.avante_model()
  local config = require('avante.config')
  -- `:AvanteModels` only knows Avante's own providers, and fails on an ACP
  -- one such as the default `claude-code`
  if not config.acp_providers[config.provider] then
    vim.cmd.AvanteModels()
    return
  end
  local avante = require('avante')
  if not avante.is_sidebar_open() then avante.open_sidebar({}) end
  local tries = 150
  local function try()
    local sidebar = avante.get(false)
    local client = sidebar and sidebar.acp_client
    local session = sidebar
      and sidebar.chat_history
      and sidebar.chat_history.acp_session_id
    if client and client.config_options and session then
      require('avante.api').select_acp_model()
    elseif client and session and client:is_ready() then
      -- Connected, with no choice to offer: waiting longer changes nothing
      notify('The ACP agent offers no model to pick', vim.log.levels.WARN)
    elseif tries > 0 then
      tries = tries - 1
      vim.defer_fn(try, 100)
    else
      notify('The ACP agent did not connect', vim.log.levels.WARN)
    end
  end
  try()
end

--- States of Avante's sidebar while a request is under way
M.BUSY_STATES = {
  generating = true,
  thinking = true,
  ['tool calling'] = true,
  searching = true,
  compacting = true,
}

--- Avante's provider and model, and whether the sidebar of this tab is busy,
--- for the statusline. Nil until Avante has loaded; only tables are read, so
--- it is cheap enough for every redraw.
---@return string? text `provider` or `provider/model`
---@return boolean busy
function M.status()
  local config = package.loaded['avante.config']
  if not config or not config.provider then return nil, false end
  local provider = config.provider
  local settings = (config.providers or {})[provider]
  -- An ACP agent picks its model itself, once connected
  local model = not (config.acp_providers or {})[provider]
    and type(settings) == 'table'
    and settings.model
  local avante = package.loaded['avante']
  local sidebar = avante
    and avante.sidebars
    and avante.sidebars[vim.api.nvim_get_current_tabpage()]
  local busy = sidebar ~= nil and M.BUSY_STATES[sidebar.current_state] == true
  return model and (provider .. '/' .. model) or provider, busy
end

---@class DyAiAction
---@field group string
---@field name string
---@field key? string Mapping that does the same, shown beside it
---@field run fun()

--- The actions of the picker other than the prompts
---@type DyAiAction[]
M.ACTIONS = {
  {
    group = 'Avante',
    name = 'Toggle chat',
    key = '<leader>avc',
    run = function() require('avante').toggle() end,
  },
  {
    group = 'Avante',
    name = 'New chat',
    key = '<leader>avC',
    run = function() vim.cmd.AvanteChatNew() end,
  },
  {
    group = 'Avante',
    name = 'Select model',
    key = '<leader>avm',
    run = function() M.avante_model() end,
  },
  {
    group = 'Avante',
    name = 'Switch provider',
    key = '<leader>avP',
    run = function() vim.cmd.AvanteSwitchProvider() end,
  },
  {
    group = 'Avante',
    name = 'History',
    key = '<leader>avh',
    run = function() vim.cmd.AvanteHistory() end,
  },
  {
    group = 'Sidekick',
    name = 'Toggle CLI',
    key = '<leader>aa',
    run = function() require('sidekick.cli').toggle() end,
  },
  {
    group = 'Sidekick',
    name = 'Select CLI',
    key = '<leader>as',
    run = function() require('sidekick.cli').select() end,
  },
  {
    group = 'Claude',
    name = 'Toggle Claude Code',
    key = '<leader>acc',
    run = function() vim.cmd.ClaudeCode() end,
  },
  {
    group = 'Claude',
    name = 'Continue Claude Code',
    key = '<leader>acC',
    run = function() vim.cmd('ClaudeCode --continue') end,
  },
  {
    group = 'MCP',
    name = 'MCP Hub',
    key = '<leader>M',
    run = function() vim.cmd.MCPHub() end,
  },
  {
    group = 'Git',
    name = 'Write commit message',
    key = '<localleader>g',
    run = function() require('tools.ai.commit').write() end,
  },
  {
    group = 'Guard',
    name = 'Why is this buffer kept from AI',
    key = '<leader>ka',
    run = function() vim.cmd.DyAiGuardCheck() end,
  },
  {
    group = 'Guard',
    name = 'Handover log',
    key = '<leader>kL',
    run = function() vim.cmd.DyAiGuardLog() end,
  },
}

--- Picker items of every prompt, then of `M.ACTIONS` unless `prompts_only`
---@param range? integer[]
---@param prompts_only? boolean
---@return table[]
function M.items(range, prompts_only)
  local items = {}
  for _, prompt in ipairs(require('tools.ai.prompts').list()) do
    table.insert(items, {
      text = prompt.name .. ' ' .. prompt.description,
      group = prompt.project and 'Project' or 'Prompt',
      name = prompt.name,
      detail = prompt.description,
      preview = { text = prompt.body, ft = 'markdown' },
      run = function() M.run(prompt.name, range) end,
    })
  end
  if prompts_only then return items end
  for _, action in ipairs(M.ACTIONS) do
    table.insert(items, {
      text = action.group .. ' ' .. action.name,
      group = action.group,
      name = action.name,
      detail = action.key or '',
      preview = { text = ('# %s\n\n%s'):format(action.name, action.key or '') },
      run = action.run,
    })
  end
  return items
end

--- Every AI action in one picker; a prompt is sent with `range`
---@param range? integer[]
---@param prompts_only? boolean
function M.pick(range, prompts_only)
  local items = M.items(range, prompts_only)
  local width = 0
  for _, item in ipairs(items) do
    width = math.max(width, vim.api.nvim_strwidth(item.group))
  end
  Snacks.picker.pick({
    title = prompts_only and 'AI Prompts' or 'AI',
    items = items,
    format = function(item)
      return {
        {
          item.group .. (' '):rep(width - vim.api.nvim_strwidth(item.group)),
          'SnacksPickerComment',
        },
        { '  ' },
        { item.name, 'SnacksPickerLabel' },
        { '  ' },
        { item.detail, 'SnacksPickerComment' },
      }
    end,
    preview = 'preview',
    confirm = function(picker, item)
      picker:close()
      -- Once the picker is gone, so a prompt reads the buffer it came from
      if item then vim.schedule(item.run) end
    end,
  })
end

--- Handle `:DyAi`
---@param args { fargs: string[], range: integer, line1: integer, line2: integer }
function M.command(args)
  local range = args.range > 0 and { args.line1, args.line2 } or nil
  local sub = args.fargs[1]
  if not sub or sub == 'pick' then
    M.pick(range)
  elseif sub == 'prompts' then
    M.pick(range, true)
  elseif sub == 'commit' then
    require('tools.ai.commit').write()
  elseif sub == 'model' then
    M.avante_model()
  else
    M.run(sub, range)
  end
end

--- Completion of `:DyAi`: the subcommands, then every prompt's name
---@param lead string
---@return string[]
function M.complete(lead)
  local words = vim.deepcopy(M.SUBCOMMANDS)
  for _, prompt in ipairs(require('tools.ai.prompts').list()) do
    table.insert(words, prompt.name)
  end
  return vim.tbl_filter(
    function(word) return word:find(lead, 1, true) == 1 end,
    words
  )
end

return M
