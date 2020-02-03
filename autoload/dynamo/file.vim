" vim:foldmethod=marker:foldmarker={,}
" Automatically download plugin manager {
function! dynamo#file#DownloadPluginManager() abort
  if empty(glob($VIMHOME . '/autoload/plug.vim'))
    silent !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
endfunction

function! dynamo#file#InstallPlugin(...) abort
  if (a:0 >= 1 && a:1 ==# 'now')
    source $MYVIMRC | PlugInstall --sync | q
  endif
  if empty(glob($VIMHOME . '/' . g:dynamo_plugins_folder))
    PlugInstall | source $MYVIMRC
  endif
endfunction
" }

" Load file in config folder {
function! dynamo#file#LoadConfig(file) abort
  if filereadable($VIMHOME . '/config/' . a:file . '.vim')
    execute 'source ' . $VIMHOME . '/config/' . a:file . '.vim'
  endif
endfunction
" }

" Register plugin to load config of plugin {
function! dynamo#file#RegisterPlugin(file) abort
  if !exists('s:dynamo_plugin_map')
    let s:dynamo_plugin_map=[]
  endif
  let s:dynamo_plugin_map=add(s:dynamo_plugin_map, a:file)
  if index(['coc', 'deoplete', 'neocomplete'], a:file) >= 0
    call dynamo#misc#RegisterEngine(a:file)
  endif
endfunction

function! dynamo#file#IsRegisteredPlugin(plugin) abort
  return index(s:dynamo_plugin_map, a:plugin) >= 0
endfunction
" }

" Read config after register plugin {
function! dynamo#file#InitPluginAfterRegister(folder) abort
  for plugin in s:dynamo_plugin_map
    call dynamo#file#LoadConfig(a:folder . '/' . plugin)
  endfor
endfunction
" }

" Declare plugins and register config of its {
function! dynamo#file#InitPluginOption() abort
  call plug#begin($VIMHOME . '/' . g:dynamo_plugins_folder)
  call dynamo#file#LoadConfig(g:dynamo_list_plugins_file)
  call plug#end()
  call dynamo#file#InstallPlugin()
  call dynamo#file#InitPluginAfterRegister(g:dynamo_plugin_configs_folder)
endfunction
" }

" Load key bindings for plugins {
function! dynamo#file#InitPluginKeyBinding() abort
  call dynamo#file#LoadConfig(g:dynamo_common_key_bindings_file)
  call dynamo#file#InitPluginAfterRegister(g:dynamo_list_key_bindings_folder)
endfunction
" }

" Load plugin list for specific language {
function! dynamo#file#LoadLanguagePlugin(filetype) abort
  let g:dynamo_language_plug_param={ 'for': a:filetype }
  call dynamo#file#LoadConfig(g:dynamo_language_plugins_folder .
        \ '/' . a:filetype)
endfunction
" }

" End of load plugin list {
function! dynamo#file#EndLoadPlugin() abort
  unlet g:dynamo_language_plug_param
endfunction
" }
