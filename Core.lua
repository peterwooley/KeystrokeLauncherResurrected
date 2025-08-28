KeystrokeLauncher = LibStub("AceAddon-3.0"):NewAddon("KeystrokeLauncherResurrected", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncherResurrected")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- CONSTANTS
local SearchIndexType = Enumm {
    ADDON = { icon = 'blau'},
    MACRO = { icon = 'dunkel_grün'},
    SPELL = { icon = 'dunkel_lila'},
    CMD = { icon = 'rosa'},
    ITEM = { icon = 'hell_grün'},
    MOUNT = { icon = 'khaki'},
    EQUIP_SET = { icon = 'türkis'},
    BLIZZ_FRAME = { icon = 'schokolade'},
    CVAR = { icon = 'gelb'},
    TOY = { icon = 'khaki'} -- TODO: Change to toy icon name
}
local ICON_BASE_PATH = 'Interface\\AddOns\\KeystrokeLauncherResurrected\\Icons\\'

-- module global vars
-- frames
local KL_MAIN_FRAME
local ITEMS_GROUP
local SCROLLCONTAINER
local SEARCH_TYPE_CHECKBOXES
local SEARCH_EDITBOX
local KEYBOARD_LISTENER_FRAME
local EDIT_HEADER

-- other
local KL_MAIN_FRAME_WIDTH
local SEARCH_TABLE_INIT_DONE
local CURRENTLY_SELECTED_LABEL_INDEX
local CURRENTLY_SELECTED_LABEL_KEY
local SEARCH_TABLE_TO_LABEL
local RELOADING -- used to mark an auto reload of the gui

local PAGINATION = 1 -- stores the current visible page
local MAX_PAGES = 2 -- stores the max amount if pages, depends on the amount of results
local ONE_ITEM_HEIGHT -- after show_result is run, this contains the height of one item

-- Binding Variables
BINDING_NAME_KL_LAUNCH = "Show Keystroke Launcher";

-- let's go
function KeystrokeLauncher:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("KeystrokeLauncherResurrectedDB")

    --[=====[ INITIALIZING DB VARS AND SETTING DEFAULTS --]=====]
    if self.db.global.searchDataFreq == nil then
        self.db.global.searchDataFreq = {}
    end
    if self.db.global.customSearchData == nil then
        self.db.global.customSearchData = {}
    end
    if self.db.global.searchDataWhatIndex == nil then
        self.db.global.searchDataWhatIndex = {
            [SearchIndexType.ADDON] = false,
            [SearchIndexType.MACRO] = false,
            [SearchIndexType.SPELL] = true,
            [SearchIndexType.CMD] = true,
            [SearchIndexType.ITEM] = true,
            [SearchIndexType.MOUNT] = true,
            [SearchIndexType.EQUIP_SET] = true,
            [SearchIndexType.BLIZZ_FRAME] = true,
            [SearchIndexType.CVAR] = true,
            [SearchIndexType.TOY] = true
        }
    end
    -- searchTypeCheckboxes saves the state of the search type boxes between sessions or program runs
    if self.db.global.searchTypeCheckboxes == nil then
        self.db.global.searchTypeCheckboxes = {}
        toggle_all_search_type_checkboxes(self)
    end
    if self.db.global.kl == nil then
        self.db.global.kl = {}
        self.db.global.kl['debug'] = false
        self.db.global.kl['show_tooltips'] = true
        self.db.global.kl['show_type_marker'] = true
        self.db.global.kl['show_type_checkboxes'] = true
        self.db.global.kl['enable_quick_filter'] = false
        self.db.global.kl['show_edit_mode_checkbox'] = false
        self.db.global.kl['edit_mode_on'] = false
        self.db.global.kl['enable_top_macros'] = false
        self.db.global.kl['enable_spell_icons'] = false
    end
    if self.db.global.kl['items_per_page'] == nil then
        self.db.global.kl['items_per_page'] = 7
    end
    if self.db.global.kl['scale'] == nil then
        self.db.global.kl['scale'] = 1
    end

    --[=====[ FILL SEARCH DATA TABLE --]=====]
    if not SEARCH_TABLE_INIT_DONE then
        C_Timer.After(2, function()
            -- this delay is needed because the items in the inventory do not seem to be ready right after login
            fill_search_data_table(self)
            SEARCH_TABLE_INIT_DONE = true
        end)
    end

    --[=====[ SLASH COMMANDS/ CONFIG OPTIONS --]=====]
    local options = {
        name = "Keystroke Launcher Resurrected",
        handler = KeystrokeLauncher,
        type = "group",
        args = {
            hide = {
                order = 1,
                name = L["config_hide_name"],
                desc = L["config_hide_desc"],
                type = "execute",
                func = function() AceConfigDialog:Close("KeystrokeLauncherResurrectedOptions") end,
                guiHidden = true
            },
            show = {
                order = 2,
                name = L["config_show_name"],
                desc = L["config_show_desc"],
                type = "execute",
                func = function() AceConfigDialog:Open("KeystrokeLauncherResurrectedOptions") end,
                guiHidden = true
            },
            --[=====[ LOOK & FEEL --]=====]
            look_n_feel = {
                order = 10,
                name = "Look & Feel",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        name = L['CONFIG_LOOK_N_FEEL_HEADER'],
                        type = "header"
                    },
                    show_tooltip = {
                        order = 2,
                        name = L['CONFIG_LOOK_N_FEEL_TOOLTIP_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_TOOLTIP_DESC'],
                        type = "toggle",
                        descStyle = "inline",
                        width = 1.3,
                        set = function(_, val) self.db.global.kl['show_tooltips'] = val end,
                        get = function() return self.db.global.kl['show_tooltips'] end
                    },
                    show_type_marker = {
                        order = 3,
                        name = L['CONFIG_LOOK_N_FEEL_MARKER_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_MARKER_DESC'],
                        type = "toggle",
                        descStyle = "inline",
                        width = 1.3,
                        set = function(_, val) self.db.global.kl['show_type_marker'] = val end,
                        get = function() return self.db.global.kl['show_type_marker'] end
                    },
                    show_type_checkboxes = {
                        order = 4,
                        name = L['CONFIG_LOOK_N_FEEL_CHECKBOXES_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_CHECKBOXES_DESC'],
                        type = "toggle",
                        descStyle = "inline",
                        width = 1.3,
                        set = function(_, val)
                            self.db.global.kl['show_type_checkboxes'] = val
                            -- when the gui element is hidden, all group filters are set to true
                            -- and the quick filters are disabled
                            if not val then
                                toggle_all_search_type_checkboxes(self)
                                self.db.global.kl['enable_quick_filter'] = false
                            end
                            set_main_frame_size(self)
                        end,
                        get = function() return self.db.global.kl['show_type_checkboxes'] end
                    },
                    show_edit_mode_checkbox = {
                        order = 5,
                        name = L['CONFIG_LOOK_N_FEEL_EDIT_MODE_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_EDIT_MODE_DESC'],
                        type = "toggle",
                        descStyle = "inline",
                        width = 1.3,
                        set = function(_, val)
                            self.db.global.kl['show_edit_mode_checkbox'] = val
                            if not val then
                                self.db.global.kl['edit_mode_on'] = false
                            end
                        end,
                        get = function() return self.db.global.kl['show_edit_mode_checkbox'] end
                    },
                    show_spell_icons = {
                        order = 6,
                        name = L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_DESC'],
                        type = "toggle",
                        descStyle = "inline",
                        width = 1.3,
                        set = function(_, val) self.db.global.kl['enable_spell_icons'] = val end,
                        get = function() return self.db.global.kl['enable_spell_icons'] end
                    },
                    -- sizes
                    header_sizes = {
                        order = 7,
                        name = L['CONFIG_LOOK_N_FEEL_SIZE'],
                        type = "header"
                    },
                    max_items_per_page = {
                        order = 8,
                        name = L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_DESC'],
                        type = "range",
                        min = 1,
                        max = 99,
                        softMin = 7,
                        softMax = 14,
                        step = 1,
                        set = function(_, val) self.db.global.kl['items_per_page'] = val end,
                        get = function() return self.db.global.kl['items_per_page'] end
                    },
                    window_scale = {
                        order = 9,
                        name = L['CONFIG_LOOK_N_FEEL_SCALE_NAME'],
                        desc = L['CONFIG_LOOK_N_FEEL_SCALE_DESC'],
                        type = "range",
                        min = 1,
                        max = 2.5,
                        softMax = 1.5,
                        step = 0.1,
                        set = function(_, val) self.db.global.kl['scale'] = val end,
                        get = function() return self.db.global.kl['scale'] end
                    },
                    -- experimental look n feel switches
                    header_experimental = {
                        order = 18,
                        name = L['CONFIG_LOOK_N_FEEL_HEADER_EXPERIMENTAL'],
                        type = "header"
                    },
                    enable_quick_filter = {
                        order = 19,
                        name = L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_NAME'],
                        type = "toggle",
                        set = function(_, val)
                            self.db.global.kl['enable_quick_filter'] = val
                            if val then
                                self.db.global.kl['show_type_checkboxes'] = true
                                set_main_frame_size(self)
                            end
                        end,
                        get = function() return self.db.global.kl['enable_quick_filter'] end
                    },
                    desc_type_marker = {
                        order = 30,
                        name = L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_DESC'],
                        type = "description"
                    },
                    show_top_macros = {
                        order = 31,
                        name = L['CONFIG_LOOK_N_FEEL_TOP_MACROS_NAME'],
                        type = "toggle",
                        set = function(_, val) self.db.global.kl['enable_top_macros'] = val end,
                        get = function() return self.db.global.kl['enable_top_macros'] end
                    },
                    desc_top_macros = {
                        order = 32,
                        name = L['CONFIG_LOOK_N_FEEL_TOP_MACROS_DESC'],
                        type = "description"
                    }
                }
            },
            --[=====[ KEYBINDINGS --]=====]
            keybindings = {
                order = 20,
                name = L["config_keybinding"],
                type = "group",
                args = {
                    keybinding = {
                        name = L["config_keybinding"],
                        type = "keybinding",
                        set = function(_, val)
                            -- we only want one key to be ever bound to this
                            local key1, key2 = GetBindingKey("KL_LAUNCH") -- so first we get both keys associated to thsi addon (in case there are)
                            -- then we delete their binding from this addon (we clear every binding from this addon)
                            if key1 then SetBinding(key1) end
                            if key2 then SetBinding(key2) end

                            -- and finally we set the new binding key
                            if (val ~= '') then -- considering we pressed one (not ESC)
                                SetBinding(val, "KL_LAUNCH"); 
                            end
                            SaveBindings(GetCurrentBindingSet())
                        end,
                        get = function() return GetBindingKey("KL_LAUNCH"); end
                    }
                }
            },
            --[=====[ SEARCH TABLE --]=====]
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
                        values = function() return enumm_to_table(SearchIndexType) end,
                        set = function(_, key, state)
                            self.db.global.searchDataWhatIndex[key] = state
                            set_main_frame_size(self)
                        end,
                        get = function(_, key)
                            return self.db.global.searchDataWhatIndex[key]
                        end,
                    },
                    header_custom_data = {
                        order = 7,
                        name = L['CONFIG_SEARCH_TABLE_CUSTOM_HEADER'],
                        type = "header"
                    },
                    clear_custom_data = {
                        order = 8,
                        name = L['CLEAR'],
                        type = "execute",
                        func = function() self.db.global.customSearchData = {} end
                    },
                    print_custom_data = {
                        order = 9,
                        name = L["PRINT"],
                        type = "execute",
                        func = function() print_custom_search_db(self) end
                    }
                }
            },
            --[=====[ SEARCH FREQUENCY TABLE --]=====]
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
                        name = L["CLEAR"],
                        type = "execute",
                        func = function()
                            self.db.global.searchDataFreq = {}
                            self:Print(L["config_search_freq_table_cleared"])
                        end
                    },
                    print = {
                        name = L["PRINT"],
                        type = "execute",
                        func = function() print_search_data_freq(self) end
                    }
                }
            },
            --[=====[ ADVANCED --]=====]
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
                            for k,_ in pairs(self.db.global) do
                                self.db.global[k] = nil
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
                        set = function(_, val) self.db.global.kl['debug'] = val end,
                        get = function() return self.db.global.kl['debug'] end
                    },
                }
            }
        }
    }
    LibStub("AceConfig-3.0"):RegisterOptionsTable("KeystrokeLauncherResurrectedOptions", options, {"kl", "keystrokelauncher"})
    AceConfigDialog:AddToBlizOptions("KeystrokeLauncherResurrectedOptions", "Keystroke Launcher Resurrected")

    --[=====[ GLOBAL KEYBOARD LISTENER --]=====]
    KEYBOARD_LISTENER_FRAME = CreateFrame("Frame", "KeyboardListener", UIParent);

    KEYBOARD_LISTENER_FRAME:RegisterEvent("PLAYER_LOGIN")
    KEYBOARD_LISTENER_FRAME:RegisterEvent("NEW_MOUNT_ADDED")
    KEYBOARD_LISTENER_FRAME:SetScript("OnEvent", function(_, event, ...)
        if(event == "PLAYER_LOGIN") then
            -- Set default key binding if no keys are currently bound
            local key1, key2 = GetBindingKey("KL_LAUNCH")
            if key1 == nil and key2 == nil then

                if self.db.global.keybindingModifiers == nil then
                    -- If the old keybindings are nil, set the new default keybinding
                    SetBinding("CTRL-SHIFT-P", "KL_LAUNCH");
                else
                    -- If old keybindings are present, use them as the new keybinding and then delete the old keybinds
                    --self.db.global.keybindingModifiers = {["alt"] = true, ["ctrl"] = true} -- default keybinding
                    local keybindings_list = {}
                    for k,_ in pairs(merge_keybindings(self)) do
                        table.insert(keybindings_list, k)
                    end

                    local oldKeybinding = string.upper(table.concat(keybindings_list, '-'))
                    SetBinding(oldKeybinding, "KL_LAUNCH");

                    -- Delete the old keyboard modifier after upgrading to the new system
                    self.db.global.keybindingModifiers = nil
                end

                SaveBindings(GetCurrentBindingSet())
            end

        elseif (event == "NEW_MOUNT_ADDED") then
            local mountID = ...
            add_mount(self, mountID)
        end
    end)
