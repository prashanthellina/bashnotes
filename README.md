# Installation

* Install Vimwiki
* Create the notes directories
    * cd $HOME
    * mkdir -p Notes/{diary}
* Copy `bash_notes.sh` to `$HOME/.bash_notes.sh`
* Add `source ~/.bash_notes.sh` to your .bashrc/.profile

* .vimrc configuration for Vimwiki
```vim
" Vimwiki configuration
set nocompatible
let g:vimwiki_list = [{'path': '~/Notes', 'path_html': '~/Notes/html/', 'ext': '.md', 'syntax': 'markdown', 'folding': 0}]
```
* Install the deskbar plugin for searching notes in GNOME
    * copy `deskbar_notes_search.py` to `/usr/lib/deskbar-applet/modules-2.20-compatible/` 
    * reload deskbar and enable "Notes Search" plugin
