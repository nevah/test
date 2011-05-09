-- Wild Mushroom Tracker Addon By Smelly
-- Credits to Hydra for code inspiration :D

local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
local tMushroom = {}
local options = {
	anchor = {"TOPLEFT", TukuiPlayer, "BOTTOMLEFT", -46, -4},
	color = {
		[1] = {192, 0, 0},
		[2] = {255, 140, 0},
		[3] = {0, 205, 0},
		},
}
if T.myclass == "DRUID" then
for i = 1, 3 do
	tMushroom[i] = CreateFrame("Frame", "tMushroom"..i, UIParent)
	tMushroom[i]:CreatePanel("Default", 43, 20, "CENTER", UIParent, "CENTER", 0, 0)	
	if i == 1 then
		tMushroom[i]:ClearAllPoints()
		tMushroom[i]:Point(unpack(options.anchor))
	else	
		tMushroom[i]:Point("TOP", tMushroom[i-1], "BOTTOM", 0, -3)
	end
	tMushroom[i].status = CreateFrame("StatusBar", "status"..i, tMushroom[i])
	tMushroom[i].status:SetStatusBarTexture(C.media.normTex)
	tMushroom[i].status:SetFrameLevel(6)
	tMushroom[i].status:Point("TOPLEFT", tMushroom[i], "TOPLEFT", 2, -2)
	tMushroom[i].status:Point("BOTTOMRIGHT", tMushroom[i], "BOTTOMRIGHT", -2, 2)
	tMushroom[i].text = T.SetFontString(tMushroom[i].status, C.media.font, 12)
	tMushroom[i].text:Point("LEFT", tMushroom[i].status, "LEFT", 3, 0)
	tMushroom[i].name = T.SetFontString(tMushroom[i].status, C.media.font, 12)
	tMushroom[i].name:Point("LEFT", tMushroom[i].status, "LEFT", 3, 0)

	tMushroom[i].status:SetStatusBarColor(unpack(options.color[i]))
	
	--[[	if i == 1 then 
	tMushroom[i].status:SetStatusBarColor(unpack(options.color1))
	end
	if i == 2 then 
	tMushroom[i].status:SetStatusBarColor(unpack(options.color2))
	end
	if i == 3 then 
	tMushroom[i].status:SetStatusBarColor(unpack(options.color3))
	end]]
end

local function MushroomUpdate(self)
	for i = 1, 3 do
		local haveTotem, totemName, start, duration = GetTotemInfo(i)
		if haveTotem then
			tMushroom[i]:Show()
			local timeLeft = (start+duration) - GetTime()
			tMushroom[i].status:SetMinMaxValues(0, 300)
			tMushroom[i].status:SetValue(timeLeft)
			tMushroom[i].text:SetText(floor(timeLeft).."s")
			--tMushroom[i].name:SetText("Mushroom "..i)
		else
			tMushroom[i]:Hide()
		end
	end 	
end

local UpdateMushroom = CreateFrame("Frame")
UpdateMushroom:SetScript("OnUpdate", MushroomUpdate)
end