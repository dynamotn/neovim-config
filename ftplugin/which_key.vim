if exists('g:which_key_ftplugin')
  finish
else
  let g:which_key_ftplugin = 1
endif
function! which_key#statusline(...)
    if &filetype ==# 'which_key'
        call airline#extensions#apply_left_override('Guide', '')
    endif
endfunction
try
    call airline#add_statusline_func('which_key#statusline')
catch
endtry
