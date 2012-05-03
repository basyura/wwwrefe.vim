
command! -nargs=? -complete=custom,wwwrefe#complete  -bang WWWRefe call s:WWWRefe('<args>', '<bang>') 

function! s:WWWRefe(param, bang)
  let pare = split(a:param, '#')
  call wwwrefe#open(pare[0], pare[1])
endfunction

