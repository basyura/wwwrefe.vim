"
function! unite#sources#wwwrefe#define()
  return [s:source_class, s:source_method]
endfunction

let s:fpath_root = expand('<sfile>:p:h') . '/../../../'

let s:url_convert = [
  \  ['=' , '=3d'],
  \  ['!' , '=21'],
  \  ['?' , '=3f'],
  \  ['[' , '=5b'],
  \  [']' , '=5d'],
  \ ]

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
  for path in split(glob(s:fpath_root . '/data/*'), '\n', 'g')
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
  for line in readfile(s:fpath_root . '/data/' . class)
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

  execute 'split wwwrefe'
  setlocal modifiable

  " 継承関係とモジュールをたどらないといけない
  let list = [a:candidate.source__class, 'Object', 'Module', 'Enumerable', 'Kernel', 'Class']
  for clazz in list
    let body = s:wwwrender(clazz, a:candidate.word)
    let &titlestring = body[1:9] . ':' . body[1:21]
    if body[1:9] != 'Not Found' && body[1:21] != 'Internal Server Error'
      break
    endif
  endfor

  call append(0, split(body, '\n'))
  :0
  setlocal noswapfile
  setlocal nomodified
  setlocal nomodifiable
endfunction
"
"
"
function! s:wwwrender(class, method)
  let url = 'http://doc.okkez.net/193/view/method/' . a:class . '/i/' . a:method
  
  for val in s:url_convert
    let url = substitute(url, val[0], val[1], 'g')
  endfor

  return wwwrenderer#render(url)
endfunction
