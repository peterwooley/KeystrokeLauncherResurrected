# Changelog

## v1.3

* added cooldowns for spells and items

## v1.2

* fixes small type check bug

## v1.1

* Now compatible with Battle for Azeroth

## v1.0

* Replaced freely resizable and scrollable window with fixed size paginated window. Handling up/down keyboard calls for moving the cursor, turned out to be too complicated. Use right / left keys to jump between pages.

## v0.9.10

* Changed loading message to only be shown when debug mode is on.
* Fixed some up / down key scrolling bugs ... still now statisfied though

## v0.9.9

* NEW: edit mode for the search database
* NEW: custom search database
* NEW: added the first CVAR (toggle global sound on/off)
* NEW: clickable action buttons instead of icons ... when you click on them, the item will be execute. Only works for the first 10 items currently, because of lag.
* NEW: experimental automatic macro writing: the top 5 results will be written into macros at window close

## v0.9.5

* NEW: experimental quick search type filter using numbers in the search string. Can be enabled in the look & feel section.

## v0.9.1

* Size of the main frame depends now on the number of visible search type checkboxes
* Typos in English and German translation

## v0.9

* NEW: enabled Tooltips again
* NEW: added equipment sets to search index
* NEW: added auto scrolling of window as soon as you up/down out of the boundaries. Note: does not handle resizing yet.
* NEW: added the possibility to filter additionally by type (spell, macro, etc)
* FIXED: options now visible in Bliizzard Interface -> Addons
* FIXED: search frequency is now correctly used for sorting based on the currently entered filter
* FIXED: sometimes the command would not trigger
* FIXED: sometimes keyboard up/down jumped two and not one entries
* FIXED: summon mount now by spell name and not creature name. Sometimes it is different (eg for the Chauffeured Mechano-Hog).
* Slightly bigger font size

## v0.8

* Disabled some debug prints
* Fixed bug where database was actually not a database and every time the addon was a loaded, everything reset.

## v0.5

* Complete rework based on Ace3
* NEW: configuration window, hit `ctrl+alt`, type in `kl` and select the `/kl show` entry.
* NEW: custom keybindings
* NEW: German translation
* REMOVED: shortcut logic and tooltops, will be added in next release

## v0.3

* Added additional logic to look for how to start an addon
* Reworked shortcut logic. See description.

## v0.2

* Added shortcuts. To use it, press `ctrl+<a number>`. After that, you can do `ctrl+alt` followed by the number.
* Added tooltip
* Added mounts
* Fixed display "In Combat" message to be only shown when ctrl+alt are actually pressed

## v0.1

* first release