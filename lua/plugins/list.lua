-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--       List of all plugins         --
---------------------------------------
local register_config = require('plugins.register').register_config

return {
    ----------- Base ------------ {
    { -- Plugin manager
        'wbthomason/packer.nvim',
        event = 'VimEnter',
    },
    { -- Base Lua functions
        'nvim-lua/plenary.nvim',
    },
    { -- Detect filetype
        'nathom/filetype.nvim',
    },
    -- { -- View startup timing
    --     'dstein64/vim-startuptime',
    -- },
    { -- Improve startup time
        'lewis6991/impatient.nvim',
    },
    ----------------------------- }

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
    { -- Indent guide
        'glepnir/indent-guides.nvim',
        config = register_config('indent'),
    },
    --------------- }
    ----------------------------- }

    --------- Navigation -------- {
    { -- File explorer
        'ms-jpq/chadtree',
        branch = 'chad',
        opt = true,
        run = ':CHADdeps',
        cmd = { 'CHADopen' },
    },
    ----------------------------- }

    ---------- Editing ---------- {
    { -- Code complete engine
        'ms-jpq/coq_nvim',
        branch = 'coq',
        run = ':COQdeps',
        config = register_config('coq'),
    },
    { -- Snippet
        'ms-jpq/coq.artifacts',
        branch = 'artifacts',
    },
    { -- Convention
        'gpanders/editorconfig.nvim',
        config = function()
            pcall(require, 'editorconfig')
        end,
    },
    { -- TreeSitter
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = register_config('treesitter'),
    },
    -- Syntax highlight {
    { -- For all basic filetypes
        'sheerun/vim-polyglot',
    },
    { -- For gentoo filetypes
        'gentoo/gentoo-syntax',
    },
    ------------------- }
    ----------------------------- }

    -------- Integration -------- {
    { -- Browser
        'glacambre/firenvim',
        run = function()
            vim.fn['firenvim#install'](0)
        end,
        config = register_config('firefox'),
    },
    { -- Show guide of keymaps
        'folke/which-key.nvim',
        config = register_config('whichkey'),
    },
    ----------------------------- }
}
