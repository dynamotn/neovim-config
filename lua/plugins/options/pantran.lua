local present, pantran = pcall(require, 'pantran')

if not present then
  return
end

pantran.setup({
  default_engine = 'google',
  engines = {
    google = {
      fallback = {
        default_source = 'en',
        default_target = 'vi',
      },
    },
  },
})
