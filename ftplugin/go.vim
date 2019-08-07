if exists(':GoDef') >= 2
  if get(g:, 'gopher_override_vimgo', 0)
    call gopher#override_vimgo()
  else
    echohl Error
    echom 'It looks like vim-go is installed; running both vim-go and gopher.vim will not'
    echom 'work well, so GOPHER.VIM WILL NOT LOAD.'
    echom 'Add this to your vimrc to override vim-go:'
    echom '   let g:gopher_override_vimgo = 1'
    echom 'This is only recommended for testing/experimenting.'
    echohl None
    sleep 2
    finish
  endif
endif

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

call gopher#init#config()
call gopher#init#version()

setlocal formatoptions-=t
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s
setlocal foldmethod=syntax
setlocal noexpandtab

" Special-fu to ensure we don't clobber the buffer with errors.
" TODO: /dev/stdin is not completely portable, but I don't know how to get the
" same effect with standard POSIX redirection.
let &l:equalprg = 'gofmt 2>/dev/null || cat /dev/stdin'

compiler go

let b:undo_ftplugin = 'setl formatoptions< comments< commentstring< equalprg<'

" Motions
onoremap <buffer> <silent> af :<C-u>call gopher#motion#function('a')<CR>
xnoremap <buffer> <silent> af :<C-u>call gopher#motion#function('a')<CR>
onoremap <buffer> <silent> if :<C-u>call gopher#motion#function('i')<CR>
xnoremap <buffer> <silent> if :<C-u>call gopher#motion#function('i')<CR>

onoremap <buffer> <silent> ac :<C-u>call gopher#motion#comment('a')<CR>
xnoremap <buffer> <silent> ac :<C-u>call gopher#motion#comment('a')<CR>
onoremap <buffer> <silent> ic :<C-u>call gopher#motion#comment('i')<CR>
xnoremap <buffer> <silent> ic :<C-u>call gopher#motion#comment('i')<CR>

nnoremap <buffer> <silent> ]] :<C-u>call gopher#motion#jump('n', 'next')<CR>
onoremap <buffer> <silent> ]] :<C-u>call gopher#motion#jump('o', 'next')<CR>
xnoremap <buffer> <silent> ]] :<C-u>call gopher#motion#jump('v', 'next')<CR>
nnoremap <buffer> <silent> [[ :<C-u>call gopher#motion#jump('n', 'prev')<CR>
onoremap <buffer> <silent> [[ :<C-u>call gopher#motion#jump('o', 'prev')<CR>
xnoremap <buffer> <silent> [[ :<C-u>call gopher#motion#jump('v', 'prev')<CR>

" Mappings
nnoremap <buffer> <Plug>(gopher-if)     :call gopher#frob#if()<CR>
nnoremap <buffer> <Plug>(gopher-err)    :call gopher#frob#ret(1)<CR>
nnoremap <buffer> <Plug>(gopher-return) :call gopher#frob#ret(0)<CR>

if !get(g:, 'gopher_map_disabled', 0)
  exe printf('nmap %si <Plug>(gopher-if)',     get(g:, 'gopher_map_prefix', ';'))
  exe printf('nmap %se <Plug>(gopher-err)',    get(g:, 'gopher_map_prefix', ';'))
  exe printf('nmap %sr <Plug>(gopher-return)', get(g:, 'gopher_map_prefix', ';'))
endif

" Commands
command! -bang                                                  GoDiag     call gopher#diag#do(<bang>0)
command!                                                        GoSetup    call gopher#system#setup()

command! -nargs=* -complete=customlist,gopher#coverage#complete GoCoverage call gopher#coverage#do(<f-args>)
command! -nargs=+ -complete=customlist,gopher#guru#complete     GoGuru     call gopher#guru#do(<f-args>)
command! -nargs=+                                               GoImport   call gopher#import#do(<f-args>)
command! -nargs=? -complete=customlist,gopher#rename#complete   GoRename   call gopher#rename#do(<f-args>)
command! -nargs=* -range                                        GoTags     call gopher#tags#modify(<line1>, <line2>, <count>, <f-args>)
