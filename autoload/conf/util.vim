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
