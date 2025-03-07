return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- I don't want to use default LazyVim parsers
    opts = function(_, opts)
      opts.ensure_installed = {
        'diff', -- for diff file
        'comment', -- for comment tags
        'query', -- for treesitter itself query
        'regex', -- for regex
        'vim', -- for old vim script
        'vimdoc', -- for vim help files
        'git_config', -- for git config
        'gitignore', -- for git ignore
        'gitattributes', -- for git attributes
      }
    end,
    config = function(_, opts)
      -- Setup treesitter parser to work with defined filetypes
      local builtin_supported_filetypes = {}
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      for name, language in pairs(require('config.languages')) do
        vim.list_extend(builtin_supported_filetypes, language.filetypes)

        if type(language.parsers) == 'table' then
          for _, parser in ipairs(language.parsers) do
            if type(parser) == 'string' then
              for _, ft in pairs(language.filetypes) do
                vim.treesitter.language.register(parser, ft)
              end
              if vim.list_contains(_G.bundle_languages, name) then table.insert(opts.ensure_installed, { parser }) end
            elseif type(parser) == 'table' then
              local parser_name = parser[1]
              if parser_config[parser_name] then
                parser_config[parser_name]['filetypes'] = language.filetypes
                parser_config[parser_name]['install_info'] = parser.install_info
              else
                parser_config[parser_name] = {
                  filetypes = language.filetypes,
                  ---@type DyParserInstallSpec
                  install_info = parser.install_info,
                  filetype = '',
                  maintainers = { 'me@dynamotn.dev' },
                }
              end
              for _, ft in pairs(language.filetypes) do
                vim.treesitter.language.register(parser_name, ft)
              end
              if vim.list_contains(_G.bundle_languages, name) then
                table.insert(opts.ensure_installed, { parser_name })
              end
            end
          end
        end
      end

      -- Setup from opts
      if type(opts.ensure_installed) == 'table' then opts.ensure_installed = LazyVim.dedup(opts.ensure_installed) end
      require('nvim-treesitter.configs').setup(opts)

      -- Automatic install parsers for window buffer
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = builtin_supported_filetypes,
        group = vim.api.nvim_create_augroup('ts_parser_manager', {}),
        callback = function()
          local parsers = require('util.languages').get_parsers_by_filetype(vim.bo.filetype)
          for _, parser in ipairs(parsers) do
            if next(vim.api.nvim_get_runtime_file('parser/' .. parser .. '.so', true)) == nil then
              vim.api.nvim_command('TSInstall ' .. parser)
            end
          end
        end,
      })
    end,
  },
}
