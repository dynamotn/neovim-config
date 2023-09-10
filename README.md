# neovim-config

<!--toc:start-->
- [neovim-config](#neovim-config)
  - [Feature](#feature)
  - [Languages, Frameworks, or Tools support](#languages-frameworks-or-tools-support)
    - [Languages](#languages)
    - [Frameworks](#frameworks)
    - [Tools & Markup](#tools-markup)
  - [Installation](#installation)
  - [Key bindings](#key-bindings)
  - [Note](#note)
<!--toc:end-->

My customization configuration for neovim

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.10-blue?style=flat-square\&logo=Neovim\&logoColor=white)](https://github.com/neovim/neovim)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=flat-square\&logo=lua)](https://lua.org)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Feature

* Manage plugin and lazy-load plugin with [lazy](https://github.com/folke/lazy.nvim)
* Elegant and beautiful UI:
  * Beautiful theme [onedark](https://github.com/navarasu/onedark.nvim)
  * Managing tabs, buffers with [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
  * Pretty and functional statusline with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
  * Beautiful icons with [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons)
  * Indentlines with [indent-guides](https://github.com/glepnir/indent-guides.nvim)
  * Highlight color with [colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)
* Fast navigation with:
  * [chadtree](https://github.com/ms-jpq/chadtree) as file explorer
  * [nvim-window](https://gitlab.com/yorickpeterse/nvim-window) as window switcher
  * [marks.nvim](chentau/marks.nvim) as mark switcher
* Fully support Git and Diff with
  * [neogit](https://github.com/TimUntersberger/neogit) as TUI of Git (although I rarely use it, I would prefer `git` command to it)
  * [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) to view diff
  * [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) to show hunks of Git
* Efficiency editing with a ton of tools
* Support fuzzy finder, terminal, key mapping board, browser, ...

## Languages, Frameworks, or Tools support
See the list of supported things in `lua/languages/list.lua`. You can comment on lines that you don't want to use.

#### Languages
* Arduino
* AWK
* Bash
* C/C++
* C#
* CSS
* Cucumber
* Fish
* Go
* HTML
* Javascript
* LESS
* Lua (of course)
* PHP
* Python
* Ruby
* Rust
* SASS/SCSS
* Solidity
* SQL

#### Frameworks

#### Tools & Markup
* Ansible
* CSV
* DBML
* Dockerfile
* Git (rebase, commit)
* GoTemplate (Helm template...)
* HTTP
* JSON
* Markdown
* Nix
* Orgmode
* Terraform
* Terragrunt
* TOML
* Treesitter
* YAML
* Yuck

## Installation

* Clone this repository to ~/.config/nvim.

```sh
  rm -rf ~/.config/nvim
  git clone https://gitlab.com/dynamo-config/vim ~/.config/nvim --single-branch
```

* After that, open Neovim. That's all! Hope you enjoy with neovim :smile:!

## Key bindings

My habit key is `Space`. You can explore it :)

## Note

* Not used for neovim < 0.10 or vim (any version)
* Not used for neovim GUI
* Used for Linux only or Mac (not sure)
