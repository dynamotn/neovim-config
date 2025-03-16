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
      local parser_config =
        require('nvim-treesitter.parsers').get_parser_configs()
      for name, language in pairs(require('config.languages')) do
        for _, parser in ipairs(language.parsers or {}) do
          -- Parse config
          local parser_name = ''
          if type(parser) == 'string' then
            parser_name = parser
            for _, ft in pairs(language.filetypes) do
              vim.treesitter.language.register(parser, ft)
            end
          elseif type(parser) == 'table' then
            parser_name = parser[1]
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
          end

          -- install parser of language in bundle languages
          if vim.list_contains(_G.bundle_languages, name) then
            table.insert(opts.ensure_installed, { parser_name })
          end
          -- lazy install parser of language not in bundle languages
          if vim.list_contains(_G.enabled_languages, name) then
            vim.api.nvim_create_autocmd({ 'FileType' }, {
              pattern = language.filetypes,
              group = vim.api.nvim_create_augroup(
                'ts_parser_' .. parser_name,
                {}
              ),
              callback = function()
                if
                  next(
                    vim.api.nvim_get_runtime_file(
                      'parser/' .. parser_name .. '.so',
                      true
                    )
                  ) == nil
                then
                  vim.api.nvim_command('TSInstall ' .. parser_name)
                end
              end,
            })
          end
        end
      end

      -- Setup from opts
      if type(opts.ensure_installed) == 'table' then
        opts.ensure_installed = LazyVim.dedup(opts.ensure_installed)
      end
      require('nvim-treesitter.configs').setup(opts)

      -- Setup predicates
      for predicate, regex in pairs(opts.custom_predicates) do
        require('vim.treesitter.query').add_predicate(
          predicate,
          function(_, _, bufnr, _)
            local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
            local filename = vim.fn.fnamemodify(filepath, ':t')
            return string.match(filename, regex)
          end,
          { force = true, all = false }
        )
      end
    end,
  },
}
