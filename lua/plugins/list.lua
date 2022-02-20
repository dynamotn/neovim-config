-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--       List of all plugins         --
---------------------------------------
local register_config = require('plugins.register').register_config

return {
    {
        'wbthomason/packer.nvim',
        event = 'VimEnter',
    },
    -------- Eyecandy ----------- {
    -- Color scheme {
    { -- OneDark for both Dark and Light colorscheme
        'navarasu/onedark.nvim',
        config = register_config('onedark'),
    },
    --------------- }

    -- Status and tab/buffer line {
    { -- Status line
        'nvim-lualine/lualine.nvim',
        config = register_config('lualine'),
    },
    { -- Buffer and tab line
        'akinsho/bufferline.nvim',
        config = register_config('bufferline'),
    },
    ----------------------------- }

    -- Miscellaneous {
    { -- Programming icons
        'kyazdani42/nvim-web-devicons',
    },
    --------------- }
    ----------------------------- }

    -------- Completion --------- {
    -- Code {
    { -- Engine
        'ms-jpq/coq_nvim',
        branch = 'coq',
        run = ':COQdeps',
        config = register_config('coq'),
    },
    { -- Snippet
        'ms-jpq/coq.artifacts',
        branch = 'artifacts',
    },
    ------- }
    ----------------------------- }
}
