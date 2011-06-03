local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
-- EXAMPLE CUSTOMBAR SETUP - C.actionbar.custombar.primary = {"Rebirth", "Innervate", "Darkflight"} C.actionbar.custombar.secondary = {"Rebirth", "Innervate", "Darkflight", 58184} 
-- names for spells / itemIDs for items
----------------------------------------------------------------------------
-- Per Class Config (overwrite general)
-- Class need to be UPPERCASE
----------------------------------------------------------------------------

if T.myclass == "DRUID" then
--some config
end

----------------------------------------------------------------------------
-- Per Character Name Config (overwrite general and class)
-- Name need to be case sensitive
----------------------------------------------------------------------------

if T.myname == "Epicgrim" then
	C.actionbar.hideshapeshift = true
	C.unitframes.classbar = false
	C.actionbar.custombar.primary = {"Rebirth", "Innervate", "Darkflight"}
	C.actionbar.custombar.secondary = {"Rebirth", "Innervate", "Darkflight", 58184}
end

if T.myname == "Epicelement" then
	C.actionbar.custombar.primary = {"Heroism", "Lifeblood", "Earth Elemental Totem", "Spiritwalker's Grace"}
	C.actionbar.custombar.secondary = {"Heroism", "Lifeblood", "Earth Elemental Totem", "Spiritwalker's Grace"}
end

if T.myname == "Epicpower" then
	C.actionbar.custombar.primary = {"Mirror Image", "Icy Veins", "Ice Block", "Evocation", "Summon Water Elemental" }
	C.actionbar.custombar.secondary = {"Mirror Image", "Icy Veins", "Ice Block" ,"Evocation", "Summon Water Elemental" }
end


if T.myname == "Epicgoose" then
	C.swingtimer.enable = true
end

----------------------------------------------------------------------------
-- Per Character Level Config 
----------------------------------------------------------------------------

if UnitLevel("player") < MAX_PLAYER_LEVEL then
	-- Settings for a Char you are leveling (lvl 1-MaxLevel)
	if C.datatext.reputation == 5 then
		C.datatext.reputation = 0
		C.datatext.experience = 5
	end
end

----------------------------------------------------------------------------
-- Special Configs :o
----------------------------------------------------------------------------

if IsAddOnLoaded("a") or IsAddOnLoaded("b") then
	C.datatext.reputation = 0
	C.datatext.experience = 0
	C.unitframes.priestarmor = true
	C.datatext.mmenu = 5
	C.pvp.ccannouncement = true
	C.castbar.classcolored = false
	C.actionbar.hotkey = false
	C.pvp.dispelannouncement = true
	C.tooltip.showspellid = true
	if UnitLevel("player") < MAX_PLAYER_LEVEL then
		C.actionbar.hotkey = true 
	end
end

if IsAddOnLoaded("b") then 
	C.Addon_Skins.background = true
	C.actionbar.hotkey = true
	C.datatext.classcolored = true
	C.castbar.classcolored = true
	C.unitframes.vengeancebar = true
end