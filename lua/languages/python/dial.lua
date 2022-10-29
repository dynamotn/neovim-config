return function(augend)
  return {
    augend.constant.new({
      elements = { 'True', 'False' },
      word = true,
      cyclic = true,
    }),
  }
end
