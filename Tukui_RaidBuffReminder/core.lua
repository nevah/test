local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
--By Elv22
--Config starts here:

BuffReminderRaidBuffs = {
	Flask = {
		67016, --"Flask of the North-ING"
		67017, --"Flask of the North-AGI"
		67018, --"Flask of the North-STR"
		53758, --"Flask of Stoneblood"
		53755, --"Flask of the Frost Wyrm",
		54212, --"Flask of Pure Mojo",
		53760, --"Flask of Endless Rage",
		17627, --"Flask of Distilled Wisdom",
		79470, --"Flask of the Draconic Mind",
		92679, --"Flask of Battle",
		79469, --"Flask of Steelskin",
		79471, --"Flask of the Winds",
		79472, --"Flask of Titanic Strength",
		79640, --"Int +80",
	},
	BattleElixir = {
		33721, --"Spellpower Elixir",
		53746, --"Wrath Elixir",
		28497, --"Elixir of Mighty Agility",
		53748, --"Elixir of Mighty Strength",
		60346, --"Elixir of Lightning Speed",
		60344, --"Elixir of Expertise",
		60341, --"Elixir of Deadly Strikes",
		80532, --"Elixir of Armor Piercing",
		60340, --"Elixir of Accuracy",
		53749, --"Guru's Elixir",
	},
	GuardianElixir = {
		60343, --"Elixir of Mighty Defense",
		53751, --"Elixir of Mighty Fortitude",
		53764, --"Elixir of Mighty Mageblood",
		60347, --"Elixir of Mighty Thoughts",
		53763, --"Elixir of Protection",
		53747, --"Elixir of Spirit",
	},
	Food = {
		57325, -- 80 AP
		57327, -- 46 SP
		57329, -- 40 CS
		57332, -- 40 Haste
		57334, -- 20 MP5
		57356, -- 40 EXP
		57360, -- 40 Hit
		57363, -- Track Humanoids
		57365, -- 40 Spirit
		57367, -- 40 AGI
		57371, -- 40 STR
		57373, -- Track Beasts
		57399, -- 80AP, 46SP (fish feast)
		59230, -- 40 DODGE
		65247, -- Pet 40 STR
		87587, -- 90 INT
		87567, -- 60 INT
		87599, -- 90 HASTE
		87597, -- 90 CRIT
		87586, -- 90 AGI
		87644, -- 90 SEA FOOD
		87915, -- 60 GOB BBQ
		87584, -- 90 STR
		87602, -- 90 PAR
		87637, -- 90 EXP
		87588, -- 90 SPI
		87604, -- 90 STAM
		87595, -- 90 HIT
		87594, -- 90 MAST
		87601, -- 90 DODGE
		}
}

--Config ends here, only edit past this point if you know what your doing.

--Locals
local flaskbuffs = BuffReminderRaidBuffs["Flask"]
local battleelixirbuffs = BuffReminderRaidBuffs["BattleElixir"]
local guardianelixirbuffs = BuffReminderRaidBuffs["GuardianElixir"]
local foodbuffs = BuffReminderRaidBuffs["Food"]	
local battleelixired	
local guardianelixired	

--Setup Caster Buffs
local function SetCasterOnlyBuffs()
	Spell3Buff = { --Total Stats
		1126, -- "Mark of the wild"
		90363, --"Embrace of the Shale Spider"
		20217, --"Greater Blessing of Kings",
	}
	Spell4Buff = { --Total Stamina
		469, -- Commanding
		6307, -- Blood Pact
		90364, -- Qiraji Fortitude
		21562, -- Fortitude
	}
	Spell5Buff = { --Total Mana
		61316, --"Dalaran Brilliance"
		1459, --"Arcane Brilliance"
	}
	Spell6Buff = { --Mana Regen
		19740, --"Blessing of Might"
		5675, --"Mana Spring Totem"
	}
end

