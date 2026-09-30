local language = require('config.languages').swift

return vim.list_contains(_G.enabled_languages, 'swift')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            sourcekit = {
              -- an Xcode project, a build server description or a package
              -- manifest each mark the root of a Swift project
              root_markers = {
                'buildServer.json',
                'Package.swift',
                '.git',
              },
            },
          },
        },
      },
      {
        -- Build, run and test an Xcode project without leaving the editor
        'wojciech-kulik/xcodebuild.nvim',
        ft = language.filetypes,
        cmd = { 'XcodebuildPicker', 'XcodebuildBuild', 'XcodebuildTest' },
        dependencies = {
          'MunifTanjim/nui.nvim',
          -- the plugin needs a picker; this config already has this one
          'folke/snacks.nvim',
        },
        opts = {
          code_coverage = { enabled = true },
        },
        keys = {
          {
            '<localleader>x',
            '<cmd>XcodebuildPicker<cr>',
            ft = language.filetypes,
            desc = 'Xcodebuild actions',
          },
          {
            '<localleader>xb',
            '<cmd>XcodebuildBuild<cr>',
            ft = language.filetypes,
            desc = 'Build project',
          },
          {
            '<localleader>xr',
            '<cmd>XcodebuildBuildRun<cr>',
            ft = language.filetypes,
            desc = 'Build and run project',
          },
          {
            '<localleader>xt',
            '<cmd>XcodebuildTest<cr>',
            ft = language.filetypes,
            desc = 'Run tests',
          },
          {
            '<localleader>xT',
            '<cmd>XcodebuildTestClass<cr>',
            ft = language.filetypes,
            desc = 'Run this test class',
          },
          {
            '<localleader>xd',
            '<cmd>XcodebuildSelectDevice<cr>',
            ft = language.filetypes,
            desc = 'Select device',
          },
          {
            '<localleader>xc',
            '<cmd>XcodebuildToggleCodeCoverage<cr>',
            ft = language.filetypes,
            desc = 'Toggle code coverage',
          },
          {
            '<localleader>xl',
            '<cmd>XcodebuildToggleLogs<cr>',
            ft = language.filetypes,
            desc = 'Toggle logs',
          },
        },
      },
    }
  or {}
