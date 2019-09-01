" Enable
let g:neocomplete#enable_at_startup=1
" Use smartcase.
let g:neocomplete#enable_smart_case=1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 2

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
 let g:neocomplete#sources#omni#input_patterns = {}
endif
if !exists('g:neocomplete#force_omni_input_patterns')
 let g:neocomplete#force_omni_input_patterns = {}
endif
