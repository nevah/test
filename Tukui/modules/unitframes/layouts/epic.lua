local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not C.unitframes.enable then return end

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}
------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local font1 = C["media"].uffont
local font2 = C["media"].font
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex
local fontsize = C.unitframes.fontsize
local playerwidth = 214
local nameoffset = 4
local lafo = C.unitframes.largefocus

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = T.oUF_colors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu? lol
	self.menu = T.SpawnMenu

	-- backdrop for every units
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 0)
	
	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
	RaidIcon:SetHeight(18)
	RaidIcon:SetWidth(18)
	RaidIcon:SetPoint("TOP", 0, 8)
	self.RaidIcon = RaidIcon
	
	-- Fader
	if C.unitframes.fader then
		if (unit and not unit:find("arena%d")) or (unit and not unit:find("boss%d")) then
			self.Fader = {
				[1] = {Combat = 1, Arena = 1, Instance = 1}, 
				[2] = {PlayerTarget = C.unitframes.fader_alpha, PlayerNotMaxHealth = C.unitframes.fader_alpha, PlayerNotMaxMana = C.unitframes.fader_alpha}, 
				[3] = {Stealth = C.unitframes.fader_alpha},
				[4] = {notCombat = 0, PlayerTaxi = 0},
			}
		end
		self.NormalAlpha = 1
	end
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then
		-- create a panel
		local panel = CreateFrame("Frame", nil, self)
		panel:Height(17)
		panel:SetFrameLevel(2)
		panel:SetFrameStrata("MEDIUM")
		self.panel = panel
	
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(23)
		health:Point("TOPLEFT", 0, -16)
		health:Point("TOPRIGHT", 0, -16)
		health:SetStatusBarTexture(normTex)
				
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
	
		health.value = T.SetFontString(health, font1, fontsize, "THINOUTLINE")
		if unit == "player" then
			health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		elseif unit == "target" then
			health.value:Point("LEFT", health, "LEFT", 4, 0)
		end
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG

		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		-- Raidicon repositioning
		RaidIcon:Point("TOP", health, "TOP", 0, 12)
		
		if C["unitframes"].unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)	
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end			
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true
			healthBG:SetTexture(.1, .1, .1)			
		end

		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(2)
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -3)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -3)
		power:SetStatusBarTexture(normTex)
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(panel, font1, fontsize, "THINOUTLINE")
		if unit == "player" then
			power.value:Point("LEFT", panel, "LEFT", 4, 0)
		elseif unit == "target" then
			power.value:Point("RIGHT", panel, "RIGHT", -4, 0)
		end
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		if C.unitframes.powerClasscolored then
			power.colorTapping = true
			power.colorClass = true		
		else
			power.colorPower = true
		end

		-- Panel position
		panel:Point("BOTTOMLEFT", health, "TOPLEFT", -2, 2)
		panel:Point("BOTTOMRIGHT", health, "TOPRIGHT", 2, 2)	
	
		-- portraits
		if (C["unitframes"].charportrait == true) then
			local portrait = CreateFrame("PlayerModel", self:GetName().."_Portrait", self)
			portrait:SetFrameLevel(8)
			portrait:SetWidth(55)
			if unit == "player" then
				portrait:Point("TOPRIGHT", panel, "TOPLEFT", -5, -4)
				portrait:Point("BOTTOMRIGHT", power, "BOTTOMLEFT", -5, 0)
			elseif unit == "target" then
				portrait:Point("TOPLEFT", panel, "TOPRIGHT", 5, -4)
				portrait:Point("BOTTOMLEFT", power, "BOTTOMRIGHT", 5, 0)
			end
			-- table.insert(self.__elements, T.HidePortrait)
			portrait.PostUpdate = T.PortraitUpdate --Worgen Fix (Hydra)
			self.Portrait = portrait
			
			-- Portrait Border
			portrait.bg = CreateFrame("Frame",nil,portrait)
			portrait.bg:CreatePanel("Default", 1 , 1, "BOTTOMLEFT", portrait, "BOTTOMLEFT", -2, -2)
			portrait.bg:Point("TOPRIGHT", portrait, "TOPRIGHT", 2, 2)
			portrait.bg:CreateShadow("Default")
			
			local AuraTracker = CreateFrame("Frame")
			self.AuraTracker = AuraTracker
			
			AuraTracker.icon = portrait:CreateTexture(nil, "OVERLAY")
			AuraTracker.icon:SetAllPoints()
			AuraTracker.icon:SetTexCoord(0.08, 0.92, 0.18, .82)
			
			AuraTracker.text = T.SetFontString(portrait, font2, 15, "THINOUTLINE")
			AuraTracker.text:SetPoint("CENTER")
			AuraTracker:SetScript("OnUpdate", updateAuraTrackerTime)
		end
		
		if T.myclass == "PRIEST" and C["unitframes"].weakenedsoulbar then
			local ws = CreateFrame("StatusBar", self:GetName().."_WeakenedSoul", power)
			ws:SetAllPoints(power)
			ws:SetStatusBarTexture(C.media.normTex)
			ws:GetStatusBarTexture():SetHorizTile(false)
			ws:SetBackdrop(backdrop)
			ws:SetBackdropColor(unpack(C.media.backdropcolor))
			ws:SetStatusBarColor(205/255, 20/255, 20/255)
			
			self.WeakenedSoul = ws
		end
		
		-- Healthbar Border
		health.border = CreateFrame("Frame", nil, health)
		health.border:CreatePanel("Default",1,1, "TOPLEFT", health, "TOPLEFT", -2, 2)
		health.border:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", 2, -2)
		health.border:CreateShadow("Default")
		
		-- Powerbar Border
		power:CreateBorder()
		power.border.shadow:Kill()
		
		if unit == "target" then
			-- alt power bar for target
			local AltPowerBar = CreateFrame("StatusBar", "TukuiAltPowerBar", self.Health)
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			AltPowerBar:SetStatusBarTexture(C.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(0, .7, 0)
			AltPowerBar:SetHeight(3)
			AltPowerBar:SetPoint("LEFT")
			AltPowerBar:SetPoint("RIGHT")
			AltPowerBar:SetPoint("TOP", self.Health, "TOP")
			
			AltPowerBar:SetBackdrop({bgFile = C["media"].blank})
			AltPowerBar:SetBackdropColor(.1, .1, .1)

			self.AltPowerBar = AltPowerBar
		end
			
		if (unit == "player") then
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:Height(19)
			Combat:Width(19)
			Combat:SetPoint("LEFT",0,1)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "TukuiFlashInfo", self)
			FlashInfo:SetScript("OnUpdate", T.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, font1, fontsize, "THINOUTLINE")
			FlashInfo.ManaLevel:Point("RIGHT", panel, "RIGHT", -4, 0)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = T.SetFontString(panel, font1, fontsize)
			status:Point("RIGHT", panel, "RIGHT", -4, 0)
			status:SetTextColor(0.69, 0.31, 0.31)
			status:Hide()
			self.Status = status
			self:Tag(status, "[pvp]")
			
			-- leader icon
			local Leader = InvFrame:CreateTexture(nil, "OVERLAY")
			Leader:Height(14)
			Leader:Width(14)
			Leader:Point("TOPLEFT", 2, -6)
			self.Leader = Leader
			
			-- master looter
			local MasterLooter = InvFrame:CreateTexture(nil, "OVERLAY")
			MasterLooter:Height(14)
			MasterLooter:Width(14)
			self.MasterLooter = MasterLooter
			self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
			
			-- Vengeance Plugin
			if C.unitframes.vengeancebar then
				local vge = CreateFrame("StatusBar", "VengeanceBar", TukuiInfoRight)
				vge:Point("TOPLEFT", 2, -2)
				vge:Point("BOTTOMRIGHT", -2, 2)
				vge:SetStatusBarTexture(normTex)
				vge:SetStatusBarColor(163/255,  24/255,  24/255)
				
				vge.Text = vge:CreateFontString(nil, "OVERLAY")
				vge.Text:SetFont(font1, fontsize, "THINOUTLINE")
				vge.Text:SetPoint("CENTER")
				
				vge.bg = vge:CreateTexture(nil, 'BORDER')
				vge.bg:SetAllPoints(vge)
				vge.bg:SetTexture(unpack(C.media.backdropcolor))
				
				self.Vengeance = vge
			end
			
			-- Strength of Soul Plugin
			if T.myclass == "PRIEST" then
				local sos = CreateFrame("Frame", nil, self)
				sos:CreatePanel("Default", 32, 32, "BOTTOMLEFT", self, "BOTTOMRIGHT", 6, -2)
				sos:CreateShadow("Default")
				
				sos.icon = sos:CreateTexture(nil, "OVERLAY")
				sos.icon:Point("TOPLEFT", 2, -2)
				sos.icon:Point("BOTTOMRIGHT", -2, 2)
				
				sos.text = T.SetFontString(sos, font2, 14, "THINOUTLINE")
				sos.text:SetPoint("CENTER", sos, 1, 0)
				sos:SetScript("OnUpdate", Priest_SoS_Time)

				self.Priest_SoS = sos
			end
			
			-- SwingTimer
			if C.swingtimer.enable and T.myclass ~= "DRUID" then
				Swing = CreateFrame("Frame", "TukuiSwingtimer", self)
				Swing:Point("BOTTOMLEFT", healthBG, "TOPLEFT", 0, 5)
				Swing:Point("BOTTOMRIGHT", healthBG, "TOPRIGHT", 0, 5)
				Swing:Height(10)
				Swing.texture = C["media"].normTex 
				Swing.color = C.swingtimer.color
				Swing.textureBG = C["media"].blank
				Swing.colorBG = {0, 0, 0, 0.8}
				Swing.hideOoc = true

				Swing:CreateBorder()
				-- pretty sure there's a better way :/
				Swing.border:Hide()
				Swing.border:RegisterEvent("PLAYER_REGEN_ENABLED")
				Swing.border:RegisterEvent("PLAYER_REGEN_DISABLED")
				Swing.border:SetScript("OnEvent", function(self, event)
					if event == "PLAYER_REGEN_ENABLED" then self:Hide()
					else self:Show()
					end
				end)

				self.Swing = Swing
			end

			-- experience bar on player via mouseover for player currently levelling a character
			if T.level ~= MAX_PLAYER_LEVEL and C["unitframes"].charportrait == true then
				local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
				Experience:SetStatusBarTexture(normTex)
				Experience:SetStatusBarColor(0, 0.4, 1, .8)
				Experience:SetBackdrop(backdrop)
				Experience:SetBackdropColor(unpack(C["media"].backdropcolor))
				Experience:SetPoint("TOPLEFT", health)
				Experience:SetPoint("BOTTOMRIGHT", health)
				Experience:SetFrameLevel(10)
				Experience:SetAlpha(0)		
				TukuiPlayer_Portrait:EnableMouse(true)
				TukuiPlayer_Portrait:HookScript("OnEnter", function()
						Experience:SetAlpha(1) 
				end)
				TukuiPlayer_Portrait:HookScript("OnLeave", function() Experience:SetAlpha(0) end)
				Experience.noTooltip = true					

				local Text = T.SetFontString(Experience, font1, fontsize)
				Text:SetSize(playerwidth-10, T.Scale(18))
				Text:Point("CENTER", Experience, "CENTER", 0, 0)
				
				local function update()
					if GetXPExhaustion() ~= nil and GetXPExhaustion() > 0 then
						Text:SetText(format('|cffefefef%d/%d (%d%%) R: %.2f%%', UnitXP("player"), UnitXPMax("player"),(UnitXP("player")/UnitXPMax("player"))*100, (GetXPExhaustion()/UnitXPMax("player"))*100))
					else
						Text:SetText(format('|cffefefef%d/%d (%d%%)', UnitXP("player"), UnitXPMax("player"),(UnitXP("player")/UnitXPMax("player"))*100))
					end
				end
				self:RegisterEvent("PLAYER_LOGIN", update)
				self:RegisterEvent("PLAYER_XP_UPDATE", update)
				self:RegisterEvent("PLAYER_LEVEL_UP", update)
				self:RegisterEvent("UPDATE_EXHAUSTION", update)
				
				local Resting = Experience:CreateTexture(nil, "OVERLAY")
				Resting:Size(24, 24)
				Resting:Point("BOTTOM", Experience, "TOP", 0, -4)
				Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
				Resting:SetTexCoord(0, 0.5, 0, 0.421875)
				Resting:SetAlpha(0.8)
				self.Resting = Resting
				
				self.Experience = Experience
			end
			
			-- reputation bar for max level character
			if T.level == MAX_PLAYER_LEVEL and C["unitframes"].charportrait == true then
				local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
				Reputation:SetStatusBarTexture(normTex)
				Reputation:SetBackdrop(backdrop)
				Reputation:SetBackdropColor(unpack(C["media"].backdropcolor))
				Reputation:SetPoint("TOPLEFT", health)
				Reputation:SetPoint("BOTTOMRIGHT", health)
				Reputation:SetFrameLevel(10)
				Reputation:SetAlpha(0)
				TukuiPlayer_Portrait:HookScript("OnEnter", function() 
						Reputation:SetAlpha(1) 
				end)
				TukuiPlayer_Portrait:HookScript("OnLeave", function() Reputation:SetAlpha(0) end)

				local Text = T.SetFontString(Reputation, font1, fontsize, "THINOUTLINE")
				Text:SetSize(playerwidth-10, health:GetHeight())
				Text:Point("CENTER", Reputation, "CENTER", 0, 0)
				
				local function update()
					local name, standing, min, max, value = GetWatchedFactionInfo()
					if GetWatchedFactionInfo() ~= nil then
						TukuiPlayer_Portrait:EnableMouse(true)
						Text:SetText(format('%s - %s/%s (%d%%)', name, value - min, max - min, (value - min) / (max - min) * 100))
						Reputation:SetStatusBarColor(FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b)
					else
						TukuiPlayer_Portrait:EnableMouse(false)
					end
				end
				self:RegisterEvent('UPDATE_FACTION', update)
				self:RegisterEvent("PLAYER_LOGIN", update)

				Reputation.PostUpdate = C["unitframes"].UpdateReputationColor
				Reputation.Tooltip = false
				self.Reputation = Reputation
			end
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, font1, fontsize, "THINOUTLINE")
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
			
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then			
					local eclipseBar = CreateFrame('Frame', nil, self)
					eclipseBar:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
					eclipseBar:Size(playerwidth, 5)
					eclipseBar:SetFrameStrata("MEDIUM")
					eclipseBar:SetFrameLevel(8)
					eclipseBar:SetScript("OnShow", function() T.EclipseDisplay(self, false) end)
					eclipseBar:SetScript("OnUpdate", function() T.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					eclipseBar:SetScript("OnHide", function() T.EclipseDisplay(self, false) end)
					
					local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
					lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
					lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					lunarBar:SetStatusBarTexture(normTex)
					lunarBar:SetStatusBarColor(.30, .52, .90)
					eclipseBar.LunarBar = lunarBar

					local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
					solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
					solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					solarBar:SetStatusBarTexture(normTex)
					solarBar:SetStatusBarColor(.80, .82,  .60)
					eclipseBar.SolarBar = solarBar

					local eclipseBarText = T.SetFontString(eclipseBar, font1, fontsize, "THINOUTLINE")
					eclipseBarText:Point("RIGHT", panel, "RIGHT", -4, 0)
					eclipseBar.PostUpdatePower = T.EclipseDirection
					
					-- hide "low mana" text on load if eclipseBar is show
					if eclipseBar and eclipseBar:IsShown() then FlashInfo.ManaLevel:SetAlpha(0) end
					
					-- border
					eclipseBar:CreateBorder("EclipseBarBorder")

					self.EclipseBar = eclipseBar
					self.EclipseBar.Text = eclipseBarText
				end

				-- set holy power bar or shard bar
				if (T.myclass == "WARLOCK" or T.myclass == "PALADIN") then
					local bars = CreateFrame("Frame", nil, self)
					bars:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
					bars:Size(playerwidth, 5)
					bars:SetTemplate("Default")
					bars:SetBackdropBorderColor(0,0,0,0)
					
					-- border
					bars:CreateBorder("ShardBarBorder")
					
					for i = 1, 3 do					
						bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
						bars[i]:Height(5)					
						bars[i]:SetStatusBarTexture(normTex)
						bars[i]:GetStatusBarTexture():SetHorizTile(false)

						bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
						
						if T.myclass == "WARLOCK" then
							bars[i]:SetStatusBarColor(205/255,40/255,40/255)
							bars[i].bg:SetTexture(205/255,40/255,40/255)
						elseif T.myclass == "PALADIN" then
							bars[i]:SetStatusBarColor(228/255,225/255,16/255)
							bars[i].bg:SetTexture(228/255,225/255,16/255)
						end
						
						if i == 1 then
							bars[i]:SetPoint("LEFT", bars)
							bars[i]:Width((bars:GetWidth()/3)-1)
							bars[i].bg:SetAllPoints(bars[i])
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", 1, 0)
							bars[i]:Width((bars:GetWidth()/3)-1)
							bars[i].bg:SetAllPoints(bars[i])
						end
						
						bars[i].bg:SetTexture(normTex)					
						bars[i].bg:SetAlpha(.15)
					end
					
					if T.myclass == "WARLOCK" then
						bars.Override = T.UpdateShards				
						self.SoulShards = bars
					elseif T.myclass == "PALADIN" then
						bars.Override = T.UpdateHoly
						self.HolyPower = bars
					end
				end

				-- deathknight runes
				if T.myclass == "DEATHKNIGHT" then
					local Runes = CreateFrame("Frame", nil, self)
					Runes:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
					Runes:Height(5)
					Runes:Size(playerwidth, 5)
					
					-- border
					Runes:CreateBorder("RuneBarBorder")

					for i = 1, 6 do
						Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, health)
						Runes[i]:SetHeight(5)
						if (i == 1) then
							Runes[i]:Width(((playerwidth) / 6)+2)
							Runes[i]:Point("LEFT", Runes.border, "LEFT", 2, 0)
						else
							Runes[i]:Width(((playerwidth) / 6)-1)
							Runes[i]:Point("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
						end
						Runes[i]:SetStatusBarTexture(normTex)
						Runes[i]:GetStatusBarTexture():SetHorizTile(false)
					end

					self.Runes = Runes
				end
				
				-- shaman totem bar
				if T.myclass == "SHAMAN" then
					local TotemBar = {}
					TotemBar.Destroy = true
					for i = 1, 4 do
						TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
						if (i == 1) then
							TotemBar[i]:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
						else
							TotemBar[i]:Point("TOPLEFT", TotemBar[i-1], "TOPRIGHT", 3, 0)
						end
						TotemBar[i]:SetStatusBarTexture(normTex)
						TotemBar[i]:Height(5)
						TotemBar[i]:Width(((playerwidth) / 4)-3)
						if i == 4 then TotemBar[i]:Width(TotemBar[1]:GetWidth()+1) end
						TotemBar[i]:SetMinMaxValues(0, 1)

						TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
						TotemBar[i].bg:SetAllPoints(TotemBar[i])
						TotemBar[i].bg:SetTexture(normTex)
						TotemBar[i].bg.multiplier = 0.2
						
						-- border
						TotemBar[i].border = CreateFrame("Frame", nil, TotemBar[i])
						TotemBar[i].border:CreatePanel("Default", 1, 1,"TOPLEFT", TotemBar[i], "TOPLEFT", -2, 2)
						TotemBar[i].border:Point("BOTTOMRIGHT", 2, -2)
					end
					-- Shadow
					TotemShadow = CreateFrame("Frame", "TotemBarBorder", TukuiPlayer_TotemBar1)
					TotemShadow:SetPoint("TOPLEFT", -2, 2)
					TotemShadow:SetPoint("BOTTOMRIGHT", TukuiPlayer_TotemBar4, "BOTTOMRIGHT", 2, -2)
					TotemShadow:CreateShadow("Default")
					
					self.TotemBar = TotemBar
			
			-- ShammyShield
				local ss = CreateFrame("StatusBar", "Shammy Shield", self)
				ss:Point("TOPLEFT", TukuiPlayer_Portrait, "BOTTOMLEFT", 0, -5)
				ss:Size(55, 5)
				ss:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				ss:SetStatusBarTexture(normTex)
				ss:SetOrientation("HORIZONTAL")
				ss:SetMinMaxValues(0, 1)

				ss.bg = ss:CreateTexture(nil, "BORDER")
				ss.bg:SetAllPoints(ss)
				ss.bg:SetTexture(.02,.02,.02)
				ss.bg.multiplier = 0.2

				-- border
				ss.border = CreateFrame("Frame", nil, ss)
				ss.border:CreatePanel("Default", 1, 1,"TOPLEFT", ss, "TOPLEFT", -2, 2)
				ss.border:Point("BOTTOMRIGHT", 2, -2)
				ss.border:CreateShadow("Default")				
				ss:RegisterEvent("UNIT_AURA")
				ss:RegisterEvent("PLAYER_ENTERING_WORLD")	
				ss:SetScript("OnEvent", function()
				if UnitAura("player", "Water Shield") or UnitAura("player", "Earth Shield") or UnitAura("player", "Lightning Shield") then
					for index = 1, 40 do
						local name,_,_,_,_, duration, expirationTime,_,_,_,_ = UnitAura("player", index)
						if name == "Water Shield" then
							ss:SetValue(1)
							ss.bg:SetTexture(.02,.02,.02)
							ss:SetStatusBarColor(.19,.48,.60)
							ss:SetScript("OnUpdate", function()
								local _,_,_,_,_, duration, expirationTime,_,_,_,_ = UnitAura("player", tostring(name))
								local time = GetTime()
								local remaining = expirationTime - time
									if (time > expirationTime) then
										ss:SetValue(0)
									else
										ss:SetValue(remaining/duration)
									end
							end)
						elseif name == "Lightning Shield" then
							ss:SetValue(1)
							ss.bg:SetTexture(.02,.02,.02)
							ss:SetStatusBarColor(.42,.18,.74)
							ss:SetScript("OnUpdate", function()
								local _,_,_,_,_, duration, expirationTime,_,_,_,_ = UnitAura("player", tostring(name))
								local time = GetTime()
								local remaining = expirationTime - time
									if (time > expirationTime) then
										ss:SetValue(0)
									else
										ss:SetValue(remaining/duration)
									end
							end)
						elseif name == "Earth Shield" then
							ss:SetValue(1)
							ss.bg:SetTexture(.02,.02,.02)
							ss:SetStatusBarColor((184/255),(134/255),(11/255))
							ss:SetScript("OnUpdate", function()
								local _,_,_,_,_, duration, expirationTime,_,_,_,_ = UnitAura("player", tostring(name))
								local time = GetTime()
								local remaining = expirationTime - time
									if (time > expirationTime) then
										ss:SetValue(0)
									else
										ss:SetValue(remaining/duration)
									end
							end)							
						end	
					end
				else
					ss.bg:SetTexture((178/225), (34/225), (34/225))
					ss:SetValue(0)
					ss:SetScript("OnUpdate", nil)
				end
				end)
			end
		end
					
			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self)
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Hide()
				end
				FlashInfo.ManaLevel:Hide()
				status:Show()
				UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Show()
				end
				FlashInfo.ManaLevel:Show()
				status:Hide()
				UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = T.SetFontString(health, font1, fontsize, "THINOUTLINE")
			Name:Point("LEFT", panel, "LEFT", 4, 0)
			Name:SetJustifyH("LEFT")

			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
			self.Name = Name
			
			-- combo points on target
			
			local cp = T.SetFontString(self, font2, 15, "THINOUTLINE")
			cp:SetPoint("RIGHT", health.border, "LEFT", -5, 0)
			
			self.CPoints = cp
		end

		if (unit == "target" and C["unitframes"].targetauras) or (unit == "player" and C["unitframes"].playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			buffs:Point("BOTTOMLEFT", self, "TOPLEFT", -2, 4)
			buffs.size = 22
			buffs.spacing = 3
			buffs:Height((buffs.size+buffs.spacing) * C.unitframes.buffrows)
			buffs:Width(playerwidth+3)
			buffs.num = ( playerwidth/(buffs.size+buffs.spacing) ) * C.unitframes.buffrows
			
			debuffs.size = 22
			debuffs.spacing = 3
			debuffs:Height((debuffs.size+debuffs.spacing) * C.unitframes.debuffrows)
			debuffs:Width(playerwidth+3)
			debuffs:Point("BOTTOMLEFT", buffs, "TOPLEFT", 1, 0)
			if C.classtimer.targetdebuffs then
				debuffs.num = ( playerwidth/(buffs.size+buffs.spacing) )
			else
				debuffs.num = ( playerwidth/(buffs.size+buffs.spacing) ) * C.unitframes.debuffrows
			end
			
			buffs.initialAnchor = 'BOTTOMLEFT'
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs
						
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			
			-- an option to show only our debuffs on target
			if unit == "target" then
				debuffs.onlyShowPlayer = C.unitframes.onlyselfdebuffs
			end
			
			self.Debuffs = debuffs
		end
		
		-- cast bar for player and target
		if (C["castbar"].enable == true) then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameStrata("HIGH")
			if unit == "player" then
				castbar:Height(21)
			elseif unit == "target" then
				castbar:Width(playerwidth)
				castbar:Height(10)
				castbar:Point("BOTTOM", healthBG, "TOP", 0, 5)
			end
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.time = T.SetFontString(castbar, font1, fontsize)
			castbar.time:Point("RIGHT", castbar, "RIGHT", -5, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, font1, fontsize)
			castbar.Text:Point("LEFT", castbar, "LEFT", 6, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			-- Border
			castbar:CreateBorder()
			castbar.border:SetFrameStrata("HIGH")
			
			if C.castbar.cbicons then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetTemplate("Default")
				castbar.button:CreateShadow("Default")
			
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
				castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
				if unit == "player" then
					castbar.button:Size(25)
					castbar.button:Point("RIGHT",castbar,"LEFT", -5, 0)
				elseif unit == "target" then
					castbar.button:Point("TOPLEFT", TukuiTarget_Portrait, "TOPLEFT", -2, 2)
					castbar.button:Point("BOTTOMRIGHT", TukuiTarget_Portrait, "BOTTOMRIGHT", 2, -2)
					castbar.button.shadow:Hide()
					castbar.icon:SetTexCoord(0.08, 0.92, 0.18, .82)
				end
			end
			
			-- cast bar latency on player
			if unit == "player" and C["castbar"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
					
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = T.SetFontString(health, font2, 14, "THINOUTLINE")
			CombatFeedbackText:SetPoint("CENTER", 0, 0)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		if C["unitframes"].healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetWidth(playerwidth)
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetWidth(playerwidth)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if C["unitframes"].playeraggro == true then
			table.insert(self.__elements, T.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Target of Target unit layout
	------------------------------------------------------------------------
	
	if (unit == "targettarget") then
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetPoint("TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", -2, 2)
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end			
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true
			healthBG:SetTexture(.1, .1, .1)			
		end
		
		-- Healthbar Border
		health:CreateBorder()
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetFont(font1, fontsize, "THINOUTLINE")
		Name:SetPoint("CENTER", health, "CENTER", 0, -1)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if C["unitframes"].totdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:Height(20)
			debuffs:Width(300)
			debuffs.size = 19.5
			debuffs.spacing = 3
			debuffs.num = 7

			debuffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
		
		-- portrait
		if C["unitframes"].charportrait == true then
		do return end
			local portrait = CreateFrame("PlayerModel", nil, self)
			portrait:SetFrameLevel(8)
			portrait:Width(21)
			portrait:Point("TOPLEFT", health,"TOPRIGHT",7,0)
			portrait:Point("BOTTOMLEFT", power,"BOTTOMRIGHT",7,0)

			table.insert(self.__elements, T.HidePortrait)
			self.Portrait = portrait
			
			-- Portrait Border
			portrait.bg = CreateFrame("Frame",nil,portrait)
			portrait.bg:CreatePanel("Default",1,1,"BOTTOMLEFT",portrait,"BOTTOMLEFT",-2,-2)
			portrait.bg:SetPoint("TOPRIGHT",portrait,"TOPRIGHT",2,2)
			portrait.bg:CreateShadow("Default")
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") then
		-- health bar panel
		local health = CreateFrame('StatusBar', nil, self)
		health:SetPoint("TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", -2, 2)
		health:SetStatusBarTexture(normTex)
		
		health.PostUpdate = T.PostUpdatePetColor
				
		self.Health = health
		self.Health.bg = healthBG
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end			
		else
			health.colorDisconnected = true	
			health.colorClass = true
			health.colorReaction = true	
			if T.myclass == "HUNTER" then
				health.colorHappiness = true
			end
			healthBG:SetTexture(.1, .1, .1)
		end
		
		-- Healthbar Border
		health:CreateBorder()
				
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetFont(font1, fontsize, "THINOUTLINE")
		Name:SetPoint("CENTER", health, "CENTER", 0, -1)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]  [Tukui:diffcolor][level]')
		self.Name = Name
		
		if (C["castbar"].enable == true) then
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			self.Castbar = castbar
			castbar:Height(2)
			
			
			castbar:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -5)
			castbar:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -5)

			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetTexture(normTex)
			castbar.bg:SetVertexColor(unpack(C["media"].backdropcolor))
			castbar:SetFrameLevel(6)
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.Text = T.SetFontString(castbar, font1, fontsize)
			castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			self.Castbar.Time = castbar.time
			
			-- Border
			castbar.border = CreateFrame("Frame", nil,castbar)
			castbar.border:CreatePanel("Default",1,1,"TOPLEFT", castbar, "TOPLEFT", -2, 2)
			castbar.border:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 2, -2)
			castbar.border:SetFrameLevel(5)
		end
		
		-- if C["unitframes"].totdebuffs == true then
			-- local debuffs = CreateFrame("Frame", nil, health)
			-- debuffs:Height(20)
			-- debuffs:Width(300)
			-- debuffs.size = 19.5
			-- debuffs.spacing = 3
			-- debuffs.num = 7

			-- debuffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
			-- debuffs.initialAnchor = "TOPLEFT"
			-- debuffs["growth-y"] = "UP"
			-- debuffs.PostCreateIcon = C["unitframes"].PostCreateAura
			-- debuffs.PostUpdateIcon = C["unitframes"].PostUpdateAura
			-- self.Debuffs = debuffs
		-- end
		
		-- update pet name, this should fix "UNKNOWN" pet names on pet unit, health and bar color sometime being "grayish".
		self:RegisterEvent("UNIT_PET", T.updateAllElements)
	end


	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		local panel = CreateFrame("Frame", nil, self)
		local power = CreateFrame('StatusBar', nil, self)
		if lafo then
			panel:CreatePanel("", 1, 13, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
			panel:SetPoint("BOTTOMRIGHT")
		
			power:Height(2)
			power:Point("BOTTOMLEFT", panel, "TOPLEFT", 2, 1)
			power:Point("BOTTOMRIGHT", panel, "TOPRIGHT", -2, 1)
			power:SetStatusBarTexture(normTex)
			
			power.frequentUpdates = true
			if C["unitframes"].showsmooth == true then
				power.Smooth = true
			end
			
			if C["unitframes"].unicolor == true then
				power.colorTapping = true
				power.colorClass = true			
			else
				power.colorPower = true
			end

			local powerBG = power:CreateTexture(nil, 'BORDER')
			powerBG:SetAllPoints(power)
			powerBG:SetTexture(normTex)
			powerBG.multiplier = 0.3
			
			power.value = panel:CreateFontString(nil, "OVERLAY")
			power.value:SetFont(font1, fontsize, "THINOUTLINE")
			power.value:Point("RIGHT", -4, 0)
			power.PreUpdate = T.PreUpdatePower
			power.PostUpdate = T.PostUpdatePower
					
			self.Power = power
			self.Power.bg = powerBG
		end
		
		-- health
		local health = CreateFrame('StatusBar', nil, self)
		if lafo then
			health:Height(19)
			health:Point("BOTTOMLEFT", power, "TOPLEFT", 0 , 3)
			health:Point("BOTTOMRIGHT", power, "TOPRIGHT", 0 , 3)
		else
			health:Point("TOPLEFT", 2, -2)
			health:Point("BOTTOMRIGHT", -2, 2)
		end
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()

		if lafo then
			health.value = health:CreateFontString(nil, "OVERLAY")
			health.value:SetFont(font1,fontsize, "THINOUTLINE")
			health.value:Point("LEFT", 4, 0)
			health.PostUpdate = T.PostUpdateHealth
		end
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
			healthBG:SetTexture(.1, .1, .1)
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetFont(font1, fontsize, "THINOUTLINE")
		if lafo then
			Name:Point("LEFT", panel, "LEFT", 4, 0)
		else
			Name:SetPoint("CENTER")
		end
		Name:SetJustifyH("LEFT")
		
		if lafo then
			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
		else
			self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		end
		self.Name = Name
	
		-- create castbar
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			
		-- Border
		health.border = CreateFrame("Frame", nil,health)
		if lafo then
			health.border:CreatePanel("Default",1,1,"TOPLEFT", health, "TOPLEFT", -2, 2)
			health.border:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", 2, -2)
		
			power:CreateBorder()
			power.border.shadow:Hide()
			
			local shd = CreateFrame("Frame", nil, health.border)
			shd:SetPoint("TOPLEFT")
			shd:SetPoint("BOTTOMRIGHT", panel)
			shd:CreateShadow("")
		else
			health.border:CreatePanel("",1,1,"TOPLEFT",health,"TOPLEFT",-2,2)
			health.border:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 2, -2)
			health.border:CreateShadow("")
		end

		if C["unitframes"].focusbuffs == true then
			local buffs = CreateFrame("Frame", nil, self)
			
			buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
			buffs.size = 25
			buffs.spacing = 3
			buffs:Height((buffs.size+buffs.spacing) * C.unitframes.buffrows)
			buffs:Width(194)
			buffs.num = (7)
			
			buffs.initialAnchor = 'BOTTOMLEFT'
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs
			
		end
		
		-- create debuffs
		if C.unitframes.focusdebuffs then
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.spacing = 3
			if lafo then
				debuffs.size = 28
				debuffs:SetHeight(28)
				debuffs:Point('BOTTOMRIGHT', self, "TOPRIGHT", 0, 32)
				debuffs.initialAnchor = 'RIGHT'
				debuffs["growth-x"] = "LEFT"
			else
				debuffs.size = 18
				debuffs:SetHeight(15)
				debuffs:Point('RIGHT', self, "LEFT", -3, 0)
				debuffs.initialAnchor = 'RIGHT'
				debuffs["growth-x"] = "LEFT"
			end
			debuffs.num = 6
			debuffs:SetWidth(debuffs:GetHeight() * (debuffs.num + debuffs.spacing))
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
		
		-- castbar
		if C["castbar"].enable == true then
			castbar:SetStatusBarTexture(normTex)			
			castbar:Point("TOPLEFT", panel, 2, -2)
			castbar:Point("BOTTOMRIGHT", panel, -2, 2)
			castbar:SetFrameLevel(6)
			
			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetAllPoints(castbar)
			castbar.bg:SetTexture(normTex)
			castbar.bg:SetVertexColor(unpack(C["media"].backdropcolor))
						
			castbar.time = T.SetFontString(castbar, font1, fontsize)
			castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = T.CustomCastTimeText

			castbar.Text = T.SetFontString(castbar, font1, fontsize)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel			
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
		end
		
		--portrait
		if 	C.unitframes.focusportrait == true and lafo then
			local portrait = CreateFrame("PlayerModel", self:GetName().."_Portrait", self)
			portrait:SetFrameLevel(8)
			portrait:SetWidth(55)
			portrait:Point("TOPRIGHT", health, "TOPLEFT", -7, 7)
			portrait:Point("BOTTOMRIGHT", panel, "BOTTOMLEFT", -7, 2)
			-- table.insert(self.__elements, T.HidePortrait)
			portrait.PostUpdate = T.PortraitUpdate --Worgen Fix (Hydra)
			self.Portrait = portrait
			
			-- Portrait Border
			portrait.bg = CreateFrame("Frame",nil,portrait)
			portrait.bg:CreatePanel("Default", 1 , 1, "BOTTOMLEFT", portrait, "BOTTOMLEFT", -2, -2)
			portrait.bg:Point("TOPRIGHT", portrait, "TOPRIGHT", 2, 2)
			portrait.bg:CreateShadow("Default")
			
			local AuraTracker = CreateFrame("Frame")
			self.AuraTracker = AuraTracker
			
			AuraTracker.icon = portrait:CreateTexture(nil, "OVERLAY")
			AuraTracker.icon:SetAllPoints()
			AuraTracker.icon:SetTexCoord(0.08, 0.92, 0.18, .82)
			
			AuraTracker.text = T.SetFontString(portrait, font2, 15, "THINOUTLINE")
			AuraTracker.text:SetPoint("CENTER")
			AuraTracker:SetScript("OnUpdate", updateAuraTrackerTime)
		end
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetPoint("TOPLEFT", 2, -2)
		health:SetPoint("BOTTOMRIGHT", -2, 2)
		health:SetStatusBarTexture(normTex)
		health:SetOrientation('VERTICAL')

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true
			healthBG:SetTexture(.1, .1, .1)
		end
			
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetFont(font1, fontsize, "THINOUTLINE")
		Name:SetPoint("CENTER")
		Name:SetJustifyV("CENTER")
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namereallyshort]')
		self.Name = Name
		
		-- Border
		health:CreateBorder()	
		
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		local panel = CreateFrame("Frame", nil, self)
		panel:CreatePanel("", 1, 13, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		panel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(2)
		power:Point("BOTTOMLEFT", panel, "TOPLEFT", 2, 1)
		power:Point("BOTTOMRIGHT", panel, "TOPRIGHT", -2, 1)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = panel:CreateFontString(nil, "OVERLAY")
		power.value:SetFont(font1, fontsize, "THINOUTLINE")
		power.value:Point("RIGHT", -4, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(19)
		health:Point("BOTTOMLEFT", power, "TOPLEFT", 0, 3)
		health:Point("BOTTOMRIGHT", power, "TOPRIGHT", 0, 3)
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()

		health.value = T.SetFontString(health, font1,fontsize, "THINOUTLINE")
		health.value:Point("LEFT", health, "LEFT", 2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		-- Raidicon repositioning
		RaidIcon:Point("TOP", health, "TOP", 0, 9)
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)	
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true
			healthBG:SetTexture(.1, .1, .1)	
		end
		
		-- Border
		health.border = CreateFrame("Frame", nil,health)
		health.border:CreatePanel("Default",1,1,"TOPLEFT", health, "TOPLEFT", -2, 2)
		health.border:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", 2, -2)
		
		power.border = CreateFrame("Frame", nil, power)
		power.border:CreatePanel("Default",1,1,"TOPLEFT", power, "TOPLEFT", -2, 2)
		power.border:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", 2, -2)
		
		local shd = CreateFrame("Frame", nil, health.border)
		shd:SetPoint("TOPLEFT")
		shd:SetPoint("BOTTOMRIGHT", panel)
		shd:CreateShadow("")
		
		-- names
		local Name = panel:CreateFontString(nil, "OVERLAY")
		Name:SetFont(font1, fontsize, "THINOUTLINE")
		Name:Point("LEFT", 4, 0)
		Name:SetJustifyH("LEFT")
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name
		
		if (unit and unit:find("boss%d")) then
			power.colorPower = true
		
			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			AltPowerBar:Height(3)
			AltPowerBar:SetStatusBarTexture(C.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(1, 0, 0)

			AltPowerBar:SetPoint("LEFT")
			AltPowerBar:SetPoint("RIGHT")
			AltPowerBar:SetPoint("TOP", self.Health, "TOP")
			-- AltPowerBar:SetBackdrop({bgFile = C["media"].blank})
			-- AltPowerBar:SetBackdropColor(.1,.1,.1)
			self.AltPowerBar = AltPowerBar
			
			-- Portrait Border
			local PBorder = CreateFrame("Frame", nil, self)
			PBorder:CreatePanel("Default", 40, 40, "BOTTOMRIGHT", panel, "BOTTOMLEFT", -3, 0)
			PBorder:CreateShadow("Default")
			
			local portrait = CreateFrame("PlayerModel", nil, PBorder)
			portrait:SetFrameLevel(8)
			portrait:Point("TOPLEFT", 2, -2)
			portrait:Point("BOTTOMRIGHT", -2, 2)
			table.insert(self.__elements, T.HidePortrait)
			portrait.PostUpdate = T.PortraitUpdate --Worgen Fix (Hydra)
			self.Portrait = portrait
			
			-- create buff at left of unit if they are boss units
			local buffs = CreateFrame("Frame", nil, self)
			buffs:SetHeight(40)
			buffs:SetWidth(252)
			buffs:Point("BOTTOMRIGHT", panel, "BOTTOMLEFT", -3, 0)
			buffs.size = 40
			buffs.num = 3
			buffs.spacing = 2
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs
			
			-- because it appear that sometime elements are not correct.
			self:HookScript("OnShow", T.updateAllElements)			
		end

		-- create debuff 
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(28)
		debuffs:SetWidth(200)
		debuffs.size = 28
		debuffs:SetHeight(28)
		debuffs:Point('LEFT', self, "RIGHT", 3, 0)
		debuffs.num = 4
		debuffs.spacing = 3
		debuffs.initialAnchor = 'LEFT'
		debuffs["growth-x"] = "RIGHT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		debuffs.onlyShowPlayer = true
		self.Debuffs = debuffs
				
		-- trinket feature via trinket plugin
		if (C.arena.unitframes) and (unit and unit:find('arena%d')) then
			if C.unitframes.unicolor then
				power.colorTapping = true
				power.colorClass = true	
			else
				power.colorPower = true
			end
		
			RaidIcon:Hide()
			-- Auratracker Frame
			local AuraTracker = CreateFrame("Frame", nil, self)
			AuraTracker:Size(40)
			AuraTracker:Point("BOTTOMRIGHT", panel, "BOTTOMLEFT", -3, 0)
			AuraTracker:SetTemplate("Default")
			AuraTracker:CreateShadow("Default")
			self.AuraTracker = AuraTracker
			
			AuraTracker.icon = AuraTracker:CreateTexture(nil, "OVERLAY")
			AuraTracker.icon:SetAllPoints(AuraTracker)
			AuraTracker.icon:Point("TOPLEFT", AuraTracker, 2, -2)
			AuraTracker.icon:Point("BOTTOMRIGHT", AuraTracker, -2, 2)
			AuraTracker.icon:SetTexCoord(0.07,0.93,0.07,0.93)
			
			AuraTracker.text = T.SetFontString(AuraTracker, font2, 15, "THINOUTLINE")
			AuraTracker.text:SetPoint("CENTER")
			AuraTracker:SetScript("OnUpdate", updateAuraTrackerTime)
			
			-- ClassIcon			
			local class = AuraTracker:CreateTexture(nil, "ARTWORK")
			class:SetAllPoints(AuraTracker.icon)
			self.ClassIcon = class
		
			-- Trinket Frame
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:Size(9,9)
			Trinketbg:Point("TOPRIGHT", health, "TOPRIGHT", 1,1)
			Trinketbg:SetBackdrop({
				edgeFile = C["media"].blank, 
				tile = false, tileSize = 0, edgeSize = 1, 
				insets = { left = -1, right = -1, top = -1, bottom = -1}
			})
			Trinketbg:SetBackdropBorderColor(0,0,0)
			Trinketbg:SetFrameLevel(health:GetFrameLevel()+1)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, self)
			Trinket:Point("TOPLEFT", Trinketbg, 1, -1)
			Trinket:Point("BOTTOMRIGHT", Trinketbg, -1, 1)
			Trinket:SetFrameLevel(Trinketbg:GetFrameLevel()+1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
			
			-- Spec info
			Talents = T.SetFontString(health.border, font1, fontsize)
			Talents:Point("TOPRIGHT", self, "BOTTOMRIGHT", -1, -3)
			Talents:SetTextColor(1,1,1,.6)
			self.Talents = Talents
		end
		
		-- boss & arena frames cast bar!
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)		
		castbar:SetHeight(12)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(10)
		
		castbar:CreateBorder()
		castbar.border:SetFrameLevel(9)

		castbar.Text = T.SetFontString(castbar, font1, fontsize)
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
		
		local Ax = 2
		if C.castbar.cbicons == true then
			Ax = 21
			castbar.button = CreateFrame("Frame", nil, castbar)
			castbar.button:CreatePanel("Default", 16, 16, "BOTTOMRIGHT", castbar, "BOTTOMLEFT",-5,-2)
			castbar.button:CreateShadow("Default")

			castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
			castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
			castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
			castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
		end
		castbar:Point("TOPLEFT", panel, "BOTTOMLEFT", Ax, -5)
		castbar:Point("TOPRIGHT", panel, "BOTTOMRIGHT", -2, -5)

		self.Castbar = castbar
		self.Castbar.Icon = castbar.icon
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthbarcolor))
			healthBG:SetVertexColor(unpack(C["unitframes"].deficitcolor))	
			healthBG:SetTexture(.6, .6, .6)
			if C.unitframes.ColorGradient then
				health.colorSmooth = true
				healthBG:SetTexture(.2, .2, .2)
			end
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true
			healthBG:SetTexture(.1, .1, .1)
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetFont(font1, fontsize, "THINOUTLINE")
		Name:SetPoint("CENTER")
		Name:SetJustifyH("CENTER")
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
		
		-- border
		local border = CreateFrame("Frame", nil, self)
		border:CreatePanel("Default", 1, 1, "TOPLEFT", self, "TOPLEFT", -2, 2)
		border:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
		border:CreateShadow("Default")
	end
	
	return self
