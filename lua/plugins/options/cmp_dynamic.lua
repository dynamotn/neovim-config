local present, cmp_dynamic = pcall(require, 'cmp_dynamic')

if not present then
  return
end

cmp_dynamic.setup({
  {
    label = 'today',
    insertText = 1,
    cb = {
      function()
        return os.date('%d/%m/%Y')
      end,
    },
  },
  {
    label = 'now',
    insertText = 1,
    cb = {
      function()
        return os.date('%H:%M:%S %d/%m/%Y')
      end,
    },
  },
  {
    label = 'now',
    insertText = 1,
    cb = {
      function()
        return os.date('%Y_%m_%d_%H_%M')
      end,
    },
  },
  {
    label = 'timestamp',
    insertText = 1,
    cb = {
      function()
        return os.date('%s')
      end,
    },
  },
})
