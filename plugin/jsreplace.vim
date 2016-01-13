" jsreplace.vim
" Distributed under the MIT license
" Copyright (C) Retorillo

command! -nargs=+ -range JsReplace :<line1>,<line2>call JsReplace(<f-args>)
cabbrev jsreplace <c-r>=getcmdtype() == ":" ? "JsReplace" : "jsreplace"<CR>

let s:escript = expand("<sfile>:p:h")."/exec.js"
let s:tscript = expand("<sfile>:p:h")."/test.js"

if !exists("g:jsreplace_defaultflags")
	let g:jsreplace_defaultflags = "gm"
endif

function! s:makeshell(args)
	let l:shell = ""
	for a in a:args
		if l:shell != ""
			let l:shell .= " "
		endif
		let l:shell .= shellescape(a)
	endfor
	return l:shell
endfunction

function! s:test(pattern, flags)
	return system(s:makeshell([
	\	"node",
	\	s:tscript,
	\	a:pattern,
	\	a:flags
	\ ]))
endfunction
function! s:exec(path, pattern, replace, flags)
	let l:enc  = &encoding
	let l:fenc = &fileencoding
	return system(s:makeshell([
	\	"node",
	\	s:escript,
	\       a:path,
	\	l:fenc != "" ? l:fenc : l:enc,
	\	a:pattern,
	\	a:replace,
	\	a:flags
	\ ]))
endfunction

function! JsReplace(pattern, ...) range
try
	if a:0 > 2
		throw "Too many arguments"
	endif
	let l:replace = a:0 < 1 ? "" : a:1
	let l:flags = a:0 < 2 ? g:jsreplace_defaultflags : a:2
	let l:test = s:test(a:pattern, l:flags)
	if len(l:test) > 0
		throw l:test
	endif
	let l:temp = tempname() 
	for ln in range(a:firstline, a:lastline)
		call writefile([getline(ln)], l:temp , "a")
	endfor
	call s:exec(l:temp, a:pattern, l:replace, l:flags)
	exec a:firstline .",". a:lastline . "d"
	let l:ln = a:firstline - 1
	for l in readfile(l:temp)
		call append(l:ln, l)
		let l:ln += 1 
	endfor
	call delete(l:temp)
endtry
endfunction
