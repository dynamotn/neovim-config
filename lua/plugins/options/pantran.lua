local pantran = require('pantran')

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
