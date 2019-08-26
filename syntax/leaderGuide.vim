scriptencoding utf-8
if exists('b:current_syntax')
  finish
endif
let b:current_syntax = "leaderguide"

syn region LeaderGuideKeys start="\["hs=e+1 end="\]\s"he=s-1
            \ contained
syn match LeaderGuideBrackets /\[[^ ]\+\]/
            \ contains=LeaderGuideKeys keepend
syn match LeaderGuideGroupDesc / ⍟ [^\[^\]]\+/ contained
syn region LeaderGuideDesc start="^" end="$"
            \ contains=LeaderGuideBrackets,LeaderGuideGroupDesc

hi def link LeaderGuideDesc Identifier
hi def link LeaderGuideKeys Type
hi def link LeaderGuideBrackets Delimiter
hi def link LeaderGuideGroupDesc Statement
