--- Window options of a side panel a plugin draws itself
---
--- A plugin such as Avante turns off numbers, signs and folds in its windows,
--- but leaves the editor's `statuscolumn`, `colorcolumn` and `scrolloff` in
--- place. Those belong to code, not to a panel, and the panels edgy lays out
--- go without them.
local M = {}

--- Window-local options every window of a panel gets
M.OPTIONS = {
  statuscolumn = '',
  colorcolumn = '',
  scrolloff = 0,
  sidescrolloff = 0,
}

--- Apply `M.OPTIONS` to every window showing `bufnr`
---@param bufnr integer
local function apply(bufnr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    for name, value in pairs(M.OPTIONS) do
      vim.wo[win][0][name] = value
    end
  end
end

--- Style the windows of panel buffer `bufnr`, now and whenever it is shown in
--- another window. A plugin may set the filetype before the buffer has any
--- window, so the options follow the buffer rather than the current window.
---@param bufnr? integer Defaults to the current buffer
function M.setup(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  apply(bufnr)
  -- An ftplugin runs again whenever the filetype is set again
  if vim.b[bufnr].dy_panel then return end
  vim.b[bufnr].dy_panel = true
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('dyneo_panel', { clear = false }),
    buffer = bufnr,
    callback = function(args) apply(args.buf) end,
  })
end

return M
