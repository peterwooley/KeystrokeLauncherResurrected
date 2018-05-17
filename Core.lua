 KeystrokeLauncher = LibStub("AceAddon-3.0"):NewAddon("KeystrokeLauncher", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncher")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function KeystrokeLauncher:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("KeystrokeLauncherDB")
    if self.db.char.keybindingModifiers == nil then
        self.db.char.keybindingModifiers = {}
    end
    if self.db.char.searchDataFreq == nil then
        self.db.char.searchDataFreq = {}
    end
    if self.db.char.searchDataWhatIndex == nil then
        self.db.char.searchDataWhatIndex = {}
    end
    if not SEARCH_TABLE_INIT_DONE then
        C_Timer.After(2, function()
            -- this delay is needed because the items in the inventory do not seem to be ready right after login 
            fill_search_data_table(self)
            SEARCH_TABLE_INIT_DONE = true
        end)
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
                    },
                    index = {
                        name = "to index",
                        type = "multiselect",
                        values = {
                            items = "items",
                            addons = "addons",
                            macros = "macros",
                            spells = "spells",
                            mounts = "mounts"
                        },
                        set = function(info, key, state) self.db.char.searchDataWhatIndex[key] = state end,
                        get = function(info, key) return self.db.char.searchDataWhatIndex[key] end
                    }
                }
            },
            search_freq = {
                name = "search_freq",
                type = "group",
                args = {
                    clear = {
                        name = "clear",
                        type = "execute",
                        func = function() self.db.char.searchDataFreq = {} end
                    }
                }
            },
            -- close = {
            --     name = "close",
            --     type = "execute",
            --     func = function() KL_MAIN_FRAME:Release() end
            -- }

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
        if check_key_bindings(self) then
            show_main_frame(self)
            show_results(self)
        end
    end)
    --fill_search_data_table(self)
end

function KeystrokeLauncher:OnEnable()
    -- Called when the addon is enabled
end

function KeystrokeLauncher:OnDisable()
    -- Called when the addon is disabled
end

function check_key_bindings(self)
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
    if not is_nil_or_empty(self.db.char.keybindingKey) then
        table.insert(mergedKeybindings, self.db.char.keybindingKey)
    end
    for key, val in pairs(self.db.char.keybindingModifiers) do
        if val then
            table.insert(mergedKeybindings, key)
        end
    end

    --self:Print("Pressed: "..dump(pressedButtons))
    --self:Print("Merged: "..dump(mergedKeybindings))

    -- check if both er identical
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

            return showWindow
        end
    end
    return false
end

function show_main_frame(self)
    KL_MAIN_FRAME = AceGUI:Create("Frame")
    KL_MAIN_FRAME:SetTitle("Keystroke Launcher")
    KL_MAIN_FRAME:SetCallback("OnClose", function(widget) 
        AceGUI:Release(widget)
    end)
    KL_MAIN_FRAME:SetCallback("OnRelease", function(widget) 
        C_Timer.After(0.1, function() 
            self:Print("Keybinding cleared")
            ClearOverrideBindings(KeyboardListenerFrame) 
        end)
    end)
    KL_MAIN_FRAME:SetLayout("Flow")
    KL_MAIN_FRAME:SetWidth(400)
    KL_MAIN_FRAME:SetHeight(300)
    KL_MAIN_FRAME.frame:SetScript("OnKeyDown", function(self, key)
        move_selector(key)
    end) 

    -- search edit box
    SEARCH_EDITBOX = AceGUI:Create("EditBox")
    SEARCH_EDITBOX:SetFullWidth(true)
    SEARCH_EDITBOX:SetFocus()
    SEARCH_EDITBOX:DisableButton(true)
    SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(false)
    SEARCH_EDITBOX.editbox:SetScript("OnKeyDown", function(widget, key)
        if key == 'ENTER' then
            execute_macro(self)
        else
            move_selector(key) 
        end
    end)
    SEARCH_EDITBOX.editbox:SetScript("OnEscapePressed", function(self) 
        KL_MAIN_FRAME:Release() 
    end)
    SEARCH_EDITBOX:SetCallback("OnTextChanged", function(widget, arg2, value)
        show_results(self, value)
    end)
    -- SEARCH_EDITBOX:SetCallback("OnEnterPressed", function(arg1, arg2, value)
    --     SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(true)
    --     KL_MAIN_FRAME:Release()
    -- end)
    KL_MAIN_FRAME:AddChild(SEARCH_EDITBOX)

    -- SCROLL container/ group
    local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetLayout("Fill")
    KL_MAIN_FRAME:AddChild(scrollcontainer)

    -- SCROLL frame
    SCROLL = AceGUI:Create("ScrollFrame")
    SCROLL:SetLayout("Flow")
    scrollcontainer:AddChild(SCROLL)

    KL_MAIN_FRAME:Show()
