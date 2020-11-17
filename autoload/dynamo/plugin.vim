" vim:foldmethod=marker:foldmarker={,}
" Automatically download plugin manager {
function! dynamo#plugin#DownloadPluginManager() abort
  if empty(glob($VIMHOME . '/autoload/plug.vim'))
    silent !curl -fLo $VIMHOME/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
endfunction
" }

" Install plugin {
function! dynamo#plugin#Install() abort
  if empty(glob($VIMHOME . '/' . g:dynamo_plugins_folder))
    PlugInstall | source $MYVIMRC
  endif
endfunction
" }

" Update plugin {
function! dynamo#plugin#Update() abort
  source $MYVIMRC | PlugUpdate
  for lsp_server_cmd in get(g:, 'dynamo_lsp_server_install_cmd', [])
    execute '!' . lsp_server_cmd
  endfor
endfunction
" }

" Load file in config folder {
function! dynamo#plugin#LoadConfig(file) abort
  if filereadable($VIMHOME . '/config/' . a:file . '.vim')
    execute 'source ' . $VIMHOME . '/config/' . a:file . '.vim'
  endif
endfunction
" }

" Register plugin to load config of plugin {
function! dynamo#plugin#Register(file) abort
  if !exists('s:dynamo_plugin_map')
    let s:dynamo_plugin_map=[]
  endif
  let s:dynamo_plugin_map=add(s:dynamo_plugin_map, a:file)
  if index(['coc', 'deoplete', 'neocomplete'], a:file) >= 0
    call dynamo#misc#RegisterEngine(a:file)
  endif
endfunction

function! dynamo#plugin#IsRegistered(plugin) abort
  return index(s:dynamo_plugin_map, a:plugin) >= 0
endfunction
" }

" Read config after register plugin {
function! dynamo#plugin#InitAfterRegister(folder) abort
  for plugin in s:dynamo_plugin_map
    call dynamo#plugin#LoadConfig(a:folder . '/' . plugin)
  endfor
endfunction
" }

" Declare plugins and register config of its {
function! dynamo#plugin#InitOption() abort
  call plug#begin($VIMHOME . '/' . g:dynamo_plugins_folder)
  call dynamo#plugin#LoadConfig(g:dynamo_list_plugins_file)
  call plug#end()
  call dynamo#plugin#Install()
  call dynamo#plugin#InitAfterRegister(g:dynamo_plugin_configs_folder)
endfunction
" }

" Load key bindings for plugins {
function! dynamo#plugin#InitKeyBinding() abort
  call dynamo#plugin#LoadConfig(g:dynamo_common_key_bindings_file)
  call dynamo#plugin#InitAfterRegister(g:dynamo_list_key_bindings_folder)
endfunction
" }

" Load plugin list for specific language {
function! dynamo#plugin#LoadLanguage(filetype) abort
  let g:dynamo_language_plug_param={ 'for': a:filetype }
  if g:dynamo_complete_engine ==? 'coc'
    let g:dynamo_language_plug_param.do='yarn install --frozen-lockfile'
  endif
  call dynamo#plugin#LoadConfig(g:dynamo_language_plugins_folder .
        \ '/' . a:filetype)
endfunction
" }

" End of load plugin list {
function! dynamo#plugin#EndLoad() abort
  unlet g:dynamo_language_plug_param
endfunction
" }

" Install language server {
function! dynamo#plugin#InstallLanguageServer(tool, package) abort
  let install_cmd='true'
  if executable(a:tool)
    if a:tool ==? 'yarn'
      let install_cmd=a:tool . ' global add ' . a:package
    elseif a:tool ==? 'gem'
      let install_cmd=a:tool . ' install ' . a:package
    endif
    call add(g:dynamo_lsp_server_install_cmd, install_cmd)
  elseif a:tool ==? 'bin'
    let install_cmd='bash ' . $VIMHOME . '/../bin/update.sh -s ' . a:package
    call add(g:dynamo_lsp_server_install_cmd, install_cmd)
  endif
  let g:dynamo_language_plug_param.do=install_cmd . ' && ' . copy(g:dynamo_language_plug_param.do)
endfunction
" }
