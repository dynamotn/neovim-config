return {
  {
    -- Formatters
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters.condense_blank_lines = {
        command = 'sed',
        args = { ':a;N;$!ba;s/\\n\\n\\+/\\n\\n/g' },
      }

      local lang_to_ft = {}
      local languages = require('config.languages')
      for _, language in pairs(languages) do
        -- `injected` resolves formatters by filetype, but treesitter hands it a
        -- language name, and the two part ways often enough (`bash` -> `sh`) to
        -- need a map. Only a language that has a formatter is worth an entry.
        local parser = language.parser
        local parser_name = type(parser) == 'table' and parser[1] or parser
        if parser_name and not vim.tbl_isempty(language.formatters or {}) then
          lang_to_ft[parser_name] = language.filetypes[1]
        end

        -- Add each formatter's own config to the list of tools if exist
        for _, tool in ipairs(language.formatters or {}) do
          if type(tool) == 'table' and tool.opts then
            opts.formatters[tool[1]] =
              vim.tbl_extend('force', opts.formatters[tool[1]] or {}, tool.opts)
          end
        end
      end

      -- `config.languages` owns the formatters of a filetype, so a filetype it
      -- names is always assigned, empty list included. But more than one entry
      -- may name the same filetype and `pairs` walks them in whatever order it
      -- likes, so the lists are built whole and assigned once instead of each
      -- entry resetting the key it happens to touch.
      ---@return table<string, string[]>
      local function build_formatters_by_ft()
        local by_ft = {}
        for name, language in pairs(languages) do
          for _, ft in ipairs(language.filetypes) do
            by_ft[ft] = by_ft[ft] or {}
          end
          for _, tool in ipairs(language.formatters or {}) do
            local tool_name, tool_command
            if type(tool) == 'string' then
              tool_name = tool
              tool_command = tool
            else
              tool_name = tool[1]
              tool_command = tool.command or tool_name
            end
            if
              vim.fn.executable(tool_command) == 1
              or name == '*'
              or tool_name == 'injected'
            then
              for _, ft in ipairs(language.filetypes) do
                table.insert(by_ft[ft], tool_name)
              end
            end
          end
        end
        return by_ft
      end

      for ft, tools in pairs(build_formatters_by_ft()) do
        opts.formatters_by_ft[ft] = tools
      end

      -- A formatter Mason installs during the session was not on `$PATH` when
      -- the lists above were built, so it would sit unused until the next
      -- restart. Rebuilding once an install lands closes that gap.
      require('lazyvim.util').on_load('mason.nvim', function()
        require('mason-registry'):on('package:install:success', function()
          vim.schedule(function()
            local formatters_by_ft = require('conform').formatters_by_ft
            for ft, tools in pairs(build_formatters_by_ft()) do
              formatters_by_ft[ft] = tools
            end
          end)
        end)
      end)

      -- Conform merges this on top of its own `injected` definition, and
      -- LazyVim already put `ignore_errors` there, so extend instead of
      -- replacing: a bare assignment loses whichever side runs first.
      opts.formatters.injected = vim.tbl_deep_extend(
        'force',
        opts.formatters.injected or {},
        { options = { lang_to_ft = lang_to_ft } }
      )
    end,
  },
  {
    -- Auto install formatters
    'mason-org/mason.nvim',
    opts = function(_, opts)
      local languages = require('config.languages')
      for name, language in pairs(languages) do
        for _, tool in ipairs(language.formatters or {}) do
          local is_mason_tool = true
          if type(tool) == 'table' and tool.mason then
            is_mason_tool = tool.mason.enabled ~= false
          end
          local tool_package = require('util.languages').get_mason_package(tool)
          if is_mason_tool then
            -- install server of language in bundle languages
            if
              vim.list_contains(_G.bundle_languages, name)
              or name == '*'
              or name == '_'
            then
              table.insert(opts.ensure_installed, tool_package)
            end
            -- lazy install server of language not in bundle languages
            if vim.list_contains(_G.enabled_languages, name) then
              vim.api.nvim_create_autocmd({ 'FileType' }, {
                pattern = language.filetypes,
                group = vim.api.nvim_create_augroup(
                  'mason_formatter_' .. name .. '_' .. tool_package,
                  {}
                ),
                callback = function()
                  if
                    not require('mason-registry').is_installed(tool_package)
                  then
                    require('mason.api.command').MasonInstall({ tool_package })
                  end
                end,
              })
            end
          end
        end
      end
    end,
  },
}
