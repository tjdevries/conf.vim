# Conf.vim

_A plugin for making good configuration for your plugins_

Are you sick of doing something like this:

```
:let g:really_long_plugin_option_name_<tab>
```

and then this shows up:

```
-------------------------------------------------------------------------------
g:really_long_plugin_option_name_this_another_thign
g:really_long_plugin_option_name_wow
g:really_long_plugin_option_name_asdf
g:really_long_plugin_option_name_lol
g:really_long_plugin_option_name_foobar
g:really_long_plugin_option_name_that
g:really_long_plugin_option_name_another
g:really_long_plugin_option_name_tijasdfk

:let g:really_long_plugin_option_name_
-------------------------------------------------------------------------------
```

Me too :smile:

Or even worse, you mispelled an option in your vimrc :cry:

This plugin is here to fix it.

## Configuration and Setup

Here's an example of a set up from another plugin of mine:

```vim
" in plugin "putty.vim"
" file: autoload/putty/configuration.vim

""
" Name of the plugin to be used in error messages
call conf#set_name(s:, 'Putty')

""
" Configuration options for PUTTY
call conf#add_area(s:, 'defaults')
call conf#add_setting(s:, 'defaults', 'plink_location', {
        \ 'type': v:t_string,
        \ 'default': 'C:\Program Files (x86)\PuTTY\plink.exe',
        \ 'description': 'Full path with executable name and extension',
        \ 'validator': {val -> executable(val) },
        \ })
call conf#add_setting(s:, 'defaults', 'window_options', {
        \ 'type': v:t_dict,
        \ 'default': {'filetype': 'lookitt', 'concealcursor': 'n'},
        \ 'description': 'The window options associated with the putty window',
        \ })
call conf#add_setting(s:, 'defaults', 'wait_time', {
        \ 'type': v:t_string,
        \ 'default': '10m',
        \ 'description': 'Wait time after sending a message through putty',
        \ })

function! putty#configuration#get(area, setting) abort
  call conf#get_setting(s:, a:area, a:setting)
endfunction

function! putty#configuration#set(area, setting, value) abort
  call conf#set_setting(s:, a:area, a:setting, a:value)
endfunction

function! putty#configuration#view() abort
  return conf#view(s:)
endfunction

function! putty#configuration#menu() abort
  return conf#menu(s:)
endfunction
```

The user can interact with these settings by calling this:

```vim
call putty#configuration#set('defaults', 'wait_time', '100m')
```

Which will update the value (you would get the value in your plugin by doing `putty#configuration#get('defaults', 'wait_time')`). However, if the user had a typo and did something like this:

```vim
" Note that it is "default", not "defaults" as originally specified
call putty#configuration#set('default', 'wait_time', '100m')
```

They would get the error like:

```
autoload\conf.vim|180| conf#set_setting[2]
|| E605: Exception not caught: [CONF][Putty] Setting area named: 'default' does not exist
```

Now they can't mess up your configuration!

## Validation

You can even add validation to your settings, to reduce the amount of bad configuration possible. For example:

```vim
" ===== Set up configuration options =====
" Set the name of this plugin
call conf#set_name(s:, 'Example Plugin')

" Add an area fo default configuration
call conf#add_area(s:, 'minimum')

" ===== Add some settings =====

" Add a setting for minimum value, it should be greater than 25
call conf#add_setting(s:, 'minimum', 'min_25', {
            \ 'type': v:t_number,
            \ 'default': 35,
            \ 'validator': { val -> val > 25 },
            \ })

" ... define autoload functions here for example#configuration ...

" Now if the user tried to something like this:
call example#configuaration#set('minimum', 'min_25', 20)

" They would get an error like:
" [CONF][Example Plugin][set.VALIDATOR] Setting 'minimum.min_25' failed
```

This `validator` can be any function that takes one input (a value) and returns a boolean.
