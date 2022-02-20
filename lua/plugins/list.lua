-- vim:foldmethod=marker:foldmarker={,}
---------------------------------------
--       List of all plugins         --
---------------------------------------
local register_config = require('plugins.register').register_config

return {
    {
        'wbthomason/packer.nvim',
        event = 'VimEnter',
    },
-------- Eyecandy ----------- {
-- Color scheme {
    { -- OneDark for both Dark and Light colorscheme
        'navarasu/onedark.nvim',
        config = register_config('onedark')
    },
--------------- }
----------------------------- }
}
