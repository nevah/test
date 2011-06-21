local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
--silly anchor trix are for kids
local cbanchor = CreateFrame("Frame", "CustomTukuiActionBarAnchor", UIParent) 
cbanchor:CreatePanel("Default", 1, 1, "CENTER", UIParent, "CENTER", 0, 0)
cbanchor:SetAlpha(0)
-- custom action bar (add spells in the profiles.lua)		
local custombar = CreateFrame("Frame", "CustomTukuiActionBar", UIParent, "SecureHandlerStateTemplate")
custombar:CreatePanel("Default", 1, 39, "TOPLEFT", cbanchor, "BOTTOMLEFT", 0, 1)
local totalprimary = table.getn(C.actionbar.custombar.primary)
local totalsecondary = table.getn(C.actionbar.custombar.secondary)
if (totalprimary ~= 0 or totalsecondary ~= 0)and C.actionbar.custombar.enable == true then
	custombarline1 = CreateFrame("Frame", nil, custombar)
	custombarline1:CreatePanel("Default", 2, 5, "BOTTOMRIGHT", custombar, "TOPRIGHT", -15, 0)
	custombarline1:SetFrameStrata("BACKGROUND")
	custombarline2 = CreateFrame("Frame", nil, custombar)
	custombarline2:CreatePanel("Default", 2, 5, "BOTTOMLEFT", custombar, "TOPLEFT", 15, 0)
	custombarline2:SetFrameStrata("BACKGROUND")
else
	custombar:Hide()
end
local cbtoggle = CreateFrame("Frame", "CustomTukuiActionBarToggle", UIParent)
cbtoggle:CreatePanel("Default", 1, 12, "TOPLEFT", custombar, "BOTTOMLEFT", 0, -3)
cbtoggle.text = T.SetFontString(cbtoggle, C.media.uffont, 8)
cbtoggle.text:SetPoint("CENTER")
cbtoggle.text:SetText("Close")
cbtoggle:SetAlpha(0)
cbtoggle:SetScript("OnEnter", function() cbtoggle:SetAlpha(1) end)
cbtoggle:SetScript("OnLeave", function() cbtoggle:SetAlpha(0) end)
cbtoggle:SetScript("OnMouseDown", function()
	if C.actionbar.custombar.enable ~= true then return end
	if custombar:IsShown() then
		custombar:Hide()
		cbtoggle:SetPoint("TOPLEFT", cbanchor, "BOTTOMLEFT")
		cbtoggle.text:SetText("Open")
	else
		custombar:Show()
		cbtoggle:SetPoint("TOPLEFT", custombar, "BOTTOMLEFT", 0, -3)
		cbtoggle.text:SetText("Close")
	end
end)

