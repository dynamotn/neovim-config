--- A stand-in for none-ls, enough for the builtins under `lua/tools/` to be
--- loaded and their `generator_opts` exercised without the plugin
---
--- `make_builtin` hands its options straight back, so a spec reaches the
--- `on_output` and friends a builtin was declared with.
local M = {}

M.severities = { error = 1, warning = 2, information = 3, hint = 4 }

--- Install the stub in `package.loaded`, and drop `modules` so the next
--- `require` builds them on top of it
---@param ... string Modules to load afresh
M.install = function(...)
  package.loaded['null-ls.helpers'] = {
    make_builtin = function(opts) return opts end,
    generator_factory = function() end,
    cache = { by_bufnr = function(fn) return fn end },
    diagnostics = {
      severities = M.severities,
      -- Hand the offenses back with what the parser was set up with, so a
      -- spec sees both the mapping and the severities it asked for
      from_json = function(opts)
        return function(params)
          return { severities = opts.severities, offenses = params.output }
        end
      end,
    },
  }
  package.loaded['null-ls.methods'] = {
    internal = {
      CODE_ACTION = 'NULL_LS_CODE_ACTION',
      DIAGNOSTICS = 'NULL_LS_DIAGNOSTICS',
      DIAGNOSTICS_ON_SAVE = 'NULL_LS_DIAGNOSTICS_ON_SAVE',
      COMPLETION = 'NULL_LS_COMPLETION',
    },
  }
  for _, name in ipairs({ ... }) do
    package.loaded[name] = nil
  end
end

M.uninstall = function()
  package.loaded['null-ls.helpers'] = nil
  package.loaded['null-ls.methods'] = nil
  package.loaded['null-ls.diagnostics'] = nil
end

return M
