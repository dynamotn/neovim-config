local M = {}

--- Setup default sources of cmp
M.setup_default_sources = function()
  local success, node = pcall(vim.treesitter.get_node)
  if
    success
    and node
    and vim.tbl_contains(
      { 'comment', 'line_comment', 'block_comment' },
      node:type()
    )
  then
    return M.sources('comment')
  else
    return M.sources('*')
  end
end

--- Sources for filetype
---@param filetype string Filetype to enable sources. `*` for undefined
M.sources = function(filetype)
  local common_sources = {
    'lsp',
    'path',
    'project_path',
    'snippets',
    'buffer',
    -- 'ripgrep',
    'calc',
    'tmux',
    'dynamic',
    'dictionary',
  }
  local unique_sources = {
    markdown = { 'obsidian' },
    fish = { 'fish' },
    sql = { 'dadbod', 'sql' },
  }

  if _G.enabled_plugins.codeium then table.insert(common_sources, 'codeium') end
  if _G.enabled_plugins.copilot then table.insert(common_sources, 'copilot') end

  if filetype == 'comment' then
    return { 'buffer', 'ripgrep', 'dictionary', 'dynamic' }
  elseif filetype == 'comment' then
    return { 'dap', 'buffer', 'ripgrep' }
  elseif vim.list_contains({ 'gitcommit', 'gitrebase' }, filetype) then
    return { 'lsp', 'snippets', 'buffer', 'dynamic', 'dictionary' }
  elseif vim.list_contains({ 'markdown', 'fish', 'sql' }, filetype) then
    local result = {}
    vim.list_extend(result, unique_sources[filetype])
    return vim.list_extend(result, common_sources)
  elseif filetype == '*' then
    return common_sources
  end
end

return M
