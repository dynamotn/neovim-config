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
  svelte = 'html',
  templ = 'html',
  twig = 'html',
  vue = 'html',
}

---@type vim.lsp.Config
return {
  get_language_id = function(_, filetype)
    return language_ids[filetype] or filetype
  end,
}
