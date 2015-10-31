vim-opengrok: opengrok interface for vim
========================================

Inspired by [youngker/eopengrok.el](https://github.com/youngker/eopengrok.el)

![vim-opengrok screenshot](https://raw.github.com/asenac/vim-opengrok/master/og-mode.gif)

Installation
------------

    Plugin 'asenac/vim-opengrok'
    
Requeriments
------------

- Java 1.7

- Exuberant ctags
  [http://ctags.sourceforge.net](http://ctags.sourceforge.net)

- Opengrok
  [https://github.com/OpenGrok/OpenGrok/releases](https://github.com/OpenGrok/OpenGrok/releases)

Configuration
-------------

Add the following lines to your vimrc using the appropriate routes:

    let g:opengrok_jar = '/path/to/opengrok/lib/opengrok.jar'
    let g:opengrok_ctags = '/path/to/ctags'

Commands
--------

    :OgIndex /path/to/index

Creates an index for the directory specified.

    :OgReIndex

Updates the index that contains the current directory.

    :OgSearch [f|d|r|p]

Searches in the index and displays the results in Vim's location list. A prompt
is displayed to introduce the text to search. Supported queries:

- d - Symbol Definitions
- r - Symbol References
- p - Path
- f - Full text


    :OgSearchCWord

Searches word under the cursor and displays the results in Vim's location list.

    :OgMode

Interactive queries displaying the results in a special buffer (see screenhost
above).

Limitations
-----------

Currently vim-opengrok displays only the first chunk of results returned by opengrok. 
