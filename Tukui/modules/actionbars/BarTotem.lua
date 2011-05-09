local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if C["actionbar"].enable ~= true then return end

-- we just use default totem bar for shaman
-- we parent it to our shapeshift bar.
-- This is approx the same script as it was in WOTLK Tukui version.

if T.myclass == "SHAMAN" then
	if MultiCastActionBarFrame then
		MultiCastActionBarFrame:SetScript("OnUpdate", nil)
		MultiCastActionBarFrame:SetScript("OnShow", nil)
		MultiCastActionBarFrame:SetScript("OnHide", nil)
		MultiCastActionBarFrame:SetParent(TukuiShiftBar)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:Point("BOTTOMLEFT", TukuiShiftBar, -2, -3)
 
		hooksecurefunc("MultiCastActionButton_Update",function(actionbutton) if not InCombatLockdown() then actionbutton:SetAllPoints(actionbutton.slotButton) end end)
 
		MultiCastActionBarFrame.SetParent = T.dummy
		MultiCastActionBarFrame.SetPoint = T.dummy
		MultiCastRecallSpellButton.SetPoint = T.dummy
	
		-- Border
		local tborder = CreateFrame("Frame", "TotemBorder", MultiCastActionBarFrame)
		tborder:SetTemplate("Transparent")
		tborder:CreateShadow("Default")
		tborder:Size(MultiCastActionBarFrame:GetWidth(), MultiCastActionBarFrame:GetHeight())
		tborder:SetFrameLevel(1)
		tborder:SetFrameStrata("BACKGROUND")
		tborder:Point("LEFT", -2, -1)
		local ssborderln1 = CreateFrame("Frame", nil, TotemBorder)
		ssborderln1:CreatePanel("Default", 5, 2, "TOPRIGHT", TotemBorder, "TOPLEFT", 0, -5)
		local ssborderln2 = CreateFrame("Frame", nil, TotemBorder)
		ssborderln2:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", TotemBorder, "BOTTOMLEFT", 0, 5)
	end
end