""
" Describes the "setting" object and it's properties
let s:config_name = '__plugin_name'
let s:config_key = '__plugin_configuration'

" TODOs:
"   - Add error checking or throwing here.

""
" Get the description for a setting
function! conf#setting#get_description(script, area, setting) abort
  let setting_dict = a:script[s:config_key][a:area][a:setting]

  if has_key(setting_dict, 'description')
    return setting_dict.description
  endif

  return printf("Set the value for '%s.%s.%s'. Default was: %s",
        \ conf#get_name(a:script), a:area, a:setting, setting_dict.default)
endfunction

""
" Get the prompt for a setting
function! conf#setting#get_prompt(script, area, setting) abort
  let setting_dict = a:script[s:config_key][a:area][a:setting]

  if has_key(setting_dict, 'prompt')
    return setting_dict.prompt . ' >> '
  endif

  return printf("> Set the value for '%s.%s.%s' [Default: %s] $ ",
        \ conf#get_name(a:script), a:area, a:setting, string(setting_dict.default))
endfunction
