local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
		
local trinketbar = CreateFrame("Frame", "CustomTukuiTrinketBar", UIParent, "SecureHandlerStateTemplate")
trinketbar:CreatePanel("Default", 76, 39, "CENTER", UIParent, "CENTER", C.actionbar.trinketbarX, C.actionbar.trinketbarY)
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
	local function OnUpdate(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
	if(TimeSinceLastUpdate > .5) then
		local var = i + 12
		local trinket1id = GetInventoryItemID("player", 13)
		local trinket2id = GetInventoryItemID("player", 14)
		if i == 1 then
			trinketbutton[i].texture:SetTexture(select(10, GetItemInfo(trinket1id)))
			local start, duration, enabled = GetItemCooldown(trinket1id)
			trinketbutton[i].startval = start
			if enabled ~= 0 then
			trinketbutton[i].texture:SetVertexColor(1,1,1)
			trinketbutton[i].cooldown:SetCooldown(start, duration)
			else
			trinketbutton[i].texture:SetVertexColor(.35, .35, .35)
			end	
		else
			trinketbutton[i].texture:SetTexture(select(10, GetItemInfo(trinket2id)))
			local start, duration, enabled = GetItemCooldown(trinket2id)
			trinketbutton[i].startval = start
			if enabled ~= 0 then
			trinketbutton[i].texture:SetVertexColor(1,1,1)
			trinketbutton[i].cooldown:SetCooldown(start, duration)
			else
			trinketbutton[i].texture:SetVertexColor(.35, .35, .35)
			end	
		end
		trinketbutton[i]:SetAttribute("type", "item");
		trinketbutton[i]:SetAttribute("item", var)
		
		if trinketbutton[i].startval == 0 then
			trinketbutton[i].cooldown:SetAlpha(0)
		else
			trinketbutton[i].cooldown:SetAlpha(1)
		end
		TimeSinceLastUpdate = 0
	end
	end
	trinketbutton[i]:SetScript("OnUpdate", OnUpdate)
end
trinketbar:Hide()

-- Toggle
local TBtoggle = CreateFrame("Button", "TrinketBarToggle", UIParent)
TBtoggle:SetTemplate("Default")
TBtoggle:CreateShadow("Default")
TBtoggle:RegisterForClicks("AnyUp")
TBtoggle:SetScript("OnClick", function(self, btn)
	if trinketbar:IsShown() then
		trinketbar:Hide()
	else
		trinketbar:Show()
	end
end)
TBtoggle:Size(18,18)
TBtoggle:Point("BOTTOMRIGHT", ChatBG2, "BOTTOMLEFT", -3, 0)
TBtoggle:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.datatext.color)) end)
TBtoggle:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
TBtoggle.text = T.SetFontString(TBtoggle, C.datatext.font, C.datatext.fontsize)
TBtoggle.text:Point("CENTER", 0, 0)
TBtoggle.text:SetText("|cff319f1bT|r")