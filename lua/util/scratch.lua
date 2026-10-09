--- Scratch buffers: a window of text that is no file, closed with `q`
---
--- What a tool shows rather than what is edited -- a log, a report, a
--- dashboard -- goes in one of these: no swap file, wiped when hidden, and
--- marked sensitive before its text goes in when it may hold secrets.
local M = {}

---@class DyScratchOpts
---@field name? string Buffer name; a name already taken is left off
---@field filetype? string
---@field sensitive? string Why it is kept from every AI integration
---@field split? 'tab'|'vertical'|'horizontal' Where it opens, `tab` unless given
---@field modifiable? boolean Left editable, `false` unless given

--- Open a scratch buffer holding `lines`, and make it current
---@param lines string[]
---@param opts? DyScratchOpts
---@return integer bufnr
function M.open(lines, opts)
  opts = opts or {}
  local split = opts.split or 'tab'
  if split == 'tab' then
    vim.cmd('tabnew')
  elseif split == 'vertical' then
    vim.cmd('vertical botright new')
  else
    vim.cmd('botright new')
  end
  local bufnr = vim.api.nvim_get_current_buf()
  if opts.sensitive then
    require('util.sensitive').mark(bufnr, opts.sensitive)
  end
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false
  if opts.name then pcall(vim.api.nvim_buf_set_name, bufnr, opts.name) end
  M.set(bufnr, lines)
  vim.bo[bufnr].modifiable = opts.modifiable == true
  if opts.filetype then vim.bo[bufnr].filetype = opts.filetype end
  vim.keymap.set(
    'n',
    'q',
    '<cmd>close<cr>',
    { buffer = bufnr, desc = 'Close', nowait = true }
  )
  return bufnr
end

--- Replace the lines of scratch buffer `bufnr`, modifiable or not
---@param bufnr integer
---@param lines string[]
function M.set(bufnr, lines)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local modifiable = vim.bo[bufnr].modifiable
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = modifiable
  vim.bo[bufnr].modified = false
end

return M
