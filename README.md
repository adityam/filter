The filter module
=================

History
-------

This module started with a simple idea. I wanted an environment
    
    \startmarkdown
    ...
    \stopmarkdown

to write content in Markdown. Such an environment requires a parser that
converts markdown to TeX. A TeX wizard would write such a parser in TeX (which
after all is Turing complete). A lua wizard would write it in LPEG (and wonder
why some users still use MkII). I, being no wizard myself, found an existing
tool that does the job---pandoc. But how could I use pandoc inside ConTeXt?

As for almost everything else in ConTeXt, Hans had already done this; albeit for
a different tool---the R programming language.  The _R
module_ (`m-r.tex`) allows the user to execute snippets of R code. I wanted the
same for Markdown.

I copied the R-module, made a couple of changes, and had a Markdown module
ready. But what if tomorrow I wanted to use ReStructured Text instead of
Markdown? Or Matlab code instead R? Surely, copying the R-module for each
program would be a waste of effort. Each new program requires only a few changes
in the R-module; what I needed was a R-module _template_ so that I could fill in
the blanks with the appropriate values. And so, the filter module was born.

Installation
------------

Writing installation instructions is always boring. Hopefully, by the time this
article is published, the filter module will be available from ConTeXt garden.
If so, and if you are using ConTeXt minimals, you already have the module. To
verify, check if

    kpsewhich t-filter.tex

returns a meaningful path. If not, you have to manually install the module.

Create a directory `tex/context/third/filter` in your `$TEXMFHOME` or
`$TEXMFLOCAL` directory. Copy `t-filter.tex` and `t-filter.lua` from 
this git repository
[http://github.com/adityam/filter](http://github.com/adityam/filter) to the
directory that you just created. Run

    mktexlsr

and

    mtxrun --generate

to refresh the TeX file database (for MkII and MkIV, respectively). If
everything went well

    kpsewhich t-filter

will return the path where you stored the file.

Unfortunately, that is not enough. For the module to work, TeX must be able to
call an external program. This feature is a potential security risk and is
disabled by default on most TeX distributions. To enable this feature, you must
set

    shell_escape=t

in your `texmf.cnf` file. See this page
[http://wiki.contextgarden.net/write18](http://wiki.contextgarden.net/write18)
on the ConTeXt wiki for detailed instructions.

Basic Usage
-----------

The steps involved in calling a filter on the contents of an evironment are:

1. Write the contents to an external file. This file is the input to the filter,
   and is, therefore, called `\externalfilterinputfile`

2. Run the filter on `\externalfilterinputfile` to generate an output, which is
   called `\externalfilteroutputfile`.

3. (Optional) Read `\externalfilteroutputfile` in ConTeXt.

Lets start from the simplest case: a filter that inputs a text file and outputs
a valid ConTeXt file, like `pandoc` to convert from Markdown to ConTeXt. The
command line syntax of this filter is

    pandoc -t context -o outputfile inputfile

Using this filter from within ConTeXt is pretty simple:

    \usemodule[filter]

    \defineexternalfilter
        [markdown]
        [filtercommand={pandoc -t context -o \externalfilteroutputfile\space \externafilterinputfile}]

Yes, its that easy! The only thing to note is that TeX macros gobble spaces, so
we have to manually insert a space after `\externalfilteroutputfile`.

This defines an environment

    \startmarkdown
      ...
    \stopmarkdown

and a macro

    \processmarkdownfile[...]

The contents of the environment are processed by `pandoc` and the output is
included back in ConTeXt.

The argument to the macro is a filename, which is processed by `pandoc` and the
output is included back in ConTeXt.

Dealing with slow filters
-------------------------

The above definition of a markdown filter creates two additional files: an
\quotation{input} file and an \quotation{output} file, *irrespective of the
number of times the environment is called*. For each markdown environment,
ConTeXt overwrites the input file and pandoc overwrites the output file. This is
the default behavior as I do not want to clutter the current directory with
temporary files. The trade off is that for each document run, the filter is
invoked as many times as the number of markdown environments. Since getting
cross-referencing right normally takes two or three runs, effectively the filter
is run two or three times more than required. Usually, the filter is fairly
fast these extra runs are not noticeable. But some filters can be slow. For
example, just started and exiting the R program takes 0.3 seconds. In such
cases, the additional runs start adding up. A better trade off is to store the
contents of each environment in a separate file and invoke the filter only if
the file *changes in between successive runes*.

The second behavior is achieved by adding `continue=yes` option to the
definition:

    \defineexternalfilter
        [...]
        [filtercommand={...},
         continue=yes]



