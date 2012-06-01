"
let s:base_url = 'http://doc.ruby-lang.org/ja/1.9.3/'
"let s:base_url = 'http://doc.okkez.net/193/view/'
""
let s:fpath = expand('<sfile>:p:h') . '/../data/'
"
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
"
let s:classes = substitute(substitute(glob(s:fpath . '*'), s:fpath, '', 'g'), '\n', '#\n', 'g')
"
"
"
function! wwwrefe#open(class, method)
  execute 'edit! wwwrefe'
  setlocal modifiable
  silent %delete _

  "継承関係とモジュールをたどる
  for clazz in split(readfile(s:fpath . a:class, '', 1)[0], ' ')
    if get(g:, 'wwwrefe_myrurema', 0)
      let ret = s:myrurema(clazz, a:method)
    else
      let ret = s:wget(clazz, a:method)
    endif
    if ret.body != ''
      break
    endif
  endfor

  if ret.body == ''
    echohl Error | echo a:class . '#' . a:method . ' was not found' | echohl None
    break
  endif

  call append(0, split(ret.body, '\n')[2:])

  if get(g:, 'wwwrefe_myrurema', 0)
    call append(0, ret.cmd)
    call append(1, s:padding('', strlen(ret.cmd), '='))
    call append(2, '')
  else
    call append(2, '<' . ret.cmd . '>')
  endif

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
function! s:wget(class, method)
  for type in ['i', 's']
    let url  = s:generate_url(a:class, a:method, type)
    let body = s:wwwrender(url)
    if body != ''
      return { 'cmd' : url, 'body' : body }
    endif
  endfor
  return { 'cmd' : '', 'body' : ''}
endfunction
"
"
"
function! s:myrurema(class, method)
  let cmd  = 'rurema ' . a:class . '#' . a:method
  let body = system(cmd)
  return { 'cmd' : cmd, 'body' : body }
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
"
"
"
function! wwwrefe#complete(argLead, cmdLine, cursorPos)
  if a:argLead !~ "#"
    return s:classes
  endif
  let class = split(a:argLead, '#')[0]
  return class . '#' . join(readfile(s:fpath . class)[1:], "\n" . class . '#')
endfunction
"
"
"
function! s:padding(msg, length, char)
  let msg = a:msg
  while len(msg) < a:length
    let msg = msg . a:char
  endwhile
  return msg
endfunction
