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

# Ensure presence of directories
mkdir -p "$NOTES_DIR"
mkdir -p "$DIARY_DIR"

# Make sure notedown commands are not stored in
# bash history. For zsh, prefix space to the command
# to prevent it from being added to history
HISTIGNORE="$HISTIGNORE:note *:"

_get_today_fname()
{
    dt=`date +%F`
    fname="$dt.md"
    echo "$fname"
}

_init_today_file()
{
    dt=`date +%F`
    fname="$DIARY_DIR/$1"
    longdt=`date +"%A, %e %B %Y"`

    if [ ! -e "$fname" ]; then
        echo "# $longdt" >> $fname
    fi
}

# today
# Opens a note from the diary corresponding to today
today() {
    fname="$(_get_today_fname)"
    _init_today_file "$fname"
    vim -c start "$fname"
}

notes() {
    vim "$NOTES_DIR"
}

diary() {
    vim "$DIARY_DIR"
}

# note [<note text>]
# Store the "note text" in today's journal entry note.
# If "note text" is not provided then behave the same
# as "today" command.
note() {

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

    echo "=> Note name matches"
    tree $NOTES_DIR | ag -i --color "$1"
    echo
    echo "=> Note content matches"
    ag -i -C2 --color --group "$1" $NOTES_DIR
}
