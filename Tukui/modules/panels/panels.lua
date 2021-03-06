local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local cp = "|cff319f1b" -- +
local cm = "|cff9a1212" -- -

local TukuiBar1 = CreateFrame("Frame", "TukuiBar1", UIParent, "SecureHandlerStateTemplate") -- Mainbar (24)
TukuiBar1:CreatePanel("Default", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, 13) 
TukuiBar1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 4)
TukuiBar1:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
if C.actionbar.disablebar2 == true then 
	TukuiBar1:SetHeight((T.buttonsize) + (T.buttonspacing * 2)) 
else
	TukuiBar1:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
end

if C.general.colorscheme == true then
	TukuiBar1:SetBackdropColor(unpack(C.general.color))
end

local TukuiBar3 = CreateFrame("Frame", "TukuiBar3", UIParent) -- Rightbars
TukuiBar3:CreatePanel("Default", 1, 1, "RIGHT", UIParent, "RIGHT", -14, -14)
TukuiBar3:SetWidth((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar3:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))

if C.general.colorscheme == true then
	TukuiBar3:SetBackdropColor(unpack(C.general.color))
end

local petbg = CreateFrame("Frame", "TukuiPetBar", UIParent, "SecureHandlerStateTemplate")
if C["actionbar"].petbarhorizontal == true then
	petbg:CreatePanel("Default",(T.hpetbuttonsize * 10) + (T.petbuttonspacing * 11) - 4, T.hpetbuttonsize + (T.petbuttonspacing * 2)-4, "BOTTOM", TukuiBar1, "TOP", 0, 0)
else
	petbg:CreatePanel("Default", T.petbuttonsize + (T.petbuttonspacing * 2), (T.petbuttonsize * 10) + (T.petbuttonspacing * 11), "RIGHT", TukuiBar3, "LEFT", -6, 0)
end

if C.general.colorscheme == true then
	petbg:SetBackdropColor(unpack(C.general.color))
end

if C["actionbar"].petbarhorizontal == true then
	TukuiPetBarline1 = CreateFrame("Frame", nil, petbg)
	TukuiPetBarline1:CreatePanel("Default", 2, 4, "TOPLEFT", petbg, "BOTTOMRIGHT", -20, 0)
	TukuiPetBarline1:SetFrameStrata("BACKGROUND")

	TukuiPetBarline2 = CreateFrame("Frame", nil, petbg)
	TukuiPetBarline2:CreatePanel("Default", 2, 4, "TOPRIGHT", petbg, "BOTTOMLEFT", 20, 0)
	TukuiPetBarline2:SetFrameStrata("BACKGROUND")
else
	local ltpetbg1 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground1", petbg)
	ltpetbg1:CreatePanel("Transparent", 8, 2, "LEFT", petbg, "TOPRIGHT", 0, -20)
	ltpetbg1:SetFrameLevel(0)
	
	local ltpetbg2 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground2", petbg)
	ltpetbg2:CreatePanel("Transparent", 8, 2, "LEFT", petbg, "BOTTOMRIGHT", 0, 20)
	ltpetbg2:SetFrameLevel(0)
end

