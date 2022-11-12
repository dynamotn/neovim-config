local present, symbols_outline = pcall(require, 'symbols-outline')

if not present then
  return
end

symbols_outline.setup({})
