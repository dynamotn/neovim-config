-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local M = {}

-- Register plugin config
M.register_config = function(plugin)
  return M.register_options(plugin)
end

-- Load per-plugin options to setup plugin after plugin load
M.register_options = function(plugin)
  if plugin.dir then
    vim.opt.rtp:append(plugin.dir)
    require('lazy.core.loader').packadd(plugin.dir)
  end
  if plugin.name then
    pcall(require, 'plugins.options.' .. plugin.name)
  end
end

-- Load per-plugin options to setup plugin before plugin load
M.register_setup = function(plugin)
  if plugin.name then
    pcall(require, 'plugins.setup.' .. plugin.name)
  end
  if plugin.dir then
    require('lazy.core.loader').ftdetect(plugin.dir)
  end
end

-- Load per-plugin keymaps
M.register_keymaps = function(plugin)
  if not plugin.name then
    return
  end

  local present, keymaps = pcall(require, 'plugins.keymaps.' .. plugin.name)
  if not present then
    return
  end

  if plugin.name == 'whichkey' then
    local present, whichkey = pcall(require, 'which-key')
    if not present then
      return
    end

    for _, keymap in ipairs(keymaps) do
      if keymap[2] then
        whichkey.register({
          [keymap[1]] = { keymap[2], keymap['desc'] },
        })
      else
        whichkey.register({
          [keymap[1]] = { name = keymap['desc'] },
        })
      end
    end
  else
    return keymaps
  end
end

return M
