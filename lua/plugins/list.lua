-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------------
--       List of all common plugins         --
----------------------------------------------
local register_config = require('plugins.register').register_config
local register_setup = require('plugins.register').register_setup

return {
  ----------- Base ------------ {
  { 'wbthomason/packer.nvim', event = 'VimEnter' }, -- Plugin manager
  { 'nvim-lua/plenary.nvim' }, -- Base Lua functions
  { 'nathom/filetype.nvim', config = register_config('filetype') }, -- Detect filetype
  DEBUG and { 'dstein64/vim-startuptime' } or nil, -- View startup timing
  { 'lewis6991/impatient.nvim', config = register_config('impatient') }, -- Improve startup time
  { 'antoinemadec/FixCursorHold.nvim', config = register_config('cursor_hold') }, -- Fix CursorHold performance
  { -- Improve wildmenu's capabilities
    'gelguy/wilder.nvim',
    config = register_config('wilder'),
    run = ':UpdateRemotePlugins',
    event = 'CmdlineEnter',
  },
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
  { 'folke/trouble.nvim', config = register_config('trouble') }, -- Highlight quickfix and diagnostics
  { 'folke/todo-comments.nvim', config = register_config('todo') }, -- Highlight TODO comments
  --------------------------- }

  -- Miscellaneous {
  { 'stevearc/dressing.nvim', config = register_config('dressing') }, -- Improve vim.ui.select and vim.ui.input
  { 'kyazdani42/nvim-web-devicons', config = register_config('icon') }, -- Programming icons
  { 'glepnir/indent-guides.nvim', event = { 'BufRead', 'BufNewFile' }, config = register_config('indent') }, -- Indent guide
  { 'norcalli/nvim-colorizer.lua', event = { 'BufRead', 'BufNewFile' }, config = register_config('colorizer') }, -- Color highlight
  { 'karb94/neoscroll.nvim', config = register_config('neoscroll') }, -- Smooth scrolling
  { 'utilyre/barbecue.nvim', config = register_config('barbecue'), requires = { 'SmiteshP/nvim-navic' } }, -- Winbar to show context of current position
  { 'p00f/nvim-ts-rainbow', config = register_config('rainbow'), after = 'nvim-treesitter' }, -- Rainbow parentheses
  { 'tami5/lspsaga.nvim', config = register_config('lspsaga') }, -- UI for LSP
  { 'simrat39/symbols-outline.nvim', config = register_config('symbols_outline') }, -- UI view for Symbols
  { 'ray-x/lsp_signature.nvim', config = register_config('lsp_signature') }, -- Show LSP function signature
  { 'j-hui/fidget.nvim', config = register_config('fidget') }, -- Show LSP progress
  { 'rcarriga/nvim-dap-ui', after = 'nvim-dap', config = register_config('dap_ui') }, -- Debugger UI
  { 'theHamsta/nvim-dap-virtual-text', after = 'nvim-dap', config = register_config('dap_virtual_text') }, -- Virtual text for DAP
  { 'kristijanhusak/vim-dadbod-ui', config = register_config('dadbod_ui') }, -- UI for dadbod
  { -- Foldtext customization
    'anuvyklack/pretty-fold.nvim',
    config = register_config('pretty_fold'),
    requires = {
      'anuvyklack/keymap-amend.nvim',
      'anuvyklack/fold-preview.nvim',
    },
  },
  { 'rcarriga/nvim-notify', config = register_config('notify') }, -- Notification
  --------------- }
  ----------------------------- }

  --------- Navigation -------- {
  { -- File explorer
    'nvim-neo-tree/neo-tree.nvim',
    cmd = { 'Neotree' },
    config = register_config('neotree'),
    requires = {
      { 'MunifTanjim/nui.nvim' },
    },
  },
  { 'https://gitlab.com/yorickpeterse/nvim-window', config = register_config('window') }, -- Window switcher
  { 'chentoast/marks.nvim', config = register_config('marks') }, -- Show mark and switch to mark
  ----------------------------- }

  ------ VCS and Project ------ {
  { 'TimUntersberger/neogit', config = register_config('neogit'), cmd = { 'Neogit' } }, -- Git TUI
  { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewFileHistory' } }, -- Diff view
  { 'lewis6991/gitsigns.nvim', config = register_config('gitsigns') }, -- Git decoration
  { 'tpope/vim-projectionist' }, -- Granular project configuration
  ----------------------------- }

  ---------- Editing ---------- {
  { 'ethanholz/nvim-lastplace', config = register_config('lastplace') }, -- Save the last edit position
  -- Comment {
  { 'numToStr/Comment.nvim', config = register_config('comment') }, -- Commenting
  { -- Comment based on cursor location
    'JoosepAlviste/nvim-ts-context-commentstring',
    after = { 'nvim-treesitter', 'Comment.nvim' },
    config = register_config('context_comment'),
  },
  { -- Generate annotation
    'danymat/neogen',
    after = { 'nvim-treesitter' },
    config = register_config('neogen'),
  },
  ---------- }
  { -- Code complete engine
    'hrsh7th/nvim-cmp',
    config = register_config('cmp'),
    requires = {
      { 'hrsh7th/cmp-nvim-lsp' }, -- LSP completion source
      { 'onsails/lspkind.nvim' }, -- LSP completion pictograms
      { 'saadparwaiz1/cmp_luasnip' }, -- Snippet completion source
      { 'hrsh7th/cmp-buffer' }, -- Buffer completion source
      { 'hrsh7th/cmp-calc' }, -- Math calculation
      { 'hrsh7th/cmp-path' }, -- Path completion source
      { 'andersevenrud/cmp-tmux' }, -- Tmux completion source
      { 'tzachar/cmp-tabnine', run = './install.sh' }, -- Tabnine completion source
      { 'rcarriga/cmp-dap' }, -- DAP completion source
      { 'ray-x/cmp-treesitter' }, -- Treesitter completion source
      { 'uga-rosa/cmp-dynamic', config = register_config('cmp_dynamic') }, -- Dynamic completion source
      { 'wxxxcxx/cmp-browser-source', config = register_config('cmp_browser') }, -- Vivaldi completion source
    },
  },
  { -- Snippet engine
    'L3MON4D3/LuaSnip',
    config = register_config('luasnip'),
    requires = {
      { 'rafamadriz/friendly-snippets' }, -- VSCode snippets
      { 'honza/vim-snippets' }, -- Snipmate snippets
    },
  },
  { 'gpanders/editorconfig.nvim', event = { 'BufRead', 'BufNewFile' }, config = register_config('editorconfig') }, -- Convention
  -- LSP {
  { 'neovim/nvim-lspconfig', config = register_config('lsp') }, -- Config for LSP server
  { 'williamboman/mason-lspconfig.nvim', config = register_config('mason_lsp'), after = 'mason.nvim' }, -- LSP server manager
  { 'jose-elias-alvarez/null-ls.nvim', config = register_config('null_ls') }, -- Config for non-LSP sources (linter and formatter)
  { 'jayp0521/mason-null-ls.nvim', config = register_config('mason_null_ls'), after = 'mason.nvim' }, -- Linter and Formatter manager
  ------ }
  { -- TreeSitter
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufRead', 'BufNewFile' },
    run = ':TSUpdate',
    config = register_config('treesitter'),
  },
  -- Syntax highlight {
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
  { 'ur4ltz/surround.nvim', config = register_config('surround') }, -- Change surround character
  { 'johmsalas/text-case.nvim', config = register_config('textcase') }, -- Convert text case
  --------- }
  { 'ThePrimeagen/refactoring.nvim', config = register_config('refactoring'), after = 'nvim-treesitter' }, -- Refactoring library
  ----------------------------- }

  ---- Debug / Test / Run ----- {
  { 'mfussenegger/nvim-dap', config = register_config('dap') }, -- Debug Adapter implementation
  { 'jayp0521/mason-nvim-dap.nvim', config = register_config('mason_dap'), after = { 'mason.nvim', 'nvim-dap' } }, -- DAP manager
  { 'nvim-neotest/neotest', config = register_config('neotest') }, -- Test integration
  { 'nvim-neotest/neotest-vim-test', before = 'neotest' }, -- Test runner compatibility that support vim-test
  { 'stevearc/overseer.nvim', config = register_config('overseer') }, -- Task runner
  ----------------------------- }

  -------- Integration -------- {
  { -- Browser
    'glacambre/firenvim',
    run = function()
      vim.fn['firenvim#install'](0)
    end,
    config = register_config('firenvim'),
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
  { 'potamides/pantran.nvim', config = register_config('pantran') }, -- Translate
  { 'ofirgall/open.nvim', config = register_config('open') }, -- Open current word by other tools
  { 'tpope/vim-dadbod' }, -- Interact with database
  { -- Google Keep integration
    'stevearc/gkeep.nvim',
    run = 'UpdateRemotePlugins',
    config = register_config('gkeep'),
    setup = register_setup('gkeep'),
  },
  --------------- }
  ----------------------------- }

  ---------- Utility ---------- {
  { 'olimorris/persisted.nvim', config = register_config('session') }, -- Automatic session management
  DEBUG and { 'nvim-treesitter/playground', config = register_config('playground'), after = 'nvim-treesitter' } or nil,
  {
    'williamboman/mason.nvim', -- Automatically ínstall language server, linter, dap server
    config = register_config('mason'),
  },
  ----------------------------- }
}