end

-- execute_macro means effectively propagate then close the main window
function execute_macro(self)
    -- save freq
    current_search = SEARCH_EDITBOX:GetText()
    if is_nil_or_empty(current_search) then
        current_search = 'EMPTY'
    end
    self:Print("CurrentSearch", current_search)
    freq = 1
    if self.db.char.searchDataFreq[current_search] then
        freq = self.db.char.searchDataFreq[current_search].freq + 1
    end
    self.db.char.searchDataFreq[current_search] = { key=CURRENT_KEY_TO_EXE, freq=freq}
    self:Print(dump(self.db.char.searchDataFreq))
    -- propagate and close
    SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(key=='ENTER')
    KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(key=='ENTER')
    KL_MAIN_FRAME:Release()
end

function show_results(self, filter)
    if filter == nil then
        filter = '' -- :find cant handle nil
    end
    SEARCH_TABLE_TO_LABEL = {}
    SCROLL:ReleaseChildren() -- clear all and start from fresh
    local counter = 0
    for key, val in pairs(self.db.char.searchDataTable) do
        if key:lower():find(filter) then
            local label = AceGUI:Create("InteractiveLabel")
            label:SetText(key)
            label:SetWidth(200)
            label:SetUserData("orig_text", key)
            label:SetCallback("OnClick", function() 
                -- cant propagate mouse clicks, so need to press enter after selecting
                select_label(key)
                edit_master_marco(self, val['slash_cmd'])
            end)
            SCROLL:AddChild(label)
            table.insert(SEARCH_TABLE_TO_LABEL, {key=key, label=label})
            -- the first entry is always the one we want to execute per default
            if counter == 0 then
                edit_master_marco(self, val['slash_cmd'])
                select_label(key)
            end
            counter = counter + 1
        end
    end
end

function edit_master_marco(self, body, key)
    macroId = get_or_create_maco('kl-master')
    if not key then
        key = 'ENTER'
    end
    EditMacro(macroId, nil, nil, body, 1, 1); 
    SetOverrideBindingMacro(KeyboardListenerFrame, true, key, macroId)
    CURRENT_KEY_TO_EXE = key
    self:Print(key.." executes: "..body)
end

function move_selector(key)
    -- but only down and up to the min and max boundaries
    if key == "UP" and CURRENTLY_SELECTED_LABEL_INDEX > 1 then
        select_label_index(CURRENTLY_SELECTED_LABEL_INDEX-1)
    elseif key == "DOWN" and CURRENTLY_SELECTED_LABEL_INDEX < #SEARCH_TABLE_TO_LABEL then
        select_label_index(CURRENTLY_SELECTED_LABEL_INDEX+1)
    end
end

function select_label_index(index)
    for k, v in pairs(SEARCH_TABLE_TO_LABEL) do
        if index == k then
            v.label:SetText(v.label:GetUserData("orig_text") ..' (sel)'..k)
            CURRENTLY_SELECTED_LABEL_INDEX = k
        else
            v.label:SetText(v.label:GetUserData("orig_text")..k)
        end
    end
end