end

function merge_keybindings(self)
    local mergedKeybindings = {}
    if not is_nil_or_empty(self.db.global.keybindingKey) then
        mergedKeybindings[self.db.global.keybindingKey] = ''
    end
    for k, v in pairs(self.db.global.keybindingModifiers) do
        if v then
            mergedKeybindings[k] = ''
        end
    end
    return mergedKeybindings
end

-- programmatically re-render the main frame
function reload_main_frame(self)
    RELOADING = true
    local curr_filter = SEARCH_EDITBOX:GetText()
    hide_all()
    RELOADING = false
    start(self, curr_filter)
end

-- window start up logic
function start(self, filter)

    -- Ignore startup if in an ignorable state (Dragonriding, etc.)
    if IsFlying() and IsAdvancedFlyableArea() then
        dprint(self, "Ignorning KL Hotkey as you're Dragonriding.")

        -- If the KL UI is still open, hide it to ensure it doesn't get stuck open
        hide_all()
        return false
    end

    set_main_frame_size(self)
    show_main_frame(self)
    SEARCH_EDITBOX:SetText(filter)
    show_results(self, filter)
end
function KeystrokeLauncher:Start()
    start(self)
end

function dprint(...)
    local arg={...}
    local obj = arg[1]
    if obj.db.global.kl['debug'] then
        local printResult = ''
        for i,v in ipairs(arg) do
            if i > 1 then
                printResult = printResult..v
            end
        end
        obj:Print("DEBUG", printResult)
    end
