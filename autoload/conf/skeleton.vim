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
      \ 'get_version': {
        \ 'name': 'version',
        \ 'args': [],
        \ 'description': ['Get the version for this plugin', 'Returns a semver dict']
        \ },
      \ }

let s:doc_skeleton = {
      \ 'docs#generate': {
        \ 'name': 'generate_docs',
        \ 'args': [],
        \ 'conf_args': ['s:autoload_prefix'],
        \ 'description': [
          \ 'Returns a list of lines to be placed in your documentation',
          \ 'Can use :call append(line("%"), func())'
          \ ],
        \ },
      \ 'docs#insert': {
        \ 'name': 'insert_docs',
        \ 'args': [],
        \ 'conf_args': ['s:autoload_prefix'],
        \ 'description': [
          \ 'Insert the generated docs under where you cursor is',
          \ ],
        \ },
      \ }

""
" Generate a skeleton for an a conf implementation in your current autoload file
function! conf#skeleton#generate() abort
  let autoload_prefix = conf#skeleton#get_current_autoload_prefix()

  let lines = []

  call s:add_comment(lines, 'Prefix to use for this autoload file')
  call add(lines, printf('let s:autoload_prefix = "%s"', autoload_prefix))
  call add(lines, 'let s:autoload_file = expand("<sfile>:p")')
  call add(lines, '')

  call s:add_comment(lines, 'Set the name of name of your plugin.')
  call s:add_comment(lines, 'Here is my best guess')
  call add(lines, printf("call conf#set_name(s:, '%s')", conf#skeleton#get_plugin_name()))
  call add(lines, '')

  call s:add_comment(lines, 'Set a version for your plugin.')
  call s:add_comment(lines, "It should be valid semver string or ['major', 'minor', 'patch'] list")
  call add(lines, "call conf#set_version(s:, [1, 0, 0])")
  call add(lines, '')

  call s:add_comment(lines, 'Try adding a configuration area to your plugin, like so')
  call add(lines, "\" call conf#add_area(s:, 'defaults')")

  " TODO: Create better examples here
  call extend(lines, ['',''])
  call s:add_comment(lines, 'And then add some options')
  call add(lines,
        \ "\" call conf#add_setting(s:, 'defaults', 'map_key', {'default': '<leader>x', 'type': v:t_string})")
  call add(lines,
        \ "\" call conf#add_setting(s:, 'defaults', 'another_key', {'default': '<leader>a', 'type': v:t_string})")

  call extend(lines, ['',''])

  " This is just to keep things sorted here
  " Unfortunately you have to update this manually when you change s:autoload_skeleton_names
  for key in ['set_setting', 'get_setting', 'view', 'menu', 'get_version']
    call extend(lines, conf#skeleton#function_generate(
        \ autoload_prefix,
        \ key,
        \ s:autoload_skeleton_names[key]
        \ ))

    call extend(lines, ['',''])
  endfor

  for key in sort(keys(s:doc_skeleton))
    call extend(lines, conf#skeleton#function_generate(
          \ autoload_prefix,
          \ key,
          \ s:doc_skeleton[key]
          \ ))
    call add(lines, '')
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

  let conf_args = get(a:conf_dict, 'conf_args', [])
  let func_args = map(copy(a:conf_dict.args), { _, val -> 'a:' . val})
  call add(lines, printf('  return conf#%s(%s)',
        \ a:conf_name,
        \ join(
          \ ['s:'] + conf_args + func_args,
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
  let prefix = expand('%:p:r')
  let prefix = substitute(prefix, "\\", '/', 'g')
  let prefix = substitute(prefix, '//', '/', 'g')
  let prefix = substitute(prefix, '.*autoload/', '', 'g')
  let prefix = substitute(prefix, '/', '#', 'g')

  return prefix
endfunction

""
" Get the guessed plugin name
function! conf#skeleton#get_plugin_name() abort
  let name = expand('%:p:r')
  let name = substitute(name, 'autoload/.*', '', 'g')
  let name = fnamemodify(name, ':h')
  let name = fnamemodify(name, ':t')

  return name
endfunction

""
" Append the configuration
function! conf#skeleton#append() abort
  if has('nvim')
    call nvim_buf_set_lines(0, -1, -1, v:false, conf#skeleton#generate())
  else
    call append(line('$'), conf#skeleton#generate())
  endif
endfunction
