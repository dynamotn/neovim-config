" vim:foldmethod=marker:foldmarker={,}
" Automatically download plugin manager {
function! dynamo#file#DownloadPluginManager() abort
  if empty(glob($VIMHOME . '/autoload/plug.vim'))
    silent !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup ReloadAndInstallVimPlug
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif
endfunction " }

" Load file in config folder {
function! dynamo#file#LoadConfig(file) abort
  if filereadable($VIMHOME . '/config/' . a:file . '.vim')
    execute 'source ' . $VIMHOME . '/config/' . a:file . '.vim'
  endif
endfunction " }
