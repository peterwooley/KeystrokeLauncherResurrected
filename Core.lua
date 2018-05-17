KeystrokeLauncher = LibStub("AceAddon-3.0"):NewAddon("KeystrokeLauncher", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncher")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function KeystrokeLauncher:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("KeystrokeLauncherDB")
    if self.db.char.keybindingModifiers == nil then
        self.db.char.keybindingModifiers = {["alt"] = true, ["ctrl"] = true} -- default keybinding
    end
    if self.db.char.searchDataFreq == nil then
        self.db.char.searchDataFreq = {}
    end
    if self.db.char.searchDataWhatIndex == nil then
        self.db.char.searchDataWhatIndex = {["spells"] = true, ["items"] = true}
    end
    print(dump(self.db.char.searchDataWhatIndex))
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
            -- enable = {
            --     name = L["config_enable_name"],
            --     desc = L["config_enable_desc"],
            --     type = "toggle",
            --     set = function(info, val) KeystrokeLauncher.enabled = val end,
            --     get = function(info) return KeystrokeLauncher.enabled end
            -- },
            hide = {
                order = 1,
                name = L["config_hide_name"],
                desc = L["config_hide_desc"],
                type = "execute",
                func = function() AceConfigDialog:Close("KeystrokeLauncher") end,
            },
            show = {
                order = 2,
                name = L["config_show_name"],
                desc = L["config_show_desc"],
                type = "execute",
                func = function() AceConfigDialog:Open("KeystrokeLauncher") end,
                guiHidden = true
            },
            reset = {
                order = 3,
                name = "Reset all",
                desc = "Do a factory reset",
                type = "execute",
                confirm = true,
                confirmText = "This resets every Kestroke Launcher database to default values - proceed?",
                func = function()
                    for k,v in pairs(self.db.char) do
                        self.db.char[k] = nil
                    end
                    ReloadUI()
                end
            },
            keybindings = {
                order = 4,
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
            search_table = {
                order = 5,
                name = "Search Data Table",
                type = "group",
                args = {
                    header_one = {
                        type = "header",
                        name = "The search data table is the main search index.",
                        order = 1
                    },
                    print = {
                        name = "print",
                        type = "execute",
                        func = function() print_search_data_table(self) end,
                        order = 2
                    },
                    rebuild = {
                        name = "rebuild",
                        type = "execute",
                        func = function() fill_search_data_table(self) end,
                        order = 3
                    },
                    header_two = {
                        type = "header",
                        name = "Configure what to index",
                        order = 4
                    },
                    desc = {
                        type = "description",
                        name = "Don't forget to hit the rebuild button after enabling/ disabling a module.\n\nNote: enabling the addons module will lead to a small lag evertime the database is refreshed (default: once per login).",
                        order = 5
                    },
                    index = {
                        name = "Select to enable",
                        type = "multiselect",
                        values = {
                            items = "items",
                            addons = "addons",
                            macros = "macros",
                            spells = "spells",
                            mounts = "mounts"
                        },
                        set = function(info, key, state) self.db.char.searchDataWhatIndex[key] = state end,
                        get = function(info, key) return self.db.char.searchDataWhatIndex[key] end,
                        order = 6
                    }
                }
            },
            search_freq = {
                order = 6,
                name = "Search Frequency Table",
                type = "group",
                args = {
                    description = {
                        type = "header",
                        name = "The search frequency table stores how often you exectued what.",
                        order = 1
                    },
                    clear = {
                        name = "clear",
                        desc= "Empty the search freq table",
                        type = "execute",
                        func = function() 
                            self.db.char.searchDataFreq = {} 
                            self:Print("Search frequency table cleared.")
                        end
                    },
                    print = {
                        name = "print",
                        type = "execute",
                        func = function() print_search_data_freq(self) end
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
    KeyboardListenerFrame:SetScript("OnKeyDown", function(widget, keyboard_key)
        if check_key_bindings(self, keyboard_key) then
            show_main_frame(self)
            show_results(self)
        end
    end)
end

function check_key_bindings(self, keyboard_key)
    -- collect currently pressed buttons
    local pressedButtons = {}
    if not table.contains({"LALT", "LCTRL", "LSHIFT", "RALT", "RCTRL", "RSHIFT"}, keyboard_key) then
        pressedButtons[keyboard_key] = ''
    end
    if IsControlKeyDown() then pressedButtons["ctrl"] = '' end
    if IsAltKeyDown() then pressedButtons["alt"] = '' end
    if IsShiftKeyDown() then pressedButtons["shift"] = '' end
    
    -- format configured keybindings
    local mergedKeybindings = {}
    if not is_nil_or_empty(self.db.char.keybindingKey) then
        mergedKeybindings[self.db.char.keybindingKey] = ''
    end
    for k, v in pairs(self.db.char.keybindingModifiers) do
        if v then
            mergedKeybindings[k] = ''
        end
    end

    --self:Print("Key:", keyboard_key)
    --self:Print("Pressed:", dump(pressedButtons))
    --self:Print("Merged:", dump(mergedKeybindings))

    -- compare both tables for exakt equality
    if table.length(pressedButtons) == table.length(mergedKeybindings) then
        local showWindow = true
        for k, v in pairs(mergedKeybindings) do
            if not pressedButtons[k] then
                showWindow = false
            end
        end
        return showWindow
    end
    return false
end

function show_main_frame(self)
    KL_MAIN_FRAME = AceGUI:Create("Frame")
    KL_MAIN_FRAME:SetTitle("Keystroke Launcher")
    KL_MAIN_FRAME:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    KL_MAIN_FRAME:SetCallback("OnRelease", function(widget) 
        C_Timer.After(0.1, function() 
            self:Print("Keybinding cleared")
            ClearOverrideBindings(KeyboardListenerFrame) 
        end)
    end)
    KL_MAIN_FRAME:SetLayout("Flow")
    KL_MAIN_FRAME:SetWidth(400)
    KL_MAIN_FRAME:SetHeight(300)
    KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(false)

    -- search edit box
    SEARCH_EDITBOX = AceGUI:Create("EditBox")
    SEARCH_EDITBOX:SetFullWidth(true)
    SEARCH_EDITBOX:SetFocus()
    SEARCH_EDITBOX:DisableButton(true)
    SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(false)
    SEARCH_EDITBOX.editbox:SetScript("OnKeyDown", function(widget, keyboard_key)
        if keyboard_key == 'ENTER' then
            execute_macro(self)
        else
            move_selector(self, keyboard_key) 
        end
    end)
    --SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(key=='ENTER')
    SEARCH_EDITBOX.editbox:SetScript("OnEscapePressed", function(self) KL_MAIN_FRAME:Release() end)
    SEARCH_EDITBOX:SetCallback("OnTextChanged", function(widget, arg2, value) show_results(self, value) end)
    KL_MAIN_FRAME:AddChild(SEARCH_EDITBOX)

    -- SCROLL container/ group
    SCROLLCONTAINER = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    SCROLLCONTAINER:SetFullWidth(true)
    SCROLLCONTAINER:SetFullHeight(true)
    SCROLLCONTAINER:SetLayout("Fill")
    SCROLLCONTAINER.frame:SetPropagateKeyboardInput(false)
    SCROLLCONTAINER.frame:SetScript("OnKeyDown", function(widget, keyboard_key)
        if keyboard_key == 'ENTER' then
            execute_macro(self)
        else
            move_selector(self, keyboard_key) 
        end
    end)
    KL_MAIN_FRAME:AddChild(SCROLLCONTAINER)

    -- SCROLL frame
    SCROLL = AceGUI:Create("ScrollFrame")
    SCROLL:SetLayout("Flow")
    SCROLLCONTAINER:AddChild(SCROLL)

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
        -- only increase by one, if it is not a different key
        if self.db.char.searchDataFreq[current_search].key == CURRENTLY_SELECTED_LABEL_KEY then
            freq = self.db.char.searchDataFreq[current_search].freq + 1
        end
    end
    self.db.char.searchDataFreq[current_search] = { key=CURRENTLY_SELECTED_LABEL_KEY, freq=freq}
    self:Print(dump(self.db.char.searchDataFreq))
    -- propagate and close
    SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(true)
    KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(true)
    SCROLLCONTAINER.frame:SetPropagateKeyboardInput(true)
    KL_MAIN_FRAME:Hide()
end

function get_freq(self, key)
    for k,v in pairs(self.db.char.searchDataFreq) do
        if v.key == key then
            return v.freq
        end
    end
    return 0
end

function print_search_data_freq(self)
    self:Print("Content of search freq table:")
    for k,v in pairs(self.db.char.searchDataFreq) do
        self:Print('  '..v.freq, v.key)
    end
end

function print_search_data_table(self)
    self:Print("Content of search data table:")
    local search_data_table_sorted = sort_search_data_table(self)
    for k,v in ipairs(search_data_table_sorted) do
        self:Print('  '..v[1])
    end
end

function sort_search_data_table(self)
    local search_data_table_sorted = {}
    for k, v in pairs(self.db.char.searchDataTable) do
        table.insert(search_data_table_sorted, {k, get_freq(self, k)})
    end
    table.sort(search_data_table_sorted, function(a,b) 
        return a[2] > b[2]
    end)
    return search_data_table_sorted
end

function show_results(self, filter)
    if filter == nil then
        filter = '' -- :find cant handle nil
    end
    SEARCH_TABLE_TO_LABEL = {}
    SCROLL:ReleaseChildren() -- clear all and start from fresh

    -- sort data by combinng two tables
    local search_data_table_sorted = sort_search_data_table(self)

    local counter = 0
    for k,v in ipairs(search_data_table_sorted) do
        local key = v[1]
        if key:lower():find(filter) then
            local slash_cmd = self.db.char.searchDataTable[key].slash_cmd
            local label = AceGUI:Create("InteractiveLabel")
            label:SetText(key)
            label:SetWidth(200)
            label:SetUserData("orig_text", key)
            label:SetCallback("OnClick", function() 
                -- cant propagate mouse clicks, so need to press enter after selecting
                select_label(self, key)
                --edit_master_marco(self, slash_cmd)
            end)
            SCROLL:AddChild(label)
            table.insert(SEARCH_TABLE_TO_LABEL, {key=key, label=label})
            -- the first entry is always the one we want to execute per default
            if counter == 0 then
                --edit_master_marco(self, slash_cmd)
                select_label(self, key)
            end
            counter = counter + 1
        end
    end
end

function move_selector(self, keyboard_key)
    -- but only down and up to the min and max boundaries
    if keyboard_key == "UP" and CURRENTLY_SELECTED_LABEL_INDEX > 1 then
        select_label(self, nil, CURRENTLY_SELECTED_LABEL_INDEX-1)
    elseif keyboard_key == "DOWN" and CURRENTLY_SELECTED_LABEL_INDEX < #SEARCH_TABLE_TO_LABEL then
        select_label(self, nil, CURRENTLY_SELECTED_LABEL_INDEX+1)
    end
end

function select_label(self, key, index)
    for k, v in pairs(SEARCH_TABLE_TO_LABEL) do
        -- differnt if logic depening on call with key or index
        local go = false
        if index then
            go = index == k
        elseif key then
            go = v.key == key
        end
        if go then
            --v.label:SetText(v.label:GetUserData("orig_text") ..' (sel)'..k)
            v.label:SetColor(255, 0, 0, 1)
            CURRENTLY_SELECTED_LABEL_INDEX = k
            CURRENTLY_SELECTED_LABEL_KEY = v.key
            edit_master_marco(self, v.key)
        else
            --v.label:SetText(v.label:GetUserData("orig_text")..k)
            v.label:SetColor(255, 255, 255, 1)
        end
    end
end

function edit_master_marco(self, key, keyboard_key)
    macroId = get_or_create_maco('kl-master')
    if not keyboard_key then
        keyboard_key = 'ENTER'
    end
    local body = self.db.char.searchDataTable[key].slash_cmd
    EditMacro(macroId, nil, nil, body, 1, 1); 
    SetOverrideBindingMacro(KeyboardListenerFrame, true, keyboard_key, macroId)
    KL_MAIN_FRAME:SetStatusText(body)
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
