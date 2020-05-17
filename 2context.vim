" Author    : Aditya Mahajan <adityam [at] umich [dot] edu> 
" version   : 2020.05.17
" license   : Simplified BSD License

" This script is part of the t-vim module for ConTeXt. It is based on 2html.vim.  

" This script is invoked by the `t-vim` module with the options
"     vim -c "syntax manual" -c "set syntax=name" ...
" The option `syntax manual` loads `$VIMRUNTIME/syntax/manual.vim`, which
" loads `$VIMRUNTIME/syntax/synload.vim`, which in turn loads,
" `$VIMRUNTIME/syntax/syncolo.vim`, which defines syntax highlighting for
" `preffered groups` and maps `minor groups` to `preffered groups`. See `:he
" group-name` for details. We want the minor groups to appear in the output,
" so we define a simple mapping for them:

" Minor group of Constant
hi String      cterm=NONE
hi Character   cterm=NONE
hi Number      cterm=NONE
hi Boolean     cterm=NONE
hi Float       cterm=NONE

" Minor group of Identifier
hi Function    cterm=NONE

" Minor group of Statement
hi Conditional cterm=NONE
hi Repeat      cterm=NONE
hi Label       cterm=NONE
hi Operator    cterm=NONE
hi Keyword     cterm=NONE
hi Exception   cterm=NONE

" Minor group of PreProc
hi Include     cterm=NONE
hi Define      cterm=NONE
hi Macro       cterm=NONE
hi PreCondit   cterm=NONE

" Minor group of Type
hi StorageClass cterm=NONE
hi Structure    cterm=NONE
hi Typedef      cterm=NONE

" Minor group of Special
hi Tag             cterm=NONE
hi SpecialChar     cterm=NONE
hi Delimiter       cterm=NONE
hi SpecialComment  cterm=NONE
hi Debug           cterm=NONE

" Since this script is called by the t-vim module, we assume that Two buffers
" are open. The first buffer is the input buffer, and the second buffer is the
" output buffer. The script parses content line-by-line from the first buffer
" and pastes the modified result on the second buffer.

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
if exists("escapecomments")
  let s:escapecomments=escapecomments " 0=off, 1=comments, 2=command
else 
  let s:escapecomments=0
endif

" Add a new syntax region to detect ConTeXt tags
if s:escapecomments==2
  syntax region vimtypingTEXcomment start="/BTEX" end="/ETEX" transparent oneline containedin=ALL contains=NONE

  " Find the id of /BTEX ... /ETEX syntax region
  let s:texcommentid = hlID("vimtypingTEXcomment")
else
  let s:texcommentid = -1 " Assuming that all ids are positive. Not documented
end

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
" Get the current line
  let s:line = getline(s:lnum)

  let s:len  = strlen(s:line)
  let s:new  = '' 

" Loop over each character in the line
  let s:col = s:strip + 1
  while s:col <= s:len
    let s:startcol = s:col " The start column for processing text

    " Check if the next transprarent syntax is "vimtypingTEXcomment". If not, 
    " find the next non-transparent syntax id. 
    let s:id = synID (s:lnum, s:col, 0)
    if s:id == s:texcommentid
      let s:texcomment = 1
    else
      let s:texcomment = 0
      let s:id = synID (s:lnum, s:col, 1)
    endif
    let s:col = s:col + 1
" Speed loop (it's small - that's the trick)
" Go along till we find a change in synID
    while s:col <= s:len 
      " If there is a "vimtypingTEXcomment" inside another syntax id, 
      " "vimtypingTEXcomment" should get preference
      let s:nextid = synID(s:lnum, s:col, 0)
      if !s:texcomment && s:nextid != s:texcommentid
        let s:nextid = synID(s:lnum, s:col, 1)
      endif

      if s:nextid != s:id
        break
      endif
         
      let s:col = s:col + 1 
    endwhile

" Output the text with the same synID, with class set to {s:id_name}
    let s:id      = synIDtrans (s:id)
    let s:id_name = synIDattr  (s:id, "name", "gui")
    if s:texcomment
      " Remove /BTEX and /ETEX which are 5 characters wide
      let s:temp = strpart(s:line, s:startcol + 5 - 1, s:col - s:startcol - 5 - 5)
    else
      let s:temp = strpart(s:line, s:startcol - 1, s:col - s:startcol)
    end
" Remove line endings (on unix machines reading windows files)
    let s:temp    = substitute(s:temp, '\r*$', '', '')
" It might have happened that that one has been the last item in a row, so
" we don't need to print in in that case
    if strlen(s:temp) > 0
" Change special TeX characters to escape sequences.
      if !(s:texcomment || (s:escapecomments == 1) && s:id_name == "Comment")
        let s:temp = escape( s:temp, '\{}')
      endif
      if !(s:texcomment || empty(s:id_name))
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