if C["chat"].leftchatbackground == true then
	-- Chat 1 Background
	local chatbg = CreateFrame("Frame", "ChatBG1", UIParent)
	chatbg:CreatePanel("Transparent", 430, 126, "TOPLEFT", ChatFrame1, "TOPLEFT", -5, 29)
	chatbg:Point("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 5, -5)
	chatbg:CreateShadow("Default")
	
	local tabchat1 = CreateFrame("Frame", "ChatBG1Tabs", chatbg)
	tabchat1:CreatePanel("Transparent", 1, 20, "TOPLEFT", chatbg, "TOPLEFT", 5, -5)
	tabchat1:Point("TOPRIGHT", chatbg, "TOPRIGHT", -28, -5)
	tabchat1:CreateShadow("Default")
	
	local copy1 = CreateFrame("Frame", nil, tabchat1)
	copy1:CreatePanel("Transparent", 20, 20, "LEFT", tabchat1, "RIGHT", 3, 0)
	copy1:CreateShadow("Default")
end

if C["chat"].rightchatbackground == true then
	-- Chat 4 Background
	local chatbg2 = CreateFrame("Frame", "ChatBG2", UIParent)
	
	chatbg2:SetScript("OnEvent", function(self)
		if IsAddOnLoaded("Skada") then Skada:SetActive(false) end	
	end)
	
	chatbg2:CreatePanel("Transparent", 430, 126, "TOPLEFT", _G["ChatFrame"..C.chat.rightchatnumber], "TOPLEFT", -5, 29)
	chatbg2:Point("BOTTOMRIGHT", _G["ChatFrame"..C.chat.rightchatnumber], "BOTTOMRIGHT", 5, -5)
	chatbg2:CreateShadow("Default")
	
	local tabchat2 = CreateFrame("Frame", "ChatBG2Tabs", chatbg2)
	tabchat2:CreatePanel("Transparent", 1, 20, "TOPLEFT", chatbg2, "TOPLEFT", 5, -5)
	tabchat2:Point("TOPRIGHT", chatbg2, "TOPRIGHT", -28, -5)
	tabchat2:CreateShadow("Default")
	
	local copy2 = CreateFrame("Frame", nil, tabchat2)
	copy2:CreatePanel("Transparent", 20, 20, "LEFT", tabchat2, "RIGHT", 3, 0)
	copy2:CreateShadow("Default")

	if C.Addon_Skins.background then
		local ca2 = CreateFrame("Frame", nil, chatbg2)
		ca2:CreatePanel("Default", 1, 18, "BOTTOM", chatbg2, "TOP", 0, 0)
		ca2:Point("BOTTOMRIGHT", chatbg2, "TOPRIGHT", 0, 28)
		ca2:Point("BOTTOMLEFT", chatbg2, "TOPLEFT", 0, 28)
		ca2:CreateShadow("Default")
		ca2:SetAlpha(0)
		
		ca2.t = ca2:CreateFontString(nil, "OVERLAY")
		ca2.t:SetPoint("CENTER")
		ca2.t:SetFont(C.datatext.font, C.datatext.fontsize)
		ca2.t:SetText(cm.."METERS|r")
		ca2:SetScript("OnEnter", function() ca2:SetAlpha(1) end)
		ca2:SetScript("OnLeave", function() ca2:SetAlpha(0) end)
		ca2:SetScript("OnMouseDown", function()
			chatbg2:Hide()
			_G["ChatFrame"..C.chat.rightchatnumber]:Hide()
			_G["ChatFrame"..C.chat.rightchatnumber.."Tab"]:Hide()
			AddonBGPanel:Show()
			if IsAddOnLoaded("Recount") then _G.Recount.MainWindow:Show() end
			if IsAddOnLoaded("Omen") then OmenAnchor:Show() end
			if IsAddOnLoaded("Skada") then Skada:SetActive(true) end
		end)

	end
end

local TukuiBarLeft = CreateFrame("Frame", "TukuiBarLeft", UIParent, "SecureHandlerStateTemplate") -- Bar on top of Main bar (12)
TukuiBarLeft:CreatePanel("Default", 1, 1, "BOTTOMLEFT", ChatBG1, "BOTTOMRIGHT", 6, 0)
TukuiBarLeft:SetWidth(33)
TukuiBarLeft:SetHeight(178)
if C.general.colorscheme == true then
	TukuiBarLeft:SetBackdropColor(unpack(C.general.color))
end

local TukuiBarRight = CreateFrame("Frame", "TukuiBarRight", UIParent, "SecureHandlerStateTemplate") -- Bar on top of Main bar (12)
TukuiBarRight:CreatePanel("Default", 1, 1, "BOTTOMRIGHT", ChatBG2, "BOTTOMLEFT", -6, 0)
TukuiBarRight:SetWidth(33)
TukuiBarRight:SetHeight(178)
if C.general.colorscheme == true then
	TukuiBarRight:SetBackdropColor(unpack(C.general.color))
end

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "TukuiInfoLeft", TukuiBar1)
if C.panels.switchchats ~= true or C.panels.switchdatatext == true then
	ileft:CreatePanel("Default", T.InfoLeftRightWidth, 19, "BOTTOM", ChatBG1, "TOP", 0, -2)
	ileft:Point("BOTTOMLEFT", ChatBG1, "TOPLEFT", 0, 6)
	ileft:Point("BOTTOMRIGHT", ChatBG1, "TOPRIGHT", 0, 6)
