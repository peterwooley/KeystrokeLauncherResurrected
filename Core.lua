KeystrokeLauncher = LibStub("AceAddon-3.0"):NewAddon("KeystrokeLauncher", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncher")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- CONSTANTS
local SearchIndexType = Enumm {
    ADDON = { icon = 'blau'},
    MACRO = { icon = 'dunkel_grün'},
    SPELL = { icon = 'dunkel_lila'},
    CMD = { icon = 'gelb'},
    ITEM = { icon = 'hell_grün'},
    MOUNT = { icon = 'khaki'},
    EQUIP_SET = { icon = 'türkis'},
    BLIZZ_FRAME = { icon = 'schokolade'}
}

local ICON_BASE_PATH = 'Interface\\AddOns\\keystrokelauncher\\Icons\\'

function KeystrokeLauncher:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("KeystrokeLauncherDB")
    if self.db.char.keybindingModifiers == nil then
        self.db.char.keybindingModifiers = {["alt"] = true, ["ctrl"] = true} -- default keybinding
    end
    if self.db.char.searchDataFreq == nil then
        self.db.char.searchDataFreq = {}
    end
    if self.db.char.searchDataWhatIndex == nil then
        self.db.char.searchDataWhatIndex = {
            [SearchIndexType.SPELL] = true, 
            [SearchIndexType.ITEM] = true,
            [SearchIndexType.EQUIP_SET] = true,
            [SearchIndexType.BLIZZ_FRAME] = true,
            [SearchIndexType.CMD] = true
        }
    end
    if self.db.char.kl == nil then
        self.db.char.kl = {}
        self.db.char.kl['debug'] = false
        self.db.char.kl['show_tooltips'] = true
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
        name = "Keystroke Launcher",
        handler = KeystrokeLauncher,
        type = "group",
        args = {
            hide = {
                order = 1,
                name = L["config_hide_name"],
                desc = L["config_hide_desc"],
                type = "execute",
                func = function() AceConfigDialog:Close("KeystrokeLauncherOptions") end,
                guiHidden = true
            },
            show = {
                order = 2,
                name = L["config_show_name"],
                desc = L["config_show_desc"],
                type = "execute",
                func = function() AceConfigDialog:Open("KeystrokeLauncherOptions") end,
                guiHidden = true
            },
            look_n_feel = {
                order = 10,
                name = "Look & Feel",
                type = "group",
                args = {
                    show_tooltip = {
                        name = "Show Tooltip",
                        desc = "Enables / disables the tooltips",
                        type = "toggle",
                        set = function(info, val) self.db.char.kl['show_tooltips'] = val end,
                        get = function(info) return self.db.char.kl['show_tooltips'] end
                    },
                }
            },
            keybindings = {
                order = 20,
                name = L["config_keybinding"],
                type = "group",
                args = {
                    desc = {
                        name = L["config_group_keybindungs_desc"],
                        type = "header"
                    },
                    keybinding = {
                        name = L["config_keybinding"],
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
                order = 30,
                name = L["config_search_table_name"],
                type = "group",
                args = {
                    header_one = {
                        order = 1,
                        name = L["config_search_table_header_one"],
                        type = "header"
                    },
                    print = {
                        order = 2,
                        name = L["config_print"],
                        type = "execute",
                        func = function() print_search_data_table(self) end
                    },
                    rebuild = {
                        order = 3,
                        name = L["config_search_table_rebuild"],
                        type = "execute",
                        func = function() fill_search_data_table(self) end
                    },
                    header_two = {
                        order = 4,
                        name = L["config_search_table_header_two"],
                        type = "header"
                    },
                    desc = {
                        order = 5,
                        name = L["config_search_table_desc"],
                        type = "description"
                    },
                    index = {
                        order = 6,
                        name = L["config_search_table_index"],
                        type = "multiselect",
                        values = function()
                            rv = {}
                            for k,v in pairs(SearchIndexType) do
                                for k1,v1 in pairs(v) do
                                    rv[k1] = L['CONFIG_INDEX_TYPES_'..k1]
                                end
                            end
                            return rv
                        end,
                        set = function(info, key, state) self.db.char.searchDataWhatIndex[key] = state end,
                        get = function(info, key) return self.db.char.searchDataWhatIndex[key] end,
                    }
                }
            },
            search_freq = {
                order = 40,
                name = L["config_search_freq_table_name"],
                type = "group",
                args = {
                    description = {
                        order = 1,
                        name = L["config_search_freq_table_desc"],
                        type = "header"
                    },
                    clear = {
                        name = L["config_search_freq_table_clear_name"],
                        desc= L["config_search_freq_table_clear_desc"],
                        type = "execute",
                        func = function() 
                            self.db.char.searchDataFreq = {} 
                            self:Print(L["config_search_freq_table_cleared"])
                        end
                    },
                    print = {
                        name = L["config_print"],
                        type = "execute",
                        func = function() print_search_data_freq(self) end
                    }
                }
            },
            advanced = {
                order = 50,
                name = "Advanced Settings",
                type = "group",
                args = {
                    reset = {
                        name = L["config_reset_name"],
                        desc = L["config_reset_desc"],
                        type = "execute",
                        confirm = true,
                        confirmText = L["config_reset_confirmText"],
                        func = function()
                            for k,v in pairs(self.db.char) do
                                self.db.char[k] = nil
                            end
                            ReloadUI()
                        end
                    },
                    mem = {
                        name = "Print memory usage to console",
                        type = "execute",
                        func = function() self:Print(get_mem_usage()) end
                    },
                    debug = {
                        name = "Debug",
                        desc = "Enables / disables debug mode",
                        type = "toggle",
                        set = function(info, val) self.db.char.kl['debug'] = val end,
                        get = function(info) return self.db.char.kl['debug'] end
                    },
                }
            }
        }
    }
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) -- enable profiles
    LibStub("AceConfig-3.0"):RegisterOptionsTable("KeystrokeLauncherOptions", options, {"kl", "keystrokelauncher"})
    AceConfigDialog:AddToBlizOptions("KeystrokeLauncherOptions", "Keystroke Launcher")

    --[=====[ GLOBAL KEYBOARD LISTENER --]=====]
    KeyboardListenerFrame = CreateFrame("Frame", "KeyboardListener", UIParent);
    --KeyboardListenerFrame:EnableKeyboard(true)
    KeyboardListenerFrame:SetPropagateKeyboardInput(true)
    KeyboardListenerFrame:SetScript("OnKeyDown", function(widget, keyboard_key)
        print("--> ", keyboard_key)
        if check_key_bindings(self, keyboard_key) then
            show_main_frame(self)
            show_results(self)
            --CURRENTLY_PRESSED_KEY = keyboard_key
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

function dprint(...)
    local arg={...}
    self = arg[1]
    -- print(dump(arg))
    -- print(n)
    if self.db.char.kl['debug'] then
        printResult = ''
        for i,v in ipairs(arg) do
            if i > 1 then
                -- print(i, v)
                printResult = printResult..v
            end
        end
        self:Print("DEBUG", printResult)
    end
end

function show_main_frame(self)
    --[=====[ KL_MAIN_FRAME --]=====]
    KL_MAIN_FRAME = AceGUI:Create("Frame")
    KL_MAIN_FRAME:SetTitle("Keystroke Launcher")
    KL_MAIN_FRAME:SetCallback("OnClose", function(widget) 
        C_Timer.After(0.2, function() 
            dprint(self, "Keybinding cleared")
            ClearOverrideBindings(KeyboardListenerFrame) 
        end)
        AceGUI:Release(widget) 
        dprint(self, "KL_MAIN_FRAME OnClose: Releasing")
    end)
    -- KL_MAIN_FRAME:SetCallback("OnRelease", function(widget) 
    -- end)
    KL_MAIN_FRAME:SetLayout("Flow")
    KL_MAIN_FRAME:SetWidth(400)
    KL_MAIN_FRAME:SetHeight(300)
    --KL_MAIN_FRAME.frame:EnableKeyboard(true)
    KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(false)
    KL_MAIN_FRAME.frame:SetScript("OnKeyDown", function(widget, keyboard_key)
        print("KL_MAIN_FRAME OnKeyDown")
        SEARCH_EDITBOX:SetFocus()
        if keyboard_key == 'ENTER' then
            execute_macro(self)
        -- elseif keyboard_key == 'ESCAPE' then
        --     hide_all()
        elseif keyboard_key == 'UP' or keyboard_key == 'DOWN' then
            move_selector(self, keyboard_key) 
        end
    end)

    --[=====[ SEARCH_EDITBOX --]=====]
    SEARCH_EDITBOX = AceGUI:Create("EditBox")
    SEARCH_EDITBOX:SetFullWidth(true)
    SEARCH_EDITBOX:SetFocus()
    SEARCH_EDITBOX:DisableButton(true)
    --SEARCH_EDITBOX.editbox:EnableKeyboard(true)
    SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(true)
    -- SEARCH_EDITBOX.editbox:SetScript("OnKeyDown", function(widget, keyboard_key)
    --     print("SEARCH_EDITBOX OnKeyDown")
    --     if keyboard_key == 'ENTER' then
    --         execute_macro(self)
    --     elseif keyboard_key == 'UP' or keyboard_key == 'DOWN' then
    --         move_selector(self, keyboard_key) 
    --     end
    -- end)
    --SEARCH_EDITBOX.editbox:SetScript("OnEscapePressed", function(self) hide_all() end)
    SEARCH_EDITBOX:SetCallback("OnTextChanged", function(widget, arg2, value) show_results(self, value) end)
    KL_MAIN_FRAME:AddChild(SEARCH_EDITBOX)

    --[=====[ SCROLLCONTAINER --]=====]
    SCROLLCONTAINER = AceGUI:Create("SimpleGroup")
    SCROLLCONTAINER:SetFullWidth(true)
    SCROLLCONTAINER:SetFullHeight(true)
    SCROLLCONTAINER:SetLayout("Fill")
    SCROLLCONTAINER.frame:SetPropagateKeyboardInput(true)
    -- print(SCROLLCONTAINER.frame:GetScript("OnKeyDown"))
    -- if SCROLLCONTAINER.frame:GetScript("OnKeyDown") == nil then
    --     SCROLLCONTAINER.frame:SetScript("OnKeyDown", function(widget, keyboard_key)
    --         print("SCROLLCONTAINER OnKeyDown")
    --         --print(debugstack())
    --         SEARCH_EDITBOX:SetFocus()
    --         if keyboard_key == 'ENTER' then
    --             execute_macro(self)
    --         elseif keyboard_key == 'ESCAPE' then
    --             hide_all()
    --         elseif keyboard_key == 'UP' or keyboard_key == 'DOWN' then
    --             move_selector(self, keyboard_key) 
    --         end
    --     end)
    -- end
    KL_MAIN_FRAME:AddChild(SCROLLCONTAINER)

    --[=====[ SCROLL --]=====]
    SCROLL = AceGUI:Create("ScrollFrame")
    SCROLL:SetLayout("Flow")
    SCROLLCONTAINER:AddChild(SCROLL)

    EXECUTED = false
    KL_MAIN_FRAME:Show()
    dprint(self, '---------')
end 

-- execute_macro means effectively propagate then close the main window
function execute_macro(self)
    -- due to the key beeing propagated, this method is executed twice sometimes
    -- if not EXECUTED then
    --SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(true)
    KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(true)
    --SCROLLCONTAINER.frame:SetPropagateKeyboardInput(true)
    
    -- save freq
    local current_search = SEARCH_EDITBOX:GetText()
    if is_nil_or_empty(current_search) then
        current_search = 'EMPTY'
    end
    local freq = 1
    local current_search_freq = self.db.char.searchDataFreq[current_search]
    if current_search_freq then
        -- only increase by one, if it is not a different key
        if current_search_freq.key == CURRENTLY_SELECTED_LABEL_KEY then
            freq = current_search_freq.freq + 1
        end
    end
    self.db.char.searchDataFreq[current_search] = { key=CURRENTLY_SELECTED_LABEL_KEY, freq=freq}
    -- propagate and close
    hide_all()
    dprint(self, "execute_macro "..CURRENTLY_SELECTED_LABEL_KEY..", "..get_mem_usage())
    -- EXECUTED = true
    -- end
end

function hide_all()
    KL_MAIN_FRAME:Hide()
    GameTooltip:Hide()
end


function print_search_data_freq(self)
    self:Print(L["PRINT_SEARCH_DATA_FREQ"])
    for k,v in pairs(self.db.char.searchDataFreq) do
        self:Print('', el(k, 8), el(v.freq, 3), v.key)
    end
end

function el(text, target_len)
    text = tostring(text)
    rv = ''
    repeat
        rv = rv..' '
    until (rv:len() + text:len()) == target_len
    return text..rv
end

function print_search_data_table(self)
    self:Print(L["PRINT_SEARCH_DATA_TABLE"])
    local search_data_table_sorted = sort_search_data_table(self)
    for k,v in ipairs(search_data_table_sorted) do
        self:Print('', v[1])
    end
end

function get_freq(self, key, current_filter)
    -- when there's an entry for current_filter, that always comes on top
    local db_entry = self.db.char.searchDataFreq[current_filter]
    if db_entry then
        if db_entry.key == key then
            return 1000 + db_entry.freq
        end
    end
    -- else sum up how often key was executed, 0 is default
    freq = 0
    for filter, v in pairs(self.db.char.searchDataFreq) do
        if v.key == key then
            freq = freq + v.freq
        end
    end
    return freq
end

function sort_search_data_table(self, filter)
    local search_data_table_sorted = {}
    for key, v in pairs(self.db.char.searchDataTable) do
        freq = get_freq(self, key, filter)
        table.insert(search_data_table_sorted, {key, freq})
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
    local search_data_table_sorted = sort_search_data_table(self, filter)

    local counter = 0
    for k,v in ipairs(search_data_table_sorted) do
        local key = v[1]
        if key:lower():find(filter) then
            local frame = AceGUI:Create("SimpleGroup")
            frame:SetLayout("flow")
            frame:SetWidth(390)

            -- spell/ macro/ etc
            key_data = self.db.char.searchDataTable[key]
            local label = AceGUI:Create("InteractiveLabel")
            if self.db.char.kl['debug'] then
                label:SetText(key.." ("..get_freq(self, key, filter)..") (idx: "..k..")")
            else
                label:SetText(key)
            end
            if key_data.icon then
                label:SetImage(key_data.icon)
            else
                label:SetImage(ICON_BASE_PATH..'transparent.blp')
            end
            label:SetWidth(330)
            label:SetHeight(15)
            label:SetFont(GameFontNormal:GetFont(), 13)
            label:SetCallback("OnClick", function() 
                -- cant propagate mouse clicks, so need to press enter after selecting
                select_label(self, key)
            end)
            frame:AddChild(label)
            
            -- index type icon
            local icon = AceGUI:Create("Icon")
            icon:SetImage(get_icon_for_index_type(key_data.type))
            icon:SetImageSize(10, 10)
            icon:SetWidth(10)
            icon:SetHeight(10)
            frame:AddChild(icon)

            SCROLL:AddChild(frame)
            table.insert(SEARCH_TABLE_TO_LABEL, {key=key, label=label})
            -- the first entry is always the one we want to execute per default
            if counter == 0 then
                select_label(self, key)
            end
            counter = counter + 1
        end
    end
end

function get_icon_for_index_type(index_type)
    for k,v in pairs(SearchIndexType) do
        for k1,v1 in pairs(v) do
            if k1 == index_type then
                return ICON_BASE_PATH..v1.icon..".blp"
            end
        end
    end
end

function move_selector(self, keyboard_key)
    -- but only down and up to the min and max boundaries
    if keyboard_key == "UP" and CURRENTLY_SELECTED_LABEL_INDEX > 1 then
        dprint(self, "move_selector", keyboard_key, CURRENTLY_SELECTED_LABEL_INDEX)
        select_label(self, nil, CURRENTLY_SELECTED_LABEL_INDEX-1)
    elseif keyboard_key == "DOWN" and CURRENTLY_SELECTED_LABEL_INDEX < #SEARCH_TABLE_TO_LABEL then
        dprint(self, "move_selector", keyboard_key, CURRENTLY_SELECTED_LABEL_INDEX)
        select_label(self, nil, CURRENTLY_SELECTED_LABEL_INDEX+1)
    end
end

function select_label(self, key, index)
    dprint(self, "select_label", key, index)
    for k, v in pairs(SEARCH_TABLE_TO_LABEL) do
        -- differnt if logic depening on call with key or index
        local go = false
        if index then
            go = index == k
        elseif key then
            go = v.key == key
        end
        if go then
            -- currently selected entry
            v.label:SetColor(255, 0, 0, 1)
            CURRENTLY_SELECTED_LABEL_INDEX = k
            CURRENTLY_SELECTED_LABEL_KEY = v.key
            edit_master_marco(self, v.key)
            display_tooltip(self, v.key, v.label.frame)
        else
            v.label:SetColor(255, 255, 255, 1)
        end
    end
end

function display_tooltip(self, key, owner)
    if self.db.char.kl['show_tooltips'] then
        local detailed_data = self.db.char.searchDataTable[key]
        if detailed_data['tooltipItemString'] then
            GameTooltip:SetOwner(owner, nil, -10)
            GameTooltip:SetHyperlink(detailed_data['tooltipItemString'])
            GameTooltip:Show()
        elseif detailed_data['tooltipText'] then
            GameTooltip:SetOwner(owner, nil, -10)
            GameTooltip:SetText(detailed_data['tooltipText'], nil, nil, nil, nil, true)
            GameTooltip:Show()
        else
            GameTooltip:Hide()
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
    dprint(self, "edit_master_marco body="..body)
end

-- http://www.wowinterface.com/forums/showthread.php?t=9210
function get_mem_usage()
    UpdateAddOnMemoryUsage()
    mem = GetAddOnMemoryUsage("keystrokelauncher")
    return formatNumber(mem,"%.1f \124cffffd200k")
end

-- from http://www.wowinterface.com/downloads/info7362-AddonUsage.html
function formatNumber(number, pattern)
    local isBig = number>=1000
    number = string.format(pattern,number)
	if isBig then
	    local subCount
	    repeat
	        number,subCount = number:gsub("^(-?%d+)(%d%d%d)","%1,%2")
	    until subCount==0
	end
  return number
end

function fill_search_data_table(self)
    self.db.char.searchDataTable = {}
    local db_search = self.db.char.searchDataTable
    local disabled = L["INDEX_DISABLED"]
    local enabled = L["INDEX_ENABLED"]

    if self.db.char.searchDataWhatIndex[SearchIndexType.ADDON] then
        for i=1, GetNumAddOns() do 
            name, title, notes, addonenabled = GetAddOnInfo(i)
            if notes == nil then
                notes = ''
            end 
            if addonenabled and IsAddOnLoaded(i) then
                local slash_cmd = '/'..name:lower()
                -- only add if slash command exists
                if slash_cmd_exists(slash_cmd) then
                    db_search[name] = {
                        slash_cmd=slash_cmd, 
                        tooltipText=name.."\n"..title.."\n"..notes,
                         type=SearchIndexType.ADDON
                        }
                else
                    -- no slash command exists, let's see if we can find something in _G['SLASH_...']
                    for k, v in pairs(_G) do
                        if k:find('SLASH_') then
                            if k:lower():find(name:lower()) then
                                db_search[name] = {
                                    slash_cmd=v, 
                                    tooltipText=name.."\n"..title.."\n"..notes, 
                                    type=SearchIndexType.ADDON
                                }
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
    if self.db.char.searchDataWhatIndex[SearchIndexType.MACRO] then
        local numglobal, numperchar = GetNumMacros();
        for i = 1, numglobal do
            name, iconTexture, body, isLocal = GetMacroInfo(i)
            if name then
                --icon_macro_name = "|T"..iconTexture..":16|t "..name
                -- why does this destroy data?
                db_search[name] = {
                    slash_cmd="/cast"..name, 
                    icon=iconTexture, 
                    tooltipText=body, 
                    type=SearchIndexType.MACRO
                }
            end
        end
        for i = 1, numperchar do
            name, iconTexture, body, isLocal = GetMacroInfo(i + 120)
            if name then
                db_search[name] = {
                    slash_cmd="/cast "..name, 
                    icon=iconTexture, 
                    tooltipText=body, 
                    type=SearchIndexType.MACRO
                }
            end
        end
        enabled = enabled.."macros "
    else
        disabled = disabled.."macros "
    end

    -- add spells
    if self.db.char.searchDataWhatIndex[SearchIndexType.SPELL] then
        local i = 1
        while true do
            local spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
            if not spellName then
                do break end
            end
            if IsUsableSpell(spellName) then
                if not IsPassiveSpell(spellName) then
                    spellString, spellname = item_link_to_string(GetSpellLink(spellName))
                    db_search[spellName] = {
                        slash_cmd="/cast "..spellName,
                        icon = GetSpellTexture(spellName), 
                        tooltipItemString=spellString,
                        type=SearchIndexType.SPELL
                    }
                end
            end
            i = i + 1
        end
        enabled = enabled.."spells "
    else
        disabled = disabled.."spells "
    end

    -- manually adding some slashcommmands
    if self.db.char.searchDataWhatIndex[SearchIndexType.CMD] then
        db_search['Reload UI'] = {slash_cmd='/reload', tooltipText=L["DB_SEARCH_RELOAD_UI"], type=SearchIndexType.CMD}
        db_search['Logout'] = {slash_cmd='/logout', tooltipText=L["DB_SEARCH_LOGOUT"], type=SearchIndexType.CMD}
        db_search['/kl show'] = {slash_cmd='/kl show', tooltipText=L["DB_SEARCH_KL_SHOW"], type=SearchIndexType.CMD}
        db_search['/kl search_freq print'] = {slash_cmd='/kl search_freq print', tooltipText=L["DB_SEARCH_KL_FREQ_PRINT"], type=SearchIndexType.CMD}
        db_search['/kl search_table rebuild'] = {slash_cmd='/kl search_table rebuild', tooltipText=L["DB_SEARCH_KL_SEARCH_REBUILD"], type=SearchIndexType.CMD}
        db_search['Dismount'] = {slash_cmd='/dismount', tooltipText=L["DB_SEARCH_DISMOUNT"], type=SearchIndexType.CMD}
        enabled = enabled.."slash commands "
    else
        disabled = disabled.."slash commands "
    end

    -- items
    if self.db.char.searchDataWhatIndex[SearchIndexType.ITEM] then
        for bag=0, NUM_BAG_SLOTS do
            for bagSlots=1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, bagSlots)
                if itemLink then
                    itemString, itemName = item_link_to_string(itemLink)
                    if IsUsableItem(itemName) then
                        db_search[itemName] = {
                            slash_cmd="/use "..itemName, 
                            icon = GetItemIcon(itemName),
                            tooltipItemString=itemString,
                            type=SearchIndexType.ITEM
                        }
                    end
                end
            end
        end
        enabled = enabled.."items "
    else
        disabled = disabled.."items "
    end

    -- add mounts
    if self.db.char.searchDataWhatIndex[SearchIndexType.MOUNT] then
        for i=1, C_MountJournal.GetNumDisplayedMounts() do
            creatureName, spellID, icon = C_MountJournal.GetDisplayedMountInfo(i)
            spellString, spellname = item_link_to_string(GetSpellLink(spellID))
            db_search[creatureName] = {
                slash_cmd="/cast "..creatureName, 
                icon = icon,
                tooltipItemString=spellString,
                type = SearchIndexType.MOUNT
            }
        end
        enabled = enabled.."mounts "
    else
        disabled = disabled.."mounts "
    end
    
    -- add equip sets
    if self.db.char.searchDataWhatIndex[SearchIndexType.EQUIP_SET] then
        for i=0, C_EquipmentSet.GetNumEquipmentSets() do
            local name, iconFileID, setID, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(i)
            if name then
                db_search[name] = {
                    slash_cmd="/equipset "..name, 
                    icon = iconFileID,
                    tooltipText=name,
                    type = SearchIndexType.EQUIP_SET
                }
            end
        end
        enabled = enabled.."equip_sets "
    else
        disabled = disabled.."equip_sets "
    end
    
    -- add blizz frames
    if self.db.char.searchDataWhatIndex[SearchIndexType.BLIZZ_FRAME] then
        -- global strings from https://www.townlong-yak.com/framexml/live/GlobalStrings.lua/DE
        -- available functions: https://github.com/tomrus88/BlizzardInterfaceCode/blob/6922484b7b57ed6b3133ea54cdc828db94c7813d/Interface/FrameXML/UIParent.lua 
        db_search[CHARACTER_BUTTON] = {
            slash_cmd = '/run ToggleCharacter("PaperDollFrame")', 
            tooltipText = L['OPEN']..' '..CHARACTER_BUTTON, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[SPELLBOOK_BUTTON] = {
            slash_cmd = '/run ToggleSpellBook("spell")', 
            tooltipText = L['OPEN']..' '..SPELLBOOK_BUTTON, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[TALENTS_BUTTON] = {
            slash_cmd = '/run ToggleTalentFrame()', 
            tooltipText = L['OPEN']..' '..TALENTS_BUTTON, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[FRIENDS] = {
            slash_cmd = '/run ToggleFriendsFrame(1)', 
            tooltipText = L['OPEN']..' '..FRIENDS, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[QUESTLOG_BUTTON] = {
            slash_cmd = '/run ToggleQuestLog()', 
            tooltipText = L['OPEN']..' '..QUESTLOG_BUTTON, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[LOOKINGFORGUILD ] = {
            slash_cmd = '/run ToggleGuildFrame(1)', 
            tooltipText = L['OPEN']..' '..LOOKINGFORGUILD , 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[GROUP_FINDER] = {
            slash_cmd = '/run ToggleFrame(PVEFrame)', 
            tooltipText = L['OPEN']..' '..GROUP_FINDER  , 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[ADVENTURE_JOURNAL] = {
            slash_cmd = '/run ToggleEncounterJournal()', 
            tooltipText = L['OPEN']..' '..ADVENTURE_JOURNAL  , 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[HELP_BUTTON] = {
            slash_cmd = '/run ToggleHelpFrame()', 
            tooltipText = L['OPEN']..' '..HELP_BUTTON  , 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[L['CALENDAR']] = {
            slash_cmd = '/run if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end Calendar_Toggle()', 
            tooltipText = GAMETIME_TOOLTIP_TOGGLE_CALENDAR, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[ACHIEVEMENT_BUTTON] = {
            slash_cmd = '/run ToggleAchievementFrame()', 
            tooltipText = L['OPEN']..' '..ACHIEVEMENT_BUTTON, 
            type = SearchIndexType.BLIZZ_FRAME
        }
        db_search[MOUNTS] = {
            slash_cmd = '/run ToggleCollectionsJournal(1)', 
            tooltipText = L['OPEN']..' '..MOUNTS, 
            type = SearchIndexType.BLIZZ_FRAME
        }

        enabled = enabled.."blizz_frames "
    else
        disabled = disabled.."blizz_frames "
    end

    self:Print(L["INDEX_HEADER"])
    self:Print(enabled)
    self:Print(disabled)
end

function icon_item_string(type, icon, item_name)
    return "|T"..icon..":16|t "..item_name
end