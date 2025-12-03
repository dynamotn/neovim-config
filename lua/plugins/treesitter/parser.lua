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
      local treesitter = require('nvim-treesitter')
      -- Setup from opts
      treesitter.setup(opts)
      LazyVim.treesitter.get_installed(true) -- initialize the installed langs

      -- Setup treesitter parser to work with defined filetypes
      local parsers = require('nvim-treesitter.parsers')
      for name, language in pairs(require('config.languages')) do
        if language.parser then
          -- Get my config
          local parser_name = ''
          local parser = language.parser
          if type(parser) == 'string' then
            parser_name = parser
          elseif type(parser) == 'table' then
            parser_name = parser[1]
            if parsers[parser_name] then
              vim.api.nvim_create_autocmd('User', {
                pattern = 'TSUpdate',
                callback = function()
                  parsers[parser_name].install_info = parser.install_info
                end,
              })
            else
              vim.api.nvim_create_autocmd('User', {
                pattern = 'TSUpdate',
                callback = function()
                  require('nvim-treesitter.parsers')[parser_name] = {
                    install_info = parser.install_info,
                    tier = 0,
                  }
                end,
              })
            end
          end
          for _, ft in pairs(language.filetypes) do
            vim.treesitter.language.register(parser_name, ft)
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
              callback = function(ev)
                if not LazyVim.treesitter.get_installed()[parser_name] then
                  treesitter
                    .install({ parser_name }, { summary = true })
                    :await(function()
                      LazyVim.treesitter.get_installed(true) -- refresh the installed langs
                      vim.cmd(string.format('%dbuffer', ev.buf))
                      vim.cmd('e!')
                    end)
                end
              end,
            })
          end
        end
      end

      -- install missing parsers
      opts.ensure_installed = LazyVim.dedup(opts.ensure_installed)
      local install = vim.tbl_filter(
        function(parser_name) return not LazyVim.treesitter.have(parser_name) end,
        opts.ensure_installed or {}
      )
      if #install > 0 then
        LazyVim.treesitter.build(function()
          treesitter.install(install, { summary = true }):await(function()
            LazyVim.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup(
          'lazyvim_treesitter',
          { clear = true }
        ),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not LazyVim.treesitter.have(ft) then return end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {} ---@type lazyvim.TSFeat
            return f.enable ~= false
              and not (type(f.disable) == 'table' and vim.tbl_contains(
                f.disable,
                lang
              ))
              and LazyVim.treesitter.have(ft, query)
          end

          -- highlighting
          if enabled('highlight', 'highlights') then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- indents
          if enabled('indent', 'indents') then
            LazyVim.set_default(
              'indentexpr',
              'v:lua.LazyVim.treesitter.indentexpr()'
            )
          end

          -- folds
          if enabled('folds', 'folds') then
            if LazyVim.set_default('foldmethod', 'expr') then
              LazyVim.set_default(
                'foldexpr',
                'v:lua.LazyVim.treesitter.foldexpr()'
              )
            end
          end
        end,
      })

      -- Setup predicates
      for predicate, regex in pairs(opts.custom_predicates or {}) do
        require('vim.treesitter.query').add_predicate(
          predicate,
          function(_, _, bufnr, _)
            local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
            local filename = vim.fn.fnamemodify(filepath, ':t')
            if type(regex) == 'string' then
              return string.match(filename, regex) == filename
            elseif type(regex) == 'table' then
              for _, r in ipairs(regex) do
                if string.match(filename, r) == filename then return true end
              end
              return false
            else
              return false
            end
          end,
          { force = true, all = false }
        )
      end
    end,
  },
}
