return {
  {
    -- Linters
    'mfussenegger/nvim-lint',
    event = 'LazyFile',
    opts = function(_, opts)
      opts = vim.tbl_deep_extend('keep', opts, {
        -- Events to lint on
        events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
        -- `*` runs on every filetype, `_` on those without linters of their own
        linters_by_ft = {
          fish = { 'fish' },
        },
        -- Merged into nvim-lint's own linter of that name, or added as a new
        -- one. `prepend_args` goes ahead of its `args`, and `condition(ctx)`
        -- decides per buffer.
        ---@type table<string, table>
        linters = {},
      })
      local languages = require('config.languages')

      -- Several parsers drop the rule id, which leaves `<leader>ci` with
      -- nothing to write an ignore comment from
      require('util.lint_code').setup()

      -- Add each linter's own config to the list of tools if exist
      for _, language in pairs(languages) do
        for _, tool in ipairs(language.linters or {}) do
          if type(tool) == 'table' and tool.opts then
            opts.linters[tool[1]] =
              vim.tbl_extend('force', opts.linters[tool[1]] or {}, tool.opts)
          end
        end
      end

      -- `config.languages` owns the linters of a filetype, so a filetype it
      -- names is always assigned, empty list included. But more than one entry
      -- may name the same filetype and `pairs` walks them in whatever order it
      -- likes, so the lists are built whole and assigned once instead of each
      -- entry resetting the key it happens to touch.
      ---@return table<string, string[]>
      local function build_linters_by_ft()
        local by_ft = {}
        for name, language in pairs(languages) do
          for _, ft in ipairs(language.filetypes) do
            by_ft[ft] = by_ft[ft] or {}
          end
          for _, tool in ipairs(language.linters or {}) do
            local tool_name, tool_command
            if type(tool) == 'string' then
              tool_name = tool
              tool_command = tool
            else
              tool_name = tool[1]
              tool_command = tool.command or tool_name
            end
            if
              (
                require('util.languages').is_available(tool_command)
                or name == '*'
              ) and tool_name ~= 'vale'
            then
              for _, ft in ipairs(language.filetypes) do
                table.insert(by_ft[ft], tool_name)
              end
            end
          end
        end
        return by_ft
      end

      for ft, tools in pairs(build_linters_by_ft()) do
        opts.linters_by_ft[ft] = tools
      end

      -- A linter Mason installs during the session was not on `$PATH` when the
      -- lists above were built, so it would sit unused until the next restart.
      -- Rebuilding once an install lands closes that gap.
      require('util.plugin').on_load('mason.nvim', function()
        require('mason-registry'):on('package:install:success', function()
          vim.schedule(function()
            local linters_by_ft = require('lint').linters_by_ft
            for ft, tools in pairs(build_linters_by_ft()) do
              linters_by_ft[ft] = tools
            end
          end)
        end)
      end)

      --- Is `vale` configured for this buffer
      ---@param buffer integer
      ---@return boolean
      local function has_vale_config(buffer)
        local config = vim.env.VALE_CONFIG_PATH
        if config ~= nil and vim.fn.filereadable(config) == 1 then
          return true
        end
        local name = vim.api.nvim_buf_get_name(buffer)
        if name == '' then return false end
        return vim.fs.find('.vale.ini', {
          path = vim.fs.dirname(name),
          upward = true,
        })[1] ~= nil
      end

      -- `:wq` quits in the same breath as the write, and a linter job started
      -- in that window dies mid-write, taking Neovim down with it (`git commit`
      -- then reports a problem with the editor). So the lint waits for the event
      -- loop, and skips altogether once the editor is on its way out.
      --
      -- `QuitPre` also fires for a plain window close, which leaves the editor
      -- running, so the flag is lifted again on the next `SafeState`: that event
      -- only arrives once Neovim is back to waiting for input, and never when it
      -- is really on its way out.
      local group = vim.api.nvim_create_augroup('dy_lint', { clear = true })
      local leaving = false
      vim.api.nvim_create_autocmd({ 'QuitPre', 'VimLeavePre' }, {
        group = group,
        callback = function()
          if leaving then return end
          leaving = true
          vim.api.nvim_create_autocmd('SafeState', {
            group = group,
            once = true,
            callback = function() leaving = false end,
          })
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        group = group,
        callback = function(args)
          vim.defer_fn(function()
            if leaving or vim.v.exiting ~= vim.NIL then return end
            if not vim.api.nvim_buf_is_valid(args.buf) then return end
            vim.api.nvim_buf_call(args.buf, function()
              local lint = require('lint')
              -- The same fallback the `config` lint applies: a filetype
              -- left with no linter of its own gets the `_` ones. A run
              -- still in flight from there is cancelled, not doubled.
              local names = lint._resolve_linter_by_ft(vim.bo.filetype)
              if #names == 0 then names = lint.linters_by_ft['_'] or {} end
              if #names > 0 then lint.try_lint(names) end
              -- `vale` looks for its config next to the file and upwards from
              -- there, so asking the working directory answers the wrong
              -- question the moment a buffer lives outside it.
              if has_vale_config(args.buf) then
                require('lint').try_lint({ 'vale' })
              end
            end)
          end, 100)
        end,
      })
      return opts
    end,
    config = function(_, opts)
      local lint = require('lint')
      for name, linter in pairs(opts.linters) do
        if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
          lint.linters[name] =
            vim.tbl_deep_extend('force', lint.linters[name], linter)
          if type(linter.prepend_args) == 'table' then
            local args = lint.linters[name].args or {}
            lint.linters[name].args =
              vim.list_extend(vim.list_extend({}, linter.prepend_args), args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      local function run()
        -- nvim-lint's own resolution first: the full filetype, else each
        -- part of a dotted one
        local names =
          vim.list_extend({}, lint._resolve_linter_by_ft(vim.bo.filetype))
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft['_'] or {})
        end
        vim.list_extend(names, lint.linters_by_ft['*'] or {})

        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            require('util.plugin').warn(
              'Linter not found: ' .. name,
              { title = 'nvim-lint' }
            )
          end
          return linter
            and not (
              type(linter) == 'table'
              and linter.condition
              and not linter.condition(ctx)
            )
        end, names)

        if #names > 0 then lint.try_lint(names) end
      end

      local timer = assert(vim.uv.new_timer())
      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        -- Debounced, as a save fires several of these events at once
        callback = function()
          timer:start(100, 0, function()
            timer:stop()
            vim.schedule(run)
          end)
        end,
      })
    end,
  },
  {
    -- Auto install linters
    'mason-org/mason.nvim',
    opts = function(_, opts)
      local languages = require('config.languages')
      for name, language in pairs(languages) do
        for _, tool in ipairs(language.linters or {}) do
          local is_mason_tool = true
          if type(tool) == 'table' and tool.mason then
            is_mason_tool = tool.mason.enabled ~= false
          end
          local tool_package = require('util.languages').get_mason_package(tool)
          if is_mason_tool then
            -- install the linters of bundle languages, `*` and `_` up front
            if
              vim.list_contains(_G.bundle_languages, name)
              or name == '*'
              or name == '_'
            then
              table.insert(opts.ensure_installed, tool_package)
            end
            -- and the others once a buffer of their language opens
            if vim.list_contains(_G.enabled_languages, name) then
              require('util.lazy_install').on_filetype(
                language.filetypes,
                function()
                  require('util.lazy_install').install_once(tool_package)
                end
              )
            end
          end
        end
      end
    end,
  },
}
