--- Markdown runbooks whose code blocks run where they are written
---
--- A runbook is a Markdown file of steps, each a fenced block of commands --
--- `kubectl`, `helm`, `psql`, a curl against a health endpoint. Running one
--- used to mean copying it into a terminal and its output back into the
--- notes. Here the block under the cursor runs as it is, from the directory
--- of the file, and what it printed lands right under it in an `output`
--- fence, replaced on the next run, so the file is the record of what was
--- done and what came back.
---
--- A block that deletes, destroys or reaches for root asks first: a runbook
--- is read in a hurry, and `<localleader>r` is a short key.
local M = {}

--- The command a block of each language runs with, its code appended
---@type table<string, string[]>
M.RUNNERS = {
  sh = { 'sh', '-c' },
  shell = { 'bash', '-c' },
  bash = { 'bash', '-c' },
  console = { 'bash', '-c' },
  zsh = { 'zsh', '-c' },
  fish = { 'fish', '-c' },
  python = { 'python3', '-c' },
  py = { 'python3', '-c' },
  javascript = { 'node', '-e' },
  js = { 'node', '-e' },
}

--- Milliseconds a block may run before it is stopped
M.TIMEOUT = 5 * 60 * 1000

--- What a block is asked about before it runs, by Lua pattern
M.DANGEROUS = {
  '%f[%w]sudo%f[%W]',
  '%f[%w]rm%s+%-%a*[rRf]',
  '%f[%w]mkfs',
  '%f[%w]dd%s+if=',
  'kubectl%s+delete',
  'kubectl%s+drain',
  'helm%s+uninstall',
  'terraform%s+destroy',
  'tofu%s+destroy',
  'terragrunt%s+destroy',
  'git%s+push%s+.*%-%-force',
  'git%s+push%s+.*%-f%f[%W]',
  'git%s+reset%s+%-%-hard',
  '[Dd][Rr][Oo][Pp]%s+[Tt][Aa][Bb][Ll][Ee]',
  '[Dd][Rr][Oo][Pp]%s+[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]',
}

---@class DyRunbookBlock
---@field open integer Line of the opening fence, 1-based
---@field close integer Line of the closing fence
---@field lang string
---@field code string[]
---@field indent string

--- The fenced block `row` is in, fences included
---@param lines string[]
---@param row integer 1-based
---@return DyRunbookBlock?
function M.block_at(lines, row)
  local open
  local fence, indent, lang
  for index, line in ipairs(lines) do
    if not open then
      local i, f, info = line:match('^(%s*)(```+)%s*([^%s`]*)')
      if not f then
        i, f, info = line:match('^(%s*)(~~~+)%s*(%S*)')
      end
      if f then
        open, fence, indent, lang = index, f, i, info:lower()
      end
    else
      local f = line:match('^%s*([`~]+)%s*$')
      if f and f:sub(1, 1) == fence:sub(1, 1) and #f >= #fence then
        if row >= open and row <= index then
          return {
            open = open,
            close = index,
            lang = lang,
            code = vim.list_slice(lines, open + 1, index - 1),
            indent = indent,
          }
        end
        open = nil
      end
    end
    if not open and index >= row then return nil end
  end
  return nil
end

--- Every fenced block of `lines` whose language has a runner, in order
---@param lines string[]
---@return DyRunbookBlock[]
function M.blocks(lines)
  local found, row = {}, 1
  while row <= #lines do
    local block = M.block_at(lines, row)
    if block then
      if M.RUNNERS[block.lang] then table.insert(found, block) end
      row = block.close + 1
    else
      row = row + 1
    end
  end
  return found
end

--- The code of `block` as it runs: a `console` block keeps only its `$ `
--- lines, without the prompt, since the rest is the output it once printed
---@param block DyRunbookBlock
---@return string
function M.code_of(block)
  if block.lang ~= 'console' then return table.concat(block.code, '\n') end
  local commands = {}
  for _, line in ipairs(block.code) do
    local command = line:match('^%s*%$%s?(.*)$')
    if command then table.insert(commands, command) end
  end
  return table.concat(commands, '\n')
