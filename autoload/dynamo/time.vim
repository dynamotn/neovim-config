" vim:foldmethod=marker:foldmarker={,}
" Automatically set background and run command depending on time of day {
function! dynamo#time#AutoDayNight(day_command, night_command) abort
  let hour=system('date +%H')
  if 6 <= hour && hour < 9
    set background=light
    exec a:day_command
  else
    set background=dark
    exec a:night_command
  endif
endfunction
" }
