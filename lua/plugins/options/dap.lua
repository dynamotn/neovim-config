local present, dap = pcall(require, 'dap')

if not present then
    return
end

local present, languages = pcall(require, 'languages')

if present then
    local adapters, debugees = languages.setup_dap()

    dap.adapters = adapters
    dap.configurations = debugees
end
