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
    DEBUG and { 'dstein64/vim-startuptime' } or nil, -- View startup timing
    { 'lewis6991/impatient.nvim', config = register_config('impatient') }, -- Improve startup time
    { 'antoinemadec/FixCursorHold.nvim' },
    ----------------------------- }

    -------- Eyecandy ----------- {
    -- Color scheme {
    { 'navarasu/onedark.nvim', config = register_config('onedark') }, -- OneDark for both Dark and Light colorscheme
    --------------- }

    -- Status and tab/buffer line {
    { 'nvim-lualine/lualine.nvim', config = register_config('lualine'), after = 'nvim-gps' }, -- Status line
    { 'akinsho/bufferline.nvim', config = register_config('bufferline') }, -- Buffer and tab line
    ----------------------------- }

    -- Miscellaneous {
    { 'kyazdani42/nvim-web-devicons' }, -- Programming icons
    { 'glepnir/indent-guides.nvim', event = { 'BufRead', 'BufNewFile' }, config = register_config('indent') }, -- Indent guide
    { 'norcalli/nvim-colorizer.lua', event = { 'BufRead', 'BufNewFile' }, config = register_config('colorizer') }, -- Color highlight
    { 'karb94/neoscroll.nvim', config = register_config('neoscroll') }, -- Smooth scrolling
    { 'SmiteshP/nvim-gps', config = register_config('gps'), after = 'nvim-treesitter' }, -- Component to show context of current position
    { 'p00f/nvim-ts-rainbow', config = register_config('rainbow'), after = 'nvim-treesitter' }, -- Rainbow parentheses
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
    { 'mcauley-penney/tidy.nvim', event = 'BufWritePre' }, -- Remove trailing whitespace and empty line before EOF
    { 'numToStr/Comment.nvim', config = register_config('comment') }, -- Commenting
    { 'ms-jpq/coq_nvim', branch = 'coq', run = ':COQdeps', config = register_config('coq') }, -- Code complete engine
    -- Complete source {
    { 'ms-jpq/coq.thirdparty', branch = '3p', config = register_config('coq_3rd') }, -- Shell REPL, Mathematic, Nvim LUA
    { 'neovim/nvim-lspconfig' }, -- LSP
    -- }
    { 'ms-jpq/coq.artifacts', branch = 'artifacts' }, -- Snippet
    { 'gpanders/editorconfig.nvim', event = { 'BufRead', 'BufNewFile' }, config = register_config('editorconfig') }, -- Convention
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
    --------- }
    -- Linter and Fixer {
    { 'mfussenegger/nvim-lint', config = register_config('linter') }, -- Linter for most common languages
    { 'dense-analysis/ale', config = register_config('ale') }, -- Linter for other languages and tools, combine fixer
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
    { 'akinsho/nvim-toggleterm.lua', config = register_config('toggleterm') }, -- Terminal
    { 'williamboman/nvim-lsp-installer', config = register_config('lsp_installer') }, -- Automatically ínstall language server
    -- Fuzzy finder {
    { -- Engine
        'nvim-telescope/telescope.nvim',
        config = register_config('telescope'),
        requires = {
            { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }, -- Increase performance with fzf (native port from Go to C)
        },
    },
    { -- Session search
        'rmagatti/session-lens',
        requires = { 'rmagatti/auto-session', 'nvim-telescope/telescope.nvim' },
        config = register_config('session_lens'),
        after = { 'telescope.nvim', 'auto-session' },
    },
    --------------- }
    ----------------------------- }

    ---------- Utility ---------- {
    { 'nvim-orgmode/orgmode', config = register_config('orgmode'), after = 'nvim-treesitter' }, -- Note taking
    { 'rmagatti/auto-session', config = register_config('auto_session') }, -- Automatic session management
    DEBUG and { 'nvim-treesitter/playground' } or nil,
    ----------------------------- }
}