else
	ileft:CreatePanel("Default", T.InfoLeftRightWidth, 19, "BOTTOM", ChatBG2, "TOP", 0, -2)
	ileft:Point("BOTTOMLEFT", ChatBG2, "TOPLEFT", 0, 6)
	ileft:Point("BOTTOMRIGHT", ChatBG2, "TOPRIGHT", 0, 6)
end
ileft:SetFrameLevel(2)

ileftline1 = CreateFrame("Frame", nil, ileft)
ileftline1:CreatePanel("Default", 2, 5, "TOPLEFT", ileft, "BOTTOMRIGHT", -20, 0)
ileftline1:SetFrameStrata("BACKGROUND")

ileftline2 = CreateFrame("Frame", nil, ileft)
ileftline2:CreatePanel("Default", 2, 5, "TOPRIGHT", ileft, "BOTTOMLEFT", 20, 0)
ileftline2:SetFrameStrata("BACKGROUND")

if C.general.colorscheme == true then
	ileft:SetBackdropColor(unpack(C.general.color))
end

-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "TukuiInfoRight", TukuiBar1)
if C.panels.switchchats ~= true or C.panels.switchdatatext == true then
	iright:CreatePanel("Default", T.InfoLeftRightWidth, 19, "BOTTOM", ChatBG2, "TOP", 0, -2)
	iright:Point("BOTTOMLEFT", ChatBG2, "TOPLEFT", 0, 6)
	iright:Point("BOTTOMRIGHT", ChatBG2, "TOPRIGHT", 0, 6)
else
	iright:CreatePanel("Default", T.InfoLeftRightWidth, 19, "BOTTOM", ChatBG1, "TOP", 0, -2)
	iright:Point("BOTTOMLEFT", ChatBG1, "TOPLEFT", 0, 6)
	iright:Point("BOTTOMRIGHT", ChatBG1, "TOPRIGHT", 0, 6)
