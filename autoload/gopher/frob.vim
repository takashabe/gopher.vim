" frob.vim: Modify Go code.

" Toggle between 'single-line' and 'normal' if checks:
"
"   err := e()
"   if err != nil {
"
" and:
"
"   if err := e(); err != nil {
"
" This works for all variables, not just error checks.
fun! gopher#frob#if()
  let l:line = getline('.')
  if match(l:line, 'if ') is -1
    " Try line below current one too.
    let l:line = getline(line('.') + 1)
    if match(l:line, 'if ') is -1
      return gopher#error('No if statement on current or next line')
    endif

    normal! j
  endif

  let l:line = substitute(l:line, '^\s*', '', '')
  let l:indent = repeat("\t", indent('.') / 4)

  " Convert "if .. {" to "if ..; err != nil {".
  if match(l:line, ';') is -1
    let l:decl = substitute(getline(line('.') - 1), '^\s*', '', '')
    if match(l:decl, '=') is# -1
      return gopher#error('No variable declaration on the line above if')
    endif

    execute ':' . (line('.') - 1) . 'd _'
    call setline('.', printf('%sif %s; %s', l:indent, l:decl, trim(getline('.'))[3:]))
  " Convert "if ..; err != nil {" to "if .. {".
  else
    let [l:prev_line, l:line] = split(l:line, '; ')
    let l:prev_line = substitute(l:prev_line, '^\s*', '', '')[3:]
    call setline('.', printf('%sif %s', l:indent, l:line))
    call append(line('.') - 1, printf('%s%s', l:indent, l:prev_line))
  endif
endfun

" Generate a return statement with zero values.
"
" If error is 1 it will return 'err' and surrounded in an 'if err != nil' check.
function! gopher#frob#ret(error)
  let [l:out, l:err] = gopher#system#run(
        \ [(a:error ? 'iferr' : 'goreturn'), '-pos=' . gopher#buf#cursor()],
        \ gopher#buf#lines())
  if l:err
    return gopher#error(l:out)
  endif

  " Remove current line if blank, e.g. when the cursor is below 'err := ... '.
  if getline('.') =~ '^\s*$'
    silent delete _
    silent normal! k
  endif

  " Copy indent.
  let l:indent = matchstr(getline('.'), '^\s*')
  if l:indent is# ''
    let l:indent = matchstr(getline(line('.') - 1), '^\s*')
  endif

  call append('.', map(split(l:out, "\n"), {_, l -> l:indent . l:l}))

  normal! j^
  if a:error
    " Position cursor on 'err'.
    normal! j$b
  endif
endfunction