end

function show_main_frame(self)
    heights = 0
    --[=====[ KL_MAIN_FRAME --]=====]
    KL_MAIN_FRAME = AceGUI:Create("KeystrokeLauncherWindow")
    KL_MAIN_FRAME:SetCallback("OnClose", function(widget)
        if not RELOADING then
            -- do not clear keybinding if we are just regenerating the ui
            C_Timer.After(0.2, function()
                ClearOverrideBindings(KEYBOARD_LISTENER_FRAME)
            end)
        end
        AceGUI:Release(widget)
        update_top_macros(self)
        if self.db.global.kl['debug'] then
            self:Print(get_mem_usage())
        end
    end)

    KL_MAIN_FRAME:SetLayout("Flow")
    KL_MAIN_FRAME:SetWidth(KL_MAIN_FRAME_WIDTH)
    KL_MAIN_FRAME.frame:SetScale(self.db.global.kl['scale'])
    KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(false)
    KL_MAIN_FRAME.frame:SetScript("OnKeyDown", function(widget, keyboard_key)
        SEARCH_EDITBOX:SetFocus()
        if keyboard_key == 'ENTER' then
            execute_macro(self)
        elseif keyboard_key == 'UP' or keyboard_key == 'DOWN' then
            move_selector(self, keyboard_key)
        end
    end)

    --[=====[ SEARCH_EDITBOX --]=====]
    SEARCH_EDITBOX = AceGUI:Create("EditBox")
    set_search_frame_size(self)
    SEARCH_EDITBOX:SetFocus()
    SEARCH_EDITBOX:DisableButton(true)
    SEARCH_EDITBOX.editbox:SetPropagateKeyboardInput(true)
    SEARCH_EDITBOX.editbox:SetFontObject("GameFontNormalLarge")
    SEARCH_EDITBOX.editbox:SetPoint("TOPLEFT",SEARCH_EDITBOX.frame,"TOPLEFT",0,0)
    SEARCH_EDITBOX.editbox.Left:SetTexture()
    SEARCH_EDITBOX.editbox.Middle:SetTexture()
    SEARCH_EDITBOX.editbox.Right:SetTexture()

    SEARCH_EDITBOX.editbox:SetScript("OnEscapePressed", function() hide_all() end)
    SEARCH_EDITBOX:SetCallback("OnTextChanged", function(_, _, value)
        show_results(self, value)
    end)
    KL_MAIN_FRAME:AddChild(SEARCH_EDITBOX)
    heights = heights + SEARCH_EDITBOX.frame:GetHeight()

    --[=====[ EDIT MODE CHECKBOX AND ADD NEW --]=====]
    if self.db.global.kl['show_edit_mode_checkbox'] then
        local edit_mode_checkbox = AceGUI:Create("CheckBox")
        edit_mode_checkbox:SetWidth(100)
        edit_mode_checkbox:SetLabel(L['CONFIG_LOOK_N_FEEL_EDIT_MODE_NAME'])
        edit_mode_checkbox:SetValue(self.db.global.kl['edit_mode_on'])
        edit_mode_checkbox:SetCallback("OnValueChanged", function(_, _, value)
            self.db.global.kl['edit_mode_on'] = value
            reload_main_frame(self)
        end)
        KL_MAIN_FRAME:AddChild(edit_mode_checkbox)
    end

    --[=====[ SEARCH TYPES CHECKBOXES --]=====]
    if self.db.global.kl['show_type_checkboxes'] then
        local search_type_group = AceGUI:Create("SimpleGroup")
        search_type_group:SetFullWidth(true)
        search_type_group:SetLayout("flow")
        SEARCH_TYPE_CHECKBOXES = {}
        local counter = 1
        for _,v in pairs(SearchIndexType) do
            for k1,_ in pairs(v) do
                -- only render checkbox if search type is enabled for indexing
                if self.db.global.searchDataWhatIndex[k1] then
                    local search_type_checkbox = AceGUI:Create("CheckBox")
                    search_type_checkbox:SetImage(get_icon_for_index_type(k1))
                    local label_text = L['CONFIG_INDEX_TYPES_'..k1]
                    if self.db.global.kl['enable_quick_filter'] then
                        -- display the id of that index type, used for the quick filter
                        label_text = '['..counter..'] '..label_text
                    end
                    search_type_checkbox:SetLabel(label_text)
                    search_type_checkbox:SetWidth(150)
                    search_type_checkbox:SetCallback("OnValueChanged", function(_, _, value)
                        self.db.global.searchTypeCheckboxes[k1] = value
                        show_results(self, SEARCH_EDITBOX:GetText())
                    end)
                    if self.db.global.searchTypeCheckboxes[k1] == true then
                        search_type_checkbox:ToggleChecked()
                    end
                    SEARCH_TYPE_CHECKBOXES[k1] = search_type_checkbox
                    search_type_group:AddChild(search_type_checkbox)
                    counter = counter + 1
                end
            end
        end
        KL_MAIN_FRAME:AddChild(search_type_group)
        heights = heights + search_type_group.frame:GetHeight() + 8
    end

    --[=====[ SEPERATOR --]=====]
    if self.db.global.kl['show_type_checkboxes'] then
        local heading = AceGUI:Create("Heading")
        heading:SetFullWidth(true)
        KL_MAIN_FRAME:AddChild(heading)
        heights = heights + heading.frame:GetHeight()
    end

    --[=====[ EDIT MODE TABLE HEADER --]=====]
    if self.db.global.kl['edit_mode_on'] then
        show_edit_header(self)
        heights = heights + EDIT_HEADER.frame:GetHeight()
    end

    --[=====[ CONTAINER FOR LABELS --]=====]
    ITEMS_GROUP = AceGUI:Create("SimpleGroup")
    ITEMS_GROUP:SetFullWidth(true)
    ITEMS_GROUP.frame:SetPropagateKeyboardInput(true)

    KL_MAIN_FRAME:AddChild(ITEMS_GROUP)

    KL_MAIN_FRAME:Show()
