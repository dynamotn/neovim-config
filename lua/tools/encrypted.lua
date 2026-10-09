--- Encrypted files, edited in the clear and written back encrypted
---
--- A SOPS file, an Ansible Vault or an `encrypted_` file of a chezmoi source
--- opens as what it holds rather than as ciphertext, and `:w` encrypts it
--- again. The clear text never reaches the file it came from: SOPS writes
--- through `sops edit`, which keeps the data key and the recipients of the
--- file as they were, Ansible Vault through `ansible-vault encrypt --output`,
--- and chezmoi through `chezmoi encrypt --output`, to the recipients of its
--- configuration. The copy each needs on its way is a file of Neovim's own
--- private temporary directory, removed straight after.
---
--- The buffer is marked sensitive before the clear text goes in, so no AI
--- integration is handed it, and it keeps no swap or undo file. Its undo
--- history starts at the clear text: there is no undoing back to ciphertext
--- and writing that out encrypted twice.
local M = {}

local sensitive = require('util.sensitive')

--- Milliseconds a decryption or an encryption may take: a KMS or a hardware
--- key can be slow, but not forever
M.TIMEOUT = 60 * 1000

--- Lines read to tell what a buffer is, beyond which it is left alone
local MAX_LINES = 20000

---@alias DyEncryptedKind 'sops'|'ansible'|'chezmoi'

--- What each kind is called, and the program that handles it
local TOOLS = {
  sops = { name = 'sops', bin = 'sops' },
  ansible = { name = 'Ansible Vault', bin = 'ansible-vault' },
  chezmoi = { name = 'chezmoi', bin = 'chezmoi' },
}

--- Whether `file` is an encrypted file of a chezmoi source directory
---
--- chezmoi names them itself: `encrypted_` in front, `.age` behind for age,
--- `.asc` for gpg. They are opened through chezmoi, whose configuration
--- holds the identity and the recipients.
---@param file string
---@return boolean
function M.is_chezmoi(file)
  local name = vim.fs.basename(file or '')
  return name:match('^encrypted_.+%.age$') ~= nil
    or name:match('^encrypted_.+%.asc$') ~= nil
end

--- What encrypts the file `lines` were read from, if anything
---
--- SOPS leaves its values as `ENC[AES256_GCM,...]` and its metadata under a
--- `sops` key -- at the end of a YAML file, inside a JSON one, as `sops_`
--- lines in a dotenv file. Ansible Vault starts the file with its header,
--- and chezmoi is told by the name of its source file.
---@param lines string[]
---@param file? string
---@return DyEncryptedKind?
function M.kind(lines, file)
  if file and M.is_chezmoi(file) then return 'chezmoi' end
  if lines[1] and lines[1]:match('^%$ANSIBLE_VAULT;%d+%.%d+;') then
    return 'ansible'
  end
  local value, metadata = false, false
  for _, line in ipairs(lines) do
    value = value or line:find('ENC[AES256_GCM,', 1, true) ~= nil
    metadata = metadata
      or line:match('^sops:') ~= nil
      or line:match('^%s*"sops"%s*:') ~= nil
      or line:match('^sops_[%w_]+=') ~= nil
      or line:match('^%[sops%]') ~= nil
    if value and metadata then return 'sops' end
  end
  return nil
end

--- The vault id of an Ansible Vault 1.2 header, which encrypting again keeps
---@param header string
---@return string?
function M.vault_id(header)
  return header:match('^%$ANSIBLE_VAULT;1%.2;[^;]+;(.+)$')
end

--- The command that prints the clear text of `file`
---@param kind DyEncryptedKind
---@param file string
---@return string[]
function M.decrypt_command(kind, file)
  if kind == 'sops' then return { 'sops', 'decrypt', file } end
  if kind == 'chezmoi' then return { 'chezmoi', 'decrypt', file } end
  return { 'ansible-vault', 'decrypt', '--output', '-', file }
end

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Encrypted file' })
end

--- What to say when the tool of `kind` failed
---@param kind DyEncryptedKind
---@param result vim.SystemCompleted
---@return string
local function failure(kind, result)
  local err = vim.trim(result.stderr or '')
  if err == '' then err = ('exit %d'):format(result.code) end
  if kind == 'ansible' then
    err = err
      .. '\nAnsible Vault cannot ask for a password here: set'
      .. ' ANSIBLE_VAULT_PASSWORD_FILE, or vault_password_file in ansible.cfg'
  end
  return err
