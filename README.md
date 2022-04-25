# vim-config

My customize configuration for vim/neovim

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.7-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Feature

*   Manage plugin and lazy-load plugin with [packer](https://github.com/wbthomason/packer.nvim)
*   Improve startup time by:
    *   Use [filetype.nvim](https://github.com/nathom/filetype.nvim), a replacement for the included filetype.vim that is sourced on startup
    *   Use [vim-startuptime](https://github.com/dstein64/vim-startuptime) for viewing startup event timing information
    *   Speed up loading Lua modules with [impatient.nvim](https://github.com/lewis6991/impatient.nvim)
*   Elegant and beautiful UI:
    *   Beautiful theme [onedark](https://github.com/navarasu/onedark.nvim)
    *   Managing tabs, buffers with [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
    *   Pretty and functional statusline with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
    *   Beautiful icons with [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons)
    *   Indentlines with [indent-guides](https://github.com/glepnir/indent-guides.nvim)
    *   Highlight color with [colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)
*   Fast navigation with:
    *   [chadtree](https://github.com/ms-jpq/chadtree) as file explorer
    *   [nvim-window](https://gitlab.com/yorickpeterse/nvim-window) as window switcher
    *   [marks.nvim](chentau/marks.nvim) as mark switcher
*   Fully support Git and Diff with
    *   [neogit](https://github.com/TimUntersberger/neogit) as TUI of Git (although I rarely use it, I would prefer `git` command to it)
    *   [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) to view diff
    *   [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) to show hunks
*   Efficiency editing with a ton of tools
*   Support fuzzy finder, terminal, key mapping board, browser...

## Languages, Frameworks or Tools support

*   Javascript
*   Lua (of course)
*   Bash
*   Fish
*   Markdown
*   Dockerfile
*   Terraform

## Installation

*   Clone this repository to ~/.config/nvim.

<!---->

    rm -rf ~/.config/nvim
    git clone https://gitlab.com/dynamo-config/vim ~/.config/nvim --single-branch

*   Make sure to have `virtualenv` installed, otherwise you must install it via your distro's package manager
*   After that, open Neovim. That's all! Hope you enjoy with neovim :smile:!

## Key bindings

My habit key is `Space`. You can explore it :)

## Note

*   Not used for neovim < 0.7 or vim (any version)
*   Not used for neovim GUI
*   Used for Linux only or Mac (not sure)
