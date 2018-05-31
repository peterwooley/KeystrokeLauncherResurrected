local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncher", "enUS", true)

if L then

--[=====[ OPTIONS --]=====] 
-- share
L["config_print"] = "print"
L["config_keybinding"] = "Keybinding"
L["OPEN"] = "Open"

-- individual
L["config_hide_name"] = "Hide"
L["config_hide_desc"] = "Hide configuration window"
L["config_show_name"] = "Show"
L["config_show_desc"] = "Show configuration window"
L["config_group_keybindungs_desc"] = "Set custom keybindings"
L["config_modifiers"] = "Modifiers"
L["config_modifiers_alt"] = "Alt"
L["config_modifiers_ctrl"] = "Ctrl"
L["config_modifiers_shift"] = "Shift"
L["config_reset_name"] = "Reset all"
L["config_reset_desc"] = "Do a factory reset"
L["config_reset_confirmText"] = "This resets every Kestroke Launcher database to default values - proceed?"

L["config_search_table_name"] = "Search Index"
L["config_search_table_header_one"] = "The main search index"
L["config_search_table_rebuild"] = "Refresh Index"
L["config_search_table_header_two"] = "Configure what to index"
L["config_search_table_desc"] = "Don't forget to hit the 'Refresh' button after enabling/ disabling a module.\n\nNote: enabling the addons module will lead to a small lag evertime the database is refreshed, especially if you have a big amount of addons installed (default: once per login)."
L["config_search_table_index"] = "Select to enable"

L["config_search_freq_table_name"] = "Search Frequency Index"
L["config_search_freq_table_desc"] = "The search frequency index stores how often you executed what."
L["config_search_freq_table_clear_name"] = "Clear"
L["config_search_freq_table_clear_desc"] = "Empty the search frequency index table"
L["config_search_freq_table_cleared"] = "Search frequency index cleared"

L['CONFIG_INDEX_TYPES_ADDON'] = 'Addons'
L['CONFIG_INDEX_TYPES_MACRO'] = 'Macros'
L['CONFIG_INDEX_TYPES_SPELL'] = 'Spells'
L['CONFIG_INDEX_TYPES_CMD'] = 'Slash Commands'
L['CONFIG_INDEX_TYPES_ITEM'] = 'Items'
L['CONFIG_INDEX_TYPES_MOUNT'] = 'Mounts'
L['CONFIG_INDEX_TYPES_EQUIP_SET'] = 'Equipment Sets'
L['CONFIG_INDEX_TYPES_BLIZZ_FRAME'] = 'Blizzard Frames'

-- look n feel
L['CONFIG_LOOK_N_FEEL_HEADER'] = 'Show / hide elements'
L['CONFIG_LOOK_N_FEEL_TOOLTIP_NAME'] = 'Tooltips'
L['CONFIG_LOOK_N_FEEL_TOOLTIP_DESC'] = 'Enables / disables the tooltips'
L['CONFIG_LOOK_N_FEEL_MARKER_NAME'] = "Type Marker"
L['CONFIG_LOOK_N_FEEL_MARKER_DESC'] = "Show/ hide the search type marker (the color dots)."
L['CONFIG_LOOK_N_FEEL_CHECKBOXES_NAME'] = "Type Checkboxes"
L['CONFIG_LOOK_N_FEEL_CHECKBOXES_DESC'] = "Show/ hide the search type filter checkboxes."
L['CONFIG_LOOK_N_FEEL_HEADER_EXPERIMENTAL'] = "Experimental Settings"
L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_NAME'] = "Quick Search Type Filter"
L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_DESC'] = [[When enabled, numbers in the search string will be interpreted as search types. The search type category id is the number in in square brackets.

Example: if you type in `r4`, the tool will filter the result list for the search type category with the id `4` and the string `r`. 

Note 1: only works when the Type Checkboses are enabled.
Note 2: because numbers are then special control characters, you cannot use them for filtering anymore"]]

--[=====[ CODE --]=====]
L["PRINT_SEARCH_DATA_TABLE"] = "Content of search frequency index:"
L["PRINT_SEARCH_DATA_FREQ"] = "Content of search data index:"
L["INDEX_HEADER"] = "Search index refreshed."
L["INDEX_DISABLED"] = "  Disabled: "
L["INDEX_ENABLED"] = "  Enabled: "

--[=====[ TOOLTIPS --]=====]
L["DB_SEARCH_RELOAD_UI"] = "Reload the UI"
L["DB_SEARCH_LOGOUT"] = "Logout"
L["DB_SEARCH_KL_SHOW"] = "Show Keystrooke Launcher UI"
L["DB_SEARCH_KL_FREQ_PRINT"] = "Print the KL search frequency table"
L["DB_SEARCH_DISMOUNT"] = "Dismount"
L["DB_SEARCH_KL_SEARCH_REBUILD"] = "Refresh the search index"

-- search index
L['CALENDAR'] = "Calendar"

end