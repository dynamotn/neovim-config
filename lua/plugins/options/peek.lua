local peek = require('peek')
local job = require('plenary.job')

local opts = {}

job
  :new({
    command = 'grep',
    args = { '-q', 'Gentoo', '/etc/os-release' },
    on_exit = function(_, return_val)
      if return_val == 0 then
        opts.app = 'firefox-bin'
      else
        opts.app = 'firefox'
      end

      peek.setup(opts)
    end,
  })
  :start()
