local present, lint = pcall(require, 'lint')

if not present then
  return
end

local present, languages = pcall(require, 'languages')

if present then
  lint.linters_by_ft = languages.setup_linter()
end
