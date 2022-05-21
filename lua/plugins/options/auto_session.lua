local present, session = pcall(require, 'auto-session')

if not present then
  return
end

session.setup({
  auto_session_enable_last_session = true,
  auto_save_enabled = true,
  auto_restore_enabled = true,
})
