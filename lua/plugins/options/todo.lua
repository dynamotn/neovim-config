local present, todo = pcall(require, 'todo-comments')

if not present then
  return
end

todo.setup({})
