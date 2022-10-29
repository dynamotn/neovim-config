return function(augend)
  return {
    augend.constant.new({
      elements = { 'let', 'const' },
      word = true,
      cyclic = true,
    }),
  }
end
