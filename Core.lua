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
            -- toggle = {
            --     name = "toggle",
            --     type = "execute",
            --     func = function() 
            --         if AceConfigDialog:IsVisible() then
            --             AceConfigDialog:Close("KeystrokeLauncher")
            --         else
            --             AceConfigDialog:Open("KeystrokeLauncher")
            --         end
            --     end
            -- },
            gui = {
                name = "gui",
                type = "group",
                args = {
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
                },
            },
            search_table = {
                name = "search_table",
                type = "group",
                args = {
                    show = {
                        name = "show",
                        type = "execute",
                        func = function() format_search_data_table(self) end
                    },
                    rebuild = {
                        name = "rebuild",
                        type = "execute",
                        func = function() fill_search_data_table(self) end
                    }
                }
            }
        }
    }
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) -- enable profiles
    LibStub("AceConfig-3.0"):RegisterOptionsTable("KeystrokeLauncher", options, {"kl", "keystrokelauncher"})
    AceConfigDialog:AddToBlizOptions("KeystrokeLauncher")

    --[=====[ GLOBAL KEYBOARD LISTENER --]=====]
    KeyboardListenerFrame = CreateFrame("Frame", "KeyboardListener", UIParent);
    KeyboardListenerFrame:EnableKeyboard(true)
    KeyboardListenerFrame:SetPropagateKeyboardInput(true)
    KeyboardListenerFrame:SetScript("OnKeyDown", function(self2, key)
        -- collect currently pressed buttons
        local pressedButtons = {}
        if not table.contains({"LALT", "LCTRL"}, key) then
            table.insert(pressedButtons, key)
        end
        if IsControlKeyDown() then
            table.insert(pressedButtons, "ctrl")
        end
        if IsAltKeyDown() then
            table.insert(pressedButtons, "alt")
        end
        
        -- format configured keybindings
        local mergedKeybindings = {}
        table.insert(mergedKeybindings, self.db.char.keybindingKey)
        for key, val in pairs(self.db.char.keybindingModifiers) do
            if val then
                table.insert(mergedKeybindings, key)
            end
        end

        -- if identical, show window
        if #mergedKeybindings == #pressedButtons then
            local showWindow = true
            for k, v in pairs(mergedKeybindings) do
                local found = false
                for k1, v1 in pairs(pressedButtons) do
                    if v == v1 then
                        found = true
                    end
                end
                if not found then
                    showWindow = false
                end
            end
    
            if showWindow then
                draw_gui(self)
            end
        end
    end)

    --[=====[ FILL SEARCH DATABASE --]=====]
    fill_search_data_table(self)
end

function KeystrokeLauncher:OnEnable()
    -- Called when the addon is enabled
end

function KeystrokeLauncher:OnDisable()
    -- Called when the addon is disabled
end

function draw_gui(self)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Keystroke Launcher")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(400)
    frame:SetHeight(300)

    -- search field
    local editbox = AceGUI:Create("EditBox")
    editbox:SetFullWidth(true)
    editbox:SetFocus()
    frame:AddChild(editbox)

    -- scroll framge
    scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetLayout("Fill")

    frame:AddChild(scrollcontainer)

    scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scrollcontainer:AddChild(scroll)

    -- the data
    SEARCH_TABLE_TO_LABEL = {}
    for key, val in pairs(self.db.char.searchDataTable) do
        local label = AceGUI:Create("InteractiveLabel")
        label:SetText(key)
        label:SetWidth(200)
        label:SetUserData("orig_text", key)
        label:SetCallback("OnClick", function() 
            select_label(key)
            self:Print(val['slash_cmd'])
            edit_master_marco(frame, val['slash_cmd'])
        end)
        scroll:AddChild(label)
        SEARCH_TABLE_TO_LABEL[key] = label
    end
   
    frame:Show()
end

function edit_master_marco(frame, body, key)
    macroId = get_or_create_maco('kl-master')

    if not key then
        key = 'ENTER'
    end

    EditMacro(macroId, nil, nil, body, 1, 1); 
    SetOverrideBindingMacro(KeyboardListenerFrame, true, key, macroId)
