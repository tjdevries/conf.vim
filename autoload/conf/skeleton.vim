let s:autoload_skeleton_names = {
      \ 'set_setting': {
        \ 'name': 'set',
        \ 'args': ['area', 'setting', 'value'],
        \ 'description': ['Set a "value" for the "area.setting"', 'See |conf.set_setting|'],
        \ },
      \ 'get_setting': {
        \ 'name': 'get',
        \ 'args': ['area', 'setting'],
        \ 'description': ['Get the "value" for the "area.setting"', 'See |conf.get_setting}'],
        \ },
      \ 'view': {
        \ 'name': 'view',
        \ 'args': [],
        \ 'description': ['View the current configuration dictionary.', 'Useful for debugging'],
        \ },
      \ 'menu': {
        \ 'name': 'menu',
        \ 'args': [],
        \ 'description': ['Provide the user with an automatic "quickmenu"', 'See |conf.menu|'],
        \ },
      \ }

""
" Generate a skeleton for an a conf implementation in your current autoload file
function! conf#skeleton#generate() abort
  let autoload_prefix = conf#skeleton#get_current_autoload_prefix()

  let lines = []

  for key in ['set_setting', 'get_setting', 'view', 'menu']
    call extend(lines, conf#skeleton#function_generate(
        \ autoload_prefix,
        \ key,
        \ s:autoload_skeleton_names[key]
        \ ))

    call extend(lines, ['',''])
  endfor

  return lines
endfunction

""
" Take a function with {name, args, description} and return an autoload for
" the current function
function! conf#skeleton#function_generate(prefix, conf_name, conf_dict) abort
  let lines = []

  call add(lines, '""')
  call s:add_comment(lines, a:prefix . '#' . a:conf_dict.name)

  for desc_line in a:conf_dict.description
    call s:add_comment(lines, desc_line)
  endfor

  call add(lines, printf('function! %s#%s(%s) abort',
        \ a:prefix,
        \ a:conf_dict.name,
        \ join(a:conf_dict.args, ', '),
        \ ))

  call add(lines, printf('  return conf#%s(%s)',
        \ a:conf_name,
        \ join(
          \ ['s:'] + map(copy(a:conf_dict.args), { _, val -> 'a:' . val}),
          \ ', '
          \ )
        \ ))


  call add(lines, 'endfunction')

  return lines
endfunction

function! s:add_comment(lines, comment_string) abort
  return add(a:lines,'" ' . a:comment_string)
endfunction

""
" Gets the current autoload file prefix
function! conf#skeleton#get_current_autoload_prefix() abort
  let prefix = expand('%:r')
  let prefix = substitute(prefix, '.*autoload/', '', 'g')
  let prefix = substitute(prefix, "\\", '/', 'g')
  let prefix = substitute(prefix, '//', '/', 'g')
  let prefix = substitute(prefix, '/', '#', 'g')

  return prefix
endfunction