end

--- A file only this user can read, holding `lines`, in Neovim's private
--- temporary directory
---@param lines string[]
---@return string
local function private_copy(lines)
  local path = vim.fn.tempname()
  vim.fn.writefile({}, path)
  vim.fn.setfperm(path, 'rw-------')
  vim.fn.writefile(lines, path)
  return path
end

--- The editor `sops edit` runs to put the buffer in place: it copies `copy`
--- over the file sops hands it, once. sops asks the editor again when it
--- cannot parse what it got back, waiting for a key in between -- which,
--- with no terminal, never comes, and sops loops until it is killed and
--- leaves its own clear copy behind. A second call fails instead, and sops
--- gives up and cleans up after itself.
---@param copy string
---@return string script
---@return string marker
local function sops_editor(copy)
  local script, marker = copy .. '.editor', copy .. '.used'
  vim.fn.writefile({
    '#!/bin/sh',
    ('[ -e %s ] && exit 1'):format(vim.fn.shellescape(marker)),
    (': > %s'):format(vim.fn.shellescape(marker)),
    ('exec cp %s "$1"'):format(vim.fn.shellescape(copy)),
  }, script)
  vim.fn.setfperm(script, 'rwx------')
  return script, marker
end

--- Encrypt the clear text of `bufnr` back into its file
---@param bufnr integer
---@return boolean written
function M.write(bufnr)
  local kind = vim.b[bufnr].dy_encrypted
  -- A handler left from an earlier opening of a buffer no longer decrypted
  if not TOOLS[kind] then return false end
  local file = vim.api.nvim_buf_get_name(bufnr)
  local tool = TOOLS[kind].bin
  if vim.fn.executable(tool) ~= 1 then
    notify(tool .. ' is not installed: not written', vim.log.levels.ERROR)
    return false
  end

  local copy = private_copy(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  local command, env
  local extra = {}
  if kind == 'sops' then
    -- `sops edit` decrypts into a file of its own, hands it to the editor
    -- and encrypts what the editor left there with the key it already had.
    -- The editor here only copies the buffer over that file.
    command = { 'sops', 'edit', file }
    local script, marker = sops_editor(copy)
    extra = { script, marker }
    env = { SOPS_EDITOR = script, EDITOR = script }
  elseif kind == 'chezmoi' then
    -- To the recipients of chezmoi's configuration, armoured or not as
    -- that configuration says
    command = { 'chezmoi', 'encrypt', '--output', file, copy }
  else
    command = { 'ansible-vault', 'encrypt', '--output', file, copy }
    local id = vim.b[bufnr].dy_vault_id
    if id then vim.list_extend(command, { '--encrypt-vault-id', id }) end
  end

  local ok, result = pcall(function()
    return vim
      .system(command, {
        text = true,
        env = env,
        timeout = M.TIMEOUT,
        -- No controlling terminal: a password prompt on /dev/tty would
        -- fight the TUI for keys while the editor waits
        detach = true,
      })
      :wait()
  end)
  vim.fn.delete(copy)
  for _, path in ipairs(extra) do
    vim.fn.delete(path)
  end
  if not ok then
    notify(tostring(result), vim.log.levels.ERROR)
    return false
  end
  -- `sops edit` exits 200 when the file came back unchanged
  if result.code ~= 0 and not (kind == 'sops' and result.code == 200) then
    notify('Not written: ' .. failure(kind, result), vim.log.levels.ERROR)
    return false
  end
  vim.bo[bufnr].modified = false
  notify(('Written, encrypted with %s'):format(TOOLS[kind].name))
  return true
end

--- Open the clear text of `bufnr`, if it holds an encrypted file
---@param bufnr integer
---@return boolean decrypted
function M.open(bufnr)
  if vim.api.nvim_buf_line_count(bufnr) > MAX_LINES then return false end
  local file = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local kind = M.kind(lines, file)
  if not kind then return false end

  -- Held back before anything of the clear text is in the buffer
  sensitive.mark(bufnr, ('decrypted with %s'):format(TOOLS[kind].name))
  pcall(function() require('util.ai_guard').detach_copilot(bufnr) end)
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false

  local command = M.decrypt_command(kind, file)
  if vim.fn.executable(command[1]) ~= 1 then
    notify(
      command[1] .. ' is not installed: left encrypted',
      vim.log.levels.WARN
    )
    return false
  end
  local ok, result = pcall(
    function()
      return vim
        .system(command, { text = true, timeout = M.TIMEOUT, detach = true })
        :wait()
    end
  )
  if not ok or result.code ~= 0 then
    notify(
      'Left encrypted: ' .. (ok and failure(kind, result) or tostring(result)),
      vim.log.levels.ERROR
    )
    return false
  end

  local clear =
    vim.split((result.stdout or ''):gsub('\n$', ''), '\n', { plain = true })
  -- No undoing back to the ciphertext
  local undolevels = vim.bo[bufnr].undolevels
  vim.bo[bufnr].undolevels = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, clear)
  vim.bo[bufnr].undolevels = undolevels
  vim.bo[bufnr].modified = false

  vim.b[bufnr].dy_encrypted = kind
  vim.b[bufnr].dy_vault_id = kind == 'ansible' and M.vault_id(lines[1]) or nil
  vim.bo[bufnr].buftype = 'acwrite'
  M.guard(bufnr)
  return true
