local language = require('config.languages').bash
local neogen_config = require('neogen.configurations.sh')

--- Neogen strips the literal string `$1` from a rendered line and turns it into
--- a jump mark, so an `@arg $1` written straight into a template comes out
--- empty. The templates below write this sentinel instead, and
--- `generate_annotation` turns it back into an escaped `$` once the snippet has
--- been rendered.
local ARG_SENTINEL = '__SHDOC_ARG'

--- Collect the names `dybatpho::expect_args` gives the arguments of a function.
--- @param node TSNode The `function_definition` node
--- @return table args One entry per named argument, with its position
--- @return boolean declared Whether the function calls `expect_args` at all,
---   which it may do while naming nothing to say that it takes no arguments
local function extract_expect_args(node)
  local args = {}
  local declared = false
  local idx = 1
  -- Iterate child nodes of function_definition
  for child in node:iter_children() do
    if child:type() == 'compound_statement' then
      for stmt in child:iter_children() do
        if stmt:type() == 'command' then
          local command_name_node = nil
          for subchild in stmt:iter_children() do
            if subchild:type() == 'command_name' then
              command_name_node = subchild
              break
            end
          end
          if
            command_name_node
            and vim.treesitter.get_node_text(command_name_node, 0)
              == 'dybatpho::expect_args'
          then
            declared = true
            for subchild in stmt:iter_children() do
              if subchild:type() == 'word' then
                local arg = vim.treesitter.get_node_text(subchild, 0)
                if arg == '--' then goto end_func end
                table.insert(args, {
                  arg = { arg },
                  index = { idx },
                })
                idx = idx + 1
              end
            end
          end
        end
      end
    end
  end
  ::end_func::
  return args, declared
end

--- Collect the positional parameters a function body actually reads, which is
--- how a script that does not source dybatpho takes its arguments. `$1` and
--- `${1}` are the same parameter, and `$@` is reported last, the way it is
--- written in a signature.
--- @param node TSNode The `function_definition` node
--- @return table positionals One entry per parameter, in numeric order
local function extract_positionals(node)
  local body = nil
  for child in node:iter_children() do
    if child:type() == 'compound_statement' then body = child end
  end
  if not body then return {} end

  local text = vim.treesitter.get_node_text(body, 0)
  local seen, order = {}, {}
  for _, pattern in ipairs({ '%$([0-9]+)', '%${([0-9]+)}' }) do
    for token in text:gmatch(pattern) do
      if not seen[token] then
        seen[token] = true
        table.insert(order, tonumber(token))
      end
    end
  end
  table.sort(order)

  local positionals = {}
  for _, number in ipairs(order) do
    table.insert(positionals, { positional = { tostring(number) } })
  end
  if text:find('%$@') or text:find('%${@}') then
    table.insert(positionals, { positional = { '@' } })
  end
  return positionals
end

-- `dybatpho::expect_args` is the authoritative signature when it is there, so
-- the positional scan is only a fallback for a function that does not use it.
-- Reporting both would double up: `expect_args name path -- "$@"` ends in `$@`,
-- which the scan would pick up as an argument of its own.
--
-- An empty key still counts as a result, which would keep the `no_results` rows
-- of the template -- `@noargs` among them -- from ever firing, so a key is
-- reported only when something was actually found.
neogen_config.data.func['function_definition']['0'].extract = function(node)
  local args, declared = extract_expect_args(node)
  if declared then
    -- `expect_args -- "$@"` names nothing on purpose: the function takes no
    -- arguments. Falling through to the scan would report the `$@` of that very
    -- line as one.
    return #args > 0 and { args = args } or {}
  end

  local positionals = extract_positionals(node)
  if #positionals > 0 then return { positionals = positionals } end

  return {}
end