end

local function HasClassBar()
	if C["unitframes"].classbar == true then
		if T.myclass == "DRUID" or T.myclass == "WARLOCK" or T.myclass == "PALADIN" or T.myclass == "DEATHKINGHT" or T.myclass == "SHAMAN" then
			return true
		end
	end
end
------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------
oUF:RegisterStyle('Tukui', Shared)

-- player
local player = oUF:Spawn('player', "TukuiPlayer")
player:Point("BOTTOMRIGHT", TukuiBar1, "TOPLEFT", -20,150)
player:Size(playerwidth, 43)

-- target
local target = oUF:Spawn('target', "TukuiTarget")
target:Point("BOTTOMLEFT", TukuiBar1, "TOPRIGHT", 20,150)
target:Size(playerwidth, 43)

-- tot
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
tot:Point("TOP", TukuiTarget, "BOTTOM", 0, -6)
tot:Size(playerwidth+4, 16)

-- pet
local pet = oUF:Spawn('pet', "TukuiPet")
if HasClassBar() == true then
	pet:Point("TOP", TukuiPlayer, "BOTTOM", 0, -16)
else
	pet:Point("TOP", TukuiPlayer, "BOTTOM", 0, -6)
end
pet:Size(playerwidth+4, 16)

-- focus & focustarget
local focus = oUF:Spawn('focus', "TukuiFocus")
local focustarget = oUF:Spawn("focustarget", "TukuiFocusTarget")
if lafo then
	focus:Size(playerwidth-20, 40)
	focus:Point("BOTTOMLEFT", TukuiPlayer, "TOPLEFT", 0, 200)
	focustarget:Size(playerwidth-194, 40)
	focustarget:Point("BOTTOMLEFT", TukuiFocus, "BOTTOMRIGHT", 3, 0)
