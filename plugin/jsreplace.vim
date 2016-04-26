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
   call writefile([s:to_json(opt)], json)

   let test = s:system_safe(g:jsReplace#nodeCommand, s:test_js, json)
   if strlen(test) > 0
      throw test
   endif

   let ln = a:firstline
   let exec = s:system_safe(g:jsReplace#nodeCommand, s:exec_js, json)
   for line in split(substitute(exec, '\r\n', '\n', 'g'), '\n')
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

" ----------------------------------------------------------------------------------------
" Internal utitilies
" ----------------------------------------------------------------------------------------

function! s:system_safe(...)
   let buf = []
   for a in a:000
      call add(buf, shellescape(a))
   endfor
   return system(join(buf, ' '))
endfunction

function! s:json_quote(str)
   let str = a:str
   let str = substitute(str, '\\', '\\\\', 'g')
   let str = substitute(str, '\t', '\\t', 'g')
   return '"'.substitute(str, '"', '\\"', 'g').'"'
endfunction

function! s:to_json(obj)
   let buf = []
   call s:to_json_internal(buf, a:obj)
   return join(buf, '')
endfunction

function! s:to_json_internal(buf, obj)
   if type(a:obj) == 3 " Array
      let c = 0
      call add(a:buf, '[')
      for item in a:obj
         if c > 0
            call add(a:buf, ', ')
         endif
         call s:to_json_internal(a:buf, item)
         let c += 1
      endfor
      call add(a:buf, ']')
   elseif type(a:obj) == 4 " Dictionary
      call add(a:buf, '{')
      let c = 0
      for key in keys(a:obj)
         if c > 0
            call add(a:buf, ', ')
         endif
         call add(a:buf, s:json_quote(key))
         call add(a:buf, ': ')
         call s:to_json_internal(a:buf, a:obj[key])
         let c += 1
      endfor
      call add(a:buf, '}')
   elseif type(a:obj) == 1 " String
      call add(a:buf, s:json_quote(a:obj))
   else
      call add(a:buf, a:obj) " Does not json_quote
   endif
endfunction
