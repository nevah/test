local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

-- custom action bar (add spells in the profiles.lua)		
local trinketbar = CreateFrame("Frame", "CustomTukuiTrinketBar", UIParent, "SecureHandlerStateTemplate")
trinketbar:CreatePanel("Default", 76, 39, "CENTER", UIParent, "CENTER", C.actionbar.trinketbarX, C.actionbar.trinketbarY)
if C.actionbar.trinketbar == true then
	local trinketbutton = CreateFrame("Button", "trinketbutton", trinketbar, "SecureActionButtonTemplate")
	-- spell stuffz
	for i = 1, 2 do
		--button stuffz
		trinketbutton[i] = CreateFrame("Button", "trinketbutton"..i, trinketbar, "SecureActionButtonTemplate")
		trinketbutton[i]:CreatePanel("Default", 35, 35, "TOPLEFT", trinketbar, "TOPLEFT", 2, -2)
		if i ~= 1 then
			trinketbutton[i]:SetPoint("TOPLEFT", trinketbutton[i-1], "TOPRIGHT", 2, 0)
		end
		-- texture settup
		trinketbutton[i].texture = trinketbutton[i]:CreateTexture(nil, "BORDER")
		trinketbutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		trinketbutton[i].texture:SetPoint("TOPLEFT", trinketbutton[i] ,"TOPLEFT", 2, -2)
		trinketbutton[i].texture:SetPoint("BOTTOMRIGHT", trinketbutton[i] ,"BOTTOMRIGHT", -2, 2)
		-- cooldown overlay
		trinketbutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", trinketbutton[i], "CooldownFrameTemplate")
		trinketbutton[i].cooldown:SetAllPoints(trinketbutton[i].texture)				
		-- text settup
		trinketbutton[i].value = trinketbutton[i]:CreateFontString(nil, "ARTWORK")
		trinketbutton[i].value:SetFont(C["media"].font, 15, "OUTLINE")
		trinketbutton[i].value:SetTextColor(1, 0, 0)
		trinketbutton[i].value:SetShadowColor(0, 0, 0, 0.5)
		trinketbutton[i].value:SetShadowOffset(2, -2)
		trinketbutton[i].value:Point("CENTER", trinketbutton[i], "CENTER")
		-- hoverover stuffz
		trinketbutton[i]:StyleButton()
		-- cooldown stuffz
		trinketbutton[i]:SetScript("OnUpdate", function()
		local var = i + 12
		local trinket1id = GetInventoryItemID("player", 13)
		local trinket2id = GetInventoryItemID("player", 14)
		if i == 1 then
			trinketbutton[i].texture:SetTexture(select(10, GetItemInfo(trinket1id)))
			local start, duration, enabled = GetItemCooldown(trinket1id)
			if enabled ~= 0 then
			trinketbutton[i].texture:SetVertexColor(1,1,1)
			trinketbutton[i].cooldown:SetCooldown(start, duration)
			else
			trinketbutton[i].texture:SetVertexColor(.35, .35, .35)
			end	
		else
			trinketbutton[i].texture:SetTexture(select(10, GetItemInfo(trinket2id)))
			local start, duration, enabled = GetItemCooldown(trinket2id)
			if enabled ~= 0 then
			trinketbutton[i].texture:SetVertexColor(1,1,1)
			trinketbutton[i].cooldown:SetCooldown(start, duration)
			else
			trinketbutton[i].texture:SetVertexColor(.35, .35, .35)
			end	
		end
		trinketbutton[i]:SetAttribute("type", "item");
		trinketbutton[i]:SetAttribute("item", var)
		end)
	end
else
	trinketbar:Hide()
end