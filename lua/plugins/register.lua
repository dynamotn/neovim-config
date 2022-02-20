-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local M = {}

-- Register plugin config
M.register_config = function(name)
    pcall(require, 'plugins.options.' .. name)
    pcall(require, 'plugins.keymaps.' .. name)
end

return M
