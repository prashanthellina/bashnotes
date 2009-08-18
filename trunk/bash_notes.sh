# Copyright (c) 2009, Prashanth Ellina
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY Prashanth Ellina ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Prashanth Ellina BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###############################################################################

# Make sure notedown commands are not stored in
# bash history
HISTIGNORE="$HISTIGNORE:notedown *:"

NOTES="$HOME/Notes"
JOURNAL="$NOTES/personal"
JOURNAL_WIKI="personal"
MODE="read"
VIM="vim"

# note [<wiki>] [<note-name>]
# eg: note personal Todo
#     note personal
#     note work Testing
#     note
note()
{
    # open today note from journal
    # if no options provided
    if [ $# -eq 0 ]; then
        today
        return 0
    fi

    # if only wiki is specified
    # and not the note name, then
    # open the index page of that wiki
    if [ $# -eq 1 ]; then
        $VIM "$NOTES/$1/index.note"
        return 0
    fi

    NOTE="$NOTES/$1/$2.note"

    # does note already exist?
    exists=1
    if [ ! -e "$NOTE" ]; then
        exists=0
    fi

    # In "insert" mode, the vim
    # editor open with cursor
    # at the last line and ready
    # for editing. In "read" mode,
    # cursor is at the start of the
    # document.
    vim_options=""
    if [ "$MODE" == "insert" ]; then
        vim_options="+ -c start"
        echo "" >> "$NOTE"
    fi

    # open the note
    $VIM $vim_options "$NOTE"

    # If the note which was just edited
    # now is a new one, add a link to the
    # index page of this wiki
    if [ $exists -eq 0 ]; then
        if [ -f "$NOTE" ]; then
            echo "    * $2" >> "$NOTES/$1/index.note"
        fi
    fi
}

_get_today_fname()
{
    dt=`date +%F`
    fname="$JOURNAL/$dt.note"
    echo "$fname"
}

_init_today_file()
{
    dt=`date +%F`
    fname="$1"
    longdt=`date +"%A, %e %B %Y"`

    if [ ! -e "$fname" ]; then
        echo "= $longdt =" >> $fname
        echo "    * [[$dt]]" >> "$JOURNAL/Journal.note"
    fi
}

# today
# Opens a note from the journal corresponding to today
today() {
    _init_today_file "$(_get_today_fname)"
    MODE="insert"
    note $JOURNAL_WIKI `date +%F`
    MODE="read"
}

# notedown [<note text>]
# Store the "note text" in today's journal entry note.
# If "note text" is not provided then behave the same
# as "today" command.
notedown() {
  
    fname="$(_get_today_fname)"

    if [ ! -e "$fname" ]; then
        _init_today_file "$fname"
    fi

    cur_time=`date +"%I:%M:%S %p"`

    # enter timestamp in the note
    echo >> "$fname"
    echo "[$cur_time]" >> "$fname"

    if [ $# -eq 0 ]; then
        MODE="insert"
        today
        MODE="read"
        return 0
    else
        echo "$*" >> "$fname"
    fi

}

# findnote <wiki> [<term>]
# Search notes in wiki for the term specified.
findnote() {
    if [ $# -ne 2 ]; then
        printf "Usage: note <wiki> <term>\n"
        return 0
    fi

    NOTE_DIR="$HOME/Notes/$1"

    grep -R -i -C1 --color=always $2 $NOTE_DIR | sed "s:$NOTE_DIR/::" | sed "s:\.note::"
}

alias note:='note'
alias notes='$VIM $NOTES/'
alias findnote='findnote'

_notes() {
    local cur names IFS

    cur="${COMP_WORDS[COMP_CWORD]}"

    if [ $COMP_CWORD -eq 1 ]; then
        names=`ls $HOME/Notes`
    else
        directory="${COMP_WORDS[1]}"
        names=`ls $HOME/Notes/$directory | sed 's/.note$//g'`
    fi
    
    IFS=$'\t\n'
    COMPREPLY=( $(compgen -W "${names}" -- ${cur}) )
    return 0
}
complete -o nospace -F _notes note
complete -o nospace -F _notes note:
complete -o nospace -F _notes findnote
