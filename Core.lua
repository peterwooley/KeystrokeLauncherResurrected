KeystrokeLauncher = LibStub("AceAddon-3.0"):NewAddon("KeystrokeLauncher", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncher")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function KeystrokeLauncher:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("KeystrokeLauncherDB")
    if self.db.char.keybindingModifiers == nil then
        self.db.char.keybindingModifiers = {}
    end

    --[=====[ SLASH COMMANDS/ CONFIG OPTIONS --]=====]
    local options = {
        name = "KeystrokeLauncher",
        handler = KeystrokeLauncher,
        type = "group",
        args = {
            enable = {
                name = L["config_enable_name"],
                desc = L["config_enable_desc"],
                type = "toggle",
                set = function(info, val) KeystrokeLauncher.enabled = val end,
                get = function(info) return KeystrokeLauncher.enabled end
            },
            moreoptions = {
                name = L["config_group_keybindings"],
                type = "group",
                args = {
                    desc = {
                        name = L["config_group_keybindungs_desc"],
                        type = "header"
                    },
                    keybinding = {
                        name = L["config_keybinding_name"],
                        type = "keybinding",
                        set = function(info, val) self.db.char.keybindingKey = val end,
                        get = function(info) return self.db.char.keybindingKey end
                    },
                    modifiers = {
                        name = L["config_modifiers"],
                        type = "multiselect",
                        values = {
                            alt = L["config_modifiers_alt"],
                            ctrl = L["config_modifiers_ctrl"],
                            shift = L["config_modifiers_shift"]
                        },
                        set = function(info, key, state) self.db.char.keybindingModifiers[key] = state end,
                        get = function(info, key) return self.db.char.keybindingModifiers[key] end
                    }
                }
            },
            show = {
                name = L["config_show_name"],
                desc = L["config_show_desc"],
                guiHidden = true,
                type = "execute",
                func = function() AceConfigDialog:Open("KeystrokeLauncher") end,
            },
            hide = {
                name = L["config_hide_name"],
                desc = L["config_hide_desc"],
                type = "execute",
                func = function() AceConfigDialog:Close("KeystrokeLauncher") end,
            },
        }
    }
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) -- enable profiles
    LibStub("AceConfig-3.0"):RegisterOptionsTable("KeystrokeLauncher", options, {"kl", "keystrokelauncher"})
    AceConfigDialog:AddToBlizOptions("KeystrokeLauncher")
end

function KeystrokeLauncher:OnEnable()
    -- Called when the addon is enabled
end

function KeystrokeLauncher:OnDisable()
    -- Called when the addon is disabled
end

function draw_gui()
    local textStore

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Example Frame")
    frame:SetStatusText("AceGUI-3.0 Example Container Frame")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")

    local editbox = AceGUI:Create("EditBox")
    editbox:SetLabel("Insert text:")
    editbox:SetWidth(200)
    editbox:SetCallback("OnEnterPressed", function(widget, event, text) textStore = text end)
    frame:AddChild(editbox)

    local button = AceGUI:Create("Button")
    button:SetText("Click Me!")
    button:SetWidth(200)
    button:SetCallback("OnClick", function() print(textStore) end)
    frame:AddChild(button)
end