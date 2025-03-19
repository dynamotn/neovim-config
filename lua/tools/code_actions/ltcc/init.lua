local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

local neoconf = require('neoconf')

return h.make_builtin({
  name = 'ltcc',
  meta = {
    description = 'My custom sources to use languagetool-code-comments',
    url = 'https://github.com/dynamotn/languagetool-code-comments',
  },
  method = methods.internal.CODE_ACTION,
  filetypes = {},
  generator_opts = {
    command = 'ltcc',
    args = { 'check', '-l', 'en-US', '-f', '$FILENAME' },
    format = 'json',
    to_stdin = true,
    ignore_stderr = true,
    timeout = 60000,
    check_exit_code = function(c) return c <= 1 end,
    on_output = function(params)
      local actions = {}

      for _, m in ipairs(params.output) do
        if
          m.replacements ~= vim.NIL
          and params.row == m.moreContext.line_number
        then
          local row = m.moreContext.line_number - 1
          local col_beg = m.moreContext.line_offset
          local col_end = m.moreContext.line_offset + m.length

          for _, r in ipairs(m.replacements) do
            if string.find(r.value, 'not shown') == nil then
              table.insert(actions, {
                title = 'Replace with “' .. r.value .. '”',
                action = function()
                  vim.api.nvim_buf_set_text(
                    params.bufnr,
                    row,
                    col_beg,
                    row,
                    col_end,
                    { r.value }
                  )
                end,
              })
            end
          end
        end
      end

      return actions
    end,
    use_cache = false,
  },
  factory = h.generator_factory,
})
