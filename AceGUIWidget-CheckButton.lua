--[[-----------------------------------------------------------------------------
Custom CheckButton Wrapper
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "CheckButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
-- local _G = _G
-- local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(24)
		self:SetWidth(24)
        self:SetIcon()
        self:SetMacroText()
	end,

	-- ["OnRelease"] = nil,

    ["SetIcon"] = function(self, spell_id)
        -- http://www.wowinterface.com/forums/showpost.php?p=255359&postcount=4
        local t = self.frame:CreateTexture(nil,"BACKGROUND",nil,-6)
        t:SetTexture(spell_id)
        t:SetTexCoord(0.1,0.9,0.1,0.9) --cut out crappy icon border
        t:SetAllPoints(self.frame) --make texture same size as button
        self.frame:SetNormalTexture(t)
    end,
    
    ["SetMacroText"] = function(self, macro_text)
        self.frame:SetAttribute("macrotext1", macro_text)
	end,

}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    local frame = CreateFrame("CheckButton", "ExtraBarButton"..AceGUI:GetNextWidgetNum(Type), UIParent, "ActionBarButtonTemplate")
    frame:SetAttribute("type1", "macro")

	local widget = {
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
