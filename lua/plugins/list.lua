-- vim:foldmethod=marker:foldmarker={,}
----------------------------------------------
--       List of all common plugins         --
----------------------------------------------
return {
  ----------- Base ------------ {
  { 'nvim-lua/plenary.nvim', name = 'plenary' }, -- Base Lua functions
  { 'MunifTanjim/nui.nvim', name = 'nui' }, -- UI component library
  DEBUG and { 'dstein64/vim-startuptime', cmd = 'StartupTime' } or nil, -- View startup timing
  ----------------------------- }

  -------- Eyecandy ----------- {
  -- Color scheme {
  { -- Catppuccin for both Dark (Macchiato) and Light (Latte) colorscheme
    'catppuccin/nvim',
    name = 'catppuccin',
    event = 'UIEnter',
  },
  --------------- }

  -- Status and tab/buffer line {
  { -- Status line
    'nvim-lualine/lualine.nvim',
    name = 'lualine',
    event = 'UIEnter',
    dependencies = { 'catppuccin' },
  },
  { -- Buffer and tab line
    'akinsho/bufferline.nvim',
    name = 'bufferline',
    event = 'UIEnter',
    dependencies = { 'catppuccin' },
  },
  ----------------------------- }

  -- Quickfix and diagnostics {
  { 'folke/trouble.nvim', name = 'trouble' }, -- Highlight quickfix and diagnostics
  { -- Show virtual lines for LSP diagnostics
    url = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    name = 'lsp_lines',
    event = 'UIEnter',
  },
  { -- Highlight TODO comments
    'folke/todo-comments.nvim',
    name = 'todo',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'plenary' },
  },
  --------------------------- }

  -- Miscellaneous {
  { -- Improve vim.ui.select and vim.ui.input
    'stevearc/dressing.nvim',
    name = 'dressing',
  },
  { -- Improve wildmenu's capabilities
    'gelguy/wilder.nvim',
    name = 'wilder',
    event = 'CmdlineEnter',
    build = ':UpdateRemotePlugins',
  },
  { -- Improve messages, cmdline, popups & LSP
    'folke/noice.nvim',
    name = 'noice',
    event = 'VeryLazy',
    dependencies = { 'nui' },
  },
  { 'nvim-tree/nvim-web-devicons', name = 'icon', event = 'UIEnter' }, -- Programming icons
  { -- Indent guide
    'lukas-reineke/indent-blankline.nvim',
    name = 'indent',
    event = { 'BufReadPost' },
  },
  { -- Color highlight
    'NvChad/nvim-colorizer.lua',
    name = 'colorizer',
    event = { 'BufRead', 'BufNewFile' },
  },
  { -- Winbar to show context of current position
    'utilyre/barbecue.nvim',
    name = 'barbecue',
    event = 'UIEnter',
    dependencies = { 'SmiteshP/nvim-navic', 'catppuccin' },
  },
  { -- Rainbow parentheses
    'p00f/nvim-ts-rainbow',
    name = 'rainbow',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  { 'rmagatti/goto-preview', name = 'goto_preview' }, -- UI view for preview LSP definition, implementation, reference
  { -- UI view for LSP code action lightbulb
    'kosayoda/nvim-lightbulb',
    name = 'lightbulb',
    event = { 'BufRead', 'BufNewFile' },
  },
  { -- Inlayhints for LSP
    'lvimuser/lsp-inlayhints.nvim',
    name = 'lsp_inlay',
    event = { 'BufRead', 'BufNewFile' },
  },
  { 'rcarriga/nvim-dap-ui', name = 'dap_ui' }, -- Debugger UI
  { 'theHamsta/nvim-dap-virtual-text', name = 'dap_virtual_text' }, -- Virtual text for DAP
  { -- UI for dadbod
    'kristijanhusak/vim-dadbod-ui',
    name = 'dadbod_ui',
    dependencies = { 'dadbod' },
  },
  { -- Explain Regex when hover
    'bennypowers/nvim-regexplainer',
    name = 'regexplainer',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'nui', 'treesitter' },
  },
  { -- Foldtext customization
    'anuvyklack/pretty-fold.nvim',
    name = 'pretty_fold',
    event = 'UIEnter',
    dependencies = {
      'anuvyklack/keymap-amend.nvim',
      'anuvyklack/fold-preview.nvim',
    },
  },
  { 'rcarriga/nvim-notify', name = 'notify', event = 'UIEnter' }, -- Notification
  --------------- }
  ----------------------------- }

  --------- Navigation -------- {
  { 'nvim-neo-tree/neo-tree.nvim', name = 'neotree' }, -- File explorer
  { url = 'https://gitlab.com/yorickpeterse/nvim-window', name = 'window' }, -- Window switcher
  { -- UI view for Symbols
    'simrat39/symbols-outline.nvim',
    name = 'symbols_outline',
  },
  { 'phaazon/hop.nvim', name = 'hop' }, -- Easymotion
  { 'numToStr/Navigator.nvim', name = 'neomux', event = 'UIEnter' }, -- Smoothly navigate between neovim and tmux
  ----------------------------- }

  ------ VCS and Project ------ {
  { -- Git TUI
    'TimUntersberger/neogit',
    name = 'neogit',
    dependencies = { 'sindrets/diffview.nvim' },
  },
  { 'lewis6991/gitsigns.nvim', name = 'gitsigns', event = 'BufReadPre' }, -- Git decoration
  { 'tpope/vim-projectionist', lazy = false }, -- Granular project configuration
  { 'klen/nvim-config-local', name = 'local_config', event = 'VeryLazy' }, -- Load local config file
  ----------------------------- }

  ---------- Editing ---------- {
  -- Comment {
  { 'echasnovski/mini.comment', name = 'comment', event = 'VeryLazy' }, -- Commenting
  { -- Comment based on cursor location
    'JoosepAlviste/nvim-ts-context-commentstring',
    name = 'context_comment',
    dependencies = { 'treesitter', 'comment' },
  },
  { -- Generate annotation
    'danymat/neogen',
    name = 'neogen',
    dependencies = { 'treesitter' },
  },
  ---------- }
  { -- Code complete engine
    'hrsh7th/nvim-cmp',
    name = 'cmp',
    event = 'InsertEnter',
    dependencies = {
      'luasnip',
      { 'hrsh7th/cmp-nvim-lsp' }, -- LSP completion source
      { 'onsails/lspkind.nvim' }, -- LSP completion pictograms
      { 'saadparwaiz1/cmp_luasnip', dependencies = { 'luasnip' } }, -- Snippet completion source
      { 'hrsh7th/cmp-buffer' }, -- Buffer completion source
      { 'hrsh7th/cmp-calc' }, -- Math calculation
      { 'hrsh7th/cmp-path' }, -- Path completion source
      { 'andersevenrud/cmp-tmux' }, -- Tmux completion source
      { 'rcarriga/cmp-dap', dependencies = { 'dap' } }, -- DAP completion source
      { 'uga-rosa/cmp-dynamic', name = 'cmp_dynamic' }, -- Dynamic completion source
      { 'wxxxcxx/cmp-browser-source', name = 'cmp_browser' }, -- Vivaldi completion source
      { 'hrsh7th/cmp-copilot', dependencies = { 'zbirenbaum/copilot.vim' } }, -- Copilot completion source
    },
  },
  { -- Snippet engine
    'L3MON4D3/LuaSnip',
    name = 'luasnip',
    dependencies = {
      { 'rafamadriz/friendly-snippets' }, -- VSCode snippets
      { 'honza/vim-snippets' }, -- Snipmate snippets
    },
  },
  { -- Convention
    'gpanders/editorconfig.nvim',
    name = 'editorconfig',
    event = { 'BufRead', 'BufNewFile' },
  },
  -- LSP {
  { 'neovim/nvim-lspconfig', name = 'lsp', event = 'BufReadPre' }, -- Config for LSP server
  { -- LSP server manager
    'williamboman/mason-lspconfig.nvim',
    name = 'mason_lsp',
    event = 'BufReadPre',
    dependencies = { 'mason' },
  },
  { -- Config for non-LSP sources (linter and formatter)
    'jose-elias-alvarez/null-ls.nvim',
    name = 'null_ls',
    event = 'VeryLazy',
    dependencies = { 'refactoring' },
  },
  { -- Linter and Formatter manager
    'jayp0521/mason-null-ls.nvim',
    name = 'mason_null_ls',
    dependencies = { 'mason' },
  },
  ------ }
  -- Treesitter {
  { -- Config for Treesitter
    'nvim-treesitter/nvim-treesitter',
    name = 'treesitter',
    event = { 'BufRead', 'BufNewFile' },
    build = ':TSUpdate',
  },
  { -- Text object for Treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    name = 'text_object',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  { -- Automatically close and rename HTML tag
    'windwp/nvim-ts-autotag',
    name = 'autotag',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  { -- Automatically insert end keyword
    'RRethy/nvim-treesitter-endwise',
    name = 'endwise',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  ------------- {
  -- Syntax highlight {
  vim.fn.system('grep -is "Gentoo" /etc/os-release') ~= '' and {
    'gentoo/gentoo-syntax',
  } or nil, -- For gentoo filetypes
  ------------------- }
  -- Typing {
  { -- Automatically insert/delete brackets, parentheses, quotes...
    'windwp/nvim-autopairs',
    name = 'autopairs',
    event = { 'BufRead', 'BufNewFile' },
  },
  { 'monaqa/dial.nvim', name = 'dial' }, -- Increment/decrement number, date...
  { 'echasnovski/mini.surround', name = 'surround' }, -- Change surround character
  { 'johmsalas/text-case.nvim', name = 'textcase' }, -- Convert text case
  --------- }
  { -- Refactoring library
    'ThePrimeagen/refactoring.nvim',
    name = 'refactoring',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'treesitter' },
  },
  ----------------------------- }

  ---- Debug / Test / Run ----- {
  { -- Debug Adapter implementation
    'mfussenegger/nvim-dap',
    name = 'dap',
    dependencies = { 'dap_ui', 'dap_virtual_text' },
  },
  { -- DAP manager
    'jayp0521/mason-nvim-dap.nvim',
    name = 'mason_dap',
    event = 'BufReadPre',
    dependencies = { 'mason', 'dap' },
  },
  { -- Test integration
    'nvim-neotest/neotest',
    name = 'neotest',
    dependencies = {
      { 'nvim-neotest/neotest-vim-test' }, -- Test runner compatibility that support vim-test
    },
  },
  { 'stevearc/overseer.nvim', name = 'overseer' }, -- Task runner
  ----------------------------- }

  -- -------- Integration -------- {
  { -- Browser
    'glacambre/firenvim',
    name = 'firenvim',
    event = 'UIEnter',
    build = function()
      vim.fn['firenvim#install'](0)
    end,
    cond = vim.g.started_by_firenvim,
  },
  { 'folke/which-key.nvim', name = 'whichkey', lazy = false }, -- Show guide of keymaps
  { 'akinsho/nvim-toggleterm.lua', name = 'toggleterm', event = 'VeryLazy' }, -- Terminal
  -- Fuzzy finder {
  { -- Engine
    'nvim-telescope/telescope.nvim',
    name = 'telescope',
    dependencies = {
      'plenary',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, -- Increase performance with fzf (native port from Go to C)
    },
    cmd = 'Telescope',
  },
  { 'potamides/pantran.nvim', name = 'pantran', cmd = 'Pantran' }, -- Translate
  { 'ofirgall/open.nvim', name = 'open' }, -- Open current word by other tools
  { 'tpope/vim-dadbod', name = 'dadbod' }, -- Interact with database
  { -- Google Keep integration
    'stevearc/gkeep.nvim',
    name = 'gkeep',
    build = ':UpdateRemotePlugins',
  },
  --------------- }
  ----------------------------- }

  -- ---------- Utility ---------- {
  { 'olimorris/persisted.nvim', name = 'session', event = 'UIEnter' }, -- Automatic session management
  DEBUG and { -- Debug Treesitter
    'nvim-treesitter/playground',
    name = 'playground',
    dependencies = { 'treesitter' },
    cmd = 'TSPlaygroundToggle',
  } or nil,
  {
    'williamboman/mason.nvim', -- Automatically ínstall language server, linter, dap server
    name = 'mason',
  },
  ----------------------------- }
}
