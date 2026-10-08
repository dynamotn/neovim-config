local M = {}

local cache_dir = vim.fn.resolve(vim.fn.stdpath('cache') .. '/diagram-cache/d2')
vim.fn.mkdir(cache_dir, 'p')

local config = {
  theme_id = 4,
  dark_theme_id = 4,
  layout = 'tala',
  -- Longest side of the preview, in pixels, when Quick Look rasterizes it
  max_size = 4096,
}

local preview_buf = nil
local preview_win = nil

--- Throw away renders more than a week old
---
--- The cache key follows the contents of a diagram, so every edit leaves the
--- previous render behind. Nothing else ever removes them. Age is the only
--- test: a render still in use is dropped as well, and simply drawn again.
local function prune_cache()
  local week = 7 * 24 * 60 * 60
  local now = os.time()
  for _, file in ipairs(vim.fn.glob(cache_dir .. '/*.png', true, true)) do
    local stat = vim.uv.fs_stat(file)
    if stat and now - stat.mtime.sec > week then vim.uv.fs_unlink(file) end
  end
end

--- Turn the SVG at `svg_path` into the PNG at `png_path`
---
--- d2 can write a PNG itself, but its rasterizer turns down icons over 64 KiB
--- and SVG attributes such as `enable-background`, which several of the
--- icons.terrastruct.com icons carry. Its SVG output takes them all.
---@param svg_path string
---@param png_path string
---@param on_done fun(err?: string)
local function svg_to_png(svg_path, png_path, on_done)
  local function run(command, next_step)
    vim.system(command, { text = true }, function(result)
      if result.code ~= 0 then
        on_done(
          result.stderr ~= '' and result.stderr or table.concat(command, ' ')
        )
        return
      end
      next_step()
    end)
  end

  if vim.fn.executable('rsvg-convert') == 1 then
    run({ 'rsvg-convert', '-o', png_path, svg_path }, on_done)
  elseif vim.fn.executable('resvg') == 1 then
    run({ 'resvg', svg_path, png_path }, on_done)
  elseif vim.fn.executable('magick') == 1 then
    run({ 'magick', '-background', 'none', svg_path, png_path }, on_done)
  elseif vim.fn.executable('qlmanage') == 1 then
    -- Quick Look draws the SVG with WebKit, so fonts and icons come out right,
    -- but always on a square canvas with the picture at the top left
    local width, height = 1, 1
    local head = table.concat(vim.fn.readfile(svg_path, '', 5), '\n')
    local w, h = head:match('viewBox="[-%d.]+ [-%d.]+ ([%d.]+) ([%d.]+)"')
    if w then
      width, height = tonumber(w), tonumber(h)
    end
    local size = config.max_size
    local out_dir = vim.fn.fnamemodify(png_path, ':h')
    local thumbnail = out_dir
      .. '/'
      .. vim.fn.fnamemodify(svg_path, ':t')
      .. '.png'
    local crop_width = math.floor(size * math.min(1, width / height))
    local crop_height = math.floor(size * math.min(1, height / width))

    run(
      { 'qlmanage', '-t', '-s', tostring(size), '-o', out_dir, svg_path },
      function()
        -- `sips` reads an offset of 0 as no offset at all and crops around
        -- the centre, so start one pixel in
        run({
          'sips',
          '--cropOffset',
          '1',
          '1',
          '-c',
          tostring(crop_height),
          tostring(crop_width),
          thumbnail,
          '--out',
          png_path,
        }, function()
          vim.uv.fs_unlink(thumbnail)
          on_done()
        end)
      end
    )
  else
    on_done('no SVG converter found: install rsvg-convert, resvg or magick')
  end
end

--- Hash the diagram together with the d2 files beside and below it, which is
--- where its imports usually live
---
--- Only the opened file used to go into the key, so editing an imported file
--- kept serving the stale picture. An import reaching up with `../` is still
--- not covered.
---@param source_path string
---@return string
local function content_hash(source_path)
  local parts = { table.concat(vim.fn.readfile(source_path), '\n') }
  local dir = vim.fn.fnamemodify(source_path, ':h')
  for _, file in ipairs(vim.fn.globpath(dir, '**/*.d2', false, true)) do
    if vim.fn.resolve(file) ~= vim.fn.resolve(source_path) then
      table.insert(
        parts,
        file .. '\0' .. table.concat(vim.fn.readfile(file), '\n')
      )
    end
  end
  return vim.fn.sha256(table.concat(parts, '\0'))
end

