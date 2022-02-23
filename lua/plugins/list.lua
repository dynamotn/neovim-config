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
    { 'norcalli/nvim-colorizer.lua', config = register_config('colorizer') }, -- Color highlight
    --------------- }
    ----------------------------- }

    --------- Navigation -------- {
    { 'ms-jpq/chadtree', branch = 'chad', opt = true, run = ':CHADdeps', cmd = { 'CHADopen' } }, -- File explorer
    ----------------------------- }

    ------------- VCS ----------- {
    { 'TimUntersberger/neogit', config = register_config('neogit') }, -- Git TUI
    { 'sindrets/diffview.nvim' }, -- Diff view
    { 'lewis6991/gitsigns.nvim', config = register_config('gitsigns') }, -- Git dcoration
    ----------------------------- }

    ---------- Editing ---------- {
    { 'ms-jpq/coq_nvim', branch = 'coq', run = ':COQdeps', config = register_config('coq') }, -- Code complete engine
    { 'ms-jpq/coq.artifacts', branch = 'artifacts' }, -- Snippet
    { 'gpanders/editorconfig.nvim', config = register_config('editorconfig') }, -- Convention
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
    { 'akinsho/nvim-toggleterm.lua' },
    ----------------------------- }
}
