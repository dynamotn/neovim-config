-- Harper picks its parser from the LSP `languageId`, and Neovim sends the
-- filetype verbatim. A filetype Harper does not know is silently dropped, so
-- every filetype whose name differs from Harper's own identifier is translated
-- here. Anything absent from this table is already spelled the way Harper
-- expects, or has no parser at all -- those languages are covered by `ltcc`.
---@type table<string, string>
local language_ids = {
  -- Harper calls the Bash grammar `shellscript`, and it reads a Zsh script
  -- well enough, both writing their comments with `#`
  bats = 'shellscript',
  sh = 'shellscript',
  ['sh.ebuild'] = 'shellscript',
  ['sh.install'] = 'shellscript',
  ['sh.PKGBUILD'] = 'shellscript',
  zsh = 'shellscript',
  -- Spelled out, unlike the filetype
  cs = 'csharp',
  -- Compound filetypes, checked as their base language
  ['javascript.jsx'] = 'javascriptreact',
  ['markdown.mdx'] = 'markdown',
  ['typescript.tsx'] = 'typescriptreact',
  -- No grammar of their own, so lend them the closest one Harper has. The
  -- markup languages all wrap HTML, and Harper reads the prose between the
  -- tags; a template directive it cannot place is prose to it too, so the odd
  -- false positive here is the price of checking the copy at all.
  arduino = 'cpp',
  astro = 'html',
  blade = 'html',
  eruby = 'html',
  handlebars = 'html',
  heex = 'html',
  htmlangular = 'html',
  htmldjango = 'html',
  jinja = 'html',
  svelte = 'html',
  templ = 'html',
  twig = 'html',
  vue = 'html',
}

-- Harper takes a single user dictionary and rewrites it whenever a word is
-- added through its code action, so it is not pointed at the word lists behind
-- `:DySpell` directly. It gets a file of its own instead, rebuilt here from
-- every `spell/*.txt` plus whatever it already holds, so the words Harper
-- learned survive and the Vim spell lists stay untouched.
---@return string path The merged dictionary
local function build_user_dict()
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
  return dict
end

---@type vim.lsp.Config
return {
  get_language_id = function(_, filetype)
    return language_ids[filetype] or filetype
  end,
  settings = {
    ['harper-ls'] = {
      userDictPath = build_user_dict(),
    },
  },
}