--Setup everyone else's buffs
local function SetBuffs()
	Spell3Buff = { --Total Stats
		1126, -- "Mark of the wild"
		90363, --"Embrace of the Shale Spider"
		20217, --"Greater Blessing of Kings",
	}
	Spell4Buff = { --Total Stamina
		469, -- Commanding
		6307, -- Blood Pact
		90364, -- Qiraji Fortitude
		21562, -- Fortitude
	}
	Spell5Buff = { --Total Mana
		61316, --"Dalaran Brilliance"
		1459, --"Arcane Brilliance"
	}
	Spell6Buff = { --Total AP
		19740, --"Blessing of Might" placing it twice because i like the icon better :D code will stop after this one is read, we want this first 
		30808, --"Unleashed Rage"
		53138, --Abom Might
		19506, --Trushot
		19740, --"Blessing of Might" because the last one on the list is the icon
	}
end

--Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local resilience
	if GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)*0.02828 > GetDodgeChance() then
		resilience = true
	else
		resilience = false
	end
	--print(dodge, resil)
	if ((TukuiDB.myclass == "PALADIN" and GetPrimaryTalentTree() == 2) or 
	(TukuiDB.myclass == "WARRIOR" and GetPrimaryTalentTree() == 3) or 
	(TukuiDB.myclass == "DEATHKNIGHT" and GetPrimaryTalentTree() == 1)) and
	resilience == false or
	--Check for 'Thick Hide' tanking talent
	(TukuiDB.myclass == "DRUID" and GetPrimaryTalentTree() == 2 and GetBonusBarOffset() == 3) then
		TukuiDB.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if ((playerap > playerint) or (playeragi > playerint)) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139))) then
			TukuiDB.Role = "Melee"
		else
			TukuiDB.Role = "Caster"
		end
	end
end	
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

-- we need to check if you have two differant elixirs if your not flasked, before we say your not flasked
local function CheckElixir(unit)
	if (battleelixirbuffs and battleelixirbuffs[1]) then
		for i, battleelixirbuffs in pairs(battleelixirbuffs) do
			local spellname = select(1, GetSpellInfo(battleelixirbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(battleelixirbuffs)))
				battleelixired = true
				break
			else
				battleelixired = false
			end
		end
	end
	
	if (guardianelixirbuffs and guardianelixirbuffs[1]) then
		for i, guardianelixirbuffs in pairs(guardianelixirbuffs) do
			local spellname = select(1, GetSpellInfo(guardianelixirbuffs))
			if UnitAura("player", spellname) then
				guardianelixired = true
				if not battleelixired then
					FlaskFrame.t:SetTexture(select(3, GetSpellInfo(guardianelixirbuffs)))
				end
				break
			else
				guardianelixired = false
			end
		end
	end	
	
	if guardianelixired == true and battleelixired == true then
		FlaskFrame:SetAlpha(1)
		return
	else
		FlaskFrame:SetAlpha(0.2)
	end
end


--Main Script
local function OnAuraChange(self, event, arg1, unit)
	if (event == "UNIT_AURA" and arg1 ~= "player") then 
		return
	end
	
	--If We're a caster we may want to see differant buffs
	if TukuiDB.Roll == "Caster" then 
		SetCasterOnlyBuffs() 
	else
		SetBuffs()
	end
	
	--Start checking buffs to see if we can find a match from the list
	if (flaskbuffs and flaskbuffs[1]) then
		FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs[1])))
		for i, flaskbuffs in pairs(flaskbuffs) do
			local spellname = select(1, GetSpellInfo(flaskbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs)))
				FlaskFrame:SetAlpha(1)
				break
			else
				CheckElixir()
			end
		end
	end
	
	if (foodbuffs and foodbuffs[1]) then
		FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs[1])))
		for i, foodbuffs in pairs(foodbuffs) do
			local spellname = select(1, GetSpellInfo(foodbuffs))
			if UnitAura("player", spellname) then
				FoodFrame:SetAlpha(1)
				FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
				break
			else
				FoodFrame:SetAlpha(0.2)
			end
		end
	end
	
	for i, Spell3Buff in pairs(Spell3Buff) do
		local spellname = select(1, GetSpellInfo(Spell3Buff))
		if UnitAura("player", spellname) then
			Spell3Frame:SetAlpha(1)
			Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
			break
		else
			Spell3Frame:SetAlpha(0.2)
			Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
		end
	end
	
	for i, Spell4Buff in pairs(Spell4Buff) do
		local spellname = select(1, GetSpellInfo(Spell4Buff))
		if UnitAura("player", spellname) then
			Spell4Frame:SetAlpha(1)
			Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
			break
		else
			Spell4Frame:SetAlpha(0.2)
			Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
		end
	end
	
	for i, Spell5Buff in pairs(Spell5Buff) do
		local spellname = select(1, GetSpellInfo(Spell5Buff))
		if UnitAura("player", spellname) then
			Spell5Frame:SetAlpha(1)
			Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
			break
		else
			Spell5Frame:SetAlpha(0.2)
			Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
		end
	end	

	for i, Spell6Buff in pairs(Spell6Buff) do
		local spellname = select(1, GetSpellInfo(Spell6Buff))
		if UnitAura("player", spellname) then
			Spell6Frame:SetAlpha(1)
			Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
			break
		else
			Spell6Frame:SetAlpha(0.2)
			Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
		end
	end
