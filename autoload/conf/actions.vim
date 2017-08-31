

""
" Helper function for action_mapping
" Defaults to noremap
function! conf#actions#mapping(map_dict) abort
  if !has_key(a:map_dict, 'rhs') || !has_key(a:map_dict, 'mode')
    echoerr 'conf#actions#mapping requires a dictionary with "rhs" and "mode"' . string(a:map_dict)
    return
  endif

  let dict = {}
  let dict.map_config = copy(a:map_dict)
  let dict.map_config['noremap'] = get(dict.map_config, 'noremap', v:true)

  let dict.result = funcref('s:mapping_function')
  return { def, old, new -> dict.result(def, old, new) }
endfunction

function! s:mapping_function(default, old_val, new_val) abort dict
  if conf#runtime#get('runtime', 'debug')
    echo 'Running the s:mapping_function'
    echo printf('  Args: %s, %s %s', a:default, a:old_val, a:new_val)
  endif

  " Handle unmapping the old value
  if a:old_val != v:null
    if conf#runtime#get('runtime', 'debug')
      echo '  maparg(current): ' . maparg(self.map_config.rhs)
    endif

    " Only unmap the old value if it actually is the expected "rhs"
    if self.map_config.rhs == maparg(a:old_val)
      let unmap_config = deepcopy(self.map_config)
      let unmap_config['lhs'] = a:old_val

      if conf#runtime#get('runtime', 'debug')
        echo '  unmapping mapping...'
        echo '  unmap_config=' . string(unmap_config)
        echo '  executing: ' . std#mapping#unmap_dict_to_string(unmap_config)
      endif

      call std#mapping#unmap_dict(unmap_config)
    endif
  endif

  if a:new_val == ''
    return
  endif

  " Map the new value
  call extend(self.map_config, {'lhs': a:new_val}, 'force')
  if conf#runtime#get('runtime', 'debug')
    echo '  executing: ' . std#mapping#map_dict_to_string(self.map_config)
  endif
  return std#mapping#map_dict(self.map_config)
endfunction
