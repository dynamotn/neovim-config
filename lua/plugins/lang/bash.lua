local filetypes = require('languages.list').bash
local i = require('neogen.types.template').item
local nodes_utils = require('neogen.utilities.nodes')
local extractors = require('neogen.utilities.extractors')
local configurations = {}

configurations.parent = {
  func = { 'function_definition' },
  file = { 'program' },
}

configurations.data = {
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
                  as = i.Parameter,
                  extract = true,
                },
                {
                  node_type = 'expansion',
                  recursive = true,
                  retrieve = 'all',
                  subtree = {
                    { node_type = 'variable_name', retrieve = 'all', extract = true },
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
        extract = function()
          return {}
        end,
      },
    },
  },
}

configurations.template = {
  annotation_convention = 'dynamo_bash',
  dynamo_bash = {
    { nil, '#######################################', { no_results = true, type = { 'func' } } },
    { nil, '# $1', { no_results = true, type = { 'func' } } },
    { nil, '#######################################', { no_results = true, type = { 'func' } } },

    { nil, '#!/usr/bin/env bash', { no_results = true, type = { 'file' } } },
    { nil, '#', { no_results = true, type = { 'file' } } },
    { nil, '# @file $1', { no_results = true, type = { 'file' } } },
    { nil, '# @brief $1', { no_results = true, type = { 'file' } } },
    { nil, '# @description $1', { no_results = true, type = { 'file' } } },
    { nil, '', { no_results = true, type = { 'file' } } },

    { nil, '#######################################' },
    { nil, '# @description $1' },
    { 'variable_name', '%s $1', { before_first_item = { '# @arg ' } } },
    { i.Parameter, '# $1', { before_first_item = { '# @arg ' } } },
    { nil, '#######################################' },
  },
}

return vim.list_contains(_G.enabled_languages, 'bash')
    and {
      {
        'nvim-treesitter',
        opts = {
          ensure_installed = {
            'bash',
          },
        },
      },
      {
        'neogen',
        opts = {
          languages = {
            sh = configurations,
          },
        },
      },
    }
  or {}
