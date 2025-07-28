local language = require('config.languages').bash
local neogen_config = require('neogen.configurations.sh')

local function extract_expect_args(node)
  local args = {}
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
  return {
    args = args,
  }
end

neogen_config.data.func['function_definition']['0'].extract =
  extract_expect_args

neogen_config.template = {
  use_default_comment = false,
  --- @diagnostic disable-next-line: assign-type-mismatch
  position = nil,
  annotation_convention = 'dynamo_shdoc',
  dynamo_shdoc = {
    {
      nil,
      '#######################################',
      { no_results = true, type = { 'func' } },
    },
    {
      nil,
      '# @description $1',
      { no_results = true, type = { 'func' } },
    },
    {
      nil,
      '# @noargs',
      { no_results = true, type = { 'func' } },
    },
    {
      nil,
      '#######################################',
      {
        no_results = true,
        type = { 'func' },
      },
    },

    { nil, '#!/usr/bin/env bash', { no_results = true, type = { 'file' } } },
    { nil, '# @file $1', { no_results = true, type = { 'file' } } },
    { nil, '# @brief $1', { no_results = true, type = { 'file' } } },
    { nil, '# @description $1', { no_results = true, type = { 'file' } } },
    { nil, '', { no_results = true, type = { 'file' } } },

    { nil, '#######################################', { type = { 'func' } } },
    { nil, '# @description $1', { type = { 'func' } } },
    {
      { 'index', 'arg' },
      '# @arg %d string %s',
      {
        required = 'args',
        type = { 'func' },
      },
    },
    { nil, '#######################################', { type = { 'func' } } },
  },
}

return vim.list_contains(_G.enabled_languages, 'bash')
    and {
      {
        -- LSP config
        'neovim/nvim-lspconfig',
        opts = {
          servers = {
            bashls = {},
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
      },
    }
  or {}
