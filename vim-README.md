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

    kpsewhich t-vim.tex

returns a meaningful path. If not, you have to manually install the module.
Download the latest version of the `filter` and `vim` modules from
[http://github.com/adityam/filter/downloads](http://github.com/adityam/filter/downloads)
and unzip them either `$TEXMFHOME` or `$TEXMFLOCAL`. Run

    mktexlsr

and

    mtxrun --generate

to refresh the TeX file database (for MkII and MkIV, respectively). If
everything went well

    kpsewhich t-vim

will return the path where you stored the file.

Unfortunately, that is not enough. For the module to work, TeX must be able to
call an external program. This feature is a potential security risk and is
disabled by default on most TeX distributions. To enable this feature, you must
set

    shell_escape=t

in your `texmf.cnf` file. See this page
[http://wiki.contextgarden.net/write18](http://wiki.contextgarden.net/write18)
on the ConTeXt wiki for detailed instructions.


Usage
-----

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

    The contents of this environment are processed by a vim script
    (`2context.vim`) and the result is read back in ConTeXt.

3. A macro

        \typeRUBYfile{...}

    The argument of this macro must a file name or a url (urls work in MkIV
    only). That file is processed by `2context.vim` and the result is read back
    in ConTeXt. For controling how frequently a remote file is downloaded when
    processing a url, see the _Processing remote files_ section of the
    `t-filter` manual.

In all the three cases, the `t-filter` module takes care of writing to external
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

The default color scheme is `pscolor`.

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

**Note**: These options can only be set using `\definevimtyping[...][...]` or
`\setupvimtyping[...][...]`. They do not work when used with
`\start<vimtyping>`.

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

Although, the source code is easy to read, the output will not be. This is
because, unlike regular TeX,  `\start<vimtyping>` ... `\stop<vimtyping>`
environment does not ignore white space. So, the output is the same as 

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

So, all the code snippets are indented by nine space. To avoid this behavior,
set

    \definevimtyping
        [...]
        [...
         strip=yes,
         ...]

The default value of `strip` is `no`.

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

Sometimes one wants to use TeX code in comments, especially for math. To
enable this use

    \definevimtyping
        [...]
        [...
         escape=on,
        ]
      
When `escape=on`, the `2context.vim` script passes the `Comment` syntax
region (as identified by `vim`) verbatim to TeX. So, we may use TeX
commands inside the comment region and they will be interpreted by TeX.
For example

    \definevimtyping[C][syntax=c, escape=on]

    \startC
    /* The following function computers the roots of \m{ax^2+bx+c=0}
     * using the determinant \m{\Delta=\frac{-b\pm\sqrt{b^2-2ac}}{2a}} 
     */
        double root (double a, double b, double c) {....}
    \stopC

**Note** that only `\ { }` have their usual meaning inside the `Comment`
region when `escape=on` is set. Thus, to enter a math expression, use
`\m{...}` instead of `$...$`. Moreover, spaces are active inside the
math mode, so, as in the above example, avoid spaces in the math expressions.

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
         vimrc=none,
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
`option=on`. One less thing to worry about!

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

