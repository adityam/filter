The vim module
==============

ConTeXt has excellent code highlighting capabilities for some languages: TeX,
metapost, XML, amongst others. In MkII, syntax highlighting was done by parsing
the source code in TeX---a task not for the faint of heart. In MkIV, the
situation is much better: syntax highlighting is done by parsing the source code
in Lua using LPEG. Nonetheless, writing a grammar to parse the source code of
languages is a tricky task. This module takes the onus of defining such a
grammar away from the user and uses Vim editor to create syntax highlighting. A
helper script, `2context.vim` does the actual work.

The idea of the module was germinated  by Mojca Miklavec. She said (crica Sep
2005):

> I am thinking of piping the code to vim, letting vim process it, and return
> something like `highlight[Conditional]{if} \highlight[Delimiter]{(}
> \highlight[Identifier]{!}`.


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

Around June 2010, I decided to completely rewrite the module from scratch. It
now uses the `t-filter` module behind the scenes for all the book-keeping of
creating and maintaining external files.

Installation
------------

You also need to install `t-filter` module.

Basic Usage
-----------

The main macro of this module is `\definevimtyping`. Suppose you want to do
syntax highlighting of ruby code in ConTeXt. For that you may use:

    \definevimtyping [RUBY]  [syntax=ruby]

This defines an environment

    \startRUBY
      ...
    \stopRUBY

The contents of this environment are written to an external file, which is then
parsed using vim, and the output is read back by ConTeXt.