else
	focus:Size(playerwidth/2 -18, 18)
	focus:Point("TOPRIGHT", TukuiPlayer_Portrait, "TOPLEFT", -5, 2)
	focustarget:Size(playerwidth/2 -18, 18)
	focustarget:Point("TOPRIGHT", TukuiFocus, "BOTTOMRIGHT", 0, -3)
end

if C.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "TukuiArena"..i)
		if i == 1 then
			arena[i]:Point("BOTTOM", UIParent, "BOTTOM", 330, 450)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 27)
		end
		arena[i]:Size(playerwidth-20, 40)
	end
end

if C["unitframes"].showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = T.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "TukuiBoss"..i)
		if i == 1 then
			boss[i]:Point("BOTTOM", UIParent, "BOTTOM", 330, 450)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 27)             
		end
		boss[i]:Size(playerwidth-20, 40)
	end
end

local assisttank_width = 90
local assisttank_height  = 20
if C["unitframes"].maintank == true then
	local tank = oUF:SpawnHeader('TukuiMainTank', nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINTANK',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	tank:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
 
if C["unitframes"].mainassist == true then
	local assist = oUF:SpawnHeader("TukuiMainAssist", nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINASSIST',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	if C["unitframes"].maintank == true then
		assist:SetPoint("TOPLEFT", TukuiMainTank, "BOTTOMLEFT", 2, -50)
	else
		assist:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

--------------------------
--custom AB move function
--------------------------
CustomBar_UpdateInterval = .5
TimeSinceLastUpdate = 0
local function Update(self, elapsed)
  TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed	

	if (TimeSinceLastUpdate > CustomBar_UpdateInterval) then
 		if HasClassBar() == true then
			CustomTukuiActionBar:Point( "TOPLEFT", TukuiPlayer, "BOTTOMLEFT", -1, -19)
		else
			CustomTukuiActionBar:Point( "TOPLEFT", TukuiPlayer, "BOTTOMLEFT", -1, -9)
		end
		
		if TukuiPet:IsShown() then
			CustomTukuiActionBar:Point( "TOPLEFT", TukuiPet, "BOTTOMLEFT", 0, -6)
		end
    TimeSinceLastUpdate = 0
	end
end

CustomTukuiActionBar:SetScript("OnUpdate", Update)
-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end


-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
	if msg == "a" or msg == "arena" then
		TukuiArena1:Show(); TukuiArena1.Hide = function() end; TukuiArena1.unit = "player"
		TukuiArena2:Show(); TukuiArena2.Hide = function() end; TukuiArena2.unit = "player"
		TukuiArena3:Show(); TukuiArena3.Hide = function() end; TukuiArena3.unit = "player"
	elseif msg == "boss" or msg == "b" then
		TukuiBoss1:Show(); TukuiBoss1.Hide = function() end; TukuiBoss1.unit = "player"
		TukuiBoss2:Show(); TukuiBoss2.Hide = function() end; TukuiBoss2.unit = "player"
		TukuiBoss3:Show(); TukuiBoss3.Hide = function() end; TukuiBoss3.unit = "player"
	elseif msg == "buffs" then -- better dont test it ^^
		UnitAura = function()
			-- name, rank, texture, count, dtype, duration, timeLeft, caster
			return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.units) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"