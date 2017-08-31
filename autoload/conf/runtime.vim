" This feels pretty meta

" Prefix to use for this autoload file
let s:autoload_prefix = "conf#runtime"

call conf#set_name(s:, 'conf.vim/main')
call conf#add_area(s:, 'runtime')
call conf#add_setting(s:, 'runtime', 'debug', {
            \ 'default': v:false,
            \ 'type': v:t_bool,
            \ 'description': 'If true, print debug messages during execution',
            \ })

""
" conf#runtime#set
" Set a "value" for the "area.setting"
" See |conf.set_setting|
function! conf#runtime#set(area, setting, value) abort
  return conf#set_setting(s:, a:area, a:setting, a:value)
endfunction


""
" conf#runtime#get
" Get the "value" for the "area.setting"
" See |conf.get_setting}
function! conf#runtime#get(area, setting) abort
  return conf#get_setting(s:, a:area, a:setting)
endfunction


""
" conf#runtime#view
" View the current configuration dictionary.
" Useful for debugging
function! conf#runtime#view() abort
  return conf#view(s:)
endfunction


""
" conf#runtime#menu
" Provide the user with an automatic "quickmenu"
" See |conf.menu|
function! conf#runtime#menu() abort
  return conf#menu(s:)
endfunction


""
" conf#runtime#generate_docs
" Returns a list of lines to be placed in your documentation
" 0
function! conf#runtime#generate_docs() abort
  return conf#docs#generate(s:, s:autoload_prefix)
endfunction
