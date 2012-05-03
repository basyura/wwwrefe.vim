"
function! unite#sources#wwwrefe#define()
  return [s:source_class, s:source_method]
endfunction

let s:fpath = expand('<sfile>:p:h') . '/../../../data/'

let s:source_class = {
      \ 'name': 'wwwrefe',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : {'common' : 'method'},
      \ }

let s:source_method = {
      \ 'name': 'wwwrefe/method',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : {'common' : 'open'},
      \ 'is_listed' : 0,
      \ }

function! s:source_class.gather_candidates(args, context)
  let candidates = []
  for path in split(glob(s:fpath . '*'), '\n', 'g')
    call add(candidates, {
          \ 'word'   : fnamemodify(path, ':t'),
          \ 'source' : 'wwwrefe',
          \ })
  endfor
  return candidates
endfunction

let s:source_class.action_table.method = {'description' : 'method list'}
function! s:source_class.action_table.method.func(candidate)
  call unite#start([['wwwrefe/method', a:candidate.word]])
endfunction

function! s:source_method.gather_candidates(args, context)
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
let s:source_method.action_table.open = {'description' : 'open reference'}
function! s:source_method.action_table.open.func(candidate)
  call wwwrefe#open(a:candidate.source__class, a:candidate.word)
endfunction
