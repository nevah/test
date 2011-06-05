local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

-- custom action bar (add spells in the profiles.lua)		
local custombar = CreateFrame("Frame", "CustomTukuiActionBar", UIParent, "SecureHandlerStateTemplate")
custombar:CreatePanel("Default", 1, 39, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, -6)
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

local customprimarybutton = CreateFrame("Button", "CustomPrimaryButton", custombar, "SecureActionButtonTemplate")
custombar:SetWidth((totalprimary)*35 + ((totalprimary)+1)*2)
-- spell stuffz
for i, v in ipairs(C.actionbar.custombar.primary) do	
	--button stuffz
	customprimarybutton[i] = CreateFrame("Button", "CustomPrimaryButton"..i, custombar, "SecureActionButtonTemplate")
	customprimarybutton[i]:CreatePanel("Default", 35, 35, "TOPLEFT", custombar, "TOPLEFT", 2, -2)
	if i ~= 1 then
		customprimarybutton[i]:SetPoint("TOPLEFT", customprimarybutton[i-1], "TOPRIGHT", 2, 0)
	end
	-- texture settup
	customprimarybutton[i].texture = customprimarybutton[i]:CreateTexture(nil, "BORDER")
	customprimarybutton[i].texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	customprimarybutton[i].texture:Point("TOPLEFT", customprimarybutton[i] ,"TOPLEFT", 2, -2)
	customprimarybutton[i].texture:Point("BOTTOMRIGHT", customprimarybutton[i] ,"BOTTOMRIGHT", -2, 2)
	-- cooldown overlay
	customprimarybutton[i].cooldown = CreateFrame("Cooldown", "$parentCD", customprimarybutton[i], "CooldownFrameTemplate")
	customprimarybutton[i].cooldown:SetAllPoints(customprimarybutton[i].texture)				
	-- text settup
	customprimarybutton[i].value = customprimarybutton[i]:CreateFontString(nil, "ARTWORK")
	customprimarybutton[i].value:SetFont(C["media"].font, 12, "OUTLINE")
	customprimarybutton[i].value:SetText("ERROR")
	customprimarybutton[i].value:SetTextColor(1, 0, 0)
	customprimarybutton[i].value:Hide()
	customprimarybutton[i].value:Point("CENTER", customprimarybutton[i], "CENTER")
	-- hoverover stuffz
	customprimarybutton[i]:StyleButton()
	-- cooldown stuffz
--local LastUpdate = .5
	
local function Update(self, t)
--LastUpdate = LastUpdate - t

--if LastUpdate < 0 then
	local name = GetItemInfo(v)
		if IsEquippedItem(name) == 1 then
			customprimarybutton[i].value:Hide()
			local trinket1id = GetInventoryItemID("player", 13)
			local trinket2id = GetInventoryItemID("player", 14)
			local var = 0
			if trinket1id == v then var = 13 elseif trinket2id == v then var = 14 end
			customprimarybutton[i].texture:SetTexture(select(10, GetItemInfo(v)))
			local start, duration, enabled = GetItemCooldown(v)
			customprimarybutton[i]:SetAttribute("type", "item");
			customprimarybutton[i]:SetAttribute("item", var)
			if enabled ~= 0 then
			customprimarybutton[i].texture:SetVertexColor(1,1,1)
			customprimarybutton[i].cooldown:SetCooldown(start, duration)
			else
			customprimarybutton[i].texture:SetVertexColor(.35, .35, .35)
			end
		elseif GetSpellInfo(v) == v then
			customprimarybutton[i].value:Hide()
			customprimarybutton[i].texture:SetTexture(select(3, GetSpellInfo(v)))
			local start, duration, enabled = GetSpellCooldown(v)
			customprimarybutton[i]:SetAttribute("type", "spell");
			customprimarybutton[i]:SetAttribute("spell", v)
			if enabled ~= 0 then
			customprimarybutton[i].texture:SetVertexColor(1,1,1)
			customprimarybutton[i].cooldown:SetCooldown(start, duration)
			else
			customprimarybutton[i].texture:SetVertexColor(.35, .35, .35)
			end
		else
			customprimarybutton[i].value:Show()
		end
		--LastUpdate = .5 -- now reset the variable
	--end
end
	customprimarybutton[i]:SetScript("OnUpdate", Update)
end