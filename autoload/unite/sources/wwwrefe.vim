"
function! unite#sources#wwwrefe#define()
  return s:source
endfunction

let s:fpath = expand('<sfile>:p:h') . '/../../../data/'

let s:source = {
      \ 'name'           : 'wwwrefe',
      \ 'action_table'   : {},
      \ 'default_action' : {'common' : 'open'},
      \ }

function! s:source.gather_candidates(args, context)
  let candidates = []
  for path in split(glob(s:fpath . '*'), '\n', 'g')
    call add(candidates, {
          \ 'word'   : fnamemodify(path, ':t'),
          \ 'source' : 'wwwrefe',
          \ })
  endfor
  return candidates
endfunction

let s:source.action_table.open = {'description' : 'method list'}
function! s:source.action_table.open.func(candidate)
  call unite#start([['wwwrefe/method', a:candidate.word]])
endfunction
