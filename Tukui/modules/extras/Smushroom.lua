-- Wild Mushroom Tracker Addon By Smelly
-- Credits to Hydra for code inspiration :D
local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

if T.myclass ~= "DRUID" then return end

local tMushroom = {}
local options = {
	anchor = {"CENTER", UIParent, "CENTER", -48, 25},
	color = {.3, .3, .3},
	readycolor = {.2, .9, .1},
}

for i = 1, 3 do
	tMushroom[i] = CreateFrame("Frame", "tMushroom"..i, UIParent)
	tMushroom[i]:CreatePanel("Default", 45, 20, "CENTER", UIParent, "CENTER", 0, 0)	
	if i == 1 then
		tMushroom[i]:ClearAllPoints()
		tMushroom[i]:Point(unpack(options.anchor))
	else	
		tMushroom[i]:Point("LEFT", tMushroom[i-1], "RIGHT", 3, 0)
	end
	tMushroom[i].status = CreateFrame("StatusBar", "status"..i, tMushroom[i])
	tMushroom[i].status:SetStatusBarTexture(C.media.normTex)
	tMushroom[i].status:SetFrameLevel(6)
	tMushroom[i].status:SetStatusBarColor(unpack(options.color))
	tMushroom[i].status:Point("TOPLEFT", tMushroom[i], "TOPLEFT", 2, -2)
	tMushroom[i].status:Point("BOTTOMRIGHT", tMushroom[i], "BOTTOMRIGHT", -2, 2)
	tMushroom[i].text = T.SetFontString(tMushroom[i].status, C.media.font, 12)
	tMushroom[i].text:Point("CENTER", tMushroom[i].status, "CENTER", 0, 0)
	tMushroom[i].name = T.SetFontString(tMushroom[i].status, C.media.font, 12)
	tMushroom[i].name:Point("LEFT", tMushroom[i].status, "LEFT", 3, 0)
end

local function FormatTime(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", ceil(s / day))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= minute / 12 then
		return floor(s)
	end
	return format("%.1f", s)
end

local function MushroomUpdate(self)
	for i = 1, 3 do
		local haveTotem, totemName, start, duration = GetTotemInfo(i)
		if haveTotem then
			tMushroom[i]:Show()
			local timeLeft = (start+duration) - GetTime()
			tMushroom[i].status:SetMinMaxValues(0, 300)
			tMushroom[i].status:SetValue(timeLeft)
			local tTime = FormatTime(timeLeft)
			tMushroom[i].text:SetText(tTime)
		else
			tMushroom[i]:Hide()
		end
		if i == 3 and haveTotem then
			for k = 1, 3 do
				tMushroom[k].status:SetStatusBarColor(unpack(options.readycolor))
			end
		else
			for k = 1, 3 do
				tMushroom[k].status:SetStatusBarColor(unpack(options.color))
			end
		end
	end 	
	
end

local UpdateMushroom = CreateFrame("Frame")
UpdateMushroom:SetScript("OnUpdate", MushroomUpdate)