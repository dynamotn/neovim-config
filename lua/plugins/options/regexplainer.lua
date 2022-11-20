local present, regexplainer = pcall(require, 'regexplainer')

if not present then
  return
end

regexplainer.setup({
  auto = true,
  display = 'split',
})