neogen_config.template = {
  use_default_comment = false,
  --- @diagnostic disable-next-line: assign-type-mismatch
  position = nil,
  annotation_convention = 'sh_docs',

  -- The dybatpho house style: banner comments, and arguments named by
  -- `dybatpho::expect_args`.
  sh_docs = {
    { nil, '#!/usr/bin/env bash', { no_results = true, type = { 'file' } } },
    { nil, '# @file $1', { no_results = true, type = { 'file' } } },
    { nil, '# @brief $1', { no_results = true, type = { 'file' } } },
    { nil, '# @description $1', { no_results = true, type = { 'file' } } },
    { nil, '', { no_results = true, type = { 'file' } } },

    -- A row without `no_results` is only rendered when the extractor found
    -- something, so the banners of the two cases cannot be shared: each block
    -- carries its own pair.
    {
      nil,
      '#######################################',
      { no_results = true, type = { 'func' } },
    },
    { nil, '# @description $1', { no_results = true, type = { 'func' } } },
    { nil, '# @noargs', { no_results = true, type = { 'func' } } },
    { nil, '# @stdout $1', { no_results = true, type = { 'func' } } },
    { nil, '# @exitcode 0 $1', { no_results = true, type = { 'func' } } },
    { nil, '# @exitcode 1 $1', { no_results = true, type = { 'func' } } },
    {
      nil,
      '#######################################',
      { no_results = true, type = { 'func' } },
    },

    { nil, '#######################################', { type = { 'func' } } },
    { nil, '# @description $1', { type = { 'func' } } },
    -- Arguments named by `dybatpho::expect_args`: the name seeds the
    -- description, the way the existing sources read.
    {
      { 'index', 'arg' },
      '# @arg ' .. ARG_SENTINEL .. '%d@ string %s',
      {
        required = 'args',
        type = { 'func' },
      },
    },
    -- Arguments a function without `expect_args` reads positionally.
    {
      { 'positional' },
      '# @arg ' .. ARG_SENTINEL .. '%s@ string $1',
      {
        required = 'positionals',
        type = { 'func' },
      },
    },
    { nil, '# @stdout $1', { type = { 'func' } } },
    { nil, '# @exitcode 0 $1', { type = { 'func' } } },
    { nil, '# @exitcode 1 $1', { type = { 'func' } } },
    { nil, '#######################################', { type = { 'func' } } },
  },
}

--- Swap the sentinel back for a literal `$` in every rendered annotation.
---
--- The hook sits on `to_snippet` rather than on a keymap of ours because that
--- is the one place every way of generating an annotation passes through: both
--- leader maps, `:Neogen`, and anything else that calls `neogen.generate`. A
--- wrapper around a single keymap leaves `__SHDOC_ARG1@` in the buffer for
--- every other entry point.
local function install_arg_sentinel_fixup()
  local snippet = require('neogen.snippet')
  if snippet.__shdoc_arg_fixup then return end
  snippet.__shdoc_arg_fixup = true

  local to_snippet = snippet.to_snippet
  snippet.to_snippet = function(template, marks, pos)
    local lines = to_snippet(template, marks, pos)
    for index, line in ipairs(lines) do
      -- `\$` is how a literal dollar is escaped in an LSP snippet; the `$$`
      -- that neogen escapes with is read as a tabstop by LuaSnip.
      lines[index] = line:gsub(ARG_SENTINEL .. '(.-)@', '\\$%1')
    end
    return lines
  end
end

--- Generate an annotation with a given convention.
--- @param convention string The annotation convention to render with
local function generate_annotation(convention)
  require('neogen').generate({
    type = 'any',
    annotation_convention = { sh = convention },
  })
end

return vim.list_contains(_G.enabled_languages, 'bash')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            bashls = {
              settings = {
                bashIde = {
                  -- nvim-lspconfig ships `*@(...)`, which only matches the
                  -- workspace root, so nothing under `src/`, `lib/` or `bin/`
                  -- ever reaches the index. Restore the recursive pattern that
                  -- bash-language-server itself defaults to. Anything more
                  -- opinionated than this belongs in a project's own
                  -- `.vscode/settings.json`, which codesettings.nvim merges on
                  -- top of these defaults.
                  globPattern = '**/*@(.sh|.inc|.bash|.command)',
                },
              },
            },
            termuxls = {},
            harper_ls = {},
          },
        },
      },
      {
        -- Extend LSP config of harper_ls by plugin for Bash
        'neovim/nvim-lspconfig',
        opts = function(_, opts)
          LazyVim.extend(
            opts.servers.harper_ls,
            'filetypes',
            language.filetypes
          )
        end,
      },
      {
        -- Custom neogen with my Shell style guide
        'neogen',
        opts = {
          languages = {
            sh = neogen_config,
          },
        },
        config = function(_, opts)
          require('neogen').setup(opts)
          install_arg_sentinel_fixup()
        end,
        keys = {
          {
            '<leader>cN',
            function() generate_annotation('sh_docs') end,
            ft = language.filetypes,
            desc = 'Generate Annotations (sh-docs)',
          },
        },
      },
    }
  or {}
