The vim module
==============

This module highlights code snippets using vim as a syntax
highlighter. Such a task may appear pointless at first glance. After all,
ConTeXt provides excellent syntax highlighting features for TeX, Metapost, XML,
and a few other langauges. And in MkIV, you can specify the grammer to parse a
language, and get syntax highlighting for a new language. But writing such
grammers is difficult. More importantly, why reinvent the wheel? Most
editors, and many other syntax highlighting programs, already syntax highlight
many programming languages. Why not just leverage these external programs to
generate syntax highlighting? This module does exactly that.

Installation
------------

TODO:

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

    The argument of this macro must a file name. That file is processed by
    `2context.vim` and the result is read back in ConTeXt.

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
temporary files. To avoid this clutter, write the temporary files to an a
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

To eanble line numbering for a particular snippet, use:

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

TODO:   

- Document linenumbering options
- continue line numbering from previous environment


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

TODO
----

- active space
