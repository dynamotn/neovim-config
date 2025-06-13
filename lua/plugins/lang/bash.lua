local language = require('config.languages').bash
local nodes_utils = require('neogen.utilities.nodes')
local extractors = require('neogen.utilities.extractors')
local neogen_configurations = {}

neogen_configurations.parent = {
  func = { 'function_definition' },
  file = { 'program' },
}

neogen_configurations.data = {
  func = {
    ['function_definition'] = {
      ['0'] = {
        extract = function(node)
          local tree = {
            {
              node_type = 'compound_statement',
              retrieve = 'first',
              subtree = {
                {
                  node_type = 'simple_expansion',
                  retrieve = 'all',
                  recursive = true,
                  subtree = {
                    {
                      node_type = 'variable_name',
                      retrieve = 'all',
                      extract = true,
                    },
                  },
                },
                {
                  node_type = 'expansion',
                  recursive = true,
                  retrieve = 'all',
                  subtree = {
                    {
                      node_type = 'variable_name',
                      retrieve = 'all',
                      extract = true,
                    },
                  },
                },
              },
            },
          }
          local nodes = nodes_utils:matching_nodes_from(node, tree)
          local res = extractors:extract_from_matched(nodes)
          return res
        end,
      },
    },
  },
  file = {
    ['program'] = {
      ['0'] = {
        extract = function() return {} end,
      },
    },
  },
}

neogen_configurations.template = {
  annotation_convention = 'dynamo_bash',
  dynamo_bash = {
    {
      nil,
      '#######################################',
      { no_results = true, type = { 'func' } },
    },
    { nil, '# $1', { no_results = true, type = { 'func' } } },
    {
      nil,
      '#######################################',
      { no_results = true, type = { 'func' } },
    },

    { nil, '#!/usr/bin/env bash', { no_results = true, type = { 'file' } } },
    { nil, '#', { no_results = true, type = { 'file' } } },
    { nil, '# @file $1', { no_results = true, type = { 'file' } } },
    { nil, '# @brief $1', { no_results = true, type = { 'file' } } },
    { nil, '# @description $1', { no_results = true, type = { 'file' } } },
    { nil, '', { no_results = true, type = { 'file' } } },

    { nil, '#######################################' },
    { nil, '# @description $1' },
    { 'variable_name', '# @arg %s $1' },
    { nil, '#######################################' },
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
          module = {
            termuxls = 'tools.lsp.termuxls',
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
            sh = neogen_configurations,
          },
        },
      },
    }
  or {}