end

function select_label(key)
    for k, label in pairs(SEARCH_TABLE_TO_LABEL) do
        if k == key then
            label:SetText(label:GetUserData("orig_text") ..' (selected)')
        else
            label:SetText(label:GetUserData("orig_text"))
        end
    end
end

function fill_search_data_table(self)
    self.db.char.searchDataTable = {}
    local db_search = self.db.char.searchDataTable
    for i=1, GetNumAddOns() do 
        name, title, notes, enabled = GetAddOnInfo(i) 
        if enabled and IsAddOnLoaded(i) then
            local slash_cmd = '/'..name:lower()
            -- only add if slash command exists
            if slash_cmd_exists(slash_cmd) then
                db_search[name] = {slash_cmd=slash_cmd, is_slash=true, tooltipText=name.."\n"..title.."\n"..notes}
            else
                -- no slash command exists, let's see if we can find something in _G['SLASH_...']
                for k, v in pairs(_G) do
                    if k:find('SLASH_') then
                        if k:lower():find(name:lower()) then
                            db_search[name] = {slash_cmd=v, is_slash=true, tooltipText=name.."\n"..title.."\n"..notes}
                        end
                    end
                end
            end
        end 
    end

    -- add macros
    local numglobal, numperchar = GetNumMacros();
    for i = 1, numglobal do
        name, iconTexture, body, isLocal = GetMacroInfo(i)
        if name then
            icon_macro_name = "|T"..iconTexture..":16|t "..name
            -- why does this destroy data?
            -- db_search[icon_macro_name] = {slash_cmd=name, is_macro=true, tooltipText=body}
        end
    end
    for i = 1, numperchar do
        name, iconTexture, body, isLocal = GetMacroInfo(i + 120)
        if name then
            icon_macro_name = "|T"..iconTexture..":16|t "..name
            db_search[icon_macro_name] = {slash_cmd=name, is_macro=true, tooltipText=body}
        end
    end


    -- add spells
    local i = 1
    while true do
        local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not spellName then
            do break end
        end

        if IsUsableSpell(spellName) then
            if not IsPassiveSpell(spellName) then
                spellString, spellname = item_link_to_string(GetSpellLink(spellName))
                icon_spell_name = "|T"..GetSpellTexture(spellName)..":16|t "..spellName
                db_search[icon_spell_name] = {slash_cmd="/cast "..spellName, is_spell=true, tooltipItemString=spellString}
            end
        end

        i = i + 1
    end

    -- manually adding some slashcommmands
    db_search['Reload UI'] = {slash_cmd='/reload', is_slash=true}
    db_search['Logout'] = {slash_cmd='/logout', is_slash=true}
    db_search['kl update'] = {slash_cmd='/kl update', is_slash=true}
    db_search['kl show'] = {slash_cmd='/kl show', is_slash=true}
    db_search['kl clear'] = {slash_cmd='/kl clear', is_slash=true}
    db_search['Dismount'] = {slash_cmd='/dismount', is_slash=true}

    -- items
    for bag=0, NUM_BAG_SLOTS do
        for bagSlots=1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, bagSlots)
            if itemLink then
                itemString, itemName = item_link_to_string(itemLink)
                if IsUsableItem(itemName) then
                    icon_item_name = "|T"..GetItemIcon(itemName)..":16|t "..itemName
                    db_search[icon_item_name] = {slash_cmd=itemName, is_item=true, tooltipItemString=itemString}
                end
            end
        end
    end

    -- add mounts
    for i=1, C_MountJournal.GetNumDisplayedMounts() do
        creatureName, spellID, icon = C_MountJournal.GetDisplayedMountInfo(i)
        spellString, spellname = item_link_to_string(GetSpellLink(spellID))
        icon_item_name = "|T"..icon..":16|t "..creatureName
        db_search[icon_item_name] = {slash_cmd=creatureName, is_item=true, tooltipItemString=spellString}
    end
    self:Print("Search database rebuild done.")
end