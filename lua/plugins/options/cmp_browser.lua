local present, cmp_browser = pcall(require, 'cmp-browser-source')

if not present then
  return
end

cmp_browser.start_server()
