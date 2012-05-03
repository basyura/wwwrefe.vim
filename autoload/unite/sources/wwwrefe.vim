"
function! unite#sources#wwwrefe#define()
  return [s:source_class, s:source_method]
endfunction

let s:base_url   = 'http://doc.ruby-lang.org/ja/1.9.3/'
"let s:base_url = 'http://doc.okkez.net/193/view/'
let s:fpath_root = expand('<sfile>:p:h') . '/../../../'

let s:url_convert = [
  \  ['=' , '=3d'],
  \  ['<' , '=3c'],
  \  ['>' , '=3e'],
  \  ['!' , '=21'],
  \  ['?' , '=3f'],
  \  ['[' , '=5b'],
  \  [']' , '=5d'],
  \  ['\~' , '=7e'],
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
  let methods = readfile(s:fpath_root . '/data/' . class) 
  for line in methods[1:]
    call add(candidates, {
          \ 'word'          : line,
          \ 'source'        : 'wwwrefe',
          \ 'source__class' : class,
          \ 'source__related_classes' : split(methods[0]),
          \ })
  endfor
  return candidates
endfunction
"
"
"
let s:source_method.action_table.open = {'description' : 'open reference'}
function! s:source_method.action_table.open.func(candidate)

  execute 'edit! wwwrefe'
  setlocal modifiable
  silent %delete _

  let list = a:candidate.source__related_classes
  " 継承関係とモジュールをたどる
  for clazz in list
    let flg = 0
    for type in ['i', 's']
      let method = a:candidate.word
      let url    = s:generate_url(clazz, method, type)
      let body   = s:wwwrender(url)
      if body != ''
        let flg = 1
        break
      endif
    endfor
    if flg
      break
    endif
  endfor

  if body == ''
    echoerr url . ' is not found'
  endif

  call append(0, split(body, '\n')[2:])
  call append(2, '<' . url . '>')
  :0
  setf markdown
  setlocal buftype=nofile
  setlocal wrap
  setlocal noswapfile
  setlocal nomodified
  setlocal nomodifiable
endfunction
"
"
"
function! s:generate_url(class, method, type)
  let url = s:base_url . 'method/' . a:class . '/' . a:type . '/' . a:method . '.html'
  for val in s:url_convert
    let url = substitute(url, val[0], val[1], 'g')
  endfor
  return url
endfunction
"
"
"
function! s:wwwrender(url)
  return wwwrefe#wwwrenderer#render(a:url)
endfunction
