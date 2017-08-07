""
" s: dictionaries passed in will be of the form:
" {
"   <area_1>: {
"       <setting_1>: {
"           type,
"           default,
"           description,
"           validator,
"       },
"       <setting_2>: {
"           type,
"           default,
"           description,
"           validator,
"       },
"   },
"   <area_2>: {
"       ...
"   }
" }

let s:config_key = '__plugin_configuration'
let s:config_name = '__plugin_name'

" Keys are:
" type: must be a v:t_*
" default: anything
" description: string
" validator: function
let s:possible_settings = {
  \ 'type': {
    \ val -> index(
      \ [v:t_bool, v:t_dict, v:t_list, v:t_string, v:t_number, v:t_func, v:t_float],
      \ type(val)) >= 0
    \ },
  \ 'default': {-> v:true},
  \ 'description': {val -> type(val) == v:t_string},
  \ 'validator': {val -> type(val) == v:t_func},
  \ }

""
" Make sure the config key is there
function! s:check_config_key(script) abort
  if !has_key(a:script, s:config_key)
    let a:script[s:config_key] = {}
  endif
endfunction

""
" Make sure that the area is added
function! s:has_config_area(script, area) abort
  call s:check_config_key(a:script)

  return has_key(a:script[s:config_key], a:area)
endfunction

""
" Make sure that the setting and area have been added
function! s:has_config_setting(script, area, setting) abort
  call s:check_config_key(a:script)

  if !s:has_config_area(a:script, a:area)
    return v:false
  endif

  return has_key(a:script[s:config_key][a:area], a:setting)
endfunction

""
" Name the function
function! conf#set_name(script, name) abort
  let a:script[s:config_name] = a:name
endfunction

""
" Get the name of the function
function! conf#get_name(script) abort
  if !has_key(a:script, s:config_name)
    throw "[CONF] No name for plugin. Please call `conf#set_name(<plugin_name>)`"
  endif

  return a:script[s:config_name]
endfunction

""
" Add an area of configuration
function! conf#add_area(script, area) abort
  call s:check_config_key(a:script)

  if has_key(a:script[s:config_key], a:area)
    " TODO: Should we throw an error here?
  else
    let a:script[s:config_key][a:area] = {}
  endif
endfunction

""
" Add a setting for a configuration area
"
" Will error if you haven't set up the area
function! conf#add_setting(script, area, setting, configuration) abort
  if !s:has_config_area(a:script, a:area)
    throw printf("[CONF][%s] No setting area named: %s. If desired, use `call conf#add_area(s:, '%s')`",
          \ conf#get_name(a:script),
          \ a:area,
          \ a:area,
          \ )
  endif

  if s:has_config_setting(a:script, a:area, a:setting)
    " throw printf("[CONF][%s] Setting area named: '%s' already exists",
    "       \ conf#get_name(a:script),
    "       \ a:area,
    "       \ )
  endif

  " Determine if it's a default value item (which could be a dictionary)
  " or if it's a value item dictionary
  let config_dict = {}
  if type(a:configuration) != v:t_dict
    let config_dict.default = a:configuration
  else
    " If we have some values that are not part of the possible keys
    " Then we assume it's a default dictionary
    for conf_key in keys(a:configuration)
      if !has_key(s:possible_settings, conf_key)
        let config_dict.default = a:configuration
      endif
    endfor

    " However, if that happened, and there are keys in common with the possible keys
    " Then we throw an error because it's too hard to determine if there was a typo
    if has_key(config_dict, 'default')
      for conf_key in keys(a:configuration)
        if has_key(s:possible_settings, conf_key)
          throw "[CONF] Too hard to determine if this is a configuration dict or a default dict"
        endif
      endfor
    endif
  endif

  " We didn't see something that seemed like a default value,
  " so the argument was a configuration dictionary
  if !has_key(config_dict, 'default')
    let config_dict = a:configuration
  endif

  " "default" is a required key
  if !has_key(config_dict, 'default')
    throw printf(
          \ "[CONF]: 'default' is a required key when adding a setting. Dict passed was %s",
          \ a:configuration)
  endif

  " Check that all the keys are valid
  for conf_key in keys(config_dict)
    if !has_key(s:possible_settings, conf_key)
      throw printf(
            \ "[CONF]: %s is not a valid setting key. %s are valid key settings",
            \ conf_key, keys(s:possible_settings)
            \ )
    endif

    " Call the check to make sure it's of a valid type
    if !s:possible_settings[conf_key](config_dict[conf_key])
      throw printf(
            \ "[CONF]: %s is not a valid setting value for %s."
            \ config_dict[conf_key], conf_key)
    endif
  endfor

  let a:script[s:config_key][a:area][a:setting] = config_dict
