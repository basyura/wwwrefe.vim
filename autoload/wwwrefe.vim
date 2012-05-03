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

  " 継承関係とモジュールをたどる
  for clazz in split(readfile(s:fpath . a:class, '', 1)[0], ' ')
    let flg = 0
    for type in ['i', 's']
      let url    = s:generate_url(clazz, a:method, type)
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