function select_label(key)
    for k, v in pairs(SEARCH_TABLE_TO_LABEL) do
        if v.key == key then
            v.label:SetText(v.label:GetUserData("orig_text") ..' (sel)'..k)
            CURRENTLY_SELECTED_LABEL_INDEX = k
        else
            v.label:SetText(v.label:GetUserData("orig_text")..k)
        end
    end
end

function fill_search_data_table(self)
    self.db.char.searchDataTable = {}
    local db_search = self.db.char.searchDataTable
    local disabled = "  Disabled: "
    local enabled = "  Enabled: "

    if self.db.char.searchDataWhatIndex["addons"] then
        for i=1, GetNumAddOns() do 
            name, title, notes, enabled = GetAddOnInfo(i)
            if notes == nil then
                notes = ''
            end 
            if enabled and IsAddOnLoaded(i) then
                local slash_cmd = '/'..name:lower()
                -- only add if slash command exists
                if slash_cmd_exists(slash_cmd) then
                    db_search[name] = {slash_cmd="/"..slash_cmd, is_slash=true, tooltipText=name.."\n"..title.."\n"..notes}
                else
                    -- no slash command exists, let's see if we can find something in _G['SLASH_...']
                    for k, v in pairs(_G) do
                        if k:find('SLASH_') then
                            if k:lower():find(name:lower()) then
                                db_search[name] = {slash_cmd="/"..v, is_slash=true, tooltipText=name.."\n"..title.."\n"..notes}
                            end
                        end
                    end
                end
            end 
        end
        enabled = enabled.."addons "
    else
        disabled = disabled.."addons "
    end

    -- add macros
    if self.db.char.searchDataWhatIndex["macros"] then
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
                db_search[icon_macro_name] = {slash_cmd="/cast "..name, is_macro=true, tooltipText=body}
            end
        end
        enabled = enabled.."macros "
    else
        disabled = disabled.."macros "
    end

    -- add spells
    if self.db.char.searchDataWhatIndex["spells"] then
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
        enabled = enabled.."spells "
    else
        disabled = disabled.."spells "
    end

    -- manually adding some slashcommmands
    db_search['Reload UI'] = {slash_cmd='/reload', is_slash=true}
    db_search['Logout'] = {slash_cmd='/logout', is_slash=true}
    db_search['kl update'] = {slash_cmd='/kl update', is_slash=true}
    db_search['kl show'] = {slash_cmd='/kl show', is_slash=true}
    db_search['kl clear'] = {slash_cmd='/kl clear', is_slash=true}
    db_search['Dismount'] = {slash_cmd='/dismount', is_slash=true}

    -- items
    if self.db.char.searchDataWhatIndex["items"] then
        for bag=0, NUM_BAG_SLOTS do
            for bagSlots=1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, bagSlots)
                if itemLink then
                    itemString, itemName = item_link_to_string(itemLink)
                    if IsUsableItem(itemName) then
                        icon_item_name = "|T"..GetItemIcon(itemName)..":16|t "..itemName
                        db_search[icon_item_name] = {slash_cmd="/use "..itemName, is_item=true, tooltipItemString=itemString}
                    end
                end
            end
        end
        enabled = enabled.."items "
    else
        disabled = disabled.."items "
    end

    -- add mounts
    if self.db.char.searchDataWhatIndex["mounts"] then
        for i=1, C_MountJournal.GetNumDisplayedMounts() do
            creatureName, spellID, icon = C_MountJournal.GetDisplayedMountInfo(i)
            spellString, spellname = item_link_to_string(GetSpellLink(spellID))
            icon_item_name = "|T"..icon..":16|t "..creatureName
            db_search[icon_item_name] = {slash_cmd="/cast "..creatureName, is_item=true, tooltipItemString=spellString}
        end
        enabled = enabled.."mounts "
    else
        disabled = disabled.."mounts "
    end
    
    self:Print("Search database rebuild done.")
    self:Print(enabled)
    self:Print(disabled)
end
