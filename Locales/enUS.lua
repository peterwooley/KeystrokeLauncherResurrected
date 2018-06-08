local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncher", "enUS", true)

if L then

--[=====[ OPTIONS --]=====]
-- share
L["config_print"] = "print"
L["config_keybinding"] = "Keybinding"
L["OPEN"] = "Open"
L["CLEAR"] = "Clear"
L["PRINT"] = "Print"

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

-- search table
L["config_search_table_name"] = "Search Index"
L["config_search_table_header_one"] = "The main search index"
L["config_search_table_rebuild"] = "Refresh Index"
L["config_search_table_header_two"] = "Configure what to index"
L["config_search_table_desc"] = "Don't forget to hit the 'Refresh' button after enabling/ disabling a module.\n\nNote: enabling the addons module will lead to a small lag evertime the database is refreshed, especially if you have a big amount of addons installed (default: once per login)."
L["config_search_table_index"] = "Select to enable"

L["config_search_freq_table_name"] = "Search Frequency Index"
L["config_search_freq_table_desc"] = "The search frequency index stores how often you executed what."
L["config_search_freq_table_cleared"] = "Search frequency index cleared"
L['CONFIG_SEARCH_TABLE_CUSTOM_HEADER'] = "Custom Search Data"

L['CONFIG_INDEX_TYPES_ADDON'] = 'Addons'
L['CONFIG_INDEX_TYPES_MACRO'] = 'Macros'
L['CONFIG_INDEX_TYPES_SPELL'] = 'Spells'
L['CONFIG_INDEX_TYPES_CMD'] = 'Slash Commands'
L['CONFIG_INDEX_TYPES_ITEM'] = 'Items'
L['CONFIG_INDEX_TYPES_MOUNT'] = 'Mounts'
L['CONFIG_INDEX_TYPES_EQUIP_SET'] = 'Equipment Sets'
L['CONFIG_INDEX_TYPES_BLIZZ_FRAME'] = 'Blizzard Frames'
L['CONFIG_INDEX_TYPES_CVAR'] = 'CVARs'

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
Note 2: because numbers are then special control characters, you cannot use them for filtering anymore]]
L['CONFIG_LOOK_N_FEEL_EDIT_MODE_NAME'] = 'Edit Mode'
L['CONFIG_LOOK_N_FEEL_EDIT_MODE_DESC'] = 'Show/ hide the checkbox which switches the edit mode on / off.'
L['CONFIG_LOOK_N_FEEL_TOP_MACROS_NAME'] = 'Write Top Marcos'
L['CONFIG_LOOK_N_FEEL_TOP_MACROS_DESC'] = [[If enabled, the top 5 most executed items will be saved into character specific macros with the naming `kl-top-n`, where n is 1 to 5. Macros will be created if they do not exist and there is free macro space.

To see more informative macro tooltips, please install the Custom Tooltips addon (https://www.curseforge.com/wow/addons/custom-tooltips).]]
L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_NAME'] = 'Use Clickable Item Icons'
L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_DESC'] = 'If enabled, you can execute the item by clicking on the icon. Disable to have smaller icons.'
L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_NAME'] = "Max Items per Page"
L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_DESC'] = "Controls how many lines the result window has. Default: 7."
L['CONFIG_LOOK_N_FEEL_SIZE'] = "UI Size Settings"

--[=====[ CODE --]=====]
L["INDEX_HEADER"] = "Search index refreshed."
L["INDEX_DISABLED"] = "  Disabled: "
L["INDEX_ENABLED"] = "  Enabled: "
L['INDEX_FOOTER'] = function(X)
    return 'Hit ' .. X .. ' to get started!';
end

--[=====[ TOOLTIPS --]=====]
L["DB_SEARCH_RELOAD_UI"] = "Reload the UI"
L["DB_SEARCH_LOGOUT"] = "Logout"
L["DB_SEARCH_KL_SHOW"] = "Show Keystrooke Launcher UI"
L["DB_SEARCH_KL_FREQ_PRINT"] = "Print the KL search frequency table"
L["DB_SEARCH_DISMOUNT"] = "Dismount"
L["DB_SEARCH_KL_SEARCH_REBUILD"] = "Refresh the search index"

-- search index
L['CALENDAR'] = "Calendar"
L['SUMMON_RANDOM_FAVORITE_MOUNT'] = "Summon random favorite mount."
L['TOGGLE_SOUND'] = "Switch global sound on / off"

end