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

" Register plugin to load config of plugin {
function! dynamo#file#RegisterPlugin(file) abort
  if !exists('g:dynamo_plugin_map')
    let g:dynamo_plugin_map = []
  endif
  let g:dynamo_plugin_map = add(g:dynamo_plugin_map, a:file)
endfunction " }

" Read config after register plugin {
function! dynamo#file#InitPluginAfterRegister(folder) abort
  for plugin in g:dynamo_plugin_map
    call dynamo#file#LoadConfig(a:folder . '/' . plugin)
  endfor
endfunction " }

" Declare plugins and register config of its {
function! dynamo#file#InitPluginOption() abort
  call plug#begin($VIMHOME . '/' . g:dynamo_plugins_folder)
  call dynamo#file#LoadConfig(g:dynamo_list_plugins_file)
  call plug#end()
  call dynamo#file#InitPluginAfterRegister(g:dynamo_plugin_configs_folder)
endfunction " }

" Load key bindings for plugins {
function! dynamo#file#InitPluginKeyBinding() abort
  call dynamo#file#LoadConfig(g:dynamo_list_key_bindings_folder .
        \ '/' . g:dynamo_common_key_bindings_file)
  call dynamo#file#InitPluginAfterRegister(g:dynamo_list_key_bindings_folder)
endfunction " }
