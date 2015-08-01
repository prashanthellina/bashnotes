# Bash notes

Bash notes allows you to organize notes and a diary in a wiki-like fashion.
The goal is extreme simplicity and the feeling of "close-to-metal-ness".

## Why?

I tried various note taking mechanisms (Evernote, Tomboy, Google Docs) and
found that not one solved all of my needs.

A note taking application of my preference would have to support the following
aspects.

- Fast - Evernote/Google Docs were slow
- Synchronized - so I can access from different computers
- Interlinked - so I could have a wiki style system and navigate within
- Diary - Allow me to quickly jot down thoughts (twitter style short messages)
- Blog - maintain a blog with the same infrastructure

I work on the command-line often and love the power it provides me (as compared
to a GUI). After having used the command-line, I find any GUI equivalent clunky
and slow.

Taking all the above into consideration, I came up with Bash notes and it is
working very well.

## How does it work?

* Notes are markdown files edited using Vim
* All notes are placed in a directory
* You can maintain an arbitrary internal hierarchy
* You can reference one note from another using a Markdown style link
* A special Vim plugin lets you navigate using those links
* The diary is a sub-directory with one Markdown file per day
* Notes can be backed using Dropbox if you like
* You can also use [pullbox](http://github.com/prashanthellina/pullbox)
* `Pullbox` uses `git`. You get code-versioning and symlink support
* The bash notes shell commands add some niceties for easier interaction

## Setting up

### Pullbox

Follow [instructions here](http://github.com/prashanthellina/pullbox) to
set up a notes directory on your machine that can backup your machine to
a server. You can repeat this process on other computers that you use to
setup automatic synchronization across machine just like Dropbox.

### Vim

Recent versions of Vim have good built-in support for Markdown files including
Syntax highlighting and code folding. If you have an older version, you can get
the same level of support by installing
[vim-markdown](https://github.com/tpope/vim-markdown).


#### Following inter-note markdown links

Consider the note text below. The link refers to another note in Markdown format
that is present in the same directory. By default, you cannot navigate to that
note in Vim. To enable that behaviour, install [follow-markdown-links](
https://github.com/prashanthellina/follow-markdown-links) Vim plugin.

```markdown
lorem ipsum [ThoughtsOnMarkdown](ThoughtsOnMarkdown.md) dolor ...
```

### Shell commands

Assuming you have placed your Notes directory at `~/notes`, let us follow this
process.

```bash
git clone https://github.com/prashanthellina/bashnotes.git
cp bashnotes/bash_notes.sh ~/.bash_notes.sh
```

Place the following in your shell startup file (eg: ~/.bashrc, ~/.zshrc,
~/.profile (OSX+bash)).

```bash
export NOTES_DIR=~/notes
export DIARY_DIR=~/notes/diary

source ~/.bash_notes.sh
```

Quit and re-open your shell (or run `source <startup file>`) for the changes to
take effect.

## Usage

After following the setup process, you have

1. A server that acts as a notes backup location using a Git repo
1. One or more local machines across which the notes are synchronized
1. Empty `notes` and `diary` directories.

Let us take this for a spin

### Note down a thought in the diary

```bash
note "I'm trying out my awesome new note taking setup"
```

You would have noticed that nothing seemed to happen for the above command. Now
do

```bash
today
```

Cool huh? Exit the file now.

Add one more thought to the diary.

```bash
note "This is really cool :)"
```

This note is also added to the diary file. The command will create a new
file for every day and record all diary notes of that day over there.

### See all diary notes
```bash
diary
```

You will see just one entry but this will change as you use this everyday.

### Create a wiki Note

```bash
vim ~/notes/ThoughtsOnMarkdown.md
```

Add some text to this (Learn [Markdown Syntax here](
http://daringfireball.net/projects/markdown/syntax))

Example text to add to above file

```markdown
# Thoughts on Markdown

`Markdown` is a great plain text format that is highly readable and translates
well to HTML with pretty formatting.

See how this helps me maintain notes in [Bash notes](Bashnotes.md)
```

Move the Vim cursor to the link and press ENTER.

Aha! You can now add content to the new file and move back to the previous one
by pressing BACKSPACE in normal mode.