--- Render `source_path` to a PNG and hand the path to `on_rendered`
---@param source_path string
---@param on_rendered fun(output_path: string)
local function render_d2(source_path, on_rendered)
  -- `executable` answers 0 or 1, and 0 is true in Lua, so `not` never caught
  -- the missing binary and the failure surfaced as a raw spawn error instead
  if vim.fn.executable('d2') == 0 then
    vim.notify('[d2] d2 not found in PATH', vim.log.levels.ERROR)
    return
  end

  local source = vim.uv.fs_stat(source_path)
  if not source then return end

  -- Keyed on the contents rather than the timestamp: two edits within the
  -- same second used to be served the earlier picture.
  local hash = content_hash(source_path)
  local svg_path = vim.fn.resolve(cache_dir .. '/' .. hash .. '.svg')
  local output_path = vim.fn.resolve(cache_dir .. '/' .. hash .. '.png')

  if vim.fn.filereadable(output_path) == 1 then
    on_rendered(output_path)
    return
  end

  local command = {
    'd2',
    source_path,
    svg_path,
    '-t',
    tostring(config.theme_id),
    '--dark-theme',
    tostring(config.dark_theme_id),
  }
  -- The flag wins over `vars.d2-config.layout-engine`, so it would silently
  -- replace the layout the diagram asks for
  local text = table.concat(vim.fn.readfile(source_path), '\n')
  if not text:find('layout%-engine%s*:') then
    vim.list_extend(command, { '--layout', config.layout })
  end

  local function fail(message)
    vim.schedule(
      function()
        vim.notify(
          ('[d2] failed to render:\n%s'):format(message or ''),
          vim.log.levels.ERROR
        )
      end
    )
  end

  -- Rendering a `tala` layout takes its time, and waiting on it held the whole
  -- editor still
  vim.system(command, { text = true }, function(result)
    if result.code ~= 0 then
      fail(result.stderr)
      return
    end
    -- Picking a converter reads the SVG through `vim.fn`, which a
    -- `vim.system` callback is not allowed to call
    vim.schedule(function()
      svg_to_png(svg_path, output_path, function(err)
        vim.uv.fs_unlink(svg_path)
        if err then
          fail(err)
          return
        end
        vim.schedule(function()
          prune_cache()
          on_rendered(output_path)
        end)
      end)
    end)
  end)
end

--- Show `output_path` outside of zellij, which drops the kitty graphics
--- protocol, so snacks.nvim has nothing to draw into
---
--- Kitty's remote control opens the picture in an overlay above the zellij
--- window; without it, the system viewer takes over.
---@param output_path string
local function show_outside_zellij(output_path)
  local listen_on = vim.env.KITTY_LISTEN_ON
  if not listen_on or vim.fn.executable('kitten') == 0 then
    vim.ui.open(output_path)
    return
  end

  vim.system({
    'kitten',
    '@',
    '--to',
    listen_on,
    'launch',
    '--type=overlay',
    '--title=D2 preview',
    'kitten',
    'icat',
    '--hold',
    output_path,
  }, { text = true }, function(result)
    if result.code == 0 then return end
    vim.schedule(function()
      vim.notify(
        ('[d2] kitty overlay failed, opening externally:\n%s'):format(
          result.stderr or ''
        ),
        vim.log.levels.WARN
      )
      vim.ui.open(output_path)
    end)
  end)
end

local function show_d2_preview()
  local buf = vim.api.nvim_get_current_buf()
  local source_path = vim.api.nvim_buf_get_name(buf)

  if not source_path or source_path == '' then return end

  -- The window to come back to, since the render no longer blocks and the
  -- cursor may have moved on by the time it lands
  local source_win = vim.api.nvim_get_current_win()

  render_d2(source_path, function(output_path)
    if vim.env.ZELLIJ ~= nil then
      show_outside_zellij(output_path)
      return
    end

    -- Close previous preview
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
      vim.api.nvim_win_close(preview_win, true)
    end
    if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
      vim.api.nvim_buf_delete(preview_buf, { force = true })
    end

    if not vim.api.nvim_win_is_valid(source_win) then return end
    vim.api.nvim_set_current_win(source_win)

    -- Open image in a new split
    vim.cmd('vsplit ' .. vim.fn.fnameescape(output_path))
    preview_win = vim.api.nvim_get_current_win()
    preview_buf = vim.api.nvim_get_current_buf()
  end)
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup('D2Preview', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'd2',
    callback = function()
      vim.keymap.set('n', '<leader>cp', show_d2_preview, {
        buffer = true,
        desc = 'Preview D2 diagram',
      })
    end,
  })
end

setup_autocmds()

return M