end

--- Whether a buffer has held clear text this session, so the registers it
--- may have filled are kept out of the shada file
local decrypted_any = false

--- The `clipboard` value to restore on leaving each guarded buffer
---@type table<integer, string>
local saved_clipboard = {}

--- Write `bufnr` encrypted, and keep its clear text out of the system
--- clipboard while it is the current buffer
---
--- The autocmds live in a group of the buffer's own, cleared each time it
--- is opened: `:bdelete` forgets buffer variables but not buffer-local
--- autocmds, and a flag kept in one would let every reopening add another
--- handler, encrypting once per handler on each `:w`.
---@param bufnr integer
function M.guard(bufnr)
  local group =
    vim.api.nvim_create_augroup('dy_encrypted_' .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    group = group,
    buffer = bufnr,
    callback = function(args) M.write(args.buf) end,
  })
  vim.keymap.set(
    'n',
    '<localleader>D',
    function() M.diff(bufnr) end,
    { buffer = bufnr, desc = 'Diff With HEAD (Encrypted)' }
  )
  M.hold(bufnr, group)
end

--- Keep the clear text of `bufnr` out of the system clipboard while it is the
--- current buffer, and out of the shada file once Neovim quits
---@param bufnr integer
---@param group integer The augroup of the buffer's autocmds
function M.hold(bufnr, group)
  -- `unnamedplus` would put every yank of a password into the system
  -- clipboard, and from there into a clipboard manager's history. The value
  -- to restore is kept per buffer, outside this call: `:e!` guards the buffer
  -- again while the clipboard is already cleared, and must not take that ''
  -- for the user's setting.
  local function clear()
    if saved_clipboard[bufnr] == nil then
      saved_clipboard[bufnr] = vim.o.clipboard
    end
    vim.o.clipboard = ''
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    buffer = bufnr,
    callback = clear,
  })
  vim.api.nvim_create_autocmd({ 'BufLeave', 'BufWipeout' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if saved_clipboard[bufnr] ~= nil then
        vim.o.clipboard = saved_clipboard[bufnr]
        saved_clipboard[bufnr] = nil
      end
    end,
  })
  if vim.api.nvim_get_current_buf() == bufnr then clear() end

  if not decrypted_any then
    decrypted_any = true
    -- Registers and the search history are written to the shada file on
    -- quitting: after clear text was in a buffer, neither is kept
    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = vim.api.nvim_create_augroup('dy_encrypted_shada', {}),
      -- Neovim reads the first `<` item, so the default `<50` has to go
      -- rather than have `<0` appended after it
      callback = function()
        local items = vim.tbl_filter(
          function(item) return not item:match('^[<"/@]') end,
          vim.split(vim.o.shada, ',', { plain = true, trimempty = true })
        )
        vim.list_extend(items, { '<0', '/0', '@0' })
        vim.o.shada = table.concat(items, ',')
      end,
    })
  end
end

--- Run `command` and wait for it, never raising
---@param command string[]
---@param opts table `vim.system` options
---@return vim.SystemCompleted?
local function run(command, opts)
  local ok, result = pcall(
    function()
      return vim
        .system(
          command,
          vim.tbl_extend('force', { timeout = M.TIMEOUT, detach = true }, opts)
        )
        :wait()
    end
  )
  return ok and result or nil
