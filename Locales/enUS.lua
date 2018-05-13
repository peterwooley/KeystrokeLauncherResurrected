local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncher", "enUS", true)

if L then


L["config_hide_name"] = "Hide"
L["config_hide_desc"] = "Hide configuration window"
L["config_show_name"] = "Show"
L["config_show_desc"] = "Show configuration window"
L["config_enable_name"] = "Enable"
L["config_enable_desc"] = "Enable the addon"
-- keybindungs
L["config_group_keybindings"] = "Keybindungs"
L["config_group_keybindungs_desc"] = "Here you can set the keybindungs"
L["config_modifiers"] = "Modifiers"
L["config_keybinding_name"] = "Keybindung"
L["config_modifiers_alt"] = "Alt"
L["config_modifiers_ctrl"] = "Ctrl"
L["config_modifiers_shift"] = "Shift"

-- self:Print(L['Added X DKP to player Y.'](dkp_value, playername));
-- L['Added X DKP to player Y.'] = function(X,Y)
--     return 'Added ' .. X .. ' DKP for player ' .. Y .. '.';
-- end

end