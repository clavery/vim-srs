# vim-srs

A Spaced repetition software system (SRS) implemented as a vim plugin using plain text (i.e. markdown) files.

vim-srs is a "spaced repetition software" implementation for the vim editor.
The plugin operates on configured conventions to load "facts" into the editor
from plain text files (and folders of files). Facts are loaded based on the 
SuperMemo 2 algorithm (https://www.supermemo.com/english/algsm11.htm). The
plugin makes use of vim folds to obsurce answers (if present). After viewing
a fact and it's answer(s) the user is asked to rate their knowledge of the
answer. This is used to drive the SRS algorithm and determine the next time this
fact should be reviewed.

Fact data is stored in a sqlite3 file in the same directory as the fact file(s).

See the vim doc for more information.

## Background

Because I take notes in markdown format stored as plain text files
on a filesystem I wanted this plugin to read those files directly with a minimum
of metadata. For this reason the default configuration for this plugin assumes
markdown files with facts loaded using standard markdown syntax (i.e. headers
for facts and code blocks for answers). However it can be configured to load any
file type.

By utilizing my note files directly and by keeping the syntax as simple as
possible I aimed to reduce the barrier to using an SRS system.
