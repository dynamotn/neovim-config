local h = require('helpers')

local DAY = 24 * 60 * 60
local now = os.time()

--- A GitHub release published `age` seconds ago
---@param tag string
---@param age integer
---@param opts? { draft?: boolean, prerelease?: boolean, published_at?: string }
---@return table
local function release(tag, age, opts)
  opts = opts or {}
  return {
    tag_name = tag,
    draft = opts.draft or false,
    prerelease = opts.prerelease or false,
    published_at = opts.published_at
      or os.date('!%Y-%m-%dT%H:%M:%SZ', now - age),
  }
end

--- The tags `quarantined` keeps out of `releases`
---@param releases table[]
---@return string[]
local function kept(releases)
  h.unload('tools.mason-quarantine')
  local quarantine = require('tools.mason-quarantine')
  return vim.tbl_map(
    function(r) return r.tag_name end,
    quarantine.quarantined(releases, now)
  )
end

describe('tools.mason-quarantine', function()
  it(
    'holds back releases younger than a week',
    function()
      assert.are.same(
        { 'old' },
        kept({ release('new', DAY), release('old', 8 * DAY) })
      )
    end
  )

  it(
    'keeps a release exactly a week old',
    function() assert.are.same({ 'week' }, kept({ release('week', 7 * DAY) })) end
  )

  it(
    'keeps the newest aged release first',
    function()
      assert.are.same(
        { 'newer', 'older' },
        kept({
          release('fresh', 2 * DAY),
          release('newer', 9 * DAY),
          release('older', 30 * DAY),
        })
      )
    end
  )

  it(
    'drops drafts and prereleases whatever their age',
    function()
      assert.are.same(
        {},
        kept({
          release('draft', 30 * DAY, { draft = true }),
          release('rc', 30 * DAY, { prerelease = true }),
        })
      )
    end
  )

  it(
    'drops a release whose date cannot be read',
    function()
      assert.are.same(
        {},
        kept({
          release('undated', 30 * DAY, { published_at = vim.NIL }),
          release('garbled', 30 * DAY, { published_at = 'last tuesday' }),
        })
      )
    end
  )

  it('reads the timestamp as UTC, whatever the local zone is', function()
    local tz = vim.env.TZ
    for _, zone in ipairs({ 'UTC', 'Asia/Ho_Chi_Minh', 'America/Anchorage' }) do
      vim.env.TZ = zone
      -- A release that has been out for a week and a minute stays in, one
      -- that is a minute short of the week does not; a zone read as local
      -- time would move either of them by hours.
      assert.are.same(
        { 'just-aged' },
        kept({
          release('too-fresh', 7 * DAY - 60),
          release('just-aged', 7 * DAY + 60),
        }),
        zone
      )
    end
    vim.env.TZ = tz
  end)
end)
