-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local M = {}

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

  local load_whichkey_keymaps = function(args)
    local whichkey = require('which-key')

    for _, keymap in ipairs(keymaps) do
      if keymap[2] then
        whichkey.register({
          [keymap[1]] = { keymap[2], keymap['desc'] },
        }, args)
      else
        whichkey.register({
          [keymap[1]] = { name = keymap['desc'] },
        }, args)
      end
    end
  end

  if plugin.name == 'whichkey' then
    load_whichkey_keymaps()
  elseif plugin.ft then
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      pattern = plugin.ft,
      group = vim.api.nvim_create_augroup('whichkey_' .. plugin.name, {}),
      callback = function()
        load_whichkey_keymaps({ buffer = 0 })
      end
    })
  else
    return keymaps
  end
end

return M
