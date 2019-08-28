if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'which_key'

let s:sep = which_key#util#get_sep()

execute 'syntax match WhichKeySeperator' '/'.s:sep.'/' 'contained'
execute 'syntax match WhichKey' '/[^\s].\{1,3}'.s:sep.'/' 'contains=WhichKeySeperator'
syntax match WhichKeyGroup / ⍟ [0-9A-Za-z_/-]*/
syntax region WhichKeyDesc start="^" end="$" contains=WhichKey, WhichKeyGroup, WhichKeySeperator

highlight default link WhichKey          Type
highlight default link WhichKeySeperator Identifier
highlight default link WhichKeyGroup     Statement
highlight default link WhichKeyDesc      Delimiter
