# Keystroke Launcher (BETA)

## Features

* Fast and small footprint
* Frequency based search results
* Shortcuts to execute things even faster

## Quickstart

1. Press `ctrl+alt` to open the window
2. Type something
3. press Enter (the first entry will be executed) or use the up/ down keys

How to use the shortcuts:

1. Press `ctrl+alt` to open the window
2. Press a number from 1 to 9. Two things will happen:
    1. The number you pressed will be assigned to the thing you executed
    2. The thing is executed

The next time you open the main window, you can directly press that number. To overwrite a binding, just navigate to the thing you want to execute and press the number again.

## Tipps

* The list is ordered by frequency (the number in brackets), use `/kl clear` to reset it
* Search database is refreshed once at login time. You can also trigger it manually with `/kl update`

## Gotchas& Known Issues

* Does not work in combat, due to Blizzard API limiations
* Needs one free slot in the "General" macro tab
* Addons are executed as `/(addon name in lower case)`, therefore will not work for addons with a diffent slash command. 
* No auto scolling in result window yet

## The search index contains

* All spells which are castable and not passive
* All addons as long as they have a slash command registered and are enabled/ loaded
* All macros
* The following slash commands: reload, logout, dismout, kl update, kl clear, kl show
* All inventory items which are usable
* All mounts

## Roadmap

* Auto scrolling of result window
* Nicer UI
* Intelligent addon start
* ExpEven quicker start of macros by holding down 

Let me know if you find any bugs :)
