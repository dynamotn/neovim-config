return function(_)
  local present, rest = pcall(require, 'rest-nvim')

  if not present then
    return
  end

  rest.setup({})
end
