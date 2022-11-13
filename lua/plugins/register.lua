-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local augroup = require('misc.augroup')
local M = {}

-- Register plugin config
M.register_config = function(name, filetypes)
  M.register_keymaps(name, nil, filetypes)
  return M.register_options(name)
end

-- Load per-plugin options to setup plugin
M.register_options = function(name)
  return "pcall(require, 'plugins.options." .. name .. "')"
end

-- Load per-plugin keymaps by `whichkey` plugin
M.register_keymaps = function(name, buffer_number, filetypes)
  local present, whichkey = pcall(require, 'which-key')
  if not present then
    return
  end

  local present, keymaps = pcall(require, 'plugins.keymaps.' .. name)
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

  if filetypes ~= nil then
    _G.dynamo_whichkey[table.concat(filetypes, '_')] = function()
      define_keymaps(0)
    end
    augroup.create_augroups({
      ['whichkey_' .. table.concat(filetypes, '_')] = {
        {
          'FileType',
          table.concat(filetypes, ','),
          'lua dynamo_whichkey["' .. table.concat(filetypes, '_') .. '"]()',
        },
      },
    })
  else
    define_keymaps(buffer_number)
  end
end

return M
