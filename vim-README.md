The vim module
==============

This module highlights code snippets using vim as a syntax
highlighter. Such a task may appear pointless at first glance. After all,
ConTeXt provides excellent syntax highlighting features for TeX, Metapost, XML,
and a few other languages. And in MkIV, you can specify the grammar to parse a
language, and get syntax highlighting for a new language. But writing such
grammars is difficult. More importantly, why reinvent the wheel? Most
editors, and many other syntax highlighting programs, already syntax highlight
many programming languages. Why not just leverage these external programs to
generate syntax highlighting? This module does exactly that.

Table of Contents
=================

* [Compatibility](#compatibility)
* [Installation](#installation)
* [Usage](#usage)
* [Start and stop lines](#start-and-stop-lines)
* [Changing tab skip](#changing-tab-skip)
* [Avoid clutter](#avoid-clutter)
* [Before and after](#before-and-after)
* [Changing the color scheme](#changing-the-color-scheme)
* [Line numbering](#line-numbering)
* [Number of the first line](#number-of-the-first-line)
* [Standard options for line numbering](#standard-options-for-line-numbering)
* [Spaces](#spaces)
* [Removing leading spaces](#removing-leading-spaces)
* [Adding left margin](#adding-left-margin)
* [Wrapping lines](#wrapping-lines)
* [Highlighting lines](#highlighting-lines)
* [Using TeX code in Comments](#using-tex-code-in-comments)
* [Tuning color schemes](#tuning-color-schemes)
* [Messages and Tracing](#messages-and-tracing)
* [Yes, on, whatever](#yes-on-whatever)
* [Name (and location) of the VIM executable](#name-and-location-of-the-vim-executable)
* [Defining a new colorscheme](#defining-a-new-colorscheme)
* [Modifying an existing color scheme](#modifying-an-existing-color-scheme)
* [XML export](#xml-export)
* [A bit of a history](#a-bit-of-a-history)



Compatibility
------------

This module works with both MkII and MkIV. 

To get colors with MkII, use

    \setupcolors[state=start]

If avoid `--` and `---` to turn into `–` and `—` in MkII, use

    \usetypescript [modern] [texnansi]
    \setupbodyfont [modern]

Both colors and no ligatures work out of the box in MkIV.
   

Installation
------------

This module depends on the `t-filter` module. If you are using ConTeXt
standalone, you can install the module using 

    first-setup.sh --modules="t-filter,t-vim"

Depending on your TeX distribution, you may already have the module.
To verify, check if

    luatools t-vim.tex

returns a meaningful path. If not, you have to manually install the module.
Download the latest version of the `filter` and `vim` modules from
[http://github.com/adityam/filter/downloads](http://github.com/adityam/filter/downloads)
and unzip them either `$TEXMFHOME` or `$TEXMFLOCAL`. Run

    mtxrun --generate

and

    mktexlsr

to refresh the TeX file database (for MkIV and MkII, respectively). If
everything went well

    luatools t-vim

will return the path where you stored the file.

Unfortunately, that is not enough. For the module to work, TeX must be able to
call an external program. This feature is a potential security risk and is
disabled by default on most TeX distributions. To enable this feature in MkII,
you must set

    shell_escape=t

in your `texmf.cnf` file. See this page
[http://wiki.contextgarden.net/write18](http://wiki.contextgarden.net/write18)
on the ConTeXt wiki for detailed instructions.


Usage
-----
Include the module

    \usemodule[vim]

Suppose you want to syntax highlight Ruby. In particular, you want

    \startRUBY
      # Wow, my first ruby program
      print("Hello World")
    \stopRUBY

to be printed with Ruby syntax highlighting. To get that, define

    \definevimtyping [RUBY]  [syntax=ruby]

Yes, its that easy. To get syntax highlighting for a particular language, all
you need to know what is its `filetype` in vim. If you don't know that, start
vim and type `:help syntax.txt` and go through the list of supported languages to
find the name of the language that you are interested in. (Oh, and in case you
don't know how to quit vim, type `:qa!`.)  Vim supports syntax
highlighting for more than 500 programming languages; the `t-vim` module enables
you to use any of them with just one `\definevimtyping`.

The command 

    \definevimtyping [RUBY]  [syntax=ruby]

defines three things:

1. An environment

        \startRUBY
          ...
        \stopRUBY

    The contents of this environment are processed by a vim script
    (`2context.vim`) and the result is read back in ConTeXt.

2. A macro

        \inlineRUBY{...}

    The contents of this macro are processed by a vim script
    (`2context.vim`) and the result is read back in ConTeXt.

3. A macro

        \typeRUBYfile{...}

    The argument of this macro must a file name or a url (urls work in MkIV
    only). That file is processed by `2context.vim` and the result is read back
    in ConTeXt. For controling how frequently a remote file is downloaded when
    processing a url, see the _Processing remote files_ section of the
    `t-filter` manual.

4. A macro

        \processRUBYbuffer[...]

     The argument to the macro is the name of a buffer, which is written to an
     external file, processesd by `2context.vim` and the result is read back in
     ConTeXt.

In all the four cases, the `t-filter` module takes care of writing to external
file, processing by `2context.vim`, and reading the contents back to ConTeXt.
The `t-vim` module simply defines the macros that are used by `2context.vim`.


Start and stop lines
--------------------

The `\start<vimtyping>` ... `\stop<vimtyping>` environment and the `\type<vimtyping>file`
macro take an optional argument that is used to set options.

For example, to typeset lines 15 through 25 of a ruby file
`rails_install.rb`, use:

    \typeRUBYfile[start=15,stop=25]{rails_install.rb}

To exclude 10 lines from the end, set `stop=-10`.

Changing tab skip
-----------------

By default, a literal tab (`0x09` or `^I`) character has a width of 8 spaces. For most
cases, this is too excessive. To reduce the shift of a tab, use the `tab` key.
For example:

    \definevimtyping
      [...]
      [...
       tab=4,
       ...]

changes the tab width to four spaces. 

Avoid clutter
-------------

Running an external file through vim is slow. So, `t-vim` reprocesses a snippet
or a file only if its contents have changed. To check if the contents have
changed, it writes each snippet to a different file and stores the md5 sum of
that snippet. As a result, the working directory gets cluttered with lot of
temporary files. To avoid this clutter, write the temporary files to a
different directory using the `directory` key. For example,

    \definevimtyping[...]
                    [directory=output/]

ensures that all the temporary files are written to the `output` directory. See
the section on _Output Directory_ in the documentation of `t-filter` module for
more details.

Before and after
---------------

Like most ConTeXt environments, `\definevimtyping` also accepts the `before` and
`after` options. These can be used, for example, to enclose the output in a
frame, etc.

Changing the color scheme
-------------------------

This module provides two colorschemes

- `pscolor` based on `ps_color` colorscheme for vim by Shi Zhu Pan.
- `blackandwhite` based on `print_bw` colorscheme for vim by Mike Williams.

A particular color scheme may be chosen using the options:

    \definevimtyping
      [...]
      [...
       alternative=pscolor,
       ...]

The default color scheme is `pscolor`. See below for instructions on how to
define a new colorscheme. 

Line numbering
---------------

**Note**: Currently only works in MkIV. In principle, it should also
work in MkII, but for some reasons it does not. 

To enable line numbering for a particular snippet, use:

    \start<vimtyping>[numbering=yes]
      ...
    \stop<vimtyping>

To enable line numbering for all code snippets, use:

    \definevimtyping
      [...]
      [...
       numbering=yes,
       ...]

If you want a particular snippet not to have line numbering, use

    \start<vimtyping>[numbering=no]
      ...
    \stop<vimtyping>

By default, numbering starts from one, all lines are numbered, numbering is
reset at each snippet, and numbers are displayed on the left. All these defaults
can be changed. 

Number of the first line
------------------------

By default, the numbering starts from one (that is, the first line is numbered
`1`). If you want the first line to be numbered something else, say `15`, you
need to set

      \start<vimtyping>[numberstart=15]

If you want the numbering to continue from where the previous snippet ended, use

      \start<vimtyping>[numbercontinue=yes]

By default, consecutive lines are numbered. If you want alternate lines to be
numbered, use

      \start<vimtyping>[numbertstep=2]

If you want every fifth line to be numbered, use

      \start<vimtyping>[numbertstep=5]

Standard options for line numbering
-----------------------------------

**Note**: Linenumbering options can only be set using `\definevimtyping[...][...]` 
or `\setupvimtyping[...][...]`. They do not work when used with
`\start<vimtyping>`. All the line numbers on a given page have the same
properties. So, if you change these properties in the middle of the page, it
will effect all the listings on that page, _even those defined earlier!_


- To change the color or style of the numbers, use the `numbercolor=...` and
  `numberstyle=...` options. By default `numbercolor` is not set, while
  `numberstyle` is set to `\ttx`.

- To change the alignment of numbers, use the `numberalign=...` option. Default
  value is `flushright`.

- To change the width of the box in which the numbers are typeset, use
  `numberwidth=...` option. Default value is `2em`.

- To change the distance between the numbers and the rest of the code, use
  `numberdistance=...` option. Default value is `0.5em`.

- To change the conversion of numbers, use `numberconversion=...` option.
  Default value is `numbers`.

- Use `numberleft=...` and `numberright=...` options to typeset
  something on the left and right of the number. By default, these options are
  not set.

- `numbercommand=...` is used to set a command for typesetting the number.

- `numberlocation=...` is used to set the location of the numbers. Default value
  is `left`. Change this to `right` if you want the numbers on the right.

Spaces
------

By default, the space is invisible. If you want to make the space visible, set

    \definevimtyping
        [...]
        [...
         space=on,
         ...]

The default value is `space=off`.

Removing leading spaces
-----------------------

If you are listing a code snippet inside another environment, it is common to
indent the TeX code. For example:

    \definevimtyping[C][syntax=C]
    \definevimtyping[ruby][syntax=ruby]

    \startitemize
        \item A hello world example in C
            \startC
              #include<stdio.h>

              int main()
              {
                printf("Hello World")
              }
            \stopC
        \item A hello world example in ruby
            \startruby
              puts "Hello World"
            \stopruby
    \stopitemize

By default, the leading whitespace is stripped so that the output is the same
as

    \startitemize
    \item A hello world example in C
    \startC
    #include<stdio.h>

    int main()
    {
      printf("Hello World")
    }
    \stopC
    \item A hello world example in ruby
    \startruby
    puts "Hello World"
    \stopruby
    \stopitemize


If you want to disable this, set

    \definevimtyping
        [...]
        [...
         strip=no,
         ...]

The default value of `strip` is ψ`yes`.

Adding left margin
------------------

By default, a `<vimtyping>` environment resets the left skip to `0pt`, so each
line is aligned to the left edge. Use the `margin` key to change the left skip
of each line:

    \definevimtyping
        [...]
        [...
         margin=<dimen>,
         ...]

where `<dimen>` is a valid TeX dimension.

    


Wrapping lines
---------------

By default, long lines are not wrapped. If your source code has long lines,
there are two alternatives. First, you can allow the lines to break at spaces by
setting

    \definevimtyping
        [...]
        [...
         lines=split,
         ...]

The default value is `lines=fixed`.

Second, you can allow lines to break between _compound_ words, such as
`long/path`, `long-path`, `long+path`, etc by setting

    \definevimtyping
        [...]
        [...
         option={packed,hyphenated},
         ...]

The default value of `option` is `packed`.  

Note that with both these alternatives do not hyphenate a word, merely break
lines at spaces or at the boundary of compound words. If you really need to
hyphenate words, use

    \definevimtyping
        [...]
        [...
         option={packed,hyphenated},
         align=hyphenated,
         ...]

Note that you have to add **both** `option=hyphenated` and `align=hyphenated`.
The default value of align is `nothypenated`. 

Highlighting lines
------------------

Sometimes you want to draw attention to a particular line (or set of lines). One
way to do so it to highlight the lines by a background color. This can be done
using:

    \start<vimtyping>[highlight={<list>}]
      ...
    \stop<vimtyping>

where `<list>` is a comma separated list. For example, if you want to highlight
lines 1 and 5, you may use:

    \start<vimtyping>[highlight={1,5}]
      ...
    \stop<vimtyping>

This will highlight lines 1 and 5 with gray background color. To change the
highlight color use

    \definevimtyping
        [...]
        [...
         highlightcolor=<color>,
         ...]

where `<color>` is any valid ConTeXt color.

When you pass a comma list to `highlight`, the `2context.vim` script
wraps **each** of those line around `\HGL{....}` macro. The `\HGL` is, in turn, set to the
value of `highlightcommand` key. So, if you want to change the way highlighting
works, change the `highlightcommand`:

    \definevimtyping
        [...]
        [...
         highlightcommand=<command>,
         ...]

where `<command>` is any valid ConTeXt command. The default value is
`highlightcommand` is `\syntaxhighlightline`; in MkIV, `\syntaxhighlightline` is
defined as a bar; in MkII, `\syntaxhighlightline` is defined as a text
background. The bar mechanism is more efficient but both mechanisms behave
differently. The text background starts from the left edge of the line, while
the bar starts from the first non-blank character. 

Using TeX code in Comments
--------------------------

Sometimes one wants to use TeX command in code. There are two different
methods to do so.

The first method is primarily aimed towards writing math in comments. To
enable this, use

    \definevimtyping
        [...]
        [...
         escape=comment,
        ]
      
For backward compatibility, this feature can also be enabled using
`escape=on`.

When `escape=comment` is enabled, the `2context.vim` script passes the
`Comment` syntax region (as identified by `vim`) verbatim to TeX. So, we may
use TeX commands inside the comment region and they will be interpreted by
TeX. For example

    \definevimtyping[C][syntax=c, escape=comment]

    \startC
    /* The following function computes the roots of \m{ax^2+bx+c=0}
     * using the determinant \m{\Delta=\frac{-b\pm\sqrt{b^2-2ac}}{2a}} 
     */
        double root (double a, double b, double c) {....}
    \stopC

**Note** that only `\ { }` have their usual meaning inside the `Comment`
region when `escape=comment` is set. Thus, to enter a math expression, use
`\m{...}` instead of `$...$`. Moreover, spaces are active inside the
math mode, so, as in the above example, avoid spaces in the math expressions.

The second method is to imitate the behavior of `\starttyping` environment,
where one can write arbitrary TeX commands in code inside `/BTEX ... /ETEX`
delimiters. To enable this, use

    \definevimtyping
        [...]
        [...
         escape=command,
        ]

When `escape=command` is enabled, the `2context.vim` script defines a new
syntax region using

    syntax region ... start="/BTEX" end="/ETEX" transparent oneline containedin=ALL contains=NONE
      
and passes content of this region verbatim to TeX. So, any TeX commands used
inside this region are interpreted by TeX. For example,

    \definevimtyping[C][syntax=c, escape=command]

    \startC
       /* Here is a comment describing a complicated function */
       /BTEX\startframedtext[width=\textwidth,corner=round]/ETEX
        double complicated (...) 
        {
          ....
        }
      /BTEX\stopframedtext/ETEX
    \stopC

**Note** that as in the case for `escape=comment`, only `\ { }` have their
usual meaning inside `/BTEX ... /ETEX`. Moreover, spaces are active
characters. So, using a space between `\startframedtext` and `[` or between
after the comma in the options to `\startframedtext` will result in an error.

Clearly, `/BTEX ... /ETEX` is not a valid syntax in any language, so if these
tags are used outside of a comment region (as is the case in the above
example), the code will not compile. So, if the code also needs to run, then
these annotations have to be restricted to the comment region of the code or
the output typeset by ConTeXt has to be manually tested for correctness prior
to the release of your document.

Although, in practice, the use of both escape mechanisms is restricted to
comments, the two mechanism have subtle differences. When using
`escape=comment`, the `2context.vim` script simply passes the content of the
comment region to TeX. This content is still typeset inside a
`\SYN[Comment]{...}` group. While when using `escape=command`, the
`2context.vim` script identifies the content of `/BTEX .. /ETEX` and passes it
to TeX _without wrapping it insider any `\SYN[..]{...}` group_. This has an
advantage when we want to use commands that cannot be used inside a group
(e.g., `\inmargin`). For example, if we want to define a `\callout` macro that
displays a note in the margin which we can refer to later, we can use:


    \define[1]\callout{\inmargin{\rm #1}}
    \definevimtyping[C][syntax=c, escape=command]

    \startC
       /* Here is a comment describing a complicated function */
       double complicated (...) 
       {
          ... // /BTEX\callout{Fancy trick!}/ETEX
       }
    \stopC

Finally, note that the value of `escape` set using `\definevimtyping` is not
used to `\inline<vim>typing`. If for some reason, you do need the escape
mechanism for inline code, use

     \inline<vim>typing[escape=command]{...}

Tuning color schemes
--------------------

Some vim syntax files have optional features that are turned on or off using
variables. To enable these optional features, you need to first create a `vimrc`
file and then use it.

To create a `vimrc` file, use

    \startvimrc[name=...]
    ...
    \stopvimrc

The `name=...` is necessary. To enable the settings in this `vimrc` file, use:

     \definevimtyping
        [...]
        [...
         vimrc=...,
         ...]

The value of `vimrc` key needs to be the same as the value of the `name`
key in `\startvimrc`. You may set the `vimrc` file for a particular code snippet
by

    \start<vimtyping>[vimrc=....]
    ..
    \stop<vimtyping>


To disable loading of `vimrc` file, use

     \definevimtyping
        [...]
        [...
         vimrc=,
         ...]
    

The default is not to use any `vimrc` file.

A `vimrc` file gets loaded before syntax highlighting is enabled. If you want to
override the default syntax highlighting scheme, add the appropriate `syn ...`
commands to a `vimrc` file, and source that using

     \definevimtyping
        [...]
        [...
         extras=<name of vimrc file>,
         ...]

For example, suppose you are using a C++ library that defines `uDouble` as a
keyword, so you want to highlight it in your code. Use

    \startvimrc[name=cpp_extras]
    syn keyword Type uDouble
    \stopvimrc

    \definevimtyping
      [cpp]
      [
        syntax=cpp,
        extras=cpp_extras,
      ]

Messages and Tracing
--------------------

The vim module uses the filter module in the background. The filter module
outputs some diagnostic information on the console output to indicate what is
happening. For example, for each code snippet, you will see messages like

    t-filter        > command : vim -u NONE -e -s -C -n -c "set tabstop=4" -c "syntax on" -c "set syntax=scala" -c "let contextstartline=1" -c "let contextstopline=0" -c "source kpse:2context.vim" -c "qa" scala-temp-SCALA-0.tmp scala-temp-SCALA-0.vimout

If, for some reason, the output file is not generated, or not found, a message
similar to 

    t-filter        > file matlab-temp-MATLAB-0.vimout cannot be found
    t-filter        > current filter : MATLAB
    t-filter        > base file : matlab-temp-MATLAB-0
    t-filter        > input file : matlab-temp-MATLAB-0.tmp
    t-filter        > output file : matlab-temp-MATLAB-0.vimout

is displayed in the console. At the same time, the string

    [[output file missing]]

is displayed in the PDF output. This data, along with the filter command, is
useful for debugging what whet wrong.

Yes, on, whatever
-----------------

ConTeXt has two ways of indicating binary options:

- `option=yes` and `option=no`
- `option=on` and `option=off`

The core commands freely switch between the two. In some cases, `option=yes` has
a different meaning than `option=on`. To avoid confusion, I have made these
synonyms. Thus, whenever the documentation says `option=yes`, you may use
`option=on`. And vice-versa. One less thing to worry about!

Name (and location) of the VIM executable
-----------------------------------------

By default, the `t-vim` module calls the program `vim` to do syntax
highlighting. If the `vim` program is not in the `$PATH`, the `vimcommand`
option may be used to specify the compete path of `vim`:

    \setupvimtyping[vimcommand=/path/to/vim]

This option may also be used to call [Neovim] instead of `vim` to do syntax
highlighting, by either using

    \setupvimtyping[vimcommand=nvim]

or, if `nvim` is not in the `$PATH`, using

    \setupvimtyping[vimcommand=/path/to/nvim]

[Neovim]: https://neovim.io/

As of 2020.04.29, `nvim` is about 10% faster than `vim`.

Defining a new colorscheme
--------------------------

Vim recommends the following names for syntax highlighting groups (information
copied from `:help group-name`):

> ```
> 	*Comment	any comment
> 
> 	*Constant	any constant
> 	 String		a string constant: "this is a string"
> 	 Character	a character constant: 'c', '\n'
> 	 Number		a number constant: 234, 0xff
> 	 Boolean	a boolean constant: TRUE, false
> 	 Float		a floating point constant: 2.3e10
> 
> 	*Identifier	any variable name
> 	 Function	function name (also: methods for classes)
> 
> 	*Statement	any statement
> 	 Conditional	if, then, else, endif, switch, etc.
> 	 Repeat		for, do, while, etc.
> 	 Label		case, default, etc.
> 	 Operator	"sizeof", "+", "*", etc.
> 	 Keyword	any other keyword
> 	 Exception	try, catch, throw
> 
> 	*PreProc	generic Preprocessor
> 	 Include	preprocessor #include
> 	 Define		preprocessor #define
> 	 Macro		same as Define
> 	 PreCondit	preprocessor #if, #else, #endif, etc.
> 
> 	*Type		int, long, char, etc.
> 	 StorageClass	static, register, volatile, etc.
> 	 Structure	struct, union, enum, etc.
> 	 Typedef	A typedef
> 
> 	*Special	any special symbol
> 	 SpecialChar	special character in a constant
> 	 Tag		you can use CTRL-] on this
> 	 Delimiter	character that needs attention
> 	 SpecialComment	special things inside a comment
> 	 Debug		debugging statements
> 
> 	*Underlined	text that stands out, HTML links
> 
> 	*Ignore		left blank, hidden  |hl-Ignore|
> 
> 	*Error		any erroneous construct
> 
> 	*Todo		anything that needs extra attention; mostly the
> 			keywords TODO FIXME and XXX
>``` 
>
> The names marked with * are the preferred groups; the others are minor groups.
> For the preferred groups, the "syntax.vim" file contains default highlighting.
> The minor groups are linked to the preferred groups, so they get the same
> highlighting.  You can override these defaults by using ":highlight" commands
> after sourcing the "syntax.vim" file.

The syntax highlighting files for almost all languages define other highlight
groups most of which get mapped to these basic groups. To define a new
colorscheme, we need to define color mappings for each of these groups. 

The basic syntax for defining a new color scheme is:

```
\startcolorscheme[name-of-scheme]
...
\stopcolorscheme
```

where the `name-of-scheme` is whatever name you want to call your colorscheme.
This name has to be used as the value for `alternative` key in
`\definevimtyping` or `setupvimtyping`. 

The bare-minimum setup needed to define a new colorscheme is as follows:

```
\startcolorscheme[name-of-scheme]
    % Vim Preferred groups
    \definesyntaxgroup
        [Constant]
        [...]

    \definesyntaxgroup
        [Identifier]
        [...]

    \definesyntaxgroup
        [Statement]
        [...]

    \definesyntaxgroup
        [PreProc]
        [...]

    \definesyntaxgroup
        [Type]
        [...]

    \definesyntaxgroup
        [Special]
        [...]

    \definesyntaxgroup
        [Comment]
        [...]

    \definesyntaxgroup
         [Ignore]
         [...]

    \definesyntaxgroup
        [Todo]
        [...]


    \definesyntaxgroup
        [Error]
        [...]

    \definesyntaxgroup
        [Underlined]
        [...]

    \definesyntaxgroup
        [Todo]
        [...]

    \setups{vim-minor-groups}

\stopcolorscheme
```

The detailed syntax of `\definesyntaxgroup` will be explained in a bit. 
The `\setups{vim-minor-groups}` line at the end maps the minor color groups to
the preferred color groups, as per the default mappings in vim. Suppose you
want to override the default mappings for `Number` and `Function`, then you
define those mappings after `\setups{vim-minor-groups}`.

```
\startcolorscheme[name-of-scheme]
    % Vim Preferred groups
    \definesyntaxgroup
        [Constant]
        [...]

    ....

    \setups{vim-minor-groups}

    \definesyntaxgroup
        [Number]
        [...]

    \definesyntaxgroup
        [Function]
        [...]

\stopcolorscheme
```

A full setup for defining a new color scheme will be add `\definesyntaxgroup`
for all the basic vim syntax highlighting groups listed from the vim help
above. If you define the mappings for *all* groups, then you can omit the
`\setups{vim-minor-groups}` line above. 

The `\definesyntaxgroup` command has the following syntax:

```
\definesyntaxgroup
    [name-of-group]
    [
      color=...,
      style=...,
      command=...,
    ]
```
where `color` is the name of any predefined color in ConTeXt, `style` can be
any predefined [style alternative][style] (such as `bold`, `italic`, etc.) or
an explicit style formatting command (such as `\bf`, `\it`, etc.), and
`command` can be any ConTeXt macro which takes one argument. 

[style]: https://wiki.contextgarden.net/Style_Alternatives

For example, if you want to highlight `Todo` with a frame, use can use:

```
\definesyntaxgroup
    [Todo]
    [command=\inframed]
```

_A convinience interface for `color`:_ A colorscheme uses a lot of colors and
defining all of them just for the purpose of defining a new colorscheme can be
cumbersome. So, the `\definesyntaxgroup` macro provides a shorthand:

```
\definesyntaxgroup
    [...]
    [
      color={r=..., g=..., b=...},
    ]
```

where `r`, `g`, `b`, values are the red, green, and blue values (between 0 and
1) of the color, or

```
\definesyntaxgroup
    [...]
    [
      color={h=...},
    ]
```

where the `h` value is the hex value of the color.

Modifying an existing color scheme
----------------------------------

It is possible to modify an existing color scheme by simply redefining
some of the syntax highlighting groups. For example, if we want to update
`pscolor` so that `Identifier` group is typeset in red color and `Function` is
typeset in bold red, we can use:

```
\startcolorscheme[pscolor]
  \definesyntaxgroup
      [Identifier]
      [color=red]

  \definesyntaxgroup
      [Function]
      [color=red, style=bold]
\stopcolorscheme
```
XML Export
----------

The vim module provides a basic support for XML export. If the user-document
contains

    \setupbackend[export=yes]

or other valid options to `export` such as `export=xml`, then the vim typing
environments are exported as well. For example, 

    \definevimtyping[PYTHON][syntax=python]
    \startPYTHON
    # Python program listing
    def foobar
        print("Hello World")
    \stopPYTHON


is exported as

    <vimtyping detail="pscolor">
     <verbatimline><syntaxgroup detail="vimComment"># Python program listing</syntaxgroup></verbatimline>
     <verbatimline><syntaxgroup detail="vimStatement">def</syntaxgroup> <syntaxgroup detail="vimFunction">foobar</syntaxgroup></verbatimline>
     <verbatimline>    <syntaxgroup detail="vimFunction">print</syntaxgroup>(<syntaxgroup detail="vimString">"</syntaxgroup><syntaxgroup detail="vimString">Hello World</syntaxgroup><syntaxgroup detail="vimString">"</syntaxgroup>)</verbatimline>
    </vimtyping>

The name of the exported envionment is `vimtyping`. 

Inline environments such as

    \definevimtyping[PYTHON][syntax=python]
    \inlinePYTHON{print("Hello World")}
    
is exported as

    <inlinevimtyping detail="pscolor"><verbatimline><syntaxgroup detail="vimFunction">print</syntaxgroup>(<syntaxgroup detail="vimString">"</syntaxgroup><syntaxgroup detail="vimString">Hello World</syntaxgroup><syntaxgroup detail="vimString">"</syntaxgroup>)</verbatimline></inlinevimtyping>

The name of the exported envionment is `inlinevimtyping`. 

In both the display and inline environments, the name of the programming
language (value of the `syntax` key) is
not exported since it is not needed to display the parse output.
Instead the name of the colorscheme (value of the `alternative` key) is
exported as the parameter `detail` of `vimtyping`. Each line is exported as a
`verbatimline`. Each syntaxgroup is exported as `<syntaxgroup detail="...">`.
The value of `defail` equals to the name of the syntax highlighting group
_prepended with `vim`_. The name is prepended with `vim` to avoid name clashes
with other elements in the exported XML. Strictly speaking this is not
necessary, but it does make it easier to write CSS selectors.

The module comes with a CSS file with default mappings for the two
colorschemes that are provided with the module (`pscolor` and
`blackandwhite`). This is meant as a simple solution which gives approximately
the same output as the PDF file. To use this CSS file, add

    \setupexport[cssfile=\vimtypingcssfile]

If you already have other values for `cssfile`, then use:

    \setupexport[cssfile={...,...,\vimtypingcssfile}]

Note that the macro `\vimtypingcssfile` is defined in the vim module, so the
above line has to come after the `vim` module has been loaded.

If you make changes to the default colorschemes, define colorschemes of your
own, or want to tweak the visual appearance of the output, you need to tweak
the default CSS file to suit your needs. It is suggested that you copy the
default css file and tweak it. You can find the location of the default CSS
file using

    luatools vimtyping-default.css

Copy it under a different name and tweak it as desired.


A bit of a history
------------------

Mojca Miklavec germinated the idea of using vim to get syntax highlighting.
Below is her message to the ConTeXt mailing list (circa Sep 2005):

> I am thinking of piping the code to vim, letting vim process it, and return
> something like `highlight[Conditional]{if} \highlight[Delimiter]{(}
> \highlight[Identifier]{!}`.
>
> One could modify the `2html.vim` file. Vim can already transform the highlighted
> code to HTML, so ConTeXt should not be so difficult. Vim already has over 400
> syntax file definitions, probably equivalent to some hundred thousand lines of
> syntax definition in ConTexT. Well, I don't know (yet) how to do it, but if
> someone on the last has more experience with vim, please feel free to
> contribute. 

A few months later (circa Dec 2005), Nikolai Webull provided such a modification
of `2html.vim` and called it `2context.vim`. That file was the foundation of
`t-vim` module. 

About two years later (circa June 2008), Mojca and I (Aditya Mahajan) pickup up
on this idea and released `t-vim`. Over the next few years, nothing much changed
in the module, except a few minor bug fixes. 

Around June 2010, I decided to completely rewrite the module from scratch. The
new version of `t-vim` relies on `t-filter` for all the bookkeeping. As a
result, the module is smaller and more robust.

