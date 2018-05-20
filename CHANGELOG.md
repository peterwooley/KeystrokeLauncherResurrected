# Changelog

## v0.9

* NEW: enabled Tooltips again
* NEW: added equipment sets to search index
* NEW: added auto scrolling of window as soon as you up/down out of the boundaries. Note: does not handle resizing yet.
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