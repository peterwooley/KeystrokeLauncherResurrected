local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncher", "deDE", false)

if L then

--[=====[ OPTIONS --]=====] 
-- share
L["config_print"] = "Anzeigen"
L["config_keybinding"] = "Tastenbelegung"

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
L["config_reset_desc"] = "Mach einen factory reset"
L["config_reset_confirmText"] = "Alle Keystroke Launcher Datenbanken werden auf die Standardwerte zurückgesetzt  - weitermachen?"

L["config_search_table_name"] = "Suchdatenbank"
L["config_search_table_header_one"] = "Die Suchdatenbank ist der Hauptsuchindex."
L["config_search_table_rebuild"] = "Aktualisieren"
L["config_search_table_header_two"] = "Einstellungen zu den Index Modulen"
L["config_search_table_desc"] = "Vergesse nicht auf den 'Aktualisieren' Knopf zu drücken, nachdem du addons aktiviert/ deaktiviert hast.\n\nAnmerkung: wenn du das 'Addons' Modul aktivierst, gibt es kleine lags beim erzeugen der Suchdatenbank (standardmäßig einmal beim Login)."
L["config_search_table_index"] = "Auswählen zum aktivieren"

L["config_search_freq_table_name"] = "Häufigkeitsdatenbank"
L["config_search_freq_table_desc"] = "Die Häufigkeitsdatenbank merkt sich wie oft du was ausgeführt hast."
L["config_search_freq_table_clear_name"] = "Clear"
L["config_search_freq_table_clear_desc"] = "Setze die Häufigkeitsdatenbank zurück"
L["config_search_freq_table_cleared"] = "Häufigkeitsdatenbank zurückgesetzt"

--[=====[ CODE --]=====]
L["PRINT_SEARCH_DATA_TABLE"] = "Inhalt der Suchdatenbank:"
L["PRINT_SEARCH_DATA_FREQ"] = "Inhalt der Häufigkeitsdatenbank:"
L["INDEX_HEADER"] = "Suchdatenbank erfolgreich aktualisiert."
L["INDEX_DISABLED"] = "  Deaktiviert: "
L["INDEX_ENABLED"] = "  Aktiviert: "

end