local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

-- custom action bar (add spells in the profiles.lua)		
local custombar = CreateFrame("Frame", "CustomTukuiActionBar", UIParent, "SecureHandlerStateTemplate")
custombar:CreatePanel("Default", 1, 39, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, -6)
local totalspells = table.getn(C.actionbar.custombar.spells)
if (totalspells ~= 0 or totalitems ~= 0) and C.actionbar.custombar.enable == true then
	custombar:SetWidth((totalspells)*35 + ((totalspells)+1)*2)
		custombarline1 = CreateFrame("Frame", nil, custombar)
		custombarline1:CreatePanel("Default", 2, 5, "BOTTOMRIGHT", custombar, "TOPRIGHT", -15, 0)
		custombarline1:SetFrameStrata("BACKGROUND")
		
		custombarline2 = CreateFrame("Frame", nil, custombar)
		custombarline2:CreatePanel("Default", 2, 5, "BOTTOMLEFT", custombar, "TOPLEFT", 15, 0)
		custombarline2:SetFrameStrata("BACKGROUND")
	local custombutton = CreateFrame("Button", "CustomButton", custombar, "SecureActionButtonTemplate")
	-- spell stuffz
	for i, v in ipairs(C.actionbar.custombar.spells) do
		--button stuffz
		custombutton[i] = CreateFrame("Button", "CustomButton"..i, custombar, "SecureActionButtonTemplate")
		custombutton[i]:CreatePanel("Default", 35, 35, "TOPLEFT", custombar, "TOPLEFT", 2, -2)
		if i ~= 1 then
			custombutton[i]:SetPoint("TOPLEFT", custombutton[i-1], "TOPRIGHT", 2, 0)
		end
		-- texture settup
		custombutton[i].texture = custombutton[i]:CreateTexture(nil, "BORDER")
		custombutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		custombutton[i].texture:SetPoint("TOPLEFT", custombutton[i] ,"TOPLEFT", 2, -2)
		custombutton[i].texture:SetPoint("BOTTOMRIGHT", custombutton[i] ,"BOTTOMRIGHT", -2, 2)
		-- cooldown overlay
		custombutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", custombutton[i], "CooldownFrameTemplate")
		custombutton[i].cooldown:SetAllPoints(custombutton[i].texture)				
		-- text settup
		custombutton[i].value = custombutton[i]:CreateFontString(nil, "ARTWORK")
		custombutton[i].value:SetFont(C["media"].font, 15, "OUTLINE")
		custombutton[i].value:SetTextColor(1, 0, 0)
		custombutton[i].value:SetShadowColor(0, 0, 0, 0.5)
		custombutton[i].value:SetShadowOffset(2, -2)
		custombutton[i].value:Point("CENTER", custombutton[i], "CENTER")
		-- hoverover stuffz
		custombutton[i]:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(.4, .4, .4) end)
		custombutton[i]:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
		-- cooldown stuffz
		custombutton[i]:SetScript("OnUpdate", function()
			local name = GetItemInfo(v)
			if IsEquippedItem(name) == 1 then
				local trinket1id = GetInventoryItemID("player", 13)
				local trinket2id = GetInventoryItemID("player", 14)
				local var = 0
				if trinket1id == v then var = 13 elseif trinket2id == v then var = 14 end
				custombutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
				local start, duration, enabled = GetItemCooldown(v)
				custombutton[i]:SetAttribute("type", "item");
				custombutton[i]:SetAttribute("item", var)
				if enabled ~= 0 then
				custombutton[i].texture:SetVertexColor(1,1,1)
				custombutton[i].cooldown:SetCooldown(start, duration)
				else
				custombutton[i].texture:SetVertexColor(.35, .35, .35)
				end
			elseif GetSpellInfo(v) == v then
				custombutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
				local start, duration, enabled = GetSpellCooldown(v)
				custombutton[i]:SetAttribute("type", "spell");
				custombutton[i]:SetAttribute("spell", v)
				if enabled ~= 0 then
				custombutton[i].texture:SetVertexColor(1,1,1)
				custombutton[i].cooldown:SetCooldown(start, duration)
				else
				custombutton[i].texture:SetVertexColor(.35, .35, .35)
				end
			else
				custombutton[i].value:SetText("ERROR")
			end
		end)
	end
else
	custombar:Hide()
end