end
if C.chat.rightchatbackground ~= true then
	iright:ClearAllPoints()
	iright:Point("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -6, 6)
end
iright:SetFrameLevel(2)

irightline1 = CreateFrame("Frame", nil, iright)
irightline1:CreatePanel("Default", 2, 5, "TOPLEFT", iright, "BOTTOMRIGHT", -20, 0)
irightline1:SetFrameStrata("BACKGROUND")

irightline2 = CreateFrame("Frame", nil, iright)
irightline2:CreatePanel("Default", 2, 5, "TOPRIGHT", iright, "BOTTOMLEFT", 20, 0)
irightline2:SetFrameStrata("BACKGROUND")

if C.general.colorscheme == true then
	iright:SetBackdropColor(unpack(C.general.color))
end

-- Info at top
local itopl = CreateFrame("Frame", "TukuiTopStatsLeft", UIParent)
local itopr = CreateFrame("Frame", "TukuiTopStatsRight", UIParent)
itopl:CreatePanel("Default", 75, 20, "RIGHT", Spec, "LEFT", -3, 0)
itopr:CreatePanel("Default", 75, 20, "LEFT", Spec, "RIGHT", 3, 0)

if C.general.colorscheme == true then
	itopl:SetBackdropColor(unpack(C.general.color))
	itopr:SetBackdropColor(unpack(C.general.color))	
end

if TukuiMinimap then	
	if C["datatext"].zonepanel == true then
		local zonepanel = CreateFrame("Frame", "TukuiZonePanel", TukuiMinimap)
		zonepanel:CreatePanel("Default", TukuiMinimap:GetWidth(), 19, "TOP", TukuiMinimap, "BOTTOM", 0, -2)
		zonepanel:CreateShadow("Default")
	end
end

--BATTLEGROUND STATS FRAME
if C["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoLeftBattleGround", UIParent)
	bgframe:CreatePanel("Default", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(ileft)
	bgframe:SetFrameStrata("LOW")
	bgframe:SetFrameLevel(3)
	bgframe:EnableMouse(true)
end

-- BNToastFrame Anchorframe
local bnet = CreateFrame("Frame", "TukuiBnetHolder", UIParent)
bnet:CreatePanel("Default", BNToastFrame:GetWidth(), BNToastFrame:GetHeight(), "TOPRIGHT", TukuiMinimap, "TOPLEFT", -(C.databars.settings.width+16), 0)
bnet:SetClampedToScreen(true)
bnet:SetMovable(true)
bnet:SetBackdropBorderColor(1,0,0)
bnet.text = T.SetFontString(bnet, C.media.font, 12)
bnet.text:SetPoint("CENTER")
bnet.text:SetText("Move BnetFrame")
bnet:Hide()

-- Shadows
iright:CreateShadow("Default")
ileft:CreateShadow("Default")
TukuiBar1:CreateShadow("Default")
TukuiBarLeft:CreateShadow("Default")
TukuiBarRight:CreateShadow("Default")
TukuiBar3:CreateShadow("Default")
petbg:CreateShadow("Default")
BNToastFrame:CreateShadow("Default")

----------------------------------------------------------------------------------------
--	ShieldMonitor skin
----------------------------------------------------------------------------------------
local SMSkin = CreateFrame("Frame")
SMSkin:RegisterEvent("PLAYER_LOGIN")
SMSkin:SetScript("OnEvent", function(self, event, addon)
	if not IsAddOnLoaded("shieldmonitor") then return end
	
	Shieldmonitor_Options.scale = 1
	
	shieldmonitor_Frame:SetTemplate("Default")
	shieldmonitor_Frame:HookScript("OnShow", function(self)
		self:SetBackdropBorderColor(unpack(C.general.bordercolor))
	end)
	shieldmonitor_Frame:RegisterEvent("UNIT_AURA")
	shieldmonitor_Frame:HookScript("OnEvent", function(self)
		self:SetBackdropBorderColor(unpack(C.general.bordercolor))
	end)
	shieldmonitor_Frame:SetSize(TukuiPlayer:GetWidth()+4, 12)
	shieldmonitor_Frame:ClearAllPoints()
	shieldmonitor_Frame:Point("BOTTOMRIGHT", TukuiPlayer, "TOPRIGHT", 2, -11)
	shieldmonitor_Frame:CreateShadow("Default")
	shieldmonitor_Frame:SetFrameStrata("HIGH")
	
	shieldmonitor_Bar:SetStatusBarTexture(C.media.normTex)
	shieldmonitor_Bar:ClearAllPoints()
	shieldmonitor_Bar:SetPoint("TOPLEFT", shieldmonitor_Frame, "TOPLEFT", 2, -2)
	shieldmonitor_Bar:SetPoint("BOTTOMRIGHT", shieldmonitor_Frame, "BOTTOMRIGHT", -2, 2)

	shieldmonitor_FrameIcon1:Hide()

	shieldmonitor_BarText:SetFont(C.media.uffont, 8, "THINOUTLINE")
	shieldmonitor_BarText:SetPoint("CENTER", shieldmonitor_Bar, "CENTER", 0, 0)

	shieldmonitor_FrameDuration:SetFont(C.media.uffont, 8, "THINOUTLINE")
	shieldmonitor_FrameDuration:SetParent(shieldmonitor_Bar)
	shieldmonitor_FrameDuration:ClearAllPoints()
	shieldmonitor_FrameDuration:SetPoint("RIGHT", shieldmonitor_Frame, "RIGHT", -2, 0)
end)

-- BELOW IS BOOMKIN SHIT!
------------------------------------------------------------------------
	-- Balance Power Panel              [MY EDIT]
------------------------------------------------------------------------
if IsAddOnLoaded("BalancePowerTracker") then
if (TukuiDB.myclass == "DRUID") then
	local eclipseBar = CreateFrame("Frame", "EclipseBar", UIParent)
	eclipseBar:CreatePanel(nil, 1, 1, "CENTER", BalancePowerTrackerBackgroundFrame, "CENTER", 0, 0)
	eclipseBar:ClearAllPoints()
	eclipseBar:Point("TOPLEFT", BalancePowerTrackerBackgroundFrame, "TOPLEFT", 0, 0)
	eclipseBar:Point("BOTTOMRIGHT", BalancePowerTrackerBackgroundFrame, "BOTTOMRIGHT", 0, 0)
	eclipseBar:CreateShadow("Default")
	
	local eclipseBarfunc = CreateFrame("Frame")
	eclipseBarfunc:RegisterEvent("PLAYER_ENTERING_WORLD")
	eclipseBarfunc:RegisterEvent("UNIT_AURA")
	eclipseBarfunc:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	eclipseBarfunc:RegisterEvent("PLAYER_TALENT_UPDATE")
	eclipseBarfunc:RegisterEvent("UNIT_TARGET")
	eclipseBarfunc:SetScript("OnEvent", function(self)
    local activeTalent = GetPrimaryTalentTree()
    local shift = GetShapeshiftForm()
	local grace = select(7, UnitAura("player", "Nature's Grace", nil, "HELPFUL"))
    	if grace then
			eclipseBar:SetBackdropBorderColor(205, 25, 0, 1)
		else
			eclipseBar:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		end

		if activeTalent == 1 then
		    if shift == 1 or shift == 2 or shift == 3 or shift == 4 or shift == 6 then
		        eclipseBar:Hide()
			else
			    eclipseBar:Show()
			end
		else
		    eclipseBar:Hide()
		end
	end)

	
end
end
------------------------------------------------------------------------
-- T11 Panels              [MY EDIT]  Astral Alignment
------------------------------------------------------------------------
if (TukuiDB.myclass == "DRUID") then
	local t11bar1 = CreateFrame("Frame", "T11Bar1", UIParent)
	local t11bar2 = CreateFrame("Frame", "T11Bar2", UIParent)
	local t11bar3 = CreateFrame("Frame", "T11Bar3", UIParent)
	
	t11bar1:CreatePanel(nil, 1, 2, "TOPLEFT", BalancePowerTrackerBackgroundFrame, "BOTTOMLEFT", 3, 2)
	t11bar1:CreateShadow("Default")
	t11bar1.shadow:SetBackdropBorderColor(192, 0, 0, 1)
	t11bar1:SetWidth(78)
	t11bar1:SetBackdropBorderColor(192, 0, 0, 1)
	t11bar1:SetFrameStrata("HIGH")
	t11bar1:Hide()
	
	t11bar2:CreatePanel(nil, 1, 2, "TOP", BalancePowerTrackerBackgroundFrame, "BOTTOM", 0, 2)
	t11bar2:CreateShadow("Default")
	t11bar2.shadow:SetBackdropBorderColor(192, 0, 0, 1)
	t11bar2:SetWidth(78)
	t11bar2:SetBackdropBorderColor(192, 0, 0, 1)
	t11bar2:SetFrameStrata("HIGH")
	t11bar2:Hide()
	
	t11bar3:CreatePanel(nil, 1, 2, "TOPRIGHT", BalancePowerTrackerBackgroundFrame, "BOTTOMRIGHT", -3, 2)
	t11bar3:CreateShadow("Default")
	t11bar3.shadow:SetBackdropBorderColor(192, 0, 0, 1)
	t11bar3:SetWidth(78)
	t11bar3:SetBackdropBorderColor(192, 0, 0, 1)
	t11bar3:SetFrameStrata("HIGH")
	t11bar3:Hide()
	
	local t11barfunc = CreateFrame("Frame")
	t11barfunc:RegisterEvent("PLAYER_ENTERING_WORLD")
	t11barfunc:RegisterEvent("UNIT_AURA")
	t11barfunc:SetScript("OnEvent", function(self)
	local _,_,_,count,_,_,i,_,_ = UnitAura("player", "Astral Alignment", nil, "HELPFUL")
		if i then
			if count > 0 then
				t11bar1:Show()
			else
				t11bar1:Hide()
			end
			if count > 1 then
				t11bar2:Show()
			else
				t11bar2:Hide()
			end
			if count > 2 then
				t11bar3:Show()
			else
				t11bar3:Hide()
			end
		else
			t11bar1:Hide()
			t11bar2:Hide()
			t11bar3:Hide()
		end
	end)
end
