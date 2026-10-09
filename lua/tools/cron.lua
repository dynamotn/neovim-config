--- Cron schedules read out where they are written
---
--- `*/15 9-17 * * 1-5` says when it runs only to someone who reads cron
--- fluently and knows the day of the week. Each schedule of a crontab, of a
--- Kubernetes CronJob and of a GitHub Actions workflow gets, at the end of
--- its line, what it means and when it runs next; one that is no schedule
--- at all, or one that never runs, is a diagnostic.
---
--- The schedule is parsed here, in Lua: nothing runs per keystroke but the
--- scan of the buffer, and that is capped at `M.MAX_LINES`.
local M = {}

local notify = require('util.notify').titled('Cron')

--- Namespace of the text at the end of each line
M.NAMESPACE = vim.api.nvim_create_namespace('dy_cron')
--- Namespace of the diagnostics
M.DIAGNOSTICS = vim.api.nvim_create_namespace('dy_cron_diagnostics')
--- Lines of a buffer read for schedules
M.MAX_LINES = 5000
--- Next runs shown on the line
M.RUNS = 3
--- Milliseconds of quiet before an edited buffer is read again
M.DEBOUNCE = 200
--- Years searched for a next run, so `0 0 30 2 *` ends as never
M.YEARS = 5

---@class DyCronField
---@field unit string
---@field min integer
---@field max integer
---@field names? string[]
---@field first? integer The value of `names[1]`

