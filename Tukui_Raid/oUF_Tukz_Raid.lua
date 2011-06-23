local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable == true then return end

local font2 = C["media"].uffont
local font1 = C["media"].font
local fontsize = C["unitframes"].fontsize

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(unpack(C.media.backdropcolor))
	
	self.menu = T.SpawnMenu
	
	local health = CreateFrame('StatusBar', nil, self)
	health:Height(16)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(C["media"].normTex)
	self.Health = health

	health.bg = self.Health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(self.Health)
	health.bg:SetTexture(C["media"].blank)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	health.PostUpdate = T.PostUpdatePetColor
	health.frequentUpdates = true
	
	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
		health.bg:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
		health.bg:SetTexture(.6, .6, .6)
		if C.unitframes.ColorGradient then
			health.colorSmooth = true
			health.bg:SetTexture(.2, .2, .2)
		end
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true	
		health.bg:SetTexture(.1, .1, .1)		
	end
	
	local power = CreateFrame("StatusBar", nil, self)
	power:Height(2)
	power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
	power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
	power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
	power:SetStatusBarTexture(C["media"].normTex)
	self.Power = power
	
	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(C["media"].normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.3
	self.Power.bg = power.bg
	
	if C.unitframes.unicolor == true then
		power.colorClass = true				
	else
		power.colorPower = true
	end
		
	local name = health:CreateFontString(nil, 'OVERLAY')
	name:SetFont(font2, fontsize, "THINOUTLINE")
	name:Point("BOTTOMLEFT", self, "TOPLEFT", -1, 4)
	if C["unitframes"].unicolor == true then
		self:Tag(name, '[Tukui:getnamecolor][Tukui:namemedium]')
	else
		self:Tag(name, '[Tukui:namemedium]')
	end
	self.Name = name
	
	local status = health:CreateFontString(nil, 'OVERLAY')
		status:SetFont(font2, fontsize, "THINOUTLINE")
		status:Point("RIGHT", self, "RIGHT", 0, 1)
		self:Tag(status, '[Tukui:dead][Tukui:afk][Tukui:offline]')
	
	if C["unitframes"].showsymbols == true then
		RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(14*T.raidscale)
		RaidIcon:Width(14*T.raidscale)
		RaidIcon:SetPoint("CENTER", self, "CENTER")
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
    end
	
	local LFDRole = health:CreateTexture(nil, "OVERLAY")
    LFDRole:Height(6*T.raidscale)
    LFDRole:Width(6*T.raidscale)
	LFDRole:Point("TOPLEFT", 2, -2)
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole
	
	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*T.raidscale)
	ReadyCheck:Width(12*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = false
	self.DebuffHighlightFilter = true

	if C["unitframes"].showsmooth == true then
		health.Smooth = true
	end
	
	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	local border = CreateFrame("Frame", nil, health)
	border:CreatePanel("Default", 1, 1, "TOPLEFT", health, "TOPLEFT", -2, 2)
	border:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", 2, -2)
	border:CreateShadow("Default")
	self.panel = border

	return self
end

oUF:RegisterStyle('TukuiDpsR40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDpsR40")
	
	local spawnG = "solo,raid,party"
	if C["unitframes"].gridonly ~= true then spawnG = "custom [@raid16,exists] show;hide" end
	
	local pointG = "LEFT"
	if C.unitframes.gridvertical then pointG = "BOTTOM" end
	
	local capG = "BOTTOM"
	if C.unitframes.gridvertical then capG = "LEFT" end
	
	local raid = self:SpawnHeader(
		"TukuiGrid", nil, spawnG,
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', T.Scale(68),
		'initial-height', T.Scale(19),
		"showParty", true,
		"showPlayer", C["unitframes"].showplayerinparty, 
		"showRaid", true, 
		"xoffset", T.Scale(8),
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"maxColumns", 8,
		"unitsPerColumn", 5,
		"columnSpacing", T.Scale(16),
		"point", pointG,
		"columnAnchorPoint", capG,
		"showSolo", C.unitframes.gridsolo
	)
	if C.panels.switchchats == true and C.panels.switchdatatext == true then	
		if TukuiInfoRight then
			raid:Point("BOTTOMLEFT", TukuiInfoRight, "TOPLEFT", 2, 6)
		else
			raid:Point("BOTTOMLEFT", ChatFrame4, "TOPLEFT", 2, 21)
		end
	else
		if TukuiInfoLeft then
			raid:Point("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 2, 6)
		else
			raid:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 2, 21)
		end
	end
end)
-- only show 5 groups in raid (25 mans raid)
local MaxGroup = CreateFrame("Frame")
MaxGroup:RegisterEvent("PLAYER_ENTERING_WORLD")
MaxGroup:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MaxGroup:SetScript("OnEvent", function(self)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
		TukuiGrid:SetAttribute("groupFilter", "1,2,3,4,5")
	else
		TukuiGrid:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
	end
end)