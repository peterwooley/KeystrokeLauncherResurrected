# Keystroke Launcher (BETA) [KL]

Execute commands fast, no need to clutter your desktop with a lot of icons, just remember the name and execute it directly!

* **Fast and small footprint**
* **Frequency based search results**
* **Configuration UI**
* **Hide/ show elements in the search screen**

## Quickstart

1. Press `ctrl+alt` to open the window
2. Type something
3. press Enter (the first entry will be executed) or use the up/ down keys

To change the keybinding go into the configuration menu: `ctrl+alt` --> type in `kl` --> select `kl show` --> `Enter`

Also check out the other options, eg in the Look & Feel :)

**Tipps:**

* Use up/ down keys to navigate or select an entry by clicking on it
* Search database is refreshed once at login time. Can also manually be refreshed using the button in the configuration ui.

## Associate a keyword to an item

KL implicitly associates a keyword with a particular item.

1. Open the tooel and enter a string, eg `r`
2. Use up/ down keys to navigate to an item, eg `reload ui`
3. Hit Enter to execute it once

Now, if you open the window again and enter `r`, `relead ui` will be the first result. The other results below the first entry, are ordered by *total number of executions*.

* Association is done at execution time, that is, when you actually launch the item.
* You may want to associate `r` with an other item later. In that case, just type `r` and select this other item before executing it. The keystroke laucnher will change the association implicitly.

## The search index can contain

* (*) All spells which are castable and not passive
* All addons as long as they have a slash command registered and are enabled/ loaded
* All macros
* (*) A few additnioal commands like reload, logout, dismout, kl show
* (*) All inventory items which are usable
* (*) All mounts
* (*) Equipment Sets
* (*) Blizzard Unit Frames

(*) enabled by default, for the rest go into the configuration window.

## Gotchas& Known Issues

* Does not work in combat, due to Blizzard API limiations
* Needs one free slot in the "General" macro tab
* Addons are executed as `/(addon name in lower case)`, therefore will not work for addons with a diffent slash commands. Am not sure how to salve that atm.
* The way the autoscrolling works right now is very basic, it does not handle resizing or manual scrolling.

## Roadmap

* Add ability to execute subcommands, based on currently selected item
* Add shortcuts blizzard frames
* Possibilty to modify the search index per GUI

Let me know if you find any bugs :)
