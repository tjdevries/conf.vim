let s:config_key = '__plugin_configuration'
let s:text_width = 80

""
" Make your documentation for yourself :)
function! conf#docs#generate(script, autoload) abort
  let lines = []
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

      " Show how to configure the values
      let autoload_func = substitute(a:autoload, 'function', 'call', '')
      let autoload_func = substitute(autoload_func, '#docs', '#set', '')
      call add(lines, '')
      call add(lines, '  To configure:')
      call add(lines, printf('    `%s("%s", "%s", <value>)`', autoload_func, area, setting))

      let autoload_func = substitute(a:autoload, 'function', 'echo', '')
      let autoload_func = substitute(autoload_func, '#docs', '#get', '')
      call add(lines, '')
      call add(lines, '  To view:')
      call add(lines, printf('    `%s("%s", "%s")`', autoload_func, area, setting))
    endfor
  endfor

  call add(lines, '')
  " call add(lines, ' vim:tw=78:ts=2:sts=2:sw=2:ft=help:norl:')

  return lines
endfunction