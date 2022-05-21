local present, coq_3rd = pcall(require, 'coq_3p')

if not present then
  return
end

coq_3rd({
  { src = 'repl', short_name = 'REPL' },
  { src = 'nvimlua', short_name = 'NVIM', conf_only = false },
  { src = 'bc', short_name = 'MATH' },
  { src = 'copilot', short_name = 'COP', accept_key = '<c-f>' },
  { src = 'orgmode', short_name = 'ORG' },
  { src = 'dap', short_name = 'DEBUG' },
})
