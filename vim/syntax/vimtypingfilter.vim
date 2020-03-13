"" include underlying syntax file as denoted by syntaxbase variable
"" keep value of b:current_syntax variable
execute "runtime! " . fnameescape("syntax/" . syntaxbase . ".vim")

"" add a new syntax group called vimTypingTeXTags and allow it to be matched
"" within other groups as well as on top

"" TODO this is a rather broad matching guess
"" some languages need to be setup more specific eg. HTML
"" single them out by questing explicitly syntaxbase string defining
"" vimTypeingTeXTags syntax group specifically for language instead of using
"" below generic pattern
"" TODO the below generic group-name pattern covering a big set of languages
"" rather well. It is rather non specific global
"" make more specific if necessary
syntax region vimTypingTeXTags start="/BTEX" end="/ETEX" transparent containedin=\w*\([Cc]omment\|[Tt]odo\|[Ss]tatement\|[Mm]acro\|[Dd]efine\|[Pp]re[Cc]ondit\|[Tt]ypedef\|[Dd]ebug\|[Bb]lock\|[Rr]egion\|[Hh]eredoc\|[Ee]nvironment\|[Ee]xpression\|[Cc]ontext\|[Dd]ocument\|[Zz]onei\|[Bb]ody\|[Ss]kip\)\w* contains=NONE


"" unless a highlighting group is needed too for transparent syntaxgroup 
"" the above should do the trick
