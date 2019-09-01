" Switch tab
for i in range(1,9)
  call dynamo#mapping#Define('nmap', '<leader>', i, '<Plug>AirlineSelectTab' . i, 'Tab index ' . i)
endfor
call dynamo#mapping#Define('nmap', '<leader>', '-', '<Plug>AirlineSelectPrevTab' . i, 'Previous tab')
call dynamo#mapping#Define('nmap', '<leader>', '+', '<Plug>AirlineSelectNextTab' . i, 'Next tab')
