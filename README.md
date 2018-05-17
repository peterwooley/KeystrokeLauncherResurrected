# Keystroke Launcher (BETA)

Execute commands fast, no need to clutter up your desktio with a lot if names, just remember the name and execute it directly!

* **Fast and small footprint**
* **Frequency based search results**
* **Configuration UI**

## Quickstart

1. Press `ctrl+alt` to open the window
2. Type something
3. press Enter (the first entry will be executed) or use the up/ down keys

## Tipps

* Open the configuration gui by doing `ctrl+alt` --> `kl show` --> `Enter`
* Use up/ down keys to navigate
* The list is ordered by frequency
* Search database is refreshed once at login time.

## Gotchas& Known Issues

* Does not work in combat, due to Blizzard API limiations
* Needs one free slot in the "General" macro tab
* Addons are executed as `/(addon name in lower case)`, therefore will not work for addons with a diffent slash command. 

## The search index can contain

* (*) All spells which are castable and not passive
* All addons as long as they have a slash command registered and are enabled/ loaded
* All macros
* (*) A few additnioal commands like reload, logout, dismout, kl show
* (*) All inventory items which are usable
* (*) All mounts

(*) enabled by default, for the rest go into the congiguration window.

## Roadmap

* Add Shortcuts and Tooltip in again
* Add ability to execute subcommands, based on currently selected item

Let me know if you find any bugs :)
