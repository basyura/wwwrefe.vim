"
function! unite#sources#wwwrefe_method#define()
  return s:source
endfunction

let s:fpath = expand('<sfile>:p:h') . '/../../../data/'

let s:source = {
      \ 'name'           : 'wwwrefe/method',
      \ 'action_table'   : {},
      \ 'default_action' : {'common' : 'open'},
      \ 'is_listed' : 0,
      \ }

function! s:source.gather_candidates(args, context)
  let candidates = []
  let class = a:args[0]
  call unite#print_message(class)
  let methods = readfile(s:fpath . class) 
  for line in methods[1:]
    call add(candidates, {
          \ 'word'          : line,
          \ 'source'        : 'wwwrefe',
          \ 'source__class' : class,
          \ })
  endfor
  return candidates
endfunction
"
"
"
let s:source.action_table.open = {'description' : 'open reference'}
function! s:source.action_table.open.func(candidate)
  call wwwrefe#open(a:candidate.source__class, a:candidate.word)
endfunction
