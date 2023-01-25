-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------------
--       List of all common plugins         --
----------------------------------------------
local register_config = require('plugins.register').register_config
local register_setup = require('plugins.register').register_setup

return {
  ----------- Base ------------ {
  { 'nvim-lua/plenary.nvim', name = 'plernary', lazy = false }, -- Base Lua functions
  { 'dstein64/vim-startuptime', cmd = 'StartupTime', cond = DEBUG }, -- View startup timing
  ----------------------------- }

  -------- Eyecandy ----------- {
  -- Color scheme {
  { 'navarasu/onedark.nvim', name = 'onedark', config = register_config, event = 'UIEnter' }, -- OneDark for both Dark and Light colorscheme
  --------------- }

  -- Status and tab/buffer line {
  {
    'nvim-lualine/lualine.nvim',
    name = 'lualine',
    config = register_config,
    event = 'UIEnter',
    dependencies = { 'onedark' },
  }, -- Status line
  { 'akinsho/bufferline.nvim', name = 'bufferline', config = register_config, event = 'UIEnter' }, -- Buffer and tab line
  ----------------------------- }

  -- Quickfix and diagnostics {
  { 'folke/trouble.nvim', name = 'trouble', config = register_config, cmd = 'TroubleToggle' }, -- Highlight quickfix and diagnostics
  {
    url = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    name = 'lsp_lines',
    config = register_config,
    event = 'UIEnter',
  }, -- Show virtual lines for LSP diagnostics
  { 'folke/todo-comments.nvim', name = 'todo', config = register_config, dependencies = { 'plernary' } }, -- Highlight TODO comments
  --------------------------- }

  -- Miscellaneous {
  { 'MunifTanjim/nui.nvim' }, -- UI component library
  { 'stevearc/dressing.nvim', name = 'dressing', config = register_config, event = 'VeryLazy' }, -- Improve vim.ui.select and vim.ui.input
  { -- Improve wildmenu's capabilities
    'gelguy/wilder.nvim',
    name = 'wilder',
    config = register_config,
    build = ':UpdateRemotePlugins',
    event = 'CmdlineEnter',
  },
  { 'folke/noice.nvim', name = 'noice', config = register_config }, -- Improve messages, cmdline, popups & LSP
  { 'kyazdani42/nvim-web-devicons', name = 'icon', config = register_config }, -- Programming icons
  { 'glepnir/indent-guides.nvim', event = { 'BufRead', 'BufNewFile' }, name = 'indent', config = register_config }, -- Indent guide
  { 'norcalli/nvim-colorizer.lua', event = { 'BufRead', 'BufNewFile' }, name = 'colorizer', config = register_config }, -- Color highlight
  { 'karb94/neoscroll.nvim', name = 'neoscroll', config = register_config }, -- Smooth scrolling
  { 'utilyre/barbecue.nvim', name = 'barbecue', config = register_config, dependencies = { 'SmiteshP/nvim-navic' } }, -- Winbar to show context of current position
  { 'p00f/nvim-ts-rainbow', name = 'rainbow', config = register_config, dependencies = { 'treesitter' } }, -- Rainbow parentheses
  { 'simrat39/symbols-outline.nvim', name = 'symbols_outline', config = register_config }, -- UI view for Symbols
  { 'rmagatti/goto-preview', name = 'goto_preview', config = register_config }, -- UI view for preview LSP definition, implementation, reference
  { 'kosayoda/nvim-lightbulb', name = 'lightbulb', config = register_config }, -- UI view for LSP code action lightbulb
  { 'lvimuser/lsp-inlayhints.nvim', name = 'lsp_inlay', config = register_config }, -- Inlayhints for LSP
  { 'rcarriga/nvim-dap-ui', dependencies = { 'dap' }, name = 'dap_ui', config = register_config }, -- Debugger UI
  { 'theHamsta/nvim-dap-virtual-text', dependencies = { 'dap' }, name = 'dap_virtual_text', config = register_config }, -- Virtual text for DAP
  { 'kristijanhusak/vim-dadbod-ui', name = 'dadbod_ui', config = register_config }, -- UI for dadbod
  { -- Foldtext customization
    'anuvyklack/pretty-fold.nvim',
    name = 'pretty_fold',
    config = register_config,
    dependencies = {
      'anuvyklack/keymap-amend.nvim',
      'anuvyklack/fold-preview.nvim',
    },
  },
  { 'rcarriga/nvim-notify', name = 'notify', config = register_config }, -- Notification
  --------------- }
  ----------------------------- }

  --------- Navigation -------- {
  { -- File explorer
    'nvim-neo-tree/neo-tree.nvim',
    cmd = { 'Neotree' },
    name = 'neotree',
    config = register_config,
  },
  { url = 'https://gitlab.com/yorickpeterse/nvim-window', name = 'window', config = register_config }, -- Window switcher
  { 'chentoast/marks.nvim', name = 'marks', config = register_config }, -- Show mark and switch to mark
  { 'phaazon/hop.nvim', name = 'hop', config = register_config }, -- Easymotion
  ----------------------------- }

  ------ VCS and Project ------ {
  { 'TimUntersberger/neogit', name = 'neogit', config = register_config, cmd = { 'Neogit' } }, -- Git TUI
  { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewFileHistory' } }, -- Diff view
  { 'lewis6991/gitsigns.nvim', name = 'gitsigns', config = register_config }, -- Git decoration
  { 'tpope/vim-projectionist', lazy = false }, -- Granular project configuration
  { 'klen/nvim-config-local', name = 'local_config', config = register_config }, -- Load local config file
  ----------------------------- }

  ---------- Editing ---------- {
  { 'ethanholz/nvim-lastplace', name = 'lastplace', config = register_config }, -- Save the last edit position
  -- Comment {
  { 'numToStr/Comment.nvim', name = 'comment', config = register_config, event = 'VeryLazy' }, -- Commenting
  { -- Comment based on cursor location
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'treesitter', 'comment' },
    name = 'context_comment',
    config = register_config,
  },
  { -- Generate annotation
    'danymat/neogen',
    dependencies = { 'treesitter' },
    name = 'neogen',
    config = register_config,
  },
  ---------- }
  { -- Code complete engine
    'hrsh7th/nvim-cmp',
    name = 'cmp',
    event = 'InsertEnter',
    config = register_config,
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' }, -- LSP completion source
      { 'onsails/lspkind.nvim' }, -- LSP completion pictograms
      { 'saadparwaiz1/cmp_luasnip', dependencies = 'luasnip' }, -- Snippet completion source
      { 'hrsh7th/cmp-buffer' }, -- Buffer completion source
      { 'hrsh7th/cmp-calc' }, -- Math calculation
      { 'hrsh7th/cmp-path' }, -- Path completion source
      { 'andersevenrud/cmp-tmux' }, -- Tmux completion source
      { 'rcarriga/cmp-dap', dependencies = { 'dap' } }, -- DAP completion source
      { 'uga-rosa/cmp-dynamic', name = 'cmp_dynamic', config = register_config }, -- Dynamic completion source
      { 'wxxxcxx/cmp-browser-source', name = 'cmp_browser', config = register_config }, -- Vivaldi completion source
      { 'hrsh7th/cmp-copilot', dependencies = { 'zbirenbaum/copilot.vim' } }, -- Copilot completion source
    },
  },
  { -- Snippet engine
    'L3MON4D3/LuaSnip',
    name = 'luasnip',
    config = register_config,
    dependencies = {
      { 'rafamadriz/friendly-snippets' }, -- VSCode snippets
      { 'honza/vim-snippets' }, -- Snipmate snippets
    },
  },
  {
    'gpanders/editorconfig.nvim',
    event = { 'BufRead', 'BufNewFile' },
    name = 'editorconfig',
    config = register_config,
  }, -- Convention
  -- LSP {
  { 'neovim/nvim-lspconfig', name = 'lsp', config = register_config }, -- Config for LSP server
  { 'williamboman/mason-lspconfig.nvim', name = 'mason_lsp', config = register_config, dependencies = { 'mason' } }, -- LSP server manager
  { 'jose-elias-alvarez/null-ls.nvim', name = 'null_ls', config = register_config }, -- Config for non-LSP sources (linter and formatter)
  { 'jayp0521/mason-null-ls.nvim', name = 'mason_null_ls', config = register_config, dependencies = { 'mason' } }, -- Linter and Formatter manager
  ------ }
  { -- TreeSitter
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufRead', 'BufNewFile' },
    build = ':TSUpdate',
    name = 'treesitter',
    config = register_config,
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  -- Syntax highlight {
  { 'gentoo/gentoo-syntax' }, -- For gentoo filetypes
  ------------------- }
  -- Typing {
  { 'windwp/nvim-autopairs', event = { 'BufRead', 'BufNewFile' }, name = 'autopairs', config = register_config }, -- Automatically insert/delete brackets, parentheses, quotes...
  { -- Automatically close and rename HTML tag
    'windwp/nvim-ts-autotag',
    event = { 'BufRead', 'BufNewFile' },
    name = 'autotag',
    config = register_config,
    dependencies = { 'treesitter' },
  },
  { -- Automatically insert end keyword
    'RRethy/nvim-treesitter-endwise',
    event = { 'BufRead', 'BufNewFile' },
    name = 'endwise',
    config = register_config,
    dependencies = { 'treesitter' },
  },
  { 'monaqa/dial.nvim', name = 'dial', config = register_config }, -- Increment/decrement number, date...
  { 'ur4ltz/surround.nvim', name = 'surround', config = register_config }, -- Change surround character
  { 'johmsalas/text-case.nvim', name = 'textcase', config = register_config }, -- Convert text case
  --------- }
  { 'ThePrimeagen/refactoring.nvim', name = 'refactoring', config = register_config, dependencies = { 'treesitter' } }, -- Refactoring library
  { 'bennypowers/nvim-regexplainer', name = 'regexplainer', config = register_config }, -- Explain Regex when hover
  ----------------------------- }

  ---- Debug / Test / Run ----- {
  { 'mfussenegger/nvim-dap', name = 'dap', config = register_config }, -- Debug Adapter implementation
  { 'jayp0521/mason-nvim-dap.nvim', name = 'mason_dap', config = register_config, dependencies = { 'mason', 'dap' } }, -- DAP manager
  { 'nvim-neotest/neotest', name = 'neotest', config = register_config }, -- Test integration
  { 'nvim-neotest/neotest-vim-test', before = 'neotest' }, -- Test runner compatibility that support vim-test
  { 'stevearc/overseer.nvim', name = 'overseer', config = register_config }, -- Task runner
  ----------------------------- }

  -------- Integration -------- {
  { -- Browser
    'glacambre/firenvim',
    build = function()
      vim.fn['firenvim#install'](0)
    end,
    name = 'firenvim',
    config = register_config,
  },
  { 'folke/which-key.nvim', name = 'whichkey', config = register_config, event = 'VeryLazy' }, -- Show guide of keymaps
  { 'akinsho/nvim-toggleterm.lua', name = 'toggleterm', config = register_config }, -- Terminal
  -- Fuzzy finder {
  { -- Engine
    'nvim-telescope/telescope.nvim',
    name = 'telescope',
    config = register_config,
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, -- Increase performance with fzf (native port from Go to C)
    },
  },
  { 'potamides/pantran.nvim', name = 'pantran', config = register_config }, -- Translate
  { 'ofirgall/open.nvim', name = 'open', config = register_config }, -- Open current word by other tools
  { 'tpope/vim-dadbod' }, -- Interact with database
  { -- Google Keep integration
    'stevearc/gkeep.nvim',
    build = ':UpdateRemotePlugins',
    name = 'gkeep',
    config = register_config,
    setup = register_setup('gkeep'),
  },
  --------------- }
  ----------------------------- }

  ---------- Utility ---------- {
  { 'olimorris/persisted.nvim', name = 'session', config = register_config }, -- Automatic session management
  {
    'nvim-treesitter/playground',
    name = 'playground',
    config = register_config,
    dependencies = { 'treesitter' },
    cond = DEBUG,
  },
  {
    'williamboman/mason.nvim', -- Automatically ínstall language server, linter, dap server
    name = 'mason',
    config = register_config,
  },
  ----------------------------- }
}
