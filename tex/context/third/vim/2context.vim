" Author    : Aditya Mahajan <adityam [at] umich [dot] edu> 
" version   : 2011.02.05
" license   : Simplified BSD License

" This script is part of the t-vim module for ConTeXt. It is based on 2html.vim.  
" It assumes that two buffers are open. The first buffer is the input buffer,
" and the second buffer is the output buffer.

" We move back and forth between the buffers, 

" Split and go to the last buffer
sblast 

" Make sure that the buffer is modifiable
set modifiable

" ... and empty
%d 

" Loop over all lines in the original text.

wincmd p

" Use contextstartline and contextstopline if they are set.

if exists("contextstartline")
  let s:lnum = contextstartline
  if !(s:lnum >= 1 && s:lnum <= line("$"))
    let s:lnum = 1
  endif
else
  let s:lnum = 1
endif

if exists("contextstopline")
  let s:end = contextstopline
  if !(s:end >= s:lnum && s:end <= line("$"))
    let s:end = line("$")
  elseif s:end < 0
    let s:end = line("$") - s:end
  endif
else
  let s:end = line("$")
endif

let s:buffer_lnum = 1

while s:lnum <= s:end
" Get the current line
  let s:line = getline(s:lnum)
  let s:len  = strlen(s:line)
  let s:new  = "\\NL{}"

" Loop over each character in the line
  let s:col = 1
  while s:col <= s:len
    let s:startcol = s:col " The start column for processing text
    let s:id       = synID (s:lnum, s:col, 1)
    let s:col      = s:col + 1
" Speed loop (it's small - that's the trick)
" Go along till we find a change in synID
    while s:col <= s:len && s:id == synID(s:lnum, s:col, 1) 
      let s:col = s:col + 1 
    endwhile

" Output the text with the same synID, with class set to {s:id_name}
    let s:id      = synIDtrans (s:id)
    let s:id_name = synIDattr  (s:id, "name", "gui")
    let s:temp    = strpart(s:line, s:startcol - 1, s:col - s:startcol)
" Remove line endings (on unix machines reading windows files)
    let s:temp    = substitute(s:temp, '\r*$', '', '')
" It might have happened that that one has been the last item in a row, so
" we don't need to print in in that case
    if strlen(s:temp) > 0
" Change special TeX characters to escape sequences.
" The funny \type{||||||||||} and \type{$$$$$$$$$} characters should never
" appear in {\em normal} \TEX\ file. As a side||effect, this script can not
" pretty print itself.
      let s:temp = substitute( s:temp,  '\\', '\\letterbackslash||||||||||$$$$$$$$$$', 'g')
      let s:temp = substitute( s:temp,  '{',  '\\letteropenbrace||||||||||$$$$$$$$$$', 'g')
      let s:temp = substitute( s:temp,  '}',  '\\letterclosebrace||||||||||$$$$$$$$$$', 'g')
      let s:temp = substitute( s:temp,  '||||||||||' , '{' , 'g')
      let s:temp = substitute( s:temp,  '\$\$\$\$\$\$\$\$\$\$' , '}' , 'g')
      let s:new  = s:new . '\SYN[' . s:id_name . ']{' . s:temp .  '}'
    endif

" Why will we ever enter this loop
"    if s:col > s:len
"      break
"    endif
  endwhile

" Expand tabs 
  let s:pad   = 0
  let s:start = 0
  let s:idx = stridx(s:line, "\t")
  while s:idx >= 0
    let s:i     = &ts - ((s:start + s:pad + s:idx) % &ts)
"   let s:new   = substitute(s:new, '\t', strpart(s:expandedtab, 0, s:i), '')
    let s:new   = substitute(s:new, '\t', '\\tab{' . s:i . '}', '')
    let s:pad   = s:pad + s:i - 1
    let s:start = s:start + s:idx + 1
    let s:idx   = stridx(strpart(s:line, s:start), "\t")
  endwhile

" Go back and paste the current line
  wincmd p
  call append (s:buffer_lnum-1, s:new)
  wincmd p

" Increment line numbers
  let s:lnum = s:lnum + 1
  let s:buffer_lnum = s:buffer_lnum + 1
endwhile

wincmd p
" We have a spurious line in the end. So we remove it.
$delete
" Write the file
write
