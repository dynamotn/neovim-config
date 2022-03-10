local present, lualine = pcall(require, 'lualine')

if not present then
    return
end

local gps = require('nvim-gps')

lualine.setup({
    options = {
        theme = 'onedark',
        disabled_filetypes = {
            'NvimTree',
        },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = {
            'branch',
            {
                'diff',
                symbols = { added = ' ', modified = ' ', removed = ' ' },
            },
            'diagnostics',
        },
        lualine_c = {
            {
                'filename',
                path = 1, -- Relative path
            },
            {
                gps.get_location,
                cond = gps.is_available,
            },
        },
        lualine_x = {
            {
                function()
                    local b = vim.api.nvim_get_current_buf()
                    if next(vim.treesitter.highlighter.active[b]) then
                        return ' '
                    end
                    return ''
                end,
                color = { fg = '#98be65' },
            },
            {
                function(msg)
                    msg = msg or '  Inactive'
                    local buf_clients = vim.lsp.buf_get_clients()
                    if next(buf_clients) == nil then
                        -- TODO: clean up this if statement
                        if type(msg) == 'boolean' or #msg == 0 then
                            return '  Inactive'
                        end
                        return msg
                    end
                    local buf_client_names = {}

                    -- add client
                    for _, client in pairs(buf_clients) do
                        table.insert(buf_client_names, client.name)
                    end
                    return '  ' .. table.concat(buf_client_names, ', ')
                end,
                color = { fg = '#008080', gui = 'bold' },
            },
            'filetype',
        },
        lualine_y = {
            {
                'encoding',
                separator = { left = '', right = '' }, -- Not use powerline between encoding and file format
            },
            'fileformat',
        },
        lualine_z = { 'progress', 'location' },
    },
    extensions = { 'quickfix', 'chadtree' },
})
