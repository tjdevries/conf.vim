""
" Get some filler spaces
function! conf#util#filler(strings, filler_char, width) abort
  let sum = 0
  for s in a:strings
    let sum = sum + len(s)
  endfor

  return repeat(a:filler_char, a:width - sum)
endfunction

""
" Conver types to nice strings
function! conf#util#type_string(t) abort
  let type_dict = {
        \ v:t_number: 'Number',
        \ v:t_float: 'Float',
        \ v:t_list: 'List',
        \ v:t_string: 'String',
        \ v:t_bool: 'Bool',
        \ v:t_dict: 'Dict',
        \ v:t_func: 'Function'
        \ }

  return type_dict[a:t]
endfunction

""
" Try and guess what the requirement function is
" for a dictionary of strings of plugins name
" And then try and make sure that all the plugins are the required versions
"
" @param current_name (string): The name of the plugin requiring functions
" @param plug_dict (dict): {'plug_name': version, 'plug_2': version}
"
" @returns True if requirements are met. False otherwise
function! conf#util#require_plugins(current_name, plug_dict) abort
  let valid = v:true

  " Let's best guess at the functions we need :)
  for [name, semver] in items(a:plug_dict)
    let function_options = split(execute(printf('function /%s#.*\(conf\|runtime\|info\).*#require', name)), "\n")

    " We have some confusing options
    if len(function_options) > 1
      echohl ErrorMsg | echo  printf('[%s]: More than one possible requires function for: %s',
            \ a:current_name,
            \ name
            \ ) | echohl None
      let valid = v:false
      continue
    endif

    " We've got no options :'(
    if len(function_options) == 0
      echohl ErrorMsg | echo printf('[%s]: No possible requires function for: %s',
            \ a:current_name,
            \ name
            \ ) | echohl None
      let valid = v:false
      continue
    endif

    let val = function_options[0]
    let function_name = matchlist(val, 'function \(.*\)(.*) \%[abort]')[1]
    if !function(function_name, [semver])()
      echohl ErrorMsg | echo  printf('[%s]: Requirement "%s:%s" not met',
            \ a:current_name,
            \ name,
            \ std#semver#string(std#semver#parse(semver))
            \ ) | echohl None
      let valid = v:false
    endif
  endfor

  if !valid
    echohl ErrorMsg | echo printf('[%s] Requirements not met', a:current_name) | echohl None
  endif

  return valid
endfunction