end

function show_edit_header(self)
    local font_size = 12
    local height = 10
    EDIT_HEADER = AceGUI:Create("SimpleGroup")
    EDIT_HEADER:SetLayout("flow")
    EDIT_HEADER:SetFullWidth(true)

    local f = AceGUI:Create("Label")
    f:SetWidth(30)
    f:SetText('#')
    f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    f = AceGUI:Create("Label")
    f:SetWidth(40)
    f:SetText('Freq.')
    f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    f = AceGUI:Create("Label")
    f:SetWidth(150)
    f:SetText('Key')
    f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    f = AceGUI:Create("Label")
    f:SetWidth(180)
    f:SetText('Slash Command')
    f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    f = AceGUI:Create("Label")
    f:SetWidth(130)
    f:SetText('Tooltip Text')
   f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    f = AceGUI:Create("Label")
    f:SetWidth(120)
    f:SetText('Tooltip ItemString')
    f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    f = AceGUI:Create("Label")
    f:SetWidth(130)
    f:SetText('Category')
    f:SetFontObject("GameFontNormal")
    EDIT_HEADER:AddChild(f)

    -- add new line
    f = AceGUI:Create("Button")
    f:SetWidth(40)
    f:SetText('+')
    -- wanted to use .frame:Hide() but that does not work (it's still visible)
    -- then I wanted to use :Release(), but then I get an "widget already released"
    -- error when closing the main windo
    f:SetCallback("OnClick", function()
        -- if you change the REPLACE_ME_ string, also adapt the sort_search_data_table function
        self.db.global.customSearchData["REPLACE_ME_"..randomString(6)] = { type=SearchIndexType.CMD }
        show_results(self, SEARCH_EDITBOX:GetText())
    end)
    -- set initial state
    f:SetDisabled(true)
    if self.db.global.kl['edit_mode_on'] then
        f:SetDisabled(false)
    end
    EDIT_HEADER:AddChild(f)

    KL_MAIN_FRAME:AddChild(EDIT_HEADER)
end

function show_results(self, filter)
    if filter == nil then
        filter = '' -- :find cant handle nil
    end

    -- remove extraneous whitespace
    filter = strtrim(filter)

    SEARCH_TABLE_TO_LABEL = {}
    ITEMS_GROUP:ReleaseChildren() -- clear all and start from fresh

    -- sort
    local search_data_table_sorted = sort_search_data_table(self, filter)

    -- filter
    local filtered_table = filter_sorted_table(self, search_data_table_sorted, filter)

    -- display
    KL_MAIN_FRAME:PauseLayout()
    FROM = PAGINATION * self.db.global.kl['items_per_page'] - (self.db.global.kl['items_per_page'] - 1)
    TO = PAGINATION * self.db.global.kl['items_per_page']
    local counter = 1
    for idx,v in ipairs(filtered_table) do
        if idx >= FROM and idx <= TO then
            if self.db.global.kl['edit_mode_on'] then
                --[=====[ EDIT MODE BOXES --]=====]
                create_edit_boxes(self, v[1], idx)
            else
                --[=====[ SEARCH MODE IMTERACTIVE LABEL --]=====]
                create_interactive_label(self, idx, v[1], internal_filter)
                -- the first entry is always the one we want to execute per default
                if counter == 1 then
                    select_label(self, v[1])
                end
            end
            counter = counter + 1
        end
    end

    KL_MAIN_FRAME:ResumeLayout()
    KL_MAIN_FRAME:DoLayout()

    -- set height into main frame
    local total_item_height = ONE_ITEM_HEIGHT * (counter-1) + 24 --self.db.global.kl['items_per_page']
    if counter == 1 then
        total_item_height = total_item_height - 6
    end
    KL_MAIN_FRAME:SetHeight(total_item_height + heights)
end

function filter_sorted_table(self, sorted_table, filter)
    local filtered_table = {}
    for k,v in ipairs(sorted_table) do
        local internal_filter = filter -- so that the filter does not change for following loops runs
        local key = v[1]
        local key_data, custom_entry_exists, entry_exists = get_search_data(self, key)

        -- 1. filter condition: must be in enabled group
        local correct_type = false
        for k1,v1 in pairs(self.db.global.searchTypeCheckboxes) do
            -- if type enabled and type of current item matches the enabled type checkboxes
            if v1 and key_data.type == k1 then
                correct_type = true
            end
        end

        -- 2. filter condition: show only if not quick filter was used, if yes, that overrules the first filter
        if self.db.global.kl['enable_quick_filter'] then
            for k1,v1 in pairs(self.db.global.searchTypeCheckboxes) do
                -- SEARCH_TYPE_CHECKBOXES[k1] is nil for currently not displayed type checkboxes
                if v1 and SEARCH_TYPE_CHECKBOXES[k1] then
                    local checkbox_text = SEARCH_TYPE_CHECKBOXES[k1].text:GetText()
                    local number = filter:match('%d')
                    if checkbox_text and number then
                        if checkbox_text:match(number) then
                            if key_data.type ~= k1 then
                                correct_type = false
                            end
                        end
                    end
                end
            end
            -- when we search for items, we do not want the numbers in this case
            internal_filter = filter:gsub('%d','')
        end

        -- 3. filter condition: must match filter string
        if correct_type and key:lower():find(internal_filter) then
            table.insert(filtered_table, v)
        end
    end
    return filtered_table
end

function create_edit_boxes(self, key, idx)
    local key_data, custom_entry_exists, entry_exists = get_search_data(self, key)

    local frame = AceGUI:Create("SimpleGroup")
    frame:SetLayout("flow")
    frame:SetFullWidth(true)

    -- ID
    local id_frame = AceGUI:Create("Label")
    id_frame:SetWidth(30)
    id_frame:SetText(idx)
    frame:AddChild(id_frame)

    -- FREQUENCY
    local freq_frame = AceGUI:Create("Label")
    freq_frame:SetWidth(40)
    freq_frame:SetText(get_freq(self, key))
    frame:AddChild(freq_frame)

    -- KEY
    if custom_entry_exists and not entry_exists then
        local key_frame = AceGUI:Create("EditBox")
        key_frame:SetWidth(150)
        key_frame:SetText(key)
        key_frame:SetCallback("OnEnterPressed", function(_, _, text)
            -- when the primary changes, we copy over the data to the new entry and delete the old
            local t = shallowcopy(self.db.global.customSearchData[key])
            self.db.global.customSearchData[text] = t
            self.db.global.customSearchData[key] = nil
            show_results(self, SEARCH_EDITBOX:GetText())
        end)
        frame:AddChild(key_frame)
    else
        local key_frame = AceGUI:Create("Label")
        key_frame:SetWidth(150)
        key_frame:SetText(key)
        frame:AddChild(key_frame)
    end

    -- SLASH CMD
    local slash_cmd_frame = AceGUI:Create("EditBox")
    slash_cmd_frame:SetWidth(180)
    slash_cmd_frame:SetText(key_data.slash_cmd)
    slash_cmd_frame:SetCallback("OnEnterPressed", function(_, _, text)
        set_custom_search_data(self, key, 'slash_cmd', text)
    end)
    frame:AddChild(slash_cmd_frame)

    -- tooltipText
    local tooltip_text_frame = AceGUI:Create("EditBox")
    tooltip_text_frame:SetWidth(130)
    tooltip_text_frame:SetText(key_data.tooltipText)
    tooltip_text_frame:SetCallback("OnEnterPressed", function(_, _, text)
        set_custom_search_data(self, key, 'tooltipText', text)
    end)
    frame:AddChild(tooltip_text_frame)

    -- TOOLTIP
    local tooltip_frame = AceGUI:Create("EditBox")
    tooltip_frame:SetWidth(120)
    tooltip_frame:SetText(key_data.tooltipItemString)
    tooltip_frame:SetCallback("OnEnterPressed", function(_, _, text)
        set_custom_search_data(self, key, 'tooltipItemString', text)
    end)
    frame:AddChild(tooltip_frame)

    -- TYPE
    local type_frame = AceGUI:Create("Dropdown")
    type_frame:SetWidth(130)
    type_frame:SetList(enumm_to_table(SearchIndexType))
    type_frame:SetValue(key_data.type)
    type_frame:SetCallback("OnValueChanged", function(_, _, text)
        self.db.global.customSearchData[key] = { slash_cmd=key_data.slash_cmd, type=text }
        show_results(self, SEARCH_EDITBOX:GetText())
    end)
    frame:AddChild(type_frame)

    -- RESTORE BUTTON
    if custom_entry_exists and entry_exists then
        local default_button = AceGUI:Create("Button")
        default_button:SetWidth(40)
        default_button:SetText('R')
        default_button:SetCallback("OnClick", function()
            self.db.global.customSearchData[key] = nil
            show_results(self, SEARCH_EDITBOX:GetText())
        end)
        frame:AddChild(default_button)
    end

    -- DELETE BUTTON
    if custom_entry_exists and not entry_exists then
        local default_button = AceGUI:Create("Button")
        default_button:SetWidth(40)
        default_button:SetText('X')
        default_button:SetCallback("OnClick", function()
            self.db.global.customSearchData[key] = nil
            show_results(self, SEARCH_EDITBOX:GetText())
        end)
        frame:AddChild(default_button)
    end

    ITEMS_GROUP:AddChild(frame)
    ONE_ITEM_HEIGHT = frame.frame:GetHeight()
end

function create_interactive_label(self, idx, key, filter)
    local key_data = get_search_data(self, key)

    local frame = AceGUI:Create("SimpleGroup")
    local label = AceGUI:Create("InteractiveLabel")
    local labelWidth = KL_MAIN_FRAME_WIDTH
    
    frame:SetLayout("flow")
    frame:SetFullWidth(true)

    --[=====[ SPELL ICON --]=====]
    if self.db.global.kl['enable_spell_icons'] then
        local f = AceGUI:Create("SecureActionButton")
        f.frame:RegisterForClicks("AnyUp", "AnyDown")
        f:SetTexture(key_data)
        f:SetMacroText(key_data.slash_cmd)
        f.frame:SetScript("PostClick", function()
            increase_freq(self)
            hide_all()
        end)
        frame:AddChild(f)

        labelWidth = labelWidth - 25
    end

    --[=====[ INTERACTIVE LABEL --]=====]
    if self.db.global.kl['debug'] then
        label:SetText(key.." (freq: "..get_freq(self, key, filter)..") (idx: "..idx..")")
    else
        label:SetText(key)
    end
    if not self.db.global.kl['enable_spell_icons'] then
        if key_data.icon then
            label:SetImage(key_data.icon)
        else
            -- Set a default icon for any commands without icons
            label:SetImage('134332')
        end
    end
    
    label:SetFontObject(GameFontNormal)
    label:SetColor(.75,.75,.75,.75)
    label:SetCallback("OnClick", function()
        -- cant propagate mouse clicks, so need to press enter after selecting
        select_label(self, key)
    end)
    frame:AddChild(label)

    --[=====[ TYPE ICON --]=====]
    if self.db.global.kl['show_type_marker'] then
        local icon = AceGUI:Create("Icon")
        labelWidth = labelWidth - 40
        icon:SetImage(get_icon_for_index_type(key_data.type))
        icon:SetImageSize(10, 10)
        icon:SetWidth(10)
        frame:AddChild(icon)
    end


    label:SetWidth(labelWidth)
    SEARCH_TABLE_TO_LABEL[idx] = {key=key, label=label}
    ITEMS_GROUP:AddChild(frame)
    ONE_ITEM_HEIGHT = frame.frame:GetHeight()
end

function increase_freq(self)
        -- save freq
        local current_search = SEARCH_EDITBOX:GetText()
        if is_nil_or_empty(current_search) then
            current_search = CURRENTLY_SELECTED_LABEL_KEY
        end

        if self.db.global.kl['enable_quick_filter'] then
            current_search = current_search:gsub('%d','')
        end

        local freq = 1
        local current_search_freq = self.db.global.searchDataFreq[current_search]
        if current_search_freq then
            -- only increase by one, if it is not a different key
            if current_search_freq.key == CURRENTLY_SELECTED_LABEL_KEY then
                freq = current_search_freq.freq + 1
            end
        end
        self.db.global.searchDataFreq[current_search] = { key=CURRENTLY_SELECTED_LABEL_KEY, freq=freq}
end

-- execute_macro means effectively propagate then close the main window
function execute_macro(self)
    if not self.db.global.kl['edit_mode_on'] then
        KL_MAIN_FRAME.frame:SetPropagateKeyboardInput(true)
        increase_freq(self)
        hide_all()
        dprint(self, "execute_macro "..CURRENTLY_SELECTED_LABEL_KEY..", "..get_mem_usage())
    end
end

function update_top_macros(self)
    if self.db.global.kl['enable_top_macros'] then
        local top_table = {}
        -- first aggreate search frequency on key
        for _,v in pairs(self.db.global.searchDataFreq) do
            if top_table[v.key] then
                top_table[v.key] = top_table[v.key] + v.freq
            else
                top_table[v.key] = v.freq
            end
        end

        -- then create a sorted table based on aggr freq
        local sorted_table = {}
        for k,v in pairs(top_table) do
            table.insert(sorted_table, {k, v})
        end
        table.sort(sorted_table, function(a,b) return a[2] > b[2] end)

        for k,v in ipairs(sorted_table) do
            if k < 6 then
                local data = get_search_data(self, v[1])
                local macroId = get_or_create_macro('kl-top-'..k, true)
                local data_tooltipText = data.tooltipText
                if not data_tooltipText then
                    data_tooltipText = v[1]
                end
                EditMacro(
                    macroId, nil, nil,
                    "#tooltipdesc "..data_tooltipText.."^"..data.slash_cmd.."\n"..data.slash_cmd,
                    1, 1);
            end
        end
    end
end

function hide_all()
    if KL_MAIN_FRAME then
        KL_MAIN_FRAME:Hide()
    end
    GameTooltip:Hide()
end

function print_search_data_freq(self)
    self:Print("Content of Search Frequence DB:")
    for k,v in pairs(self.db.global.searchDataFreq) do
        self:Print(' ', string.lpad(v.freq, 4), string.lpad(k, 16), v.key)
    end
end

function print_custom_search_db(self)
    self:Print("Content of Custom Search DB:")
    for k,v in pairs(self.db.global.customSearchData) do
        self:Print(' '..k)
        for k1,v1 in pairs(v) do
            self:Print('  '..k1..'='..v1)
        end
    end
end

function print_search_db(self, key)
    self:Print("Content of Search DB:")
    for k,v in pairs(self.db.global.searchDataTable) do
        if k == key then
            self:Print(' '..k)
            for k1,v1 in pairs(v) do
                self:Print('  '..k1..'='..v1)
            end
        end
    end
end

function get_freq(self, key, current_filter)
    -- when there's an entry for current_filter, that always comes on top
    local db_entry = self.db.global.searchDataFreq[current_filter]
    if db_entry then
        if db_entry.key == key then
            return 1000 + db_entry.freq
        end
    end
    -- else sum up how often key was executed, 0 is default
    local freq = 0
    for _, v in pairs(self.db.global.searchDataFreq) do
        if v.key == key then
            freq = freq + v.freq
        end
    end
    return freq
end

function sort_search_data_table(self, filter)
    local search_data_table_sorted = {}

    -- merge the two search data table into one
    -- the custom one overwrites the not custom one
    -- which is intended, because it overrules the other one
    local merged_table = {}
    for k,v in pairs(self.db.global.searchDataTable) do
        merged_table[k] = v
    end
    for k,v in pairs(self.db.global.customSearchData) do
        merged_table[k] = v
    end

    -- sort merged table based on the freq and if freq is 0, alphabetically
    for key, _ in pairs(merged_table) do
        local freq = get_freq(self, key, filter)
        -- if you change the REPLACE_ME_ string, also adapt the show_main_frame function
        if key:match('REPLACE_ME_') then
            freq = 9999
        end
        table.insert(search_data_table_sorted, {key, freq})
    end
    table.sort(search_data_table_sorted, function(a,b)
        if a[2] == 0 and b[2] == 0 then
            return a[1]:lower() < b[1]:lower()
        else
            return a[2] > b[2]
        end
    end)

    return search_data_table_sorted
end

function get_icon_for_index_type(index_type)
    for _,v in pairs(SearchIndexType) do
        for k1,v1 in pairs(v) do
            if k1 == index_type then
                return ICON_BASE_PATH..v1.icon..".blp"
            end
        end
    end
end

function toggle_all_search_type_checkboxes(self)
    for _,v in pairs(SearchIndexType) do
        for k1,_ in pairs(v) do
            self.db.global.searchTypeCheckboxes[k1] = true
        end
    end
end

function move_selector(self, keyboard_key)
    if not self.db.global.kl['edit_mode_on'] then
        if keyboard_key == "DOWN" and CURRENTLY_SELECTED_LABEL_INDEX < TO then
            select_label(self, nil, CURRENTLY_SELECTED_LABEL_INDEX+1)
        elseif keyboard_key == "UP" and CURRENTLY_SELECTED_LABEL_INDEX > FROM then
            select_label(self, nil, CURRENTLY_SELECTED_LABEL_INDEX-1)
        end
    end
end

function select_label(self, key, index)
    -- method disable in edit_mode, as there is nothing to highlight
    if not self.db.global.kl['edit_mode_on'] then
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
                v.label:SetColor(.996, .815, .184)
                CURRENTLY_SELECTED_LABEL_INDEX = k
                CURRENTLY_SELECTED_LABEL_KEY = v.key
                edit_master_marco(self, v.key)
                display_tooltip(self, v.key, v.label.frame)
            else
                v.label:SetColor(.75, .75, .75, .75)
            end
        end
    end
end

function set_search_frame_size(self)
    if self.db.global.kl['show_edit_mode_checkbox'] then
        -- make space for the edit mode check box
        SEARCH_EDITBOX:SetWidth(KL_MAIN_FRAME_WIDTH-140)
    else
        SEARCH_EDITBOX:SetWidth(KL_MAIN_FRAME_WIDTH-40)
    end
end

function set_main_frame_size(self)
    local cols = 0
    for _,v in pairs(SearchIndexType) do
        for k1,_ in pairs(v) do
            if self.db.global.searchDataWhatIndex[k1] then
                cols = cols + 1
            end
        end
    end
    local rows = 2
    cols = math.floor((cols/rows)+0.5) -- round up
    local one_item_width = 170
    -- min columns
    if cols < 2 then
        cols = 2
    end

    if self.db.global.kl['edit_mode_on'] then
        KL_MAIN_FRAME_WIDTH = one_item_width * 5
    elseif self.db.global.kl['show_type_checkboxes'] then
        KL_MAIN_FRAME_WIDTH = one_item_width * cols
    else
        KL_MAIN_FRAME_WIDTH = 380
    end

    if KL_MAIN_FRAME then
        KL_MAIN_FRAME:SetWidth(KL_MAIN_FRAME_WIDTH)
        set_search_frame_size(self)
        GameTooltip:Hide()
    end
end

function display_tooltip(self, key, owner)
    if self.db.global.kl['show_tooltips'] then
        local detailed_data = self.db.global.searchDataTable[key]
        if detailed_data then
            if detailed_data['tooltipItemString'] then
                GameTooltip:SetOwner(owner, "ANCHOR_BOTTOMLEFT", -20, 15)
                GameTooltip:SetHyperlink(detailed_data['tooltipItemString'])
                GameTooltip:Show()
            elseif detailed_data['tooltipText'] then
                GameTooltip:SetOwner(owner, "ANCHOR_BOTTOMLEFT", -20, 15)
                GameTooltip:SetText(detailed_data['tooltipText'], nil, nil, nil, nil, true)
                GameTooltip:Show()
            else
                GameTooltip:Hide()
            end
        end
    end
end

-- get a value from the searchDataTable, overriden by customSearchData if exists
-- @key key to get
-- @value if nil, the whole entry is returned
function get_search_data(self, key, value)
    local rv
    local data = self.db.global.searchDataTable[key]
    local custom_data = self.db.global.customSearchData[key]

    local custom_entry_exists = false
    local entry_exists = false
    if data then
        entry_exists = true
    end
    if custom_data then
        custom_entry_exists = true
    end

    if custom_entry_exists then
        -- custom data always wins
        rv = custom_data
    else
        rv = data
    end

    if value then
        rv = rv[value]
    end
    return rv, custom_entry_exists, entry_exists
end

function set_custom_search_data(self, key, sub_key, value)
    -- copy over values if not exist yet
    if not self.db.global.customSearchData[key] then
        local t = shallowcopy(self.db.global.searchDataTable[key])
        self.db.global.customSearchData[key] = t
    end

    self.db.global.customSearchData[key][sub_key] = value
    show_results(self, SEARCH_EDITBOX:GetText())
end

function edit_master_marco(self, key, keyboard_key)
    local macroId = get_or_create_macro('kl-master')
    if not keyboard_key then
        keyboard_key = 'ENTER'
    end
    local body = get_search_data(self, key, 'slash_cmd')
    if body then
        EditMacro(macroId, nil, nil, body, 1, 1);
        SetOverrideBindingMacro(KEYBOARD_LISTENER_FRAME, true, keyboard_key, macroId)
        --KL_MAIN_FRAME:SetStatusText(body)
        dprint(self, "edit_master_marco body="..body)
    end
end

-- http://www.wowinterface.com/forums/showthread.php?t=9210
function get_mem_usage()
    UpdateAddOnMemoryUsage()
    local mem = GetAddOnMemoryUsage("KeystrokeLauncherResurrected")
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
    self.db.global.searchDataTable = {}
    local db_search = self.db.global.searchDataTable

    --[=====[ ADDON --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.ADDON] then
        for i=1, C_AddOns.GetNumAddOns() do
            local name, title, notes, addonenabled = C_AddOns.GetAddOnInfo(i)
            if notes == nil then
                notes = ''
            end
            if addonenabled and C_AddOns.IsAddOnLoaded(i) then
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
                        if type(k) == "string" then
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
        end
    end

    --[=====[ MACROS --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.MACRO] then
        local numglobal, numperchar = GetNumMacros();
        for i = 1, numglobal do
            local name, iconTexture, body = GetMacroInfo(i)
            if name then
                db_search[name] = {
                    slash_cmd=body,
                    icon=iconTexture,
                    tooltipText=body,
                    type=SearchIndexType.MACRO
                }
            end
        end
        for i = 1, numperchar do
            local name, iconTexture, body = GetMacroInfo(i + 120)
            if name then
                db_search[name] = {
                    slash_cmd=body,
                    icon=iconTexture,
                    tooltipText=body,
                    type=SearchIndexType.MACRO
                }
            end
        end
    end

    --[=====[ SPELLS --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.SPELL] then
        local i = 1
        while true do
            local spellName = C_SpellBook.GetSpellBookItemName(i, Enum.SpellBookSpellBank.Player)
            if not spellName then
                do break end
            end
            if C_Spell.IsSpellUsable(spellName) then
                if not C_Spell.IsSpellPassive(spellName) then
                    local spellString = item_link_to_string(C_Spell.GetSpellLink(spellName))
                    db_search[spellName] = {
                        slash_cmd="/cast "..spellName,
                        icon = C_Spell.GetSpellTexture(spellName),
                        tooltipItemString=spellString,
                        type=SearchIndexType.SPELL,
                        spell_name=spellName
                    }
                end
            end
            i = i + 1
        end
    end

    --[=====[ CMDs --]=====]
    add_many(self, SearchIndexType.CMD, {
        {'Reload UI', '/reload', L["DB_SEARCH_RELOAD_UI"]},
        {'Logout', '/logout', L["DB_SEARCH_LOGOUT"]},
        {'/kl show', '/kl show', L["DB_SEARCH_KL_SHOW"]},
        {'/kl search_freq print', '/kl search_freq print', L["DB_SEARCH_KL_FREQ_PRINT"]},
        {'/kl search_table rebuild', '/kl search_table rebuild', L["DB_SEARCH_KL_SEARCH_REBUILD"]},
        {'Dismount', '/dismount', L["DB_SEARCH_DISMOUNT"]},
        {L['SUMMON_RANDOM_FAVORITE_MOUNT'], '/run C_MountJournal.SummonByID(0)'},
        {'Quit WoW', '/quit'},
        {'Force Quit WoW', '/forecequit'}
    })


    --[=====[ CVARS --]=====]
    add_many(self, SearchIndexType.CVAR, {
        {L['TOGGLE_SOUND'], '/run SetCVar("Sound_EnableAllSound",GetCVar("Sound_EnableAllSound")=="0" and 1 or 0)'}
    })

    --[=====[ ITEMS --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.ITEM] then
        for bag=0, NUM_BAG_SLOTS do
            for bagSlots=1, C_Container.GetContainerNumSlots(bag) do
                local itemLink = C_Container.GetContainerItemLink(bag, bagSlots)
                if itemLink then
                    local itemString, itemName, itemId = item_link_to_string(itemLink)
                    if C_Item.IsUsableItem(itemName) then
                        db_search[itemName] = {
                            slash_cmd="/use "..itemName,
                            icon = C_Item.GetItemIconByID(itemName),
                            tooltipItemString=itemString,
                            type=SearchIndexType.ITEM,
                            item_id=itemId
                        }
                    end
                end
            end
        end
    end

    --[=====[ MOUNTS --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.MOUNT] then
        for i=1, C_MountJournal.GetNumDisplayedMounts() do
            local creatureName, spellID, icon, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(i)
            local spellString, spellname = item_link_to_string(C_Spell.GetSpellLink(spellID))
            if isCollected then
                db_search[creatureName] = {
                    slash_cmd="/cast "..spellname,
                    icon = icon,
                    tooltipItemString=spellString,
                    type = SearchIndexType.MOUNT
                }
            end
        end
    end

    --[=====[ TOYS --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.TOY] then
        C_ToyBox.SetAllSourceTypeFilters(true);
        C_ToyBox.SetCollectedShown(true);
        C_ToyBox.SetUncollectedShown(true);
        C_ToyBox.SetUnusableShown(true);
        C_ToyBox.SetFilterString("");

        local NumToys = C_ToyBox.GetNumToys();
        local toyList = {};
        for idx = NumToys, 1, -1 do
            local itemId = C_ToyBox.GetToyFromIndex(idx)
            if itemId ~= -1 then
                table.insert(toyList, itemId)
            end
        end
        local counter = 0
        for i, id in pairs(toyList) do
            if (PlayerHasToy(id)) then
                local itemId, toyName, icon = C_ToyBox.GetToyInfo(id)
                local spellString = item_link_to_string(C_ToyBox.GetToyLink(id))
                
                if toyName ~= nil then
                    counter = counter+1
                  db_search[toyName] = {
                      slash_cmd="/usetoy "..toyName,
                      icon = icon,
                      tooltipItemString=spellString,
                      type = SearchIndexType.TOY
                  }
                end
                
            end
        end
        dprint(self, "Toys added: " .. counter)
    end

    --[=====[ EQUIPMENT SETS --]=====]
    if self.db.global.searchDataWhatIndex[SearchIndexType.EQUIP_SET] then
        for i=0, C_EquipmentSet.GetNumEquipmentSets() do
            local name, iconFileID = C_EquipmentSet.GetEquipmentSetInfo(i)
            if name then
                db_search[name] = {
                    slash_cmd="/equipset "..name,
                    icon = iconFileID,
                    tooltipText=name,
                    type = SearchIndexType.EQUIP_SET
                }
            end
        end
    end

    --[=====[ BLIZZARD FRAMES --]=====]
    -- global strings from https://www.townlong-yak.com/framexml/live/GlobalStrings.lua/DE
    -- available functions: https://github.com/tomrus88/BlizzardInterfaceCode/blob/6922484b7b57ed6b3133ea54cdc828db94c7813d/Interface/FrameXML/UIParent.lua
    add_many(self, SearchIndexType.BLIZZ_FRAME, {
        {CHARACTER_BUTTON, '/run ToggleCharacter("PaperDollFrame")', L['OPEN']..' '..CHARACTER_BUTTON},
        {SPELLBOOK_BUTTON, '/run ToggleSpellBook("spell")', L['OPEN']..' '..SPELLBOOK_BUTTON},
        {TALENTS_BUTTON, '/run ToggleTalentFrame()', L['OPEN']..' '..TALENTS_BUTTON},
        {FRIENDS, '/run ToggleFriendsFrame(1)', L['OPEN']..' '..FRIENDS},
        {QUESTLOG_BUTTON, '/run ToggleQuestLog()', L['OPEN']..' '..QUESTLOG_BUTTON},
        {LOOKINGFORGUILD, '/run ToggleGuildFrame(1)', L['OPEN']..' '..LOOKINGFORGUILD},
        {GROUP_FINDER, '/run ToggleFrame(PVEFrame)', L['OPEN']..' '..GROUP_FINDER},
        {ADVENTURE_JOURNAL, '/run ToggleEncounterJournal(1)', L['OPEN']..' '..ADVENTURE_JOURNAL},
        {HELP_BUTTON, '/run ToggleHelpFrame()', L['OPEN']..' '..HELP_BUTTON},
        {L['CALENDAR'], '/run if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end Calendar_Toggle()', GAMETIME_TOOLTIP_TOGGLE_CALENDAR},
        {ACHIEVEMENT_BUTTON, '/run ToggleAchievementFrame()', L['OPEN']..' '..ACHIEVEMENT_BUTTON},
        {MOUNTS, '/run ToggleCollectionsJournal(1)', L['OPEN']..' '..MOUNTS},
        {HEIRLOOMS, '/run ToggleCollectionsJournal(4)', L['OPEN']..' '..HEIRLOOMS}
    })

    -- print out start message
    local disabled = L["INDEX_DISABLED"]
    local enabled = L["INDEX_ENABLED"]
    dprint(self, L["INDEX_HEADER"])
    for type, type_enabled in pairs(self.db.global.searchDataWhatIndex) do
        if type_enabled then
            enabled = enabled..type..' '
        else
            disabled = disabled..type..' '
        end
    end
    dprint(self, enabled)
    dprint(self, disabled)

    --dprint(self, L["INDEX_FOOTER"](GetBindingKey("KL_LAUNCH")..""))
end

function add_many(self, type, tables)
    for _,v in pairs(tables) do
        add_one(self, type, v)
    end
end

function add_one(self, type, data)
    if self.db.global.searchDataWhatIndex[type] then
        -- tooltip default value is the key
        if not data[3] then
            data[3] = data[1]
        end
        self.db.global.searchDataTable[data[1]] = { slash_cmd=data[2], tooltipText=data[3], type=type}
    end
end

function add_mount(self, mountID)
    local db_search = self.db.global.searchDataTable
    local creatureName, spellID, icon = C_MountJournal.GetMountInfoByID(mountID)
    local spellString, spellname = item_link_to_string(C_Spell.GetSpellLink(spellID))
    
    dprint(self, "Adding new mount: " .. creatureName)

    db_search[creatureName] = {
        slash_cmd = "/cast " .. spellname,
        icon = icon,
        tooltipItemString = spellString,
        type = SearchIndexType.MOUNT
    }
end


local AceGUI = LibStub("AceGUI-3.0")
do
	local Type = "KeystrokeLauncherWindow"
	local Version = 1

	local function frameOnClose(this)
		this.obj:Fire("OnClose")
	end
	
	local function closeOnClick(this)
		this.obj:Hide()
	end
	
	local function frameOnMouseDown(this)
		AceGUI:ClearFocus()
	end
	
	local function titleOnMouseDown(this)
		this:GetParent():StartMoving()
		AceGUI:ClearFocus()
	end
	
	local function frameOnMouseUp(this)
		local frame = this:GetParent()
		frame:StopMovingOrSizing()
		local self = frame.obj
		local status = self.status or self.localstatus
		status.width = frame:GetWidth()
		status.height = frame:GetHeight()
		status.top = frame:GetTop()
		status.left = frame:GetLeft()
	end

	local function SetTitle(self,title)
		self.titletext:SetText(title)
	end
	
	local function SetStatusText(self,text)
		-- self.statustext:SetText(text)
	end
	
	local function Hide(self)
		self.frame:Hide()
	end
	
	local function Show(self)
        self.frame:SetPoint("TOP",UIParent,"TOP",0,-GetScreenHeight()*.3/self.frame:GetScale())
		self.frame:Show()
	end
	
	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:EnableResize(true)
		self:Show()
	end
	
	local function OnRelease(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end
	
	-- called to set an external table to store status in
	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
	end
	
	local function OnWidthSet(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end
	
	
	local function OnHeightSet(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end
	
	local function EnableResize(self, state)
		local func = state and "Show" or "Hide"
	end
	
	local function Constructor()
		local frame = CreateFrame("Frame","KeystrokeLauncherWindow",UIParent,"BackdropTemplate")
		
		local self = {}
		self.type = "KeystrokeLauncherWindow"
		
		self.Hide = Hide
		self.Show = Show
		self.SetTitle =  SetTitle
		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.SetStatusText = SetStatusText
		self.SetStatusTable = SetStatusTable
		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet
		self.EnableResize = EnableResize
		
		self.localstatus = {}
		
		self.frame = frame
		frame.obj = self
		frame:SetWidth(700)
		frame:SetHeight(500)
		frame:EnableMouse()
		frame:SetMovable(true)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		frame:SetScript("OnMouseDown", frameOnMouseDown)
		
        
        frame:SetScript("OnHide",frameOnClose)
		frame:SetToplevel(true)

        frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 1, edgeSize = 10, insets = { left = 1, right = 1, top = 1, bottom = 1 }});
        frame:SetBackdropColor(0, 0, 0, .75);
        frame:SetBackdropBorderColor(1, 1, 1, .75)
		
        -- close button
        local close = CreateFrame("Button", "closeButton", frame, "KLR_CloseButton");
        close:SetPoint("TOPRIGHT", -10, -9);
        close:SetScript("OnClick", closeOnClick);
        self.closebutton = close
		close.obj = self
	
		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		self.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",frame,"TOPLEFT",12, -7)
		content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT", -12,12)
		
		AceGUI:RegisterAsContainer(self)
		return self	
	end
	
	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end