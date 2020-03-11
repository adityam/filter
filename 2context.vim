" Author    : Aditya Mahajan <adityam [at] umich [dot] edu> 
" version   : 2011.12.23
" license   : Simplified BSD License

" This script is part of the t-vim module for ConTeXt. It is based on 2html.vim.  
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

let s:preservetagspattern = '\\\(some\|st\(art\|op\)\)line\[[^\]]\+\]'

" Set highlight
if !exists("highlight") 
  let highlight=[]
endif

" Set escapecomments
if !exists("escapecomments")
  let escapecomments=0
endif

if !exists("showlinetags")
   let showlinetags=1
endif
let s:startcomment = []
let s:stopcomment = []
for s:comsym in split(&comments,',')
  let s:comsym = split(s:comsym,':')
  echo s:comsym
  if len(s:comsym) < 2
    let s:startcomment = add(s:startcomment,escape(s:comsym[0],'\[*.]^$'))
  elseif ( s:comsym[0] =~ 's\|m\|^[^e]*$' || s:comsym[0] =~ '^$' )
    let s:startcomment = add(s:startcomment,escape(s:comsym[1],'\[*.]^$'))
  else
    let s:stopcomment = add(s:stopcomment,escape(s:comsym[1],'\[*.]^$'))
  endif
endfor
if len(s:startcomment) < 1 && exists("+commentstring")
  let s:havecomment = split(&commentstring,"%s")
  if len(s:havecomment) > 0
    let s:startcomment = add(s:startcomment,s:havecomment[0])
    if len(s:havecomment) > 1
      let s:stopcomment = add(s:stopcomment,s:havecomment[1])
    endif
  endif
endif
let s:endcomment = add(s:stopcomment,'$')
let s:emptycomment = '^\(' . join(s:startcomment,'\|') . '\)\s*\(' . join(s:stopcomment,'\|') . '\)$'

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

      let s:tags = ''
      if ( s:id_name != "Comment" || s:temp =~ s:emptycomment )
          let s:temp = escape( s:temp, '\{}')
      else 
        let s:strip = s:temp
       	let s:foundtag = matchstrpos(s:temp,s:preservetagspattern)
		if s:foundtag[1] < 0
          let s:temp = ''
          let s:tail = 0
        else
          let s:temp = s:temp[:(s:foundtag[1]-1)]
          let s:tail = s:foundtag[2]
        endif
        if !(escapecomments)
          if ( showlinetags || s:foundtag[1] < 0 )
" extract \someline, \linestart, \linestop tags and ensure that they are
" processed by lex eventhough escapecomments is off. In addition keep them visible in
" output if present 
            let s:temp = escape(s:strip,'\{}')
            while ( s:foundtag[1] >= 0 )
              let s:tags = s:tags . s:foundtag[0]
       	      let s:foundtag = matchstrpos(s:strip,s:preservetagspattern,s:foundtag[2])
            endwhile
          else
" extract \someline, \linestart, \linestop tags and ensure that they are
" processed by lex eventhough escapecomments is off.
            let s:temp = escape(s:temp,'\{}')
            while ( s:foundtag[1] >= 0 )
              let s:tags = s:tags . s:foundtag[0]
              let s:temp = s:temp . escape(s:strip[(s:tail) : (s:foundtag[1]-1)],'\{}')
              let s:tail = s:foundtag[2]
       	      let s:foundtag = matchstrpos(s:strip,s:preservetagspattern,s:tail)
            endwhile
            let s:temp = s:temp . escape(s:strip[(s:tail):],'\{}')
          endif
        elseif showlinetags
" extract \someline, \linestart, \linestop tags and show them literally in
" output disregarding that escapecomments is set 
          while (s:foundtag[1] >= 0 )
            let s:tags = s:tags . s:foundtag[0]
            let s:temp = s:temp . s:strip[(s:tail) : (s:foundtag[1]-1) ] . escape(s:foundtag[0],'\{}')
            let s:tail = s:foundtag[2]
       	    let s:foundtag = matchstrpos(s:strip,s:preservetagspattern,s:tail)
          endwhile
          let s:temp = s:temp . s:strip[(s:tail):]
        else
" extract \someline, \linestart, \linestop tags disregarding the fact that 
" escapecomments is set anyway.
          while ( s:foundtag[1] >= 0 )
            let s:tags = s:tags . s:foundtag[0]
            let s:temp = s:temp . s:strip[(s:tail) : (s:foundtag[1]-1) ]
            let s:tail = s:foundtag[2]
       	    let s:foundtag = matchstrpos(s:strip,s:preservetagspattern,s:tail)
          endwhile
          let s:temp = s:temp . s:strip[(s:tail):]
        endif
" check if comment falls empty after removing all \someline, \startline and
" \stopline tags. If it does hide it from syntaxhighlighting
        if ( s:temp =~ s:emptycomment )
           let s:temp = ''
           let s:id_name = ''
        endif
      endif
      if !empty(s:id_name)
        let s:temp = '\SYN[' . s:id_name . ']{' . s:temp .  '}'
      endif
" assemble output and append string containing \someline, \startline and
" \stopline tags if any 
      let s:new  = s:new . s:temp . s:tags
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
