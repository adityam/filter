" Author    : Aditya Mahajan <adityam [at] umich [dot] edu> 
" version   : 2011.12.23
" license   : Simplified BSD License

" This script is part of the t-vim module for ConTeXt. It is based on 2html.vim.  
" Since this script is called by the t-vim module, we assume that Two buffers
" are open. The first buffer is the input buffer, and the second buffer is the
" output buffer. The script parses content line-by-line from the first buffer
" and pastes the modified result on the second buffer.

"" before starting open buffer to get syntaxid of vimTypingTeXTags syntax
"" group. knowing the id simplifies and speedsup location of /BTEX /ETEX
"" syntax group added by vimtypingfilter.vim syntax file.
"" These are used to hide context commands from vim syntax highlighting and
"" checking. For details see vim/syntax/vimtypingfilter.vim file

"" open hidden [scratch] buffer
new 
setlocal buftype=nofile noswapfile bufhidden=hide

"" write line containing begin and end tex tags only
call setline(1,"/BTEX /ETEX")

"" denominate vimtypingfilter as the syntax file to be used for this buffer
set syntax=vimtypingfilter

"" loop through characters of first line containing the string unti
"" synid returns the id of the transparent 'vimTypingTeXTags' group
"" stop as soon as found and remove buffer
let s:vimtypingid = synID(1,0,0)
let s:col = 1
while synIDattr(s:vimtypingid,"name") != "vimTypingTeXTags"
	let s:vimtypingid = synID(1,s:col,0)
	let s:col = s:col + 1
endwhile
"" done discard the [scratch] buffer again
q!

"" start processing regular input

" Split screen and go to the second buffer, ensure modifiable is set, and the
" buffer is empty.
sblast 
set modifiable
%d 

" Go to first buffer
wincmd p

" If contextstartline and contextstartline are set, use them.
if exists("contextstartline")
  let s:lstart = max([1,  min([line("$"), contextstartline]) ])
else
  let s:lstart = 1
endif

if exists("contextstopline")
  if contextstopline <= 0 
      let contextstopline = line("$") + contextstopline 
  endif
  let s:lstop = min([line("$"), max([s:lstart, contextstopline]) ])
else
  let s:lstop = line("$")
endif

" Set highlight
if !exists("highlight") 
  let highlight=[]
endif

" Set escapecomments
if !exists("escapecomments")
  let escapecomments=0
endif

let s:strip = strlen( matchstr( getline(s:lstart), '^\s*' ) )

" Find the smallest leading white space
if exists("strip") && strip && (s:strip != 0)
  echo "Calculating amount of leading whitespace"
  for s:lnum in range(s:lstart, s:lstop)
    let s:line  = getline(s:lnum)
    if (match(s:line, '^\s*$')) == -1 " line is not empty
      let s:space = matchstr(s:line, '^\s*')
      let s:len   = strlen(s:space)
      " echo s:len
      let s:strip = min([s:strip, s:len])
      if s:strip == 0
        break 
      end
    end
  endfor
  " echo "Strip amount:" . s:strip
else
  let s:strip = 0
endif

let s:lines = []

" Loop over all lines in the original text.
let s:buffer_lnum = 1
let s:lnum = s:lstart

while s:lnum <= s:lstop
" Get the current line and remove windows line ends
  let s:line = getline(s:lnum)

  let s:len  = strlen(s:line)
  let s:new  = '' 

" Loop over each character in the line
  let s:col = s:strip + 1
  while s:col <= s:len
    let s:startcol = s:col " The start column for processing text

" tets the syntaxid at the current column position
" check if it resembles the special, transparent vimTypingTeXTags section
" in case not reread the syntax id hiding transparent syntax groups
    let s:id       = synID (s:lnum, s:col, 0)
	if s:id != s:vimtypingid 
      let s:id   = synID (s:lnum, s:col, 1)
	endif
    let s:col      = s:col + 1
" Speed loop (it's small - that's the trick)
" Go along till we find a change in synID
" changes may include begin or end of the transparent vimTypingTeXTags
" syntax group. Any other transparent syntax group is ignored and it's
" syntax id recalculated with transparent groups hidden
    while s:col <= s:len
      let s:nextid = synID(s:lnum, s:col, 0)
      if s:nextid != s:vimtypingid
        let s:nextid = synID(s:lnum, s:col, 1) 
      endif
      if s:nextid != s:id
		break
      endif
      let s:col = s:col + 1 
    endwhile

" Output the text with the same synID, with class set to {s:id_name}
" For vimTypingTeXTags remove leading and trailing /BTEX and /ETEX tags
" which are 5 characters wide each
    if s:id == s:vimtypingid

" finally get synID of enclosing syntax group if any to pick proper color
" for any visible content between /BTEX /ETEX
      let s:id = synID(s:lnum,s:startcol,1)
      let s:escapetexchars = 0 " do not escape tex commands inbetween /BTEX /ETEX in any case
      let s:temp    = strpart(s:line, s:startcol + 4, s:col - s:startcol - 10)
	else
      let s:escapetexchars = !(escapecomments && s:id_name == "Comment" )
      let s:temp    = strpart(s:line, s:startcol - 1, s:col - s:startcol)
    endif

" Remove line endings (on unix machines reading windows files)
    let s:temp    = substitute(s:temp, '\r*$', '', '')
    let s:id      = synIDtrans (s:id)
    let s:id_name = synIDattr  (s:id, "name", "gui")
" It might have happened that that one has been the last item in a row, so
" we don't need to print in in that case
    if strlen(s:temp) > 0
" Change special TeX characters to escape sequences.
      if s:escapetexchars 
        let s:temp = escape( s:temp, '\{}')
      endif
      if !empty(s:id_name)
        let s:temp = '\SYN[' . s:id_name . ']{' . s:temp .  '}'
      endif
      let s:new  = s:new . s:temp
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

" Remove leading whitespace
" let s:new = substitute(s:new, '^\s\{' . s:strip . '\}', "", "")

" Highlight line, if needed.
  if (index(highlight, s:lnum) != -1)
    let s:new = '\HGL{' . s:new . '}'
  endif

  " Add begin and end line markers 
  let s:new = "\\SYNBOL{}" . s:new . "\\SYNEOL{}"

  call add(s:lines, s:new)

" Increment line numbers
  let s:lnum = s:lnum + 1
  let s:buffer_lnum = s:buffer_lnum + 1
endwhile

" Go to previous buffer
wincmd p
echo s:lines
call setline(1,s:lines)
unlet s:lines
write
