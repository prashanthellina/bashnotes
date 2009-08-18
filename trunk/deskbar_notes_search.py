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

'''
To be used in conjunction with "Notes" setup using Vimwiki and custom .bash_config.
Enables search capability in Gnome GUI using Deskbar applet. This is a Deskbar
plugin. To enable this drag-n-drop onto deskbar preferences window.
'''

import os
import os.path
import glob
import re

import deskbar.interfaces.Action
import deskbar.interfaces.Match
import deskbar.core.Utils
import deskbar.interfaces.Module
from deskbar.handlers.actions.CopyToClipboardAction import CopyToClipboardAction

MAX_MATCHES = 10
HANDLERS = ["Module"]
HOME_DIR = os.environ.get('HOME')
NOTES_DIR = os.path.join(HOME_DIR, 'Notes')

class SearchResult:
    def __init__(self, book, note, context, title_match=False):
        self.book = book
        self.note = note
        self.context = context
        self.title_match = title_match

def remove_extra_whitespace(text):
    return re.sub('\s+', ' ', text)

class NotesSearch:
    def __init__(self, notes_dir):
        self.notes_dir = notes_dir
        self.books = []

        self._find_books()

    def _find_books(self):
        self.books = [os.path.basename(f) \
                        for f in glob.glob(self.notes_dir + '/*') \
                        if os.path.isdir(f)]

    def search(self, text, only_title=False):
        results = []

        for book in self.books:
            bdir = os.path.join(self.notes_dir, book)
            fpattern = bdir + '/*'
            fnames = glob.glob(fpattern)

            for fname in fnames:
                note_name = os.path.basename(fname).rsplit('.', 1)[0]
                search_term = '.{0,30}%s.{0,30}(?is)' % text

                if re.findall(search_term, note_name):
                    s = SearchResult(book, note_name, '', True)
                    results.append(s)
                    continue

                if only_title:
                    continue

                data = open(fname).read()
                matches = re.findall(search_term, data)

                if not matches:
                    continue

                matches = [remove_extra_whitespace(m) for m in matches]
                matches = ['... %s ...' % m for m in matches][:MAX_MATCHES]
                context = '\n'.join(matches)
                context = context.replace('%', '%%')
                s = SearchResult(book, note_name, context, False)
                results.append(s)

        return results

NOTES_SEARCH = NotesSearch(NOTES_DIR)

class Action(deskbar.interfaces.Action):
    
    def __init__(self, result):
        deskbar.interfaces.Action.__init__(self, result.note)
        self._result = result

    def activate(self, text=None):
        book = self._result.book
        note = self._result.note

        note_path = os.path.join(NOTES_DIR, book, note) + '.note'
        deskbar.core.Utils.spawn_async( ['/usr/bin/env', 'gvim', note_path] )
        
    def get_verb(self):
        verb = "Open note <b>%s</b>(<i>%s</i>)" % (self._result.note, self._result.book)
        if self._result.context:
            context = '\n<span size="smaller"><i>%s</i></span>' % self._result.context
        else:
            context = ''
        verb = verb + context
        return verb
        
    def get_icon(self):
        return "gtk-execute"

    def get_tooltip(self, text=None):
        return self._result.context
        
    def is_valid(self, text=None):
        return True
        
class Match (deskbar.interfaces.Match):
    
    def __init__(self, result, **kwargs):

        deskbar.interfaces.Match.__init__(self,
            name=result.note,
            icon="gtk-execute", category="notes", **kwargs)

        self.result = result
        self.add_action( Action(self.result) )
        
    def get_hash(self):
        r = self.result
        return (r.book, r.note)
        
class Module (deskbar.interfaces.Module):

    INFOS = {'icon': deskbar.core.Utils.load_icon("gtk-execute"),
        'name': 'Notes search',
        'description': 'Search my notes',
        'version': '0.1',
        }
    
    def __init__(self):
        deskbar.interfaces.Module.__init__(self)
        
    def query(self, text):

        if text.startswith('full:'):
            only_title = False
            stext = text.split('full:', 1)[-1].strip()
        else:
            only_title = True
            stext = text

        results = NOTES_SEARCH.search(stext, only_title)

        matches = []
        matches = [Match(r) for r in results]
        self.set_priority_for_matches(matches)

        self._emit_query_ready( text, matches )
