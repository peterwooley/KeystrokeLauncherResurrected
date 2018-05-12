local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncher", "enUS", true)

if L then

L["identifier"] = "Translation for that identifier"
L["something"] = "Translation for something"

-- self:Print(L['Added X DKP to player Y.'](dkp_value, playername));
L['Added X DKP to player Y.'] = function(X,Y)
    return 'Added ' .. X .. ' DKP for player ' .. Y .. '.';
end

end