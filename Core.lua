KeystrokeLauncher = LibStub("AceAddon-3.0"):NewAddon("KeystrokeLauncher", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncher")

-- function KeystrokeLauncher:MyFunction()
--     self.db.char.myVal = "My character-specific saved value"
--     self.db.global.myOtherVal = "My global saved value"
-- end

--[=====[ SLASH COMMANDS --]=====]
-- local options = {
--     type = "group",
--     args = {
--         enable = {
--             name = "Enable",
--             desc = "Enables / disables the addon",
--             type = "toggle",
--             set = function(info,val) KeystrokeLauncher.enabled = val end,
--             get = function(info) return KeystrokeLauncher.enabled end
--         },
--         moreoptions = {
--             name = "More Options",
--             type = "group",
--             args = {
--                 -- more options go here
--             }
--         }
--     }
-- }

local options = {
    name = "KeystrokeLauncher",
    handler = KeystrokeLauncher,
    type = 'group',
    args = {
        msg = {
            type = 'input',
            name = 'My Message',
            desc = 'The message for my addon',
            set = 'SetMyMessage',
            get = 'GetMyMessage',
        },
    },
}

function KeystrokeLauncher:GetMyMessage(info)
    return myMessageVar
end

function KeystrokeLauncher:SetMyMessage(info, input)
    myMessageVar = input
end




--[=====[ PROFILES --]=====]
function KeystrokeLauncher:OnInitialize()
    self:Print(L["identifier"])
    -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("KeystrokeLauncherDB") -- saved vars
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) -- enable profiles
    LibStub("AceConfig-3.0"):RegisterOptionsTable("KeystrokeLauncherName", options, {"/kl", "/keystrokelauncher"})
end

function KeystrokeLauncher:OnEnable()
    -- Called when the addon is enabled
end

function KeystrokeLauncher:OnDisable()
    -- Called when the addon is disabled
end