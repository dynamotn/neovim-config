-- Keep sensitive files away from every AI integration. Installed at startup
-- rather than with `config.autocmds`, which LazyVim defers to `VeryLazy`:
-- a guard that turns up late misses whatever happens before it.
require('util.ai_guard').setup()
