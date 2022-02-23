-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------
-- Plugin registration to load config --
----------------------------------------
local M = {}

-- Register plugin config
M.register_config = function(name, config_function)
    M.register_keymaps(name)
    return M.register_options(name)
end

-- Load per-plugin options to setup plugin
M.register_options = function(name, config_function)
    local result = "pcall(require, 'plugins.options." .. name .. "')"
    if type(config_function) == 'string' and config_function ~= '' then
        result = result .. '.' .. config_function .. '()'
    end

    return result
end

-- Load per-plugin keymaps by `whichkey` plugin
M.register_keymaps = function(name)
    local present, whichkey = pcall(require, 'which-key')
    if not present then
        return
    end

    local present, keymaps = pcall(require, 'plugins.keymaps.' .. name)
    if not present then
        return
    end

    if type(keymaps) == 'table' then
        whichkey.register(keymaps)
    end
end

return M
