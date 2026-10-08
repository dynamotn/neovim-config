---@module 'overseer'

--- Whether the file asks for privilege escalation, so the run prompts for
--- the become password
---@param file string
---@return boolean
local function has_become(file)
  for _, line in ipairs(vim.fn.readfile(file)) do
    if line:find('become:%s*true') then return true end
  end
  return false
end

---@type overseer.TemplateDefinition
return {
  name = 'ansible run',
  desc = 'Run the playbook, or the role this file belongs to',
  builder = function()
    local file = vim.fn.expand('%:p')
    local roles_dir, role = file:match('^(.*)/roles/([%w_.-]+)/')

    local cmd
    if role then
      -- A role on its own, against this machine: `--playbook-dir` is where
      -- Ansible looks for `roles/`
      cmd = {
        'ansible',
        'localhost',
        '--playbook-dir',
        roles_dir,
        '-m',
        'import_role',
        '-a',
        'name=' .. role,
      }
    else
      cmd = { 'ansible-playbook', file }
    end
    if vim.uv.fs_stat(file) and has_become(file) then
      table.insert(cmd, '--ask-become-pass')
    end

    ---@type overseer.TaskDefinition
    return {
      cmd = cmd,
      -- `ansible.cfg` is read from the working directory
      cwd = vim.fs.root(file, { 'ansible.cfg', '.git' })
        or vim.fs.dirname(file),
      components = {
        'output',
      },
    }
  end,
  condition = {
    filetype = require('config.languages').ansible.filetypes,
  },
  priority = -1,
}
