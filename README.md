vim-opengrok: opengrok interface for vim
========================================

Inspired by [youngker/eopengrok.el](https://github.com/youngker/eopengrok.el)

![vim-opengrok screenshot](https://raw.github.com/asenac/vim-opengrok/master/og-mode.gif)

Installation
------------

    Plugin 'asenac/vim-opengrok'

Configuration
-------------

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

     * d - Symbol Definitions
     * r - Symbol References
     * p - Path
     * f - Full text

    :OgSearchCWord

Searches word under the cursor and displays the results in Vim's location list.

    :OgMode

Interactive queries displaying the results in a special buffer (see screenhost
above).