endfunction

""
" Set a setting and ensure that is the correct value
function! conf#set_setting(script, area, setting, value) abort
  if !s:has_config_setting(a:script, a:area, a:setting)
    throw printf("[CONF][%s] Setting area named: '%s' does not exist",
          \ conf#get_name(a:script),
          \ a:area,
          \ )
  endif

  let config_dict = a:script[s:config_key][a:area][a:setting]

  " Check for the correct type
  if has_key(config_dict, 'type')
    if type(a:value) != config_dict.type
      " TODO: Get a better type message
      throw printf("[CONF][%s][set.TYPE] Setting '%s.%s' requires type '%s'. Value '%s' is not of the correct type",
            \ conf#get_name(a:script), a:area, a:setting, config_dict.type, a:value
            \ )
    endif
  endif

  if has_key(config_dict, 'validator')
    if !config_dict.validator(a:value)
      " TODO: better error
      throw printf("[CONF][%s][set.VALIDATOR] Setting '%s.%s' failed its validation function with val '%s'.",
            \ conf#get_name(a:script), a:area, a:setting, a:value
            \ )
    endif
  endif

  let a:script[s:config_key][a:area][a:setting].value = a:value
endfunction

function! conf#get_setting(script, area, setting) abort
  call s:check_config_key(a:script)

  if !s:has_config_area(a:script, a:area)
    throw printf(
          \ "[CONF][%s]: '%s' is not a valid area for a setting",
          \ conf#get_name(a:script), a:area
          \ )
  endif

  if !has_key(a:script[s:config_key][a:area], a:setting)
    throw printf(
          \ "[CONF][%s]: '%s' is not a valid setting for area '%s'",
          \ conf#get_name(a:script), a:setting, a:area
          \ )
  endif

  " If we've never set a new value,
  "     return the default
  " Else
  "     return the value that has been set
  if !has_key(a:script[s:config_key][a:area][a:setting], 'value')
    return a:script[s:config_key][a:area][a:setting].default
  else
    return a:script[s:config_key][a:area][a:setting].value
  endif
endfunction

""
" View the configuration dictionary
function! conf#view(script) abort
  return copy(a:script[s:config_key])
endfunction

""
" Make a quickmenu menu
function! conf#menu(script) abort
  let s:has_quickmenu = get(s:, 'has_quickmenu', stridx(&runtimepath, 'quickmenu.vim') >= 0)

  if !s:has_quickmenu
    throw printf(
          \ '[CONF][%s]. skywind3000/quickmenu.vim required to have menus'
          \ conf#get_name(a:script)
          \ )
  endif

  call quickmenu#reset()

  call quickmenu#header(printf('[%s] Configuration Menu', conf#get_name(a:script)))

  for area in keys(a:script[s:config_key])
    " Make a smaller header area for each area
    call quickmenu#append('# ' . area, '')

    for setting in keys(a:script[s:config_key][area])
      " Give the option of a setting for each item:
      " TODO: Wait for an update to quickmenu to use function refs
      call quickmenu#append(
            \ printf('Set: %s.%s', area, setting),
            \ printf('call conf#set_setting("%s", "%s", input("New Setting: "))', area, setting),
            \ )
    endfor
  endfor

  call quickmenu#toggle(0)
endfunction
