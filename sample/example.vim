
" ===== Set up configuration options =====
" Set the name of this plugin
call conf#set_name(s:, 'Example Plugin')

" Add an area fo default configuration
call conf#add_area(s:, 'defaults')
call conf#add_area(s:, 'minimum')

" ===== Add some settings =====

" Add a simple setting, don't care about validation
call conf#add_setting(s:, 'defaults', 'example_string', 'this setting configuration')

" Add a setting for wait time, it should just be a number
call conf#add_setting(s:, 'defaults', 'wait_time', {
            \ 'type': v:t_number,
            \ 'default': 100,
            \ })

" Add a setting for minimum value, it should be greater than 25
call conf#add_setting(s:, 'minimum', 'min_25', {
            \ 'type': v:t_number,
            \ 'default': 35,
            \ 'validator': { val -> val > 25 },
            \ })


" ==== Add some autoload functions for configuring your plugin =====
function! example#configuration#get(area, setting)  abort
  return conf#get_setting(s:, a:area, a:setting)
endfunction

function! example#configuration#set(area, setting, value) abort
  return conf#set_setting(s:, a:area, a:setting, a:value)
endfunction

function! example#configuration#menu() abort
  return conf#menu(s:)
endfunction
