% Beg, Borrow, and Steal <br /> Running external filters in ConTeXt
% Aditya Mahajan (presented by Luigi Scarso)

## Acknowledgments

- Luigi, for giving this talk
- Jano, for being extremely patient with my fickle schedule
- Wolfgang, for teaching me a few tricks and cleaning up the module

## Apologies

- To everyone for missing the meeting
- ... and not using TeX for presentation!

# History

I wanted to use Markdown content

    \startmarkdown
    ...
    \stopmarkdown

- Write a markdown parser in TeX or LPEG
- Or use `pandoc`, an existing markdown to ConTeXt converter

# How do I run an external program?

- The R-module (`m-r.tex`) does that for R.
- **First draft:** copied the R-module and replaced the call to R with call to
  pandoc
- Code reuse? What if I wanted reStructured Text rather than markdown?
- Gave rise to a general module to run external programs.

# Installation

- Hosted at http://www.github.com/adityam/filter.
- Will be uploaded to garden (or Taco's subversion repo for modules)
- **For TeX Live users:** `write18` (or shell escape) must be enabled. See wiki
  for details.

# Examples: Markdown

- Usage:

        \usemodule[filter]

        \defineexternalfilter
            [markdown]
            [filtercommand={pandoc -t context -o \externalfilteroutputfile\space
                            \externalfilterinputfile}]

- **`\externalfilterinputfile`:** Temporary file where the contents of
  environment are stored.
- **`\externalfilteroutputfile`:** File where the output of the filter is
  stored.
- In **`filtercommand`** notice the `\space`...TeX gobbles spaces after macros
- Simple, isn't it?

# Existing markdown file?

- `\processmarkdownfile[...]`
- **Warning:** Creates a new file with `.tex` extension and can overwrite
  existing file. Safest way is to store all markdown files in a separate
  directory.


# Example: texttile

- `pandoc` does not support textile.
- Plenty of textile to html converters. Either write a xml parser for html or
  use `pandoc` to convert the html to ConTeXt. 

        \defineexternalfilter
          [textile]
          [filtercommand={redcloth \externalfilterinputfile \letterbar
                          pandoc -r html -w context -o \externalfilteroutputfile}]

- **Note:** the `\letterbar`; In MkII `|` does not work.


# Example: R-module

- R-module defines two environment `\startR` ... `\stopR` and `\startRhidden`
  ... `\stopRhidden`. 

        \defineexternalfilter
          [R]
          [filtercommand={R CMD BATCH -q \externalfilterinputfile\space 
                          \externalfilteroutputfile},
           output=\externalfilterbasefile.out,
           readcommand=\typefile,
           continue=yes]

- **`\externalfilterbasefile`:** basename of `\externalfilterinputfile` 
- **`output=name`:** Sets the name of `\externalfilteroutputfile`
- **`readcommand=command`:** What to do with `\externalfilteroutputfile` (default:
  `\ReadFile`)

# Example: R-module (continued)

- **`continue=yes`:** Writes the content of each environment to a separate file, and
  runs R only if the file content has changed. Extremely useful if the filter is
  slow. (Default: `continue=no`)

- What about `\startRhidden` ... `\stopRhidden`

- Option 1:

        \defineexternalfilter
          [...]
          [....
           read=no,
           ...]

# Example: R-module (continued)

- Option 2: 

        \startR[read=no]
          ...
        \stopR

- **Warning:** Options must be on the same line as `\start<filter>`

- **Cool Trick:** If you want to restrict the `[...]` argument of a macro to the
  same line.

        \def\startR
            {\bgroup\obeylines\dosingleargument\dostartR}

        \def\dostartR[#1]
            {\egroup
             .... }


# Example: Word clouds

- IBM's wordcloud engine: http://www.alphaworks.ibm.com/tech/wordcloud/

- Usage: 


        \defineexternalfilter
          [wordcloud]
          [filtercommand=/opt/java/jre/bin/java -jar $HOME/bin/ibm-word-cloud.jar 
            -c $HOME/.config/IBM-Word-Cloud/configuration.txt 
            -w \externalfilterparameter{width}
            -h \externalfilterparameter{height}
            -o \externalfilteroutputfile\space
            -i \externalfilterinputfile,
          output=\externalfilterbasefile.png,
          height=600,
          width=800,
          readcommand=\ExternalFigure,
          continue=yes,
          ]


# Some salient features

- `readcommand` must take a brace delimited argument

        \defineexternalfilter
            [...]
            [...
             readcommand=\ExternalFigure,
             ...]


        \def\ExternalFigure#1{\externalfigure[#1]}

# Some salient features

- You can pass arguments to the filter

        \defineexternalfilter
            [...]
            [filtercommand={ .... 
                            -w \externalfilterparameter{width}
                            -h \externalfilterparameter{height}
                            .... },
             height=600,
             width=800,
             ....
            ]

- You can use any key inside `\defineexternalfilter` and then access it using

        \externalfilterparameter{...}



# Standard options

- `before={...}`, `after={...}`, and `setup={...}`

        \def\dodoreadprocessedfile
          {\bgroup
           \externalfilterparameter\c!before
           \processcommacommand[\externalfilterparameter\c!setups]\directsetup
           \externalfilterparameter\c!readcommand\externalfilteroutputfile
           \externalfilterparameter\c!after
           \egroup}

- Keys that I am considering (not yet added)

    > `style`, `color`, `indenting`, `indentnext`

- Not sure if these keys are needed. Feedback appreciated.

# Setup for all filters

- `\setupexternalfilters`

- Current defaults:

        \setupexternalfilters
          [before=,
           after=,
           setups=,
           continue=no,
           read=yes,
           readcommand=\ReadFile,
           output=\externalfilterbasefile.tex,
          ]


# Future plans

- Use this module as a basis for an external syntax highlighting module (`t-vim`
  on steroids)

    - Proof of concept implementation at http://www.github.com/adityam/filter
    - Want to make it configurable, so that one can use any external syntax
      highlighter (pgyments, source-highlight, hsColour, etc.)

- Allow running content through a web service. Works for HTTP GET services; am
  working on allowing HTTP POST services. 

    - MkIV only. No plans to make it work in MkII.
    - Not sure if it should be in the same module or a different module

- Allow lua pre and post filters.