local function OnUpdate(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

  if(self.TimeSinceLastUpdate > .5) then
		self.start, self.duration, self.enabled = GetSpellCooldown(self.id)
		
		if self.enabled ~= 0 then
			SetDesaturation(self.texture, nil)
			self.cooldown:SetCooldown(self.start, self.duration)
		else
			SetDesaturation(self.texture, 1)
		end
		
		if self.start == 0 then
			self.cooldown:SetAlpha(0)
		else
			self.cooldown:SetAlpha(1)
		end

    self.TimeSinceLastUpdate = 0
  end
end

local function MakePrimaryButtons()
	custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	if GetActiveTalentGroup() == 1 then
		custombar:SetWidth((totalprimary)*35 + ((totalprimary)+1)*2)
		cbtoggle:SetWidth((totalprimary)*35 + ((totalprimary)+1)*2)
	else
		custombar:SetWidth((totalsecondary)*35 + ((totalsecondary)+1)*2)
		cbtoggle:SetWidth((totalsecondary)*35 + ((totalsecondary)+1)*2)
	end
		-- spell stuffz
	for i, v in ipairs(C.actionbar.custombar.primary) do	
		--button stuffz
		custombutton[i] = CreateFrame("Button", "customprimarybutton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:CreatePanel("Default", 35, 35, "TOPLEFT", custombar, "TOPLEFT", 2, -2)
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", 2, 0)
		end
		-- texture settup
		custombutton[i].texture = custombutton[i]:CreateTexture(nil, "BORDER")
		custombutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		custombutton[i].texture:Point("TOPLEFT", custombutton[i] ,"TOPLEFT", 2, -2)
		custombutton[i].texture:Point("BOTTOMRIGHT", custombutton[i] ,"BOTTOMRIGHT", -2, 2)
		-- cooldown overlay
		custombutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", custombutton[i], "CooldownFrameTemplate")
		custombutton[i].cooldown:SetAllPoints(custombutton[i].texture)				
		-- hoverover stuffz
		custombutton[i]:StyleButton()
		-- functional stuffz
		local name = GetItemInfo(v)
		if IsEquippedItem(name) == 1 then
			custombutton[i].id = v			
			local trinket1id = GetInventoryItemID("player", 13)
			local trinket2id = GetInventoryItemID("player", 14)
			local var = 0
			if trinket1id == v then var = 13 elseif trinket2id == v then var = 14 end
			custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
			custombutton[i]:SetAttribute("type", "item");
			custombutton[i]:SetAttribute("item", var)
		elseif GetSpellInfo(v) == v then
			custombutton[i].id = v
			custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
			custombutton[i]:SetAttribute("type", "spell");
			custombutton[i]:SetAttribute("spell", v)
		elseif IsEquippableItem(name) == nil then
			if type(v) == "number" then
				custombutton[i].id = v 
				custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
				custombutton[i]:SetAttribute("type", "item");
				custombutton[i]:SetAttribute("item", GetItemInfo(v))
			end
		end
		-- cooldown stuffz
		custombutton[i]:SetScript("OnUpdate", OnUpdate)
		custombutton[i].TimeSinceLastUpdate = 0
	end
end

local function MakeSecondaryButtons()
	custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	if GetActiveTalentGroup() == 1 then
		custombar:SetWidth((totalprimary)*35 + ((totalprimary)+1)*2)
		cbtoggle:SetWidth((totalprimary)*35 + ((totalprimary)+1)*2)
	else
		custombar:SetWidth((totalsecondary)*35 + ((totalsecondary)+1)*2)
		cbtoggle:SetWidth((totalsecondary)*35 + ((totalsecondary)+1)*2)
	end
		-- spell stuffz
	for i, v in ipairs(C.actionbar.custombar.secondary) do	
		--button stuffz
		custombutton[i] = CreateFrame("Button", "customsecondarybutton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:CreatePanel("Default", 35, 35, "TOPLEFT", custombar, "TOPLEFT", 2, -2)
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", 2, 0)
		end
		-- texture settup
		custombutton[i].texture = custombutton[i]:CreateTexture(nil, "BORDER")
		custombutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		custombutton[i].texture:Point("TOPLEFT", custombutton[i] ,"TOPLEFT", 2, -2)
		custombutton[i].texture:Point("BOTTOMRIGHT", custombutton[i] ,"BOTTOMRIGHT", -2, 2)
		-- cooldown overlay
		custombutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", custombutton[i], "CooldownFrameTemplate")
		custombutton[i].cooldown:SetAllPoints(custombutton[i].texture)				
		-- hoverover stuffz
		custombutton[i]:StyleButton()
		-- functional stuffz
		local name = GetItemInfo(v)
		if IsEquippedItem(name) == 1 then
			custombutton[i].id = v			
			local trinket1id = GetInventoryItemID("player", 13)
			local trinket2id = GetInventoryItemID("player", 14)
			local var = 0
			if trinket1id == v then var = 13 elseif trinket2id == v then var = 14 end
			custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
			custombutton[i]:SetAttribute("type", "item");
			custombutton[i]:SetAttribute("item", var)
		elseif GetSpellInfo(v) == v then
			custombutton[i].id = v
			custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
			custombutton[i]:SetAttribute("type", "spell");
			custombutton[i]:SetAttribute("spell", v)
		elseif IsEquippableItem(name) == nil then
			if type(v) == "number" then
				custombutton[i].id = v 
				custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
				custombutton[i]:SetAttribute("type", "item");
				custombutton[i]:SetAttribute("item", GetItemInfo(v))
			end
		end
		-- cooldown stuffz
		custombutton[i]:SetScript("OnUpdate", OnUpdate)
		custombutton[i].TimeSinceLastUpdate = 0
	end
end

local function OnEvent(self, event)
	if GetActiveTalentGroup() ~= 1 then
		for i = 1, totalprimary do
			if _G["customprimarybutton"..i] then
				_G["customprimarybutton"..i]:Kill()
				_G["customprimarybutton"..i] = nil
				_G["customprimarybutton"..i.."CD"]:Kill()
				_G["customprimarybutton"..i.."CD"] = nil
			end
		end
		MakeSecondaryButtons()
	else
		for i = 1, totalsecondary do
			if _G["customsecondarybutton"..i] then
				_G["customsecondarybutton"..i]:Kill()
				_G["customsecondarybutton"..i] = nil
				_G["customsecondarybutton"..i.."CD"]:Kill()
				_G["customsecondarybutton"..i.."CD"] = nil
			end
		end
		MakePrimaryButtons()
	end		
end

local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:SetScript("OnEvent", OnEvent)