---@type DyCronField[]
local FIELDS = {
  { unit = 'minute', min = 0, max = 59 },
  { unit = 'hour', min = 0, max = 23 },
  { unit = 'day', min = 1, max = 31 },
  {
    unit = 'month',
    min = 1,
    max = 12,
    first = 1,
    names = {
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    },
  },
  {
    unit = 'day of the week',
    min = 0,
    max = 7,
    first = 0,
    names = { 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' },
  },
}

--- What each macro stands for
local MACROS = {
  yearly = '0 0 1 1 *',
  annually = '0 0 1 1 *',
  monthly = '0 0 1 * *',
  weekly = '0 0 * * 0',
  daily = '0 0 * * *',
  midnight = '0 0 * * *',
  hourly = '0 * * * *',
}

---@class DyCronSchedule
---@field fields string[] The five fields as written, a macro expanded
---@field sets table<integer, boolean>[] The values each field matches
---@field any boolean[] Whether each field starts with `*`
---@field macro? string The macro written, without its `@`
---@field reboot? boolean `@reboot`, which has no time
---@field tz? string From a `CRON_TZ=` or `TZ=` prefix

--- The number a field value stands for, or nil
---@param text string
---@param field DyCronField
---@return integer?
local function number(text, field)
  local n = tonumber(text)
  if n and text:match('^%d+$') then return n end
  for i, name in ipairs(field.names or {}) do
    if text:lower() == name:lower() then return i - 1 + field.first end
  end
end

--- The values one field matches
---@param text string
---@param field DyCronField
---@return table<integer, boolean>? set
---@return string? err
local function parse_field(text, field)
  local set = {}
  for part in vim.gsplit(text, ',', { plain = true }) do
    local range, step = part:match('^(.+)/(%d+)$')
    range = range or part
    step = tonumber(step) or 1
    if step < 1 then return nil, ('a step of 0 in `%s`'):format(text) end
    local lo, hi
    if range == '*' then
      lo, hi = field.min, field.max
    else
      local a, b = range:match('^(%w+)%-(%w+)$')
      if a then
        lo, hi = number(a, field), number(b, field)
      else
        lo = number(range, field)
        -- `5/15` is from 5 to the end, every 15
        hi = part:find('/', 1, true) and field.max or lo
      end
    end
    if not lo or not hi then
      return nil, ('`%s` is no %s'):format(part, field.unit)
    end
    if lo < field.min or hi > field.max or lo > hi then
      return nil,
        ('`%s` is outside the %s range %d-%d'):format(
          part,
          field.unit,
          field.min,
          field.max
        )
    end
    for v = lo, hi, step do
      set[v] = true
    end
  end
  return set
end

--- A schedule, or nil and why it is none
---@param expr string
---@return DyCronSchedule? schedule
---@return string? err
function M.parse(expr)
  expr = vim.trim(expr)
  local tz, rest = expr:match('^CRON_TZ=(%S+)%s+(.*)$')
  if not tz then
    tz, rest = expr:match('^TZ=(%S+)%s+(.*)$')
  end
  expr = rest or expr
  local macro
  if expr:match('^@') then
    macro = expr:sub(2):lower()
    if macro == 'reboot' then
      return { fields = {}, sets = {}, any = {}, reboot = true, macro = macro }
    end
    if not MACROS[macro] then return nil, ('`%s` is no macro'):format(expr) end
    expr = MACROS[macro]
  end
  local fields = vim.split(expr, '%s+', { trimempty = true })
  if #fields ~= 5 then
    return nil, ('%d fields where cron takes five'):format(#fields)
  end
  local schedule =
    { fields = fields, sets = {}, any = {}, macro = macro, tz = tz }
  for i, field in ipairs(FIELDS) do
    local set, err = parse_field(fields[i], field)
    if not set then return nil, err end
    schedule.sets[i] = set
    schedule.any[i] = fields[i]:sub(1, 1) == '*'
  end
  -- Sunday is both 0 and 7
  if schedule.sets[5][7] then
    schedule.sets[5][0] = true
    schedule.sets[5][7] = nil
  end
  return schedule
end

--- One part of a field, in words: `9-17` as `9–17`, `1-5` of the days of
--- the week as `Mon–Fri`, `*/15` as `every 15 minutes`
---@param part string
---@param i integer Which field
---@return string
local function part_text(part, i)
  local field = FIELDS[i]
  local function name(text)
    local n = number(text, field)
    if not n or not field.names then return text end
    return field.names[(n - field.first) % #field.names + 1]
  end
  local range, step = part:match('^(.+)/(%d+)$')
  local span = (range or part):gsub('%w+', name):gsub('%-', '–')
  if not step then return span end
  local every = ('every %s %ss'):format(step, field.unit)
  if range == '*' then return every end
  return every .. ' from ' .. span
end

--- A whole field in words
---@param text string
---@param i integer
---@return string
local function field_text(text, i)
  local parts = {}
  for part in vim.gsplit(text, ',', { plain = true }) do
    parts[#parts + 1] = part_text(part, i)
  end
  return table.concat(parts, ', ')
end

--- Whether a field is one plain value
---@param text string
---@return boolean
local function single(text) return text:match('^%w+$') ~= nil end

--- The schedule in words: `every 15 minutes, hours 9–17, on Mon–Fri`
---@param schedule DyCronSchedule
---@return string
function M.describe(schedule)
  if schedule.reboot then return 'at boot' end
  local f = schedule.fields
  local time
  local hours = vim.split(f[2], ',', { plain = true })
  local all_single = vim.iter(hours):all(single)
  if f[1] == '*' and f[2] == '*' then
    time = 'every minute'
  elseif single(f[1]) and all_single and #hours <= 4 then
    time = 'at '
      .. table.concat(
        vim.tbl_map(
          function(h) return ('%02d:%02d'):format(tonumber(h), tonumber(f[1])) end,
          hours
        ),
        ', '
      )
  else
    if f[1] == '*' then
      time = 'every minute'
    elseif f[1]:match('^%*/%d+$') then
      time = field_text(f[1], 1)
    elseif single(f[1]) then
      time = ('at minute %s'):format(f[1])
    else
      time = 'at minutes ' .. field_text(f[1], 1)
    end
    if f[2] == '*' then
      if single(f[1]) then time = time .. ' of every hour' end
    elseif f[2]:match('^%*/%d+$') then
      time = time .. ', ' .. field_text(f[2], 2)
    else
      time = time .. ', hours ' .. field_text(f[2], 2)
    end
  end
  local days = {}
  if not schedule.any[3] then
    days[#days + 1] = 'on day ' .. field_text(f[3], 3) .. ' of the month'
  end
  if not schedule.any[5] then days[#days + 1] = 'on ' .. field_text(f[5], 5) end
  local out = time
  if #days > 0 then out = out .. ' ' .. table.concat(days, ' or ') end
  if not schedule.any[4] then out = out .. ' in ' .. field_text(f[4], 4) end
  return out
end

--- Days since 1970-01-01 of a date of the proleptic Gregorian calendar
---@param y integer
---@param m integer
---@param d integer
---@return integer
local function days_from_civil(y, m, d)
  y = m <= 2 and y - 1 or y
  local era = math.floor(y / 400)
  local yoe = y - era * 400
  local doy = math.floor((153 * ((m + 9) % 12) + 2) / 5) + d - 1
  local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
  return era * 146097 + doe - 719468
end

--- Seconds since the epoch of a UTC time, which `os.time` cannot give
---@param y integer
---@param m integer
---@param d integer
---@param hour integer
---@param min integer
---@return integer
function M.utc_time(y, m, d, hour, min)
  return days_from_civil(y, m, d) * 86400 + hour * 3600 + min * 60
end

---@param y integer
---@param m integer
---@return integer
local function days_in_month(y, m)
  if m == 2 then
    local leap = (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0
    return leap and 29 or 28
  end
  return ({ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 })[m]
end

--- Whether a day matches: when the day of the month and the day of the
--- week are both given, either one is enough, as every cron has it
---@param schedule DyCronSchedule
---@param d integer
---@param wday integer 0 for Sunday
---@return boolean
local function day_matches(schedule, d, wday)
  local dom = schedule.sets[3][d] == true
  local dow = schedule.sets[5][wday] == true
  if schedule.any[3] or schedule.any[5] then return dom and dow end
  return dom or dow
end

--- The next `count` times `schedule` runs after `from`, in seconds since the
--- epoch, the fields read as UTC or as local time
---@param schedule DyCronSchedule
---@param from integer
---@param count integer
---@param utc boolean
---@return integer[]
function M.next_runs(schedule, from, count, utc)
  local runs = {}
  if schedule.reboot then return runs end
  local start = os.date(utc and '!*t' or '*t', from) --[[@as osdate]]
  local y, m, d = start.year, start.month, start.day
  for _ = 1, 366 * M.YEARS do
    if schedule.sets[4][m] then
      local days = days_from_civil(y, m, d)
      if day_matches(schedule, d, (days + 4) % 7) then
        for h = 0, 23 do
          if schedule.sets[2][h] then
            for mi = 0, 59 do
              if schedule.sets[1][mi] then
                local t
                if utc then
                  t = M.utc_time(y, m, d, h, mi)
                else
                  t = os.time({
                    year = y,
                    month = m,
                    day = d,
                    hour = h,
                    min = mi,
                    sec = 0,
                  })
                  -- A time the clocks skip over does not happen
                  if os.date('*t', t).hour ~= h then t = nil end
                end
                if t and t > from then
                  runs[#runs + 1] = t
                  if #runs == count then return runs end
                end
              end
            end
          end
        end
      end
    end
    d = d + 1
    if d > days_in_month(y, m) then
      d, m = 1, m + 1
      if m > 12 then
        m, y = 1, y + 1
      end
    end
  end
  return runs
end

---@class DyCronEntry
---@field row integer 0-based
---@field expr string
---@field zone string `local`, `UTC` or the name of a time zone
---@field github? boolean Run by GitHub Actions

--- Strip a YAML scalar of a trailing comment and its quotes
---@param value string
---@return string
local function scalar(value)
  value = value:gsub('%s+#.*$', '')
  return vim.trim(value):match('^["\'](.*)["\']$') or vim.trim(value)
end

--- The schedules of `lines`, read as a crontab or as YAML
---@param lines string[]
---@param filetype string
---@return DyCronEntry[]
function M.find(lines, filetype)
  local entries = {}
  if filetype == 'crontab' then
    local zone = 'local'
    for i, line in ipairs(lines) do
      local tz = line:match('^%s*CRON_TZ%s*=%s*["\']?([^"\'%s]+)')
      if tz then
        zone = tz
      elseif
        not line:match('^%s*#')
        and not line:match('^%s*$')
        and not line:match('^%s*[%a_][%w_]*%s*=')
      then
        local expr = line:match('^%s*(@%S+)')
        if not expr then
          local fields = {}
          for word in line:gmatch('%S+') do
            fields[#fields + 1] = word
            if #fields == 5 then break end
          end
          expr = table.concat(fields, ' ')
        end
        entries[#entries + 1] = { row = i - 1, expr = expr, zone = zone }
      end
    end
    return entries
  end

  local github = filetype == 'yaml.gh-action'
  -- The time zone of a CronJob is in its own document
  local first = 1
  local function document_zone(row)
    for i = first, #lines do
      if i > row and lines[i]:match('^%-%-%-') then break end
      local tz = lines[i]:match('^%s*timeZone:%s*(.-)%s*$')
      if tz then return scalar(tz) end
    end
    return 'UTC'
  end
  local scheduled = false
  for _, line in ipairs(lines) do
    if
      line:match('^kind:%s*["\']?CronJob')
      or line:match('^kind:%s*["\']?CronWorkflow')
    then
      scheduled = true
    end
  end
  for i, line in ipairs(lines) do
    if line:match('^%-%-%-') then first = i + 1 end
    local value = github and line:match('^%s*%-?%s*cron:%s*(.+)$')
      or (scheduled and line:match('^%s*schedule:%s*(.+)$'))
    if value then
      local expr = scalar(value)
      if expr ~= '' then
        entries[#entries + 1] = {
          row = i - 1,
          expr = expr,
          zone = github and 'UTC' or document_zone(i),
          github = github or nil,
        }
      end
    end
  end
  return entries
end

--- Whether the next runs of a zone can be worked out here
---@param zone string
---@return boolean? utc nil when they cannot
local function utc_of(zone)
  if zone == 'local' then return false end
  if zone == 'UTC' or zone == 'Etc/UTC' or zone == 'GMT' then return true end
end

--- What one schedule says, and the diagnostics it raises
---@param entry DyCronEntry
---@param now integer
---@return string? text
---@return { message: string, severity: integer }[]
function M.explain(entry, now)
  local problems = {}
  local schedule, err = M.parse(entry.expr)
  if not schedule then
    return nil,
      {
        {
          message = 'Not a cron schedule: ' .. err,
          severity = vim.diagnostic.severity.ERROR,
        },
      }
  end
  local text = M.describe(schedule)
  local zone = schedule.tz or entry.zone
  if entry.github and schedule.macro then
    problems[#problems + 1] = {
      message = 'GitHub Actions takes five fields, not a macro',
      severity = vim.diagnostic.severity.ERROR,
    }
  end
  if schedule.reboot then return text, problems end
  local utc = utc_of(zone)
  if utc == nil then return ('%s (%s)'):format(text, zone), problems end
  local runs = M.next_runs(schedule, now, M.RUNS, utc)
  if #runs == 0 then
    problems[#problems + 1] = {
      message = ('Never runs: no date in the next %d years matches'):format(
        M.YEARS
      ),
      severity = vim.diagnostic.severity.WARN,
    }
    return text, problems
  end
  if entry.github and runs[2] and runs[2] - runs[1] < 300 then
    problems[#problems + 1] = {
      message = 'GitHub runs a schedule at most every 5 minutes',
      severity = vim.diagnostic.severity.WARN,
    }
  end
  local times = vim.tbl_map(
    function(t) return os.date((utc and '!' or '') .. '%a %d %b %H:%M', t) end,
    runs
  )
  return ('%s · next %s %s'):format(
    text,
    table.concat(times, ', '),
    utc and 'UTC' or 'local'
  ),
    problems
end

--- Read the schedules of `bufnr` again
---@param bufnr integer
function M.refresh(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, M.NAMESPACE, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, M.MAX_LINES, false)
  local now = os.time()
  local diagnostics = {}
  for _, entry in ipairs(M.find(lines, vim.bo[bufnr].filetype)) do
    local text, problems = M.explain(entry, now)
    if text then
      vim.api.nvim_buf_set_extmark(bufnr, M.NAMESPACE, entry.row, 0, {
        virt_text = { { '⏱ ' .. text, 'Comment' } },
        virt_text_pos = 'eol',
      })
    end
    for _, problem in ipairs(problems) do
      diagnostics[#diagnostics + 1] = {
        lnum = entry.row,
        col = 0,
        message = problem.message,
        severity = problem.severity,
        source = 'cron',
      }
    end
  end
  vim.diagnostic.set(M.DIAGNOSTICS, bufnr, diagnostics)
end

--- The pending refresh of each buffer
---@type table<integer, uv.uv_timer_t>
local timers = {}

--- Read the schedules of `bufnr` now, and again whenever it changes
---@param bufnr integer
function M.attach(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  -- Cleared each time, so reopening the buffer adds no second handler
  local group =
    vim.api.nvim_create_augroup('dy_cron_' .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      local timer = timers[bufnr] or vim.uv.new_timer()
      timers[bufnr] = timer
      timer:stop()
      timer:start(
        M.DEBOUNCE,
        0,
        vim.schedule_wrap(function() M.refresh(bufnr) end)
      )
    end,
  })
  -- The next runs move on with the clock
  vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
    group = group,
    buffer = bufnr,
    callback = function() M.refresh(bufnr) end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = bufnr,
    callback = function()
      if timers[bufnr] then
        timers[bufnr]:stop()
        timers[bufnr]:close()
        timers[bufnr] = nil
      end
    end,
  })
  M.refresh(bufnr)
end

--- `:DyCron [{expr}]`: the schedule given, or the one on the cursor line, in
--- words with its next runs
---@param args { args: string }
function M.command(args)
  local entry
  if args.args ~= '' then
    entry = { row = 0, expr = args.args, zone = 'local' }
  else
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local lines = vim.api.nvim_buf_get_lines(0, 0, M.MAX_LINES, false)
    for _, found in ipairs(M.find(lines, vim.bo.filetype)) do
      if found.row == row then entry = found end
    end
    M.attach(0)
  end
  if not entry then
    return notify('No cron schedule on this line', vim.log.levels.WARN)
  end
  local text, problems = M.explain(entry, os.time())
  local lines = { '`' .. entry.expr .. '`' }
  if text then lines[#lines + 1] = text end
  local level = vim.log.levels.INFO
  for _, problem in ipairs(problems) do
    lines[#lines + 1] = problem.message
    level = math.max(
      level,
      problem.severity == vim.diagnostic.severity.ERROR and vim.log.levels.ERROR
        or vim.log.levels.WARN
    )
  end
  notify(table.concat(lines, '\n'), level)
end

return M
