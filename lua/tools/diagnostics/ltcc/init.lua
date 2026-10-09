local h = require('null-ls.helpers')
local methods = require('null-ls.methods')

return h.make_builtin({
  name = 'ltcc',
  meta = {
    description = 'My custom sources to use languagetool-code-comments',
    url = 'https://github.com/dynamotn/languagetool-code-comments',
  },
  method = methods.internal.DIAGNOSTICS,
  filetypes = {},
  generator_opts = {
    command = 'ltcc',
    args = { 'check', '-l', 'en-US', '-f', '$FILENAME' },
    format = 'json',
    -- `ltcc` reads a file and has no stdin mode: the buffer goes to a
    -- temporary copy, so the result matches what is on screen, not the
    -- saved file the offsets would be wrong for
    to_temp_file = true,
    ignore_stderr = true,
    timeout = 60000,
    check_exit_code = function(c) return c <= 1 end,
    on_output = function(params)
      local file = params.output
      if file then
        local parser = h.diagnostics.from_json({
          severities = {
            ERROR = h.diagnostics.severities.error,
          },
        })

        local offenses = {}

        for _, m in ipairs(file) do
          -- `"replacements": null` decodes to `vim.NIL`
          local replacements = type(m.replacements) == 'table'
              and m.replacements
            or {}
          local tip = table.concat(
            vim.tbl_map(
              function(r) return '“' .. r.value .. '”' end,
              replacements
            ),
            ', '
          )

          table.insert(offenses, {
            message = tip == '' and m.message or m.message .. ' Try: ' .. tip,
            ruleId = m.rule.id,
            level = 'ERROR',
            line = m.moreContext.line_number,
            column = m.moreContext.line_offset + 1,
            endLine = m.moreContext.line_number,
            endColumn = m.moreContext.line_offset + m.length + 1,
          })
        end

        return parser({ output = offenses })
      end

      return {}
    end,
    use_cache = false,
  },
  factory = h.generator_factory,
})
