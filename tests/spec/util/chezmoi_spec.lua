local h = require('helpers')
local chezmoi = require('util.chezmoi')

describe('util.chezmoi', function()
  local restore
  after_each(function()
    for _, undo in ipairs(restore) do
      undo()
    end
  end)

  for _, case in ipairs({
    { full = false, plugin = false, expected = false },
    { full = true, plugin = false, expected = true },
    { full = false, plugin = true, expected = true },
  }) do
    it(
      ('is %s with full=%s, chezmoi=%s'):format(
        case.expected,
        case.full,
        case.plugin
      ),
      function()
        restore = {
          h.stub(_G, 'used_full_plugins', case.full),
          h.stub(_G, 'enabled_plugins', { chezmoi = case.plugin }),
        }
        assert.equals(case.expected, chezmoi.enabled() and true or false)
      end
    )
  end
end)
