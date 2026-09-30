-- Harper picks its parser from the LSP `languageId`, and Neovim sends the
-- filetype verbatim. A filetype Harper does not know is silently dropped, so
-- every filetype whose name differs from Harper's own identifier is translated
-- here. Anything absent from this table is already spelled the way Harper
-- expects, or has no parser at all -- those languages are covered by `ltcc`.
---@type table<string, string>
local language_ids = {
  -- Harper calls the Bash grammar `shellscript`
  bats = 'shellscript',
  sh = 'shellscript',
  ['sh.ebuild'] = 'shellscript',
  ['sh.install'] = 'shellscript',
  ['sh.PKGBUILD'] = 'shellscript',
  -- Spelled out, unlike the filetype
  cs = 'csharp',
  -- Compound filetypes, checked as their base language
  ['javascript.jsx'] = 'javascriptreact',
  ['markdown.mdx'] = 'markdown',
  ['typescript.tsx'] = 'typescriptreact',
  -- No grammar of their own, so lend them the closest one Harper has
  arduino = 'cpp',
  eruby = 'html',
  htmlangular = 'html',
  vue = 'html',
}

---@type vim.lsp.Config
return {
  get_language_id = function(_, filetype)
    return language_ids[filetype] or filetype
  end,
}
