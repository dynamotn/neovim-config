-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local M = {}

-- Register plugin config
M.register_config = function(name, config_function)
    local result = "pcall(require, 'plugins.options." .. name .. "')"
    if type(config_function) == 'string' and config_function ~= '' then
        result = result .. '.' .. config_function .. '()'
    end
    pcall(require, 'plugins.keymaps.' .. name)
    return result
end

return M
