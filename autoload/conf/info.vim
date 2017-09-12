""
" Information regarding conf.vim
" You can use this to make sure you have the correct version

""
" Get the semver version
function! conf#info#get_version() abort
  return conf#__version()
endfunction

""
" Require a certain version of conf.vim
function! conf#info#require(semver) abort
  let semver_obj = std#semver#parse(a:semver)

  return std#semver#is(conf#info#get_version(), '>=', semver_obj)
endfunction
