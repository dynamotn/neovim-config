Feature
========

- Plugin manager with `vim-plug`
- Keep configuration organized with separated and corresponded file
- Key bindings are useful and organized with mnemonic prefixes
- Minimalistic and awesome GUI
- LSP to use same with IDE

Installation
=============
- Clone this repository to ~/.config/nvim (for neovim) or ~/.vim (for vim).
```
rm -rf ~/.config/nvim
git clone https://gitlab.com/dynamo-config/vim ~/.config/nvim
```
- With vim, you must create ~/.vimrc link from vimrc of this repository
```
ln -sf ~/.vim/vimrc ~/.vimrc
```
- After that, install plugins with command
```
# for vim
vim +PlugInstall +qa
# for neovim
nvim +PlugInstall +UpdateRemotePlugins +qa
```
That's all! Hope you enjoy with vim :smile:!

Key bindings
=============

See at [KEY_BINDING.md](../KEY_BINDING.md)

License
========

Copyright © 2019 Tran Duc Nam <dynamo.foss@gmail.com>

The project is licensed under Creative Common BY-NC-SA 4.0.

You can read it online at [here](http://creativecommons.org/licenses/by-nc-sa/4.0/).

Note
=====

- Not use for neovim/vim GUI
- Use for Linux only
- Vim version >= 7.4 or NVim version >= 0.3 to use all features
- To use LSP features with neovim, must install nodejs and yarn
- Must install pynvim if want to use with Nvim
- Must install universal-ctags if want to use tag
