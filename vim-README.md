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

How it all works
----------------

Changing the color scheme
-------------------------

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
