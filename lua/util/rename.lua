--- Rename the file of a buffer through `Snacks.rename`, which tells the
--- language servers, without its two traps: it renames over a file already
--- at the target, and it force-deletes the old buffer, so edits not written
--- yet are lost. Here an existing target needs `force`, and a modified
--- buffer is saved first or the rename is called off.

local M = {}

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.WARN, { title = 'Rename' })
end

--- Rename `from` to `to` once both pass the checks
---@param buf integer
---@param from string
---@param to string
---@param force? boolean
local function rename(buf, from, to, force)
  to = vim.fs.normalize(vim.fn.fnamemodify(to, ':p'))
  if to == from then return end
  if vim.uv.fs_stat(to) and not force then
    return notify(
      ('`%s` exists, use `:DyRename!` to overwrite it'):format(
        vim.fn.fnamemodify(to, ':~:.')
      )
    )
  end
  if vim.bo[buf].modified then
    local choice = vim.fn.confirm(
      ('Save changes to `%s` before renaming it?'):format(
        vim.fn.fnamemodify(from, ':t')
      ),
      '&Save\n&Cancel',
      1
    )
    if choice ~= 1 then return end
    vim.api.nvim_buf_call(buf, function() vim.cmd('silent write') end)
  end
  Snacks.rename.rename_file({ from = from, to = to })
end

--- Rename the file of the current buffer to `opts.to`, asked for when not
--- given and relative to the working directory
---@param opts? { to?: string, force?: boolean }
function M.rename_file(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' or vim.bo[buf].buftype ~= '' then
    return notify('This buffer has no file to rename')
  end
  local from = vim.fs.normalize(vim.fn.fnamemodify(name, ':p'))
  if opts.to then return rename(buf, from, opts.to, opts.force) end
  vim.ui.input({
    prompt = 'New File Name: ',
    default = vim.fn.fnamemodify(from, ':.'),
    completion = 'file',
  }, function(value)
    if value and value ~= '' then rename(buf, from, value, opts.force) end
  end)
end

--- Add `:DyRename[!] [name]`
function M.setup()
  vim.api.nvim_create_user_command(
    'DyRename',
    function(args)
      M.rename_file({
        to = args.args ~= '' and args.args or nil,
        force = args.bang,
      })
    end,
    {
      bang = true,
      nargs = '?',
      complete = 'file',
      desc = 'Rename the file of the buffer, `!` to overwrite',
    }
  )
end

return M
