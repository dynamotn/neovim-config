local present, coq_3rd = pcall(require, 'coq_3p')

if not present then
    return
end

coq_3rd ({
    { src = 'repl', short_name = 'REPL' },
    { src = 'nvimlua', short_name = 'NVIM' },
    { src = 'bc', short_name = 'MATH' },
})
