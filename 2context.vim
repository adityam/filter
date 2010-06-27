"D \module
"D   [      file=2context.vim,
"D        version=2007.01.03,
"D          title=ViM to \CONTEXT,
"D       subtitle=Use ViM to generate code listing,
"D         author=Mojca Miklavec \& Aditya Mahajan,
"D          email=adityam at umich dot edu,
"D           date=\currentdate,
"D      copyright=Public Domain]

"D This file is based on \filename{2html.vim}. It uses VIM systax highlighting
"D to generate a \CONTEXT\ file which is parsed using \filename{t-vimsyntax}
"D module.

if expand("%") == ""
  new texput.vimout
else
  new %:r.vimout
endif

"D We are right now in the new buffer.

set modifiable
%d "This empties the buffer.

wincmd p

"D Loop over all lines in the original text.
"D Use contextstartline and contextstopline if they are set.

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
  endif
else
  let s:end = line("$")
endif

let s:buffer_lnum = 1

while s:lnum <= s:end
"D Get the current line
  let s:line = getline(s:lnum)
  let s:len  = strlen(s:line)
  let s:new  = ""

"D Loop over each character in the line
  let s:col = 1
  while s:col <= s:len
    let s:startcol = s:col " The start column for processing text
    let s:id       = synID (s:lnum, s:col, 1)
    let s:col      = s:col + 1
"D Speed loop (it's small - that's the trick)
"D Go along till we find a change in synID
    while s:col <= s:len && s:id == synID(s:lnum, s:col, 1) 
      let s:col = s:col + 1 
    endwhile

"D Output the text with the same synID, with class set to {s:id_name}
    let s:id      = synIDtrans (s:id)
    let s:id_name = synIDattr  (s:id, "name", "gui")
    let s:temp    = strpart(s:line, s:startcol - 1, s:col - s:startcol)
"D Remove line endings (on unix machines reading windows files)
    let s:temp    = substitute(s:temp, '\r*$', '', '')
"D It might have happened that that one has been the last item in a row, so
"D we don't need to print in in that case
    if strlen(s:temp) > 0
"D We need to get rid of the characters that can cause trouble in \CONTEXT.
"D The funny \type{||||||||||} and \type{$$$$$$$$$} characters should never
"D appear in {\em normal} \TEX\ file. As a side||effect, this script can not
"D pretty print itself.
      let s:temp = substitute( s:temp,  '\\', '||||||||||\\letterbackslash$$$$$$$$$$', 'g')
      let s:temp = substitute( s:temp,  '{',  '||||||||||\\letteropenbrace$$$$$$$$$$', 'g')
      let s:temp = substitute( s:temp,  '}',  '||||||||||\\letterclosebrace$$$$$$$$$$', 'g')
      let s:temp = substitute( s:temp,  '||||||||||' , '{' , 'g')
      let s:temp = substitute( s:temp,  '\$\$\$\$\$\$\$\$\$\$' , '}' , 'g')
      let s:temp = substitute( s:temp,  '&',  '{\\letterampersand}', 'g')
      let s:temp = substitute( s:temp,  '<',  '{\\letterless}', 'g')
      let s:temp = substitute( s:temp,  '>',  '{\\lettermore}', 'g')
      let s:temp = substitute( s:temp,  '#',  '{\\letterhash}', 'g')
      let s:temp = substitute( s:temp,  '"',  '{\\letterdoublequote}', 'g')
      let s:temp = substitute( s:temp,  "'",  '{\\lettersinglequote}', 'g')
      let s:temp = substitute( s:temp,  '\$', '{\\letterdollar}', 'g')
      let s:temp = substitute( s:temp,  '%',  '{\\letterpercent}', 'g')
      let s:temp = substitute( s:temp,  '\^', '{\\letterhat}', 'g')
      let s:temp = substitute( s:temp,  '_',  '{\\letterunderscore}', 'g')
      let s:temp = substitute( s:temp,  '|',  '{\\letterbar}', 'g')
      let s:temp = substitute( s:temp,  '\~', '{\\lettertilde}', 'g')
      let s:temp = substitute( s:temp,  '/',  '{\\letterslash}', 'g')
      let s:temp = substitute( s:temp,  '?',  '{\\letterquestionmark}', 'g')
      let s:temp = substitute( s:temp,  '!',  '{\\letterexclamationmark}', 'g')
      let s:temp = substitute( s:temp,  '@',  '{\\letterat}', 'g')
      let s:temp = substitute( s:temp,  ':',  '{\\lettercolon}', 'g')
      let s:new  = s:new . '\SYNTAX[' . s:id_name . ']{' . s:temp .  '}'
    endif

" Why will we ever enter this loop
"    if s:col > s:len
"      break
"    endif
  endwhile

"D Expand tabs 
  let s:pad   = 0
  let s:start = 0
  let s:idx = stridx(s:line, "\t")
  while s:idx >= 0
    let s:i     = &ts - ((s:start + s:pad + s:idx) % &ts)
"    let s:new   = substitute(s:new, '\t', strpart(s:expandedtab, 0, s:i), '')
    let s:new   = substitute(s:new, '\t', '\\tab{' . s:i . '}', '')
    let s:pad   = s:pad + s:i - 1
    let s:start = s:start + s:idx + 1
    let s:idx   = stridx(strpart(s:line, s:start), "\t")
  endwhile

"D Go back and paste the current line
  wincmd p
  call append (s:buffer_lnum-1, s:new)
  wincmd p

"D Increment line numbers
  let s:lnum = s:lnum + 1
  let s:buffer_lnum = s:buffer_lnum + 1
endwhile

wincmd p
"D We have a spurious line in the end. So we remove it.
$delete
