local M = {}

---@type string? The merged dictionary, once built this session
local user_dict

-- Harper takes a single user dictionary and rewrites it whenever a word is
-- added through its code action, so it is not pointed at the word lists behind
-- `:DySpell` directly. It gets a file of its own instead, rebuilt from every
-- `spell/*.txt` plus whatever it already holds, so the words Harper learned
-- survive and the Vim spell lists stay untouched.
--
-- Built once a session: `vim.lsp` runs `lsp/harper_ls.lua` again on every
-- read of the config it has not resolved yet, which is several times as the
-- first file opens, and each run read, sorted and wrote every list again.
-- Words added later reach Harper through `plugin/spell.lua` instead.
---@return string path The merged dictionary
function M.user_dict()
  if user_dict then return user_dict end
  local dict =
    vim.fs.joinpath(vim.fn.stdpath('state'), 'harper', 'dictionary.txt')
  local sources = vim.fn.glob(
    vim.fs.joinpath(vim.fn.stdpath('config'), 'spell', '*.txt'),
    false,
    true
  )
  table.insert(sources, dict)

  local seen, words = {}, {}
  for _, source in ipairs(sources) do
    if vim.uv.fs_stat(source) then
      for _, word in ipairs(vim.fn.readfile(source)) do
        word = vim.trim(word)
        if word ~= '' and not seen[word] then
          seen[word] = true
          table.insert(words, word)
        end
      end
    end
  end
  table.sort(words)

  vim.fn.mkdir(vim.fs.dirname(dict), 'p')
  vim.fn.writefile(words, dict)
  user_dict = dict
  return dict
end

return M
