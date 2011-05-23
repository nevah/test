local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
-- EXAMPLE CUSTOMBAR SETUP - C.actionbar.custombar.spells = {"Regrowth", "Rebirth"}
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
	C.actionbar.custombar.spells = {"Regrowth", "Rebirth", "Innervate", "Swiftmend"}
end

if T.myname == "Epicshot" then
	C.swingtimer.enable = true
	--C.actionbar.custombar.spells = {"Ice Trap", "Mend Pet"}
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