end

--- The first dangerous pattern `code` matches, or nil
---@param code string
---@return string?
function M.danger(code)
  for _, pattern in ipairs(M.DANGEROUS) do
    local found = code:match(pattern)
    if found then return found end
  end
end

--- The `output` fence that follows the block closing at `close`, if any:
--- right after it, or after one blank line
---@param lines string[]
---@param close integer
---@return integer? first
---@return integer? last
function M.output_after(lines, close)
  local first = close + 1
  if lines[first] and vim.trim(lines[first]) == '' then first = first + 1 end
  local fence = lines[first] and lines[first]:match('^%s*(```+)%s*output%s*$')
  if not fence then return nil end
  for index = first + 1, #lines do
    local f = lines[index]:match('^%s*(`+)%s*$')
    if f and #f >= #fence then return close + 1, index end
  end
  return nil
end

--- The lines of an `output` fence holding `output`, indented like its block
---
--- The fence is longer than any run of backticks the output starts a line
--- with, so a command printing Markdown cannot close it early.
---@param output string[]
---@param indent string
---@return string[]
function M.fence(output, indent)
  local longest = 2
  for _, line in ipairs(output) do
    local run = line:match('^%s*(`+)')
    if run then longest = math.max(longest, #run) end
  end
  local fence = ('`'):rep(longest + 1)
  local lines = { '', indent .. fence .. 'output' }
  for _, line in ipairs(output) do
    table.insert(lines, line == '' and '' or indent .. line)
  end
  table.insert(lines, indent .. fence)
  return lines
end

--- What a finished run shows: its output, then how it ended unless well
---@param result vim.SystemCompleted
---@return string[]
function M.render(result)
  -- stdout, then stderr: `vim.system` keeps them apart, so how they
  -- interleaved is lost, but neither is
  local output = {}
  for _, stream in ipairs({ result.stdout or '', result.stderr or '' }) do
    local text = stream:gsub('\n+$', '')
    if text ~= '' then
      vim.list_extend(output, vim.split(text, '\n', { plain = true }))
    end
  end
  if result.signal and result.signal ~= 0 then
    table.insert(output, ('[stopped: signal %d]'):format(result.signal))
  elseif result.code ~= 0 then
    table.insert(output, ('[exit %d]'):format(result.code))
  end
  if #output == 0 then output = { '[no output]' } end
  return output
end

local ns = vim.api.nvim_create_namespace('dy_runbook')

--- The processes running per buffer, to stop them
---@type table<integer, vim.SystemObj[]>
local running = {}

--- Put `output` under the block whose closing fence the extmark `mark`
--- follows, replacing what an earlier run left there
---@param bufnr integer
---@param mark integer
---@param indent string
---@param output string[]
local function place(bufnr, mark, indent, output)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local position = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, mark, {})
  vim.api.nvim_buf_del_extmark(bufnr, ns, mark)
  if not position[1] then return end
  local close = position[1] + 1
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local first, last = M.output_after(lines, close)
  local start, finish = close, close
  if first and last then
    start, finish = first - 1, last
  end
  vim.api.nvim_buf_set_lines(
    bufnr,
    start,
    finish,
    false,
    M.fence(output, indent)
  )
end

--- Run `block` of `bufnr`, and call `on_done` with whether it went well
---@param bufnr integer
---@param block DyRunbookBlock
---@param on_done? fun(ok: boolean)
function M.run_block(bufnr, block, on_done)
  on_done = on_done or function() end
  local runner = M.RUNNERS[block.lang]
  if not runner then
    vim.notify(
      ('No runner for a `%s` block'):format(block.lang),
      vim.log.levels.WARN,
      { title = 'Runbook' }
    )
    return on_done(false)
  end
  if vim.fn.executable(runner[1]) ~= 1 then
    vim.notify(
      runner[1] .. ' is not installed',
      vim.log.levels.ERROR,
      { title = 'Runbook' }
    )
    return on_done(false)
  end

  local code = M.code_of(block)
  local danger = M.danger(code)
  if danger then
    local answer = vim.fn.confirm(
      ('This block runs `%s`. Run it?'):format(danger),
      '&Run\n&Cancel',
      2
    )
    if answer ~= 1 then return on_done(false) end
  end

  local mark = vim.api.nvim_buf_set_extmark(bufnr, ns, block.close - 1, 0, {
    virt_text = { { ' running…', 'DiagnosticInfo' } },
    virt_text_pos = 'eol',
  })
  local name = vim.api.nvim_buf_get_name(bufnr)
  local cwd = name ~= '' and vim.fs.dirname(name) or vim.uv.cwd()
  local command = vim.list_extend(vim.deepcopy(runner), { code })

  local ok, process = pcall(vim.system, command, {
    cwd = cwd,
    text = true,
    timeout = M.TIMEOUT,
  }, function(result)
    vim.schedule(function()
      running[bufnr] = vim.tbl_filter(
        function(p) return p.pid ~= result.pid end,
        running[bufnr] or {}
      )
      place(bufnr, mark, block.indent, M.render(result))
      on_done(result.code == 0 and (result.signal or 0) == 0)
    end)
  end)
  if not ok then
    vim.api.nvim_buf_del_extmark(bufnr, ns, mark)
    vim.notify(tostring(process), vim.log.levels.ERROR, { title = 'Runbook' })
    return on_done(false)
  end
  running[bufnr] = running[bufnr] or {}
  table.insert(running[bufnr], process)
end

--- Run the block under the cursor
function M.run()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local block = M.block_at(lines, vim.api.nvim_win_get_cursor(0)[1])
  if not block then
    return vim.notify(
      'The cursor is in no code block',
      vim.log.levels.WARN,
      { title = 'Runbook' }
    )
  end
  M.run_block(bufnr, block)
end

--- Run every block that has a runner, top to bottom, one after the other,
--- stopping at the first that fails
---
--- The blocks are found again before each one runs, since the output of the
--- one before has moved everything below it.
function M.run_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local index = 0
  local function next_block()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    index = index + 1
    local blocks = M.blocks(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    local block = blocks[index]
    if not block then
      return vim.notify(
        ('Ran %d blocks'):format(index - 1),
        vim.log.levels.INFO,
        { title = 'Runbook' }
      )
    end
    M.run_block(bufnr, block, function(ok)
      if ok then return next_block() end
      vim.notify(
        ('Stopped at block %d, on line %d'):format(index, block.open),
        vim.log.levels.WARN,
        { title = 'Runbook' }
      )
    end)
  end
  next_block()
end

--- Remove every `output` fence of the buffer
function M.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  -- From the bottom up, so the line numbers above stay where they are
  local blocks = M.blocks(lines)
  for index = #blocks, 1, -1 do
    local first, last = M.output_after(lines, blocks[index].close)
    if first and last then
      vim.api.nvim_buf_set_lines(bufnr, first - 1, last, false, {})
    end
  end
end

--- Stop whatever the buffer is running; its output so far is shown as usual
function M.stop()
  local bufnr = vim.api.nvim_get_current_buf()
  for _, process in ipairs(running[bufnr] or {}) do
    process:kill('sigterm')
  end
end

--- `:Runbook [run|all|clear|stop]`
---@param args { fargs: string[] }
function M.command(args)
  local sub = args.fargs[1] or 'run'
  local actions =
    { run = M.run, all = M.run_all, clear = M.clear, stop = M.stop }
  if not actions[sub] then
    return vim.notify(
      'Unknown subcommand: ' .. sub,
      vim.log.levels.ERROR,
      { title = 'Runbook' }
    )
  end
  actions[sub]()
end

--- The mappings of a Markdown buffer
---@param bufnr integer
function M.attach(bufnr)
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map('<localleader>r', M.run, 'Run Block (Runbook)')
  map('<localleader>R', M.run_all, 'Run All Blocks (Runbook)')
  map('<localleader>x', M.clear, 'Clear Outputs (Runbook)')
  map('<localleader>s', M.stop, 'Stop Running (Runbook)')
end

return M