end

--TukuiMinimap:SetSize(TukuiDB.Scale(TukuiMinimap:GetWidth() + 4), TukuiDB.Scale(TukuiMinimap:GetHeight() + 4))
local bsize = (((TukuiMinimap:GetWidth()) - (TukuiDB.Scale(4) * 7)) / 6)


--Create the Main bar
local raidbuff_reminder = CreateFrame("Frame", "RaidBuffReminder", TukuiMinimap)
raidbuff_reminder:CreatePanel(raidbuff_reminder, TukuiMinimap:GetWidth(), bsize + TukuiDB.Scale(8), "TOPLEFT", TukuiMinimapStatsLeft, "BOTTOMLEFT", 0, TukuiDB.Scale(-3))
	if C.general.ali == true then
	raidbuff_reminder:SetBackdropColor(unpack(C.general.color))
	end
raidbuff_reminder:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
raidbuff_reminder:RegisterEvent("UNIT_INVENTORY_CHANGED")
raidbuff_reminder:RegisterEvent("UNIT_AURA")
raidbuff_reminder:RegisterEvent("PLAYER_ENTERING_WORLD")
raidbuff_reminder:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
raidbuff_reminder:RegisterEvent("CHARACTER_POINTS_CHANGED")
raidbuff_reminder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
raidbuff_reminder:SetScript("OnEvent", OnAuraChange)


--Function to create buttons
local function CreateButton(name, relativeTo, firstbutton)
	local button = CreateFrame("Frame", name, RaidBuffReminder)
	if firstbutton == true then
		TukuiDB.CreatePanel(button, bsize, bsize, "LEFT", relativeTo, "LEFT", TukuiDB.Scale(4), 0)
	else
		TukuiDB.CreatePanel(button, bsize, bsize, "LEFT", relativeTo, "RIGHT", TukuiDB.Scale(4), 0)
	end
	button:SetFrameLevel(RaidBuffReminder:GetFrameLevel() + 2)
	button:SetBackdropBorderColor(0,0,0,0)
	
	button.FrameBackdrop = CreateFrame("Frame", nil, button)
	TukuiDB.SetTemplate(button.FrameBackdrop)
	button.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	button.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	button.FrameBackdrop:SetFrameLevel(button:GetFrameLevel() - 1)	
	button.t = button:CreateTexture(name..".t", "OVERLAY")
	button.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.t:SetAllPoints(button)
end

--Create Buttons
do
	CreateButton("FlaskFrame", RaidBuffReminder, true)
	CreateButton("FoodFrame", FlaskFrame, false)
	CreateButton("Spell3Frame", FoodFrame, false)
	CreateButton("Spell4Frame", Spell3Frame, false)
	CreateButton("Spell5Frame", Spell4Frame, false)
	CreateButton("Spell6Frame", Spell5Frame, false)
end
