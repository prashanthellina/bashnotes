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
JOURNAL="$NOTES/diary"
MODE="read"
VIM="vim"

# note [<note-name>]
# eg: note Todo
#     note
note()
{
    # open today note from journal
    # if no options provided
    if [ $# -eq 0 ]; then
        today
        return 0
    fi

    NOTE="$NOTES/$1.md"

    # does note already exist?
    exists=1
    if [ ! -e "$NOTE" ]; then
        exists=0
    fi

    # open the note
    if [ $exists -eq 0 ]; then
        $VIM -c start -c "VimwikiIndex" -c "VimwikiGoto $1"
    else
        $VIM -c "VimwikiIndex" -c "VimwikiGoto $1"
    fi
}

_get_today_fname()
{
    dt=`date +%F`
    fname="diary/$dt.md"
    echo "$fname"
}

_init_today_file()
{
    dt=`date +%F`
    fname="$NOTES/$1"
    longdt=`date +"%A, %e %B %Y"`

    if [ ! -e "$fname" ]; then
        echo "# $longdt" >> $fname
    fi
}

# today
# Opens a note from the journal corresponding to today
today() {
    _init_today_file "$(_get_today_fname)"
    vim -c start -c VimwikiMakeDiaryNote
}

# notes
# Opens the wiki index
notes() {
    # Specifying VimwikiIndex command twice as a hack
    # to overcome issue in OSX
    vim -c VimwikiIndex -c VimwikiIndex
}

# journal
# Opens the journal index
journal() {
    vim -c VimwikiDiaryIndex
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
    echo "**[$cur_time]**" >> "$fname"

    if [ $# -eq 0 ]; then
        MODE="insert"
        today
        MODE="read"
        return 0
    else
        echo "$*" >> "$fname"
    fi

}

# findnote [<term>]
# Search notes in wiki for the term specified.
findnote() {
    if [ $# -ne 1 ]; then
        printf "Usage: note <term>\n"
        return 0
    fi

    grep -R -i -C1 --color=always $1 $NOTES | sed "s:$NOTES/::" | sed "s:\.md::"
}

alias findnote='findnote'

_notes() {
    local cur names IFS

    cur="${COMP_WORDS[COMP_CWORD]}"

    if [ $COMP_CWORD -eq 1 ]; then
        names=`cd $NOTES && tree -f -P "*.md" | grep "md$" | grep -o "\..*.md" | cut -b3- | sed 's/.md$//g' && cd - &> /dev/null`
    fi

    IFS=$'\t\n'
    COMPREPLY=( $(compgen -W "${names}" -- ${cur}) )
    return 0
}
complete -o nospace -F _notes note
complete -o nospace -F _notes findnote
