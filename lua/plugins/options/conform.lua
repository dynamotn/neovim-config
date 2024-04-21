require('conform').setup({
  format = {
    timeout_ms = 3000,
    quiet = false,
    lsp_fallback = true,
  },
  format_on_save = {
    lsp_fallback = true,
  },
  formatters_by_ft = require('languages').setup_conform(),
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
})
