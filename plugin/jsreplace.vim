" JsReplace.vim < https://github.com/retorillo/jsreplace.vim>
" Distributed under the MIT license
" Copyright (C) Retorillo

let s:exec_js = expand('<sfile>:p:h').'/exec.js'
let s:test_js = expand('<sfile>:p:h').'/test.js'

" ----------------------------------------------------------------------------------------
" Global Variables
" ----------------------------------------------------------------------------------------

function! s:let_safe(name, default)
   if !exists(a:name)
      exec 'let '.a:name.' = '.a:default
   endif
endfunction

call s:let_safe('g:jsReplace#defaultFlags', '""')
call s:let_safe('g:jsReplace#nodeCommand', '"node"')

" ----------------------------------------------------------------------------------------
" JsReplace
" ----------------------------------------------------------------------------------------

command! -nargs=+ -range JsReplace :<line1>,<line2>call JsReplace(<f-args>)
cabbrev jsreplace <c-r>=getcmdtype() == ':' && getcmdline()[0 : getcmdpos() - 1] =~ '^\S*$' ? 'JsReplace' : 'jsreplace'<CR>
cabbrev jsr <c-r>=getcmdtype() == ':' && getcmdline()[0 : getcmdpos() - 1] =~ '^\S*$' ? 'JsReplace' : 'jsr'<CR>

function! JsReplace(pattern, ...) range
try
   if g:jsReplace#nodeCommand == 'node' && !executable('node')
      throw 'Command "node" is not found on your system. Install Node.js or optimally set g:jsReplace#nodeCommand.'
   endif
   if a:0 > 2
      throw 'USAGE: JsReplace pattern [replacement [flags]]'
   endif

   " When using require() to parse JSON, extension must be '.json'
   let json = tempname().'.json'
   let opt = {
      \ 'lines': [],
      \ 'pattern': a:pattern,
      \ 'replacement': (a:0 < 1 ? '' : a:1),
      \ 'flags': (a:0 < 2 ? g:jsReplace#defaultFlags : a:2),
      \ 'fileformat': &fileformat,
   \ }

   for ln in range(a:firstline, a:lastline)
      call add(opt.lines, getline(ln))
   endfor
   call writefile([json_encode(opt)], json)

   let test = system(s:mkshell(g:jsReplace#nodeCommand, s:test_js, json))
   if strlen(test) > 0
      throw test
   endif

   let ln = a:firstline
   for line in systemlist(s:mkshell(g:jsReplace#nodeCommand, s:exec_js, json))
      call setline(ln, line)
      let ln += 1
   endfor
   call delete(json)
catch
   echohl Error
   for line in split(v:exception, '\n')
      echo line
   endfor
   echohl None
endtry
endfunction

function! s:mkshell(...)
   let buf = []
   for a in a:000
      call add(buf, shellescape(a))
   endfor
   return join(buf, ' ')
endfunction
