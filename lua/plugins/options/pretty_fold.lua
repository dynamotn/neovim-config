local present, pretty_fold = pcall(require, 'pretty-fold')

if not present then
    return
end

pretty_fold.setup({})
require('pretty-fold.preview').setup()
