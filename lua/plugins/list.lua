-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------------
--       List of all common plugins         --
----------------------------------------------
local register_config = require('plugins.register').register_config

return {
    ----------- Base ------------ {
    { 'wbthomason/packer.nvim', event = 'VimEnter' }, -- Plugin manager
    { 'nvim-lua/plenary.nvim' }, -- Base Lua functions
    { 'nathom/filetype.nvim', config = register_config('filetype') }, -- Detect filetype
    DEBUG and { 'dstein64/vim-startuptime' } or nil, -- View startup timing
    { 'lewis6991/impatient.nvim', config = register_config('impatient') }, -- Improve startup time
    { 'antoinemadec/FixCursorHold.nvim', config = register_config('cursor_hold') }, -- Fix CursorHold performance
    { 'gelguy/wilder.nvim', config = register_config('wilder') }, -- Improve wildmenu's capabilities
    ----------------------------- }

    -------- Eyecandy ----------- {
    -- Color scheme {
    { 'navarasu/onedark.nvim', config = register_config('onedark') }, -- OneDark for both Dark and Light colorscheme
    --------------- }

    -- Status and tab/buffer line {
    { 'nvim-lualine/lualine.nvim', config = register_config('lualine'), after = 'onedark.nvim' }, -- Status line
    { 'akinsho/bufferline.nvim', config = register_config('bufferline') }, -- Buffer and tab line
    ----------------------------- }

    -- Quickfix and diagnostics {
    { 'folke/trouble.nvim', config = register_config('trouble') },
    --------------------------- }

    -- Miscellaneous {
    { 'kyazdani42/nvim-web-devicons' }, -- Programming icons
    { 'glepnir/indent-guides.nvim', event = { 'BufRead', 'BufNewFile' }, config = register_config('indent') }, -- Indent guide
    { 'norcalli/nvim-colorizer.lua', event = { 'BufRead', 'BufNewFile' }, config = register_config('colorizer') }, -- Color highlight
    { 'karb94/neoscroll.nvim', config = register_config('neoscroll') }, -- Smooth scrolling
    { 'Xuyuanp/scrollbar.nvim' }, -- Show scrollbar
    { 'SmiteshP/nvim-gps', config = register_config('gps'), after = 'nvim-treesitter' }, -- Component to show context of current position
    { 'p00f/nvim-ts-rainbow', config = register_config('rainbow'), after = 'nvim-treesitter' }, -- Rainbow parentheses
    { 'ray-x/lsp_signature.nvim', config = register_config('lsp_signature') }, -- Show LSP function signature
    { 'anuvyklack/pretty-fold.nvim', config = register_config('pretty_fold'), requires = { 'anuvyklack/nvim-keymap-amend' } }, -- Foldtext customization
    { 'rcarriga/nvim-notify', config = register_config('notify') }, -- Notification
    { 'sunjon/Shade.nvim', config = register_config('shade') }, -- Dim inactive windows
    --------------- }
    ----------------------------- }

    --------- Navigation -------- {
    { -- File explorer
        'ms-jpq/chadtree',
        branch = 'chad',
        opt = true,
        run = ':CHADdeps',
        cmd = { 'CHADopen' },
        config = register_config('chadtree'),
    },
    { 'https://gitlab.com/yorickpeterse/nvim-window', config = register_config('window') }, -- Window switcher
    { 'chentau/marks.nvim', config = register_config('marks') }, -- Show mark and switch to mark
    ----------------------------- }

    ------------- VCS ----------- {
    { 'TimUntersberger/neogit', config = register_config('neogit'), cmd = { 'Neogit' } }, -- Git TUI
    { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewFileHistory' } }, -- Diff view
    { 'lewis6991/gitsigns.nvim', config = register_config('gitsigns') }, -- Git decoration
    ----------------------------- }

    ---------- Editing ---------- {
    { 'ethanholz/nvim-lastplace', config = register_config('lastplace') }, -- Save the last edit position
    { 'numToStr/Comment.nvim', config = register_config('comment') }, -- Commenting
    { 'ms-jpq/coq_nvim', branch = 'coq', run = ':COQdeps', config = register_config('coq') }, -- Code complete engine
    -- Complete source {
    { 'ms-jpq/coq.thirdparty', branch = '3p', config = register_config('coq_3rd') }, -- Shell REPL, Mathematic, Nvim LUA
    { 'github/copilot.vim' }, -- Github Copilot
    -- }
    { 'ms-jpq/coq.artifacts', branch = 'artifacts' }, -- Snippet
    { 'gpanders/editorconfig.nvim', event = { 'BufRead', 'BufNewFile' }, config = register_config('editorconfig') }, -- Convention
    -- LSP {
    { 'neovim/nvim-lspconfig' }, -- Config for LSP server
    { 'williamboman/nvim-lsp-installer', config = register_config('lsp_installer') }, -- Automatically ínstall language server
    { 'jose-elias-alvarez/null-ls.nvim', config = register_config('null_ls') }, -- Config for non-LSP sources
    { 'tami5/lspsaga.nvim', config = register_config('lspsaga') }, -- UI for LSP
    ------ }
    { -- TreeSitter
        'nvim-treesitter/nvim-treesitter',
        event = { 'BufRead', 'BufNewFile' },
        run = ':TSUpdate',
        config = register_config('treesitter'),
    },
    -- Syntax highlight {
    { 'sheerun/vim-polyglot' }, -- For all basic filetypes
    { 'gentoo/gentoo-syntax' }, -- For gentoo filetypes
    ------------------- }
    -- Typing {
    { 'windwp/nvim-autopairs', event = { 'BufRead', 'BufNewFile' }, config = register_config('autopairs') }, -- Automatically insert/delete brackets, parentheses, quotes...
    { -- Automatically close and rename HTML tag
        'windwp/nvim-ts-autotag',
        event = { 'BufRead', 'BufNewFile' },
        config = register_config('autotag'),
        after = 'nvim-treesitter',
    },
    { -- Automatically insert end keyword
        'RRethy/nvim-treesitter-endwise',
        event = { 'BufRead', 'BufNewFile' },
        config = register_config('endwise'),
        after = 'nvim-treesitter',
    },
    { 'monaqa/dial.nvim', config = register_config('dial') }, -- Increment/decrement number, date...
    --------- }
    { 'ThePrimeagen/refactoring.nvim', config = register_config('refactoring'), after = 'nvim-treesitter' }, -- Refactoring library
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
    { 'akinsho/nvim-toggleterm.lua', config = register_config('toggleterm') }, -- Terminal
    -- Fuzzy finder {
    { -- Engine
        'nvim-telescope/telescope.nvim',
        config = register_config('telescope'),
        requires = {
            { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }, -- Increase performance with fzf (native port from Go to C)
        },
    },
    --------------- }
    ----------------------------- }

    ---------- Utility ---------- {
    { 'nvim-orgmode/orgmode', config = register_config('orgmode'), after = 'nvim-treesitter' }, -- Note taking
    { 'olimorris/persisted.nvim', config = register_config('session') }, -- Automatic session management
    DEBUG and { 'nvim-treesitter/playground' } or nil,
    ----------------------------- }
}
