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

local function render_d2(source_path)
  if not vim.fn.executable('d2') then
    vim.notify('[d2] d2 not found in PATH', vim.log.levels.ERROR)
    return nil
  end

  local stat = vim.uv.fs_stat(source_path)
  if not stat then return nil end

  local hash = vim.fn.sha256(source_path .. ':' .. stat.mtime.sec)
  local output_path = vim.fn.resolve(cache_dir .. '/' .. hash .. '.png')

  if vim.fn.filereadable(output_path) == 1 then return output_path end

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

  local result = vim.system(command, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify(
      ('[d2] failed to render:\n%s'):format(result.stderr or ''),
      vim.log.levels.ERROR
    )
    return nil
  end

  return output_path
end

local function show_d2_preview()
  local buf = vim.api.nvim_get_current_buf()
  local source_path = vim.api.nvim_buf_get_name(buf)

  if not source_path or source_path == '' then return end

  local output_path = render_d2(source_path)
  if not output_path then return end

  -- Close previous preview
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
  end
  if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
    vim.api.nvim_buf_delete(preview_buf, { force = true })
  end

  -- Open image in a new split
  vim.cmd('vsplit ' .. vim.fn.fnameescape(output_path))
  preview_win = vim.api.nvim_get_current_win()
  preview_buf = vim.api.nvim_get_current_buf()
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
