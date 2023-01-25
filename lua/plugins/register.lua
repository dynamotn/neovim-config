-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local augroup = require('misc.augroup')
local M = {}

-- Register plugin config
M.register_config = function(plugin)
  M.register_keymaps(plugin, nil)
  return M.register_options(plugin)
end

-- Load per-plugin options to setup plugin after plugin load
M.register_options = function(plugin)
  if plugin.dir then
    vim.opt.rtp:append(plugin.dir)
  end
  if plugin.name then
    pcall(require, 'plugins.options.' .. plugin.name)
  end
end

-- Load per-plugin options to setup plugin before plugin log
M.register_setup = function(plugin)
  if plugin.name then
    pcall(require, 'plugins.setup.' .. plugin.name)
  end
end

-- Load per-plugin keymaps by `whichkey` plugin
M.register_keymaps = function(plugin, buffer_number)
  local present, whichkey = pcall(require, 'which-key')
  if not present then
    return
  end

  local present, keymaps = pcall(require, 'plugins.keymaps.' .. plugin.name)
  if not present then
    return
  end

  local define_keymaps = function(bufnr)
    if type(keymaps) == 'table' then
      whichkey.register(keymaps, { buffer = bufnr })
    elseif type(keymaps) == 'function' then
      keymaps(whichkey, bufnr)
    end
  end

  if plugin.ft ~= nil then
    _G.dynamo_whichkey[table.concat(plugin.ft, '_')] = function()
      define_keymaps(0)
    end
    augroup.create_augroups({
      ['whichkey_' .. table.concat(plugin.ft, '_')] = {
        {
          'FileType',
          table.concat(plugin.ft, ','),
          'lua dynamo_whichkey["' .. table.concat(plugin.ft, '_') .. '"]()',
        },
      },
    })
  else
    define_keymaps(buffer_number)
  end
end

return M
