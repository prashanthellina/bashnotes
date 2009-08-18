= Installation =
    * Install Vimwiki
        * Download from http://code.google.com/p/vimwiki/
        * De-compress the archive and open the Vimwiki_setup:vba file in Vim.
        * Install by executing this command in Vim "so %"
    * Create the notes directories
        * cd $HOME
        * mkdir -p Notes/{personal,work}
    * Copy bash_notes.sh to $HOME/.bash_notes.sh
    * Add "source ~/.bash_notes.sh" to your .bashrc

    * .vimrc configuration for Vimwiki
    {{{
        " Vimwiki configuration
        set nocompatible
        hi wikiHeader1 guifg=#FF0000
        hi wikiHeader2 guifg=#00FF00
        hi wikiHeader3 guifg=#0000FF
        hi wikiHeader4 guifg=#FF00FF
        hi wikiHeader5 guifg=#00FFFF
        hi wikiHeader6 guifg=#FFFF00

        let g:vimwiki_list = [{'path': '~/Notes/personal', 'path_html': '~/Notes/personal/html/', 'ext': '.note', 'folding': 0}, {'path': '~/Notes/work', 'path_html': '~/Notes/work/html/', 'ext': '.note', 'folding': 0}]
    }}}
    * Install the deskbar plugin for searching notes in GNOME
        * copy deskbar_notes_search.py to /usr/lib/deskbar-applet/modules-2.20-compatible/ 
        * reload deskbar and enable "Notes Search" plugin