end

--- The clear text of the file of `bufnr` as it was at `rev`
---
--- The blob goes to a directory of its own only this user can read, under
--- the name of the file -- sops tells the format from the extension -- and
--- both are removed as soon as it is decrypted. Nothing of the clear text
--- is written anywhere.
---@param bufnr integer
---@param rev string
---@return string[]? lines
---@return string? err
function M.clear_at(bufnr, rev)
  local kind = vim.b[bufnr].dy_encrypted
  local file = vim.api.nvim_buf_get_name(bufnr)
  local dir, name = vim.fs.dirname(file), vim.fs.basename(file)
  local blob = run(
    { 'git', 'show', ('%s:./%s'):format(rev, name) },
    { cwd = dir, text = false }
  )
  if not blob or blob.code ~= 0 then
    return nil,
      ('%s is not in git at %s%s'):format(
        name,
        rev,
        blob and blob.stderr ~= '' and (': ' .. vim.trim(blob.stderr)) or ''
      )
  end

  local private = vim.fn.tempname()
  vim.fn.mkdir(private, 'p', tonumber('700', 8))
  local copy = vim.fs.joinpath(private, name)
  local fd = vim.uv.fs_open(copy, 'w', tonumber('600', 8))
  if not fd then
    vim.fn.delete(private, 'rf')
    return nil, 'could not write a private copy'
  end
  vim.uv.fs_write(fd, blob.stdout or '')
  vim.uv.fs_close(fd)

  local result = run(M.decrypt_command(kind, copy), { text = true })
  vim.fn.delete(private, 'rf')
  if not result or result.code ~= 0 then
    return nil,
      'could not decrypt it: ' .. (result and failure(kind, result) or 'failed')
  end
  return vim.split(
    (result.stdout or ''):gsub('\n$', ''),
    '\n',
    { plain = true }
  )
end

--- Diff the clear text of `bufnr` with its clear text at `rev` (`HEAD`), in
--- a split that is held back like the buffer itself
---@param bufnr? integer
---@param rev? string
function M.diff(bufnr, rev)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf()
    or bufnr
  rev = rev or 'HEAD'
  local kind = vim.b[bufnr].dy_encrypted
  if not kind then
    return notify('This buffer is not a decrypted file', vim.log.levels.ERROR)
  end
  local lines, err = M.clear_at(bufnr, rev)
  if not lines then return notify(err, vim.log.levels.ERROR) end

  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then vim.api.nvim_set_current_win(win) end
  vim.cmd('leftabove vnew')
  local scratch = vim.api.nvim_get_current_buf()
  -- Held back before the clear text goes in, as the buffer itself is
  sensitive.mark(
    scratch,
    ('decrypted with %s, at %s'):format(TOOLS[kind].name, rev)
  )
  vim.bo[scratch].buftype = 'nofile'
  vim.bo[scratch].bufhidden = 'wipe'
  vim.bo[scratch].swapfile = false
  vim.bo[scratch].undofile = false
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)
  vim.bo[scratch].modifiable = false
  vim.bo[scratch].filetype = vim.bo[bufnr].filetype
  pcall(
    vim.api.nvim_buf_set_name,
    scratch,
    ('%s@%s'):format(vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)), rev)
  )
  local group =
    vim.api.nvim_create_augroup('dy_encrypted_' .. scratch, { clear = true })
  M.hold(scratch, group)
  -- Gone with the old text: the window of the buffer leaves diff mode too
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = scratch,
    once = true,
    callback = function()
      vim.schedule(function()
        local original = vim.fn.bufwinid(bufnr)
        if original ~= -1 then
          vim.api.nvim_win_call(original, function() vim.cmd('diffoff') end)
        end
      end)
    end,
  })
  vim.keymap.set(
    'n',
    'q',
    '<cmd>close<cr>',
    { buffer = scratch, desc = 'Close', nowait = true }
  )
  vim.cmd('diffthis')
  vim.cmd('wincmd p')
  vim.cmd('diffthis')
end

--- `:EncryptedDiff [{rev}]`
---@param args { fargs: string[] }
function M.command(args) M.diff(0, args.fargs[1]) end

return M
