-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--       List of all plugins         --
---------------------------------------
local register_config = require('plugins.register').register_config

return {
    ----------- Base ------------ {
    { 'wbthomason/packer.nvim', event = 'VimEnter' }, -- Plugin manager
    { 'nvim-lua/plenary.nvim' }, -- Base Lua functions
    { 'nathom/filetype.nvim' }, -- Detect filetype
    -- {'dstein64/vim-startuptime'}, -- View startup timing
    { 'lewis6991/impatient.nvim' }, -- Improve startup time
    ----------------------------- }

    -------- Eyecandy ----------- {
    -- Color scheme {
    { 'navarasu/onedark.nvim', config = register_config('onedark') }, -- OneDark for both Dark and Light colorscheme
    --------------- }

    -- Status and tab/buffer line {
    { 'nvim-lualine/lualine.nvim', config = register_config('lualine') }, -- Status line
    { 'akinsho/bufferline.nvim', config = register_config('bufferline') }, -- Buffer and tab line
    ----------------------------- }

    -- Miscellaneous {
    { 'kyazdani42/nvim-web-devicons' }, -- Programming icons
    { 'glepnir/indent-guides.nvim', config = register_config('indent') }, -- Indent guide
    --------------- }
    ----------------------------- }

    --------- Navigation -------- {
    { 'ms-jpq/chadtree', branch = 'chad', opt = true, run = ':CHADdeps', cmd = { 'CHADopen' } }, -- File explorer
    ----------------------------- }

    ---------- Editing ---------- {
    { 'ms-jpq/coq_nvim', branch = 'coq', run = ':COQdeps', config = register_config('coq') }, -- Code complete engine
    { 'ms-jpq/coq.artifacts', branch = 'artifacts' }, -- Snippet
    { -- Convention
        'gpanders/editorconfig.nvim',
        config = function()
            pcall(require, 'editorconfig')
        end,
    },
    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', config = register_config('treesitter') }, -- TreeSitter
    -- Syntax highlight {
    { 'sheerun/vim-polyglot' }, -- For all basic filetypes
    { 'gentoo/gentoo-syntax' }, -- For gentoo filetypes
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
    { 'folke/which-key.nvim', config = register_config('whichkey') }, -- Show guide of keymaps
    ----------------------------- }
}
