--- Debug adapters named in `config.languages`, and what they share
---
--- An entry of a language's `dap` is the adapter's name in nvim-dap. For most
--- adapters that is all there is to say, because mason-nvim-dap maps the name
--- to the Mason package that installs it. One it does not know is written as
--- a table and carries the package itself, the way a linter or formatter does:
--- `{ 'perl', mason = { package = 'perl-debug-adapter' } }`.

local M = {}

---@param spec string|DyDapSpec
---@return string
M.name = function(spec)
  if type(spec) == 'table' then return spec[1] end
  return spec
end

--- Mason package that installs the adapter of `spec`
---@param spec string|DyDapSpec
---@return string?
M.package = function(spec)
  if type(spec) == 'table' and spec.mason then return spec.mason.package end
  local ok, source = pcall(require, 'mason-nvim-dap.mappings.source')
  return ok and source.nvim_dap_to_package[M.name(spec)] or nil
end

--- Whether mason-nvim-dap knows the adapter of `spec` by name
---
--- Only such an adapter can go to its `ensure_installed`, and only such an
--- adapter is set up by it once installed; any other is installed by
--- `plugins.executor.debugging` itself and set up by the language's own plugin
--- file.
---@param spec string|DyDapSpec
---@return boolean
M.is_mapped = function(spec) return type(spec) == 'string' end

--- Register the `codelldb` adapter, unless something already did
---
--- mason-nvim-dap registers it once the package is installed, and rustaceanvim
--- brings its own; a language that debugs through LLDB calls this first so it
--- does not depend on either having run.
M.codelldb_adapter = function()
  local dap = require('dap')
  if dap.adapters['codelldb'] then return end
  dap.adapters['codelldb'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
      command = 'codelldb',
      args = { '--port', '${port}' },
    },
  }
end

--- Launch and attach configurations for a program debugged through `codelldb`
---@param build_dir string Where the prompt for the executable starts, under the
--- working directory: the build tool's output directory, or `''`.
---@return dap.Configuration[]
M.codelldb_configurations = function(build_dir)
  return {
    {
      type = 'codelldb',
      request = 'launch',
      name = 'Launch file',
      program = function()
        return vim.fn.input(
          'Path to executable: ',
          vim.fn.getcwd() .. '/' .. build_dir,
          'file'
        )
      end,
      cwd = '${workspaceFolder}',
    },
    {
      type = 'codelldb',
      request = 'attach',
      name = 'Attach to process',
      pid = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
    },
  }
end

return M
