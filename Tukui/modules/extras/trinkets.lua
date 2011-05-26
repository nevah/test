local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
--[[
-- custom action bar (add spells in the profiles.lua)		
local trinketbar = CreateFrame("Frame", "CustomTukuiActionBar", UIParent, "SecureHandlerStateTemplate")
trinketbar:CreatePanel("Default", 76, 39, "CENTER", UIParent, "CENTER", 0, -150)
if C.actionbar.trinketbar == true then
		trinketbarline1 = CreateFrame("Frame", nil, trinketbar)
		trinketbarline1:CreatePanel("Default", 2, 5, "BOTTOMRIGHT", trinketbar, "TOPRIGHT", -15, 0)
		trinketbarline1:SetFrameStrata("BACKGROUND")
		
		trinketbarline2 = CreateFrame("Frame", nil, trinketbar)
		trinketbarline2:CreatePanel("Default", 2, 5, "BOTTOMLEFT", trinketbar, "TOPLEFT", 15, 0)
		trinketbarline2:SetFrameStrata("BACKGROUND")
	local custombutton = CreateFrame("Button", "CustomButton", trinketbar, "SecureActionButtonTemplate")
	-- spell stuffz
	for i = 1, 2 do
		--button stuffz
		custombutton[i] = CreateFrame("Button", "CustomButton"..i, trinketbar, "SecureActionButtonTemplate")
		custombutton[i]:CreatePanel("Default", 35, 35, "TOPLEFT", trinketbar, "TOPLEFT", 2, -2)
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
			else
				custombutton[i].value:SetText("ERROR")
			end
		end)
	end
else
	trinketbar:Hide()
end]]