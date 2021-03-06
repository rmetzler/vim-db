if exists('g:autoloaded_db_mysql')
  finish
endif
let g:autoloaded_db_mysql = 1

function! db#adapter#mysql#canonicalize(url) abort
  let url = substitute(a:url, '^mysql\d*:/\@!', 'mysql:///', '')
  " JDBC
  let url = substitute(url, '//address=(\(.*\))\(/[^#]*\)', '\="//".submatch(2)."&".substitute(submatch(1), ")(", "\\&", "g")', '')
  let url = substitute(url, '[&?]', '?', '')
  return db#url#absorb_params(url, {
        \ 'user': 'user',
        \ 'password': 'password',
        \ 'path': 'host',
        \ 'host': 'host',
        \ 'port': 'port',
        \ 'protocol': ''})
endfunction

function! s:command_for_url(url)
  return 'mysql' . db#url#as_args(a:url, '-h ', '-P ', '-S ', '-u ', '-p', '')
endfunction

function! db#adapter#mysql#interactive(url) abort
  return s:command_for_url(a:url)
endfunction

function! db#adapter#mysql#filter(url) abort
  return db#adapter#mysql#interactive(a:url) . ' -t'
endfunction

function! db#adapter#mysql#auth_pattern() abort
  return '^ERROR 104[45] '
endfunction

function! db#adapter#mysql#complete_opaque(url) abort
  return db#adapter#mysql#complete_database('mysql:///')
endfunction

function! db#adapter#mysql#complete_database(url) abort
  let pre = matchstr(a:url, '[^:]\+://.\{-\}/')
  let cmd = s:command_for_url(pre)
  let out = system(cmd, 'show databases')
  return split(out, "\n")[1:-1]
endfunction

function! db#adapter#mysql#tables(url) abort
  return split(system(db#adapter#mysql#interactive(a:url). ' -e "show tables"'), "\n")[1:-1]
endfunction
