local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncher", "deDE", false)

if L then

--[=====[ OPTIONS --]=====]
-- share
L["config_print"] = "Anzeigen"
L["config_keybinding"] = "Tastenbelegung"
L["OPEN"] = "Öffnen"
L["CLEAR"] = "Zurücksetzen"
L["PRINT"] = "Anzeigen"

-- individual
L["config_hide_name"] = "Verstecke"
L["config_hide_desc"] = "Verstecke das Konfigurationsfenster"
L["config_show_name"] = "Anzeigen"
L["config_show_desc"] = "Zeige das Konfigurationsfenster an"
L["config_group_keybindungs_desc"] = "Hier kannst du deine Tastenbelegung setzen"
L["config_modifiers"] = "Modifiers"
L["config_modifiers_alt"] = "Alt"
L["config_modifiers_ctrl"] = "Ctrl"
L["config_modifiers_shift"] = "Shift"
L["config_reset_name"] = "Alles zurücksetzen"
L["config_reset_desc"] = "Mache einen factory reset"
L["config_reset_confirmText"] = "Alle Keystroke Launcher Datenbanken werden auf die Standardwerte zurückgesetzt  - weitermachen?"

-- search table
L["config_search_table_name"] = "Suchindex"
L["config_search_table_header_one"] = "Der Suchindex."
L["config_search_table_rebuild"] = "Aktualisieren"
L["config_search_table_header_two"] = "Einstellungen zu den Suchindex Modulen"
L["config_search_table_desc"] = "Vergiss nicht auf 'Aktualisieren' zu drücken, nachdem du ein Modul aktiviert / deaktiviert hast.\n\nAnmerkung: wenn du das 'Addons' Modul aktivierst, gibt es, wenn du viele Addons hast, kleine lags beim Erzeugen der Suchdatenbank (standardmäßig einmal beim Login)."
L["config_search_table_index"] = "Auswählen zum aktivieren"

L["config_search_freq_table_name"] = "Häufigkeitsindex"
L["config_search_freq_table_desc"] = "Der Häufigkeitsindex merkt sich wie oft du was ausgeführt hast."
L["config_search_freq_table_cleared"] = "Häufigkeitsindex zurückgesetzt"
L['CONFIG_SEARCH_TABLE_CUSTOM_HEADER'] = "Eigene Suchdaten"

L['CONFIG_INDEX_TYPES_ADDON'] = 'Addons'
L['CONFIG_INDEX_TYPES_MACRO'] = 'Makros'
L['CONFIG_INDEX_TYPES_SPELL'] = 'Zaubersprüche'
L['CONFIG_INDEX_TYPES_CMD'] = 'Slash Befehle'
L['CONFIG_INDEX_TYPES_ITEM'] = 'Gegenstände'
L['CONFIG_INDEX_TYPES_MOUNT'] = 'Reittiere'
L['CONFIG_INDEX_TYPES_EQUIP_SET'] = 'Ausrüstungs-Sets'
L['CONFIG_INDEX_TYPES_BLIZZ_FRAME'] = 'Blizzard Fenster'
L['CONFIG_INDEX_TYPES_CVAR'] = 'CVARs'
L['CONFIG_INDEX_TYPES_TOY'] = 'Spielzeuge'

-- look n feel
L['CONFIG_LOOK_N_FEEL_HEADER'] = 'Anzeigen / verstecken von Elementen'
L['CONFIG_LOOK_N_FEEL_TOOLTIP_NAME'] = 'Tooltips'
L['CONFIG_LOOK_N_FEEL_TOOLTIP_DESC'] = 'Zeigt / versteckt die Tooltips'
L['CONFIG_LOOK_N_FEEL_MARKER_NAME'] = "Typ Markierungen"
L['CONFIG_LOOK_N_FEEL_MARKER_DESC'] = "Zeigt / versteckt die Typ Markierungen (die farbigen Punkte)."
L['CONFIG_LOOK_N_FEEL_CHECKBOXES_NAME'] = "Typ Checkboxen"
L['CONFIG_LOOK_N_FEEL_CHECKBOXES_DESC'] = "Zeigt / versteckt die Suchtyp Checkboxen."
L['CONFIG_LOOK_N_FEEL_HEADER_EXPERIMENTAL'] = "Experimentale Einstellungen"
L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_NAME'] = "Schneller Suchtyp Filter"
L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_DESC'] = [[Wenn aktiviert werden Nummern im Suchfeld als Suchtyp interpretiert. Die Suchtyp id ist die Nummer in eckigen Klammern.

Beispiel: wenn du `r4` eintippst, wird in der Suchtyp Kategorie `4` nach dem Buchstaben `r` gefiltert.

Anmerkung 1: funktioniert nur wenn die Suchtyp Checkboxen auch aktiviert sind.
Anmerkung 2: weil Zahlen dann als spezielle Kontroll-Charaktere behandelt werden, kannst du sie nicht mehr als Filter verwenden.]]
L['CONFIG_LOOK_N_FEEL_EDIT_MODE_NAME'] = 'Edit Modus'
L['CONFIG_LOOK_N_FEEL_EDIT_MODE_DESC'] = 'Zeigt / versteckt die Checkbox die den Edit Modus an / aus schaltet.'
L['CONFIG_LOOK_N_FEEL_TOP_MACROS_NAME'] = 'Schreibe Top Makros'
L['CONFIG_LOOK_N_FEEL_TOP_MACROS_DESC'] = [[Wenn an, werden die 5 meist ausgeführten Befehle in Charakter spezifischen Makros mit dem Namen `kl-top-n` gespeichert (n ist 1 bis 5). Die Makros werden erzeugt wenn sie nicht existieren.

Für informativere Tooltips, installire das Custom Tooltips Addon (https://www.curseforge.com/wow/addons/custom-tooltips).]]
L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_NAME'] = 'Benutze klickbare Icons'
L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_DESC'] = 'Wenn an, kannst du auf die Icons klicken um den Eintrag auszuführen. Deaktiviere es für kleinere Icons.'
L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_NAME'] = "Maximale Ergebnisse / Seite"
L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_DESC'] = "Kontrolliert die Anzahl an Ergebniszeilen. Default: 7."
L['CONFIG_LOOK_N_FEEL_SIZE'] = "Einstellungen der UI Größe"

--[=====[ CODE --]=====]
L["INDEX_HEADER"] = "Suchdatenbank erfolgreich aktualisiert."
L["INDEX_DISABLED"] = "  Deaktiviert: "
L["INDEX_ENABLED"] = "  Aktiviert: "
L['INDEX_FOOTER'] = function(X)
    return 'Drücke ' .. X .. ' um anzufangen!';
end

--[=====[ TOOLTIPS --]=====]
L["DB_SEARCH_RELOAD_UI"] = "Lade die UI neu"
L["DB_SEARCH_LOGOUT"] = "Ausloggen"
L["DB_SEARCH_KL_SHOW"] = "Zeige die Keystroke Launcher UI an"
L["DB_SEARCH_KL_FREQ_PRINT"] = "Zeige den Häufigkeitsindex an"
L["DB_SEARCH_DISMOUNT"] = "Absteigen"
L["DB_SEARCH_KL_SEARCH_REBUILD"] = "Aktualisiere den Suchindex"

-- search index
L['CALENDAR'] = "Kalender"
L['SUMMON_RANDOM_FAVORITE_MOUNT'] = "Zufälliges Lieblingsreittiert beschwören."
L['TOGGLE_SOUND'] = "Schalte den globalen Ton an / aus"

end
