let s:config_key = '__plugin_configuration'
let s:text_width = 80

" TODO: Fix this get/set functions

""
" Make your documentation for yourself :)
function! conf#docs#generate(script, autoload_prefix) abort
  let lines = []

  " {{{ Configuration Options
  call add(lines, repeat('=', s:text_width))
  let header_line = 'Configuration Options:'
  let name = '*' . conf#get_name(a:script) . '-options*'
  let spaces = conf#util#filler([header_line, name], ' ', s:text_width)
  call add(lines, header_line . spaces . name)

  for area in keys(a:script[s:config_key])
    call add(lines, '')

    let small_header = area
    let name = '*' . conf#get_name(a:script) . '.' . area . '*'
    let filler = conf#util#filler([small_header, name], '.', s:text_width)
    call add(lines, small_header . filler . name)

    for setting in keys(a:script[s:config_key][area])
      let setting_dict = a:script[s:config_key][area][setting]

      " Add an empty line
      call add(lines, '')
      call add(lines, '')

      " Get the header of the line and define the tag
      let left = area . '.' . setting
      let right = '*' . conf#get_name(a:script) . '.' . left . '*'
      let spaces = conf#util#filler([left, right], ' ', s:text_width)
      call add(lines, left . spaces . right)

      call add(lines, '')
      if has_key(setting_dict, 'type')
        call add(lines, printf('  Type: |%s|',
              \ conf#util#type_string(setting_dict.type)
              \ ))
      endif

      if has_key(setting_dict, 'default')
        call add(lines, printf('  Default: `%s`', setting_dict.default))
      endif

      if has_key(setting_dict, 'description')
        call add(lines, '')
        call add(lines, '  ' . setting_dict.description)
      endif

      if has_key(setting_dict, 'validator')
        call add(lines, '')
        call add(lines, '  Validator:')
        call add(lines, '>')

        let func_def = split(execute('function setting_dict.validator'), "\n")
        for func_line in func_def
          call add(lines, '    ' . func_line)
        endfor

        call add(lines, '<')
      endif

      " TODO: Should restructure this so that it's actually useful for
      " mappings
      if has_key(setting_dict, 'action')
        call add(lines, '')
        call add(lines, '  Action:')
        call add(lines, '>')

        let func_def = split(execute('function setting_dict.action'), "\n")
        for func_line in func_def
          call add(lines, '    ' . func_line)
        endfor

        call add(lines, '<')
      endif

      " Show how to configure the values
      let checked_prefix = a:autoload_prefix[len(a:autoload_prefix) - 1] == '#' ?
            \ a:autoload_prefix
            \ : a:autoload_prefix . '#'
      let autoload_func = printf('call %s%s', checked_prefix, 'set')
      call add(lines, '')
      call add(lines, '  To configure:')
      call add(lines, printf('    `%s("%s", "%s", <value>)`', autoload_func, area, setting))

      let autoload_func = printf('call %s%s', checked_prefix, 'get')
      call add(lines, '')
      call add(lines, '  To view:')
      call add(lines, printf('    `%s("%s", "%s")`', autoload_func, area, setting))
    endfor
  endfor

  call add(lines, '')
  call add(lines, '') " }}}
  " {{{ Configuration functions
  call add(lines, repeat('=', s:text_width))
  let header_line = 'Configuration Functions:'
  let name = '*' . conf#get_name(a:script) . '-functions*'
  let spaces = conf#util#filler([header_line, name], ' ', s:text_width)
  call add(lines, header_line . spaces . name)
  call add(lines, '')

  " Just cache this function call
  let introspective = conf#skeleton#__introspection()

  " TODO: I can't seem to get this to sort correctly
  let introspective_values = sort(values(introspective), { val1, val2 -> 
        \ val1.name == val2.name ? 0
        \ : val1.name > val2.name ? -1
          \ : 1 })

  for conf_func in split(execute('function /' . a:autoload_prefix), "\n")
    let left = matchstr(conf_func, a:autoload_prefix . '.*)')
    let right = '*' . matchstr(conf_func, a:autoload_prefix . '.*(') . '()*'
    " Get the header of the line and define the tag
    let spaces = conf#util#filler([right], ' ', s:text_width)

    call add(lines, spaces . right)
    call add(lines, left)

    " If we've got a description, let's use it
    let post_autoload = matchstr(conf_func, a:autoload_prefix . '\(.*\)(')[len(a:autoload_prefix) + 1:-2]
    for info in introspective_values
      if info.name == post_autoload
        call extend(lines, map(copy(info.description), {idx, val -> '    ' . val}))
        break
      endif
    endfor

    call add(lines, '')
  endfor
  call add(lines, '')
  call add(lines, '')
  " }}}
  call add(lines, ' vim:tw=78:ts=2:sts=2:sw=2:ft=help:norl:')
  return lines
endfunction

""
" Inserts the docs under where your cursor is
function! conf#docs#insert(script, autoload_prefix) abort
  call append(line('.'), conf#docs#generate(a:script, a:autoload_prefix))
endfunction
