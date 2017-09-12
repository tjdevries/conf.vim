" Add a variable to check if conf_vim has been loaded
let g:loaded_conf_vim = 1
let g:conf_vim = {}
let g:conf_vim.unable_to_load = v:false
let g:conf_vim.requirements = {}
let g:conf_vim.requirements.standard_vim = [1, 0]

if !std#info#require(g:conf_vim.requirements.standard_vim)
    echoerr '[CONF] You need to install a newer version of "tjdevries/standard.vim". Install it like you instaleld this"'
    let g:conf_vim.unable_to_load = v:true
endif
