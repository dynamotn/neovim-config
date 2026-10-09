--- none-ls code action: fix the diagnostics of the line, or of the
--- selection, with AI
---
--- Offered only where there is a diagnostic to fix. It runs the `fix` prompt
--- of `tools.ai` over those lines, so the buffer goes through the same guard
--- as `<leader>ax`; `remote` in `config.languages` keeps the action off
--- sensitive buffers to begin with.
local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

local M = {}

--- Characters of a diagnostic's message shown in the title
M.TITLE_WIDTH = 60

--- The title of the action for `diagnostics`
---@param diagnostics vim.Diagnostic[]
---@return string
function M.title(diagnostics)
  if #diagnostics > 1 then
    return ('Fix with AI: %d diagnostics'):format(#diagnostics)
  end
  local message = vim.split(diagnostics[1].message, '\n', { plain = true })[1]
  if vim.fn.strchars(message) > M.TITLE_WIDTH then
    message = vim.fn.strcharpart(message, 0, M.TITLE_WIDTH - 1) .. '…'
  end
  return 'Fix with AI: ' .. message
end

--- The actions for `params`: one, when its lines have diagnostics
---@param params table What none-ls hands a generator
---@return table[]?
function M.actions(params)
  local first, last = params.row, params.row
  if params.range then
    first, last = params.range.row, params.range.end_row
  end
  local found = vim.tbl_filter(
    function(d) return d.lnum + 1 >= first and d.lnum + 1 <= last end,
    vim.diagnostic.get(params.bufnr)
  )
  if #found == 0 then return nil end
  return {
    {
      title = M.title(found),
      action = function()
        vim.api.nvim_buf_call(
          params.bufnr,
          function() require('tools.ai').run('fix', { first, last }) end
        )
      end,
    },
  }
end

return h.make_builtin({
  name = 'ai_fix',
  meta = {
    description = 'Fix the diagnostics of the line or selection with AI.',
  },
  method = methods.internal.CODE_ACTION,
  filetypes = {},
  generator = { fn = M.actions },
})
