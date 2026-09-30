local M = {}

local cache_dir = vim.fn.resolve(vim.fn.stdpath('cache') .. '/diagram-cache/d2')
vim.fn.mkdir(cache_dir, 'p')

local config = {
  theme_id = 4,
  dark_theme_id = 4,
  layout = 'tala',
}

local preview_buf = nil
local preview_win = nil

--- Throw away renders nothing points at any more
---
--- The cache key follows the contents of a diagram, so every edit leaves the
--- previous render behind. Nothing else ever removes them.
local function prune_cache()
  local week = 7 * 24 * 60 * 60
  local now = os.time()
  for _, file in ipairs(vim.fn.glob(cache_dir .. '/*.png', true, true)) do
    local stat = vim.uv.fs_stat(file)
    if stat and now - stat.mtime.sec > week then vim.uv.fs_unlink(file) end
  end
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
  local hash = vim.fn.sha256(table.concat(vim.fn.readfile(source_path), '\n'))
  local output_path = vim.fn.resolve(cache_dir .. '/' .. hash .. '.png')

  if vim.fn.filereadable(output_path) == 1 then
    on_rendered(output_path)
    return
  end

  local command = {
    'd2',
    source_path,
    output_path,
    '-t',
    tostring(config.theme_id),
    '--dark-theme',
    tostring(config.dark_theme_id),
    '--layout',
    config.layout,
  }

  -- Rendering a `tala` layout takes its time, and waiting on it held the whole
  -- editor still
  vim.system(command, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          ('[d2] failed to render:\n%s'):format(result.stderr or ''),
          vim.log.levels.ERROR
        )
        return
      end
      prune_cache()
      on_rendered(output_path)
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
