local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

if C.Addon_Skins.background then
	-- Addons Background (same size as right chat background)
	local bg = CreateFrame("Frame", "AddonBGPanel", UIParent)
	bg:CreatePanel("Transparent", 376, 151, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4)
	bg:CreateShadow("Default")

	local bgtab = CreateFrame("Frame", nil, bg)
	bgtab:CreatePanel("Transparent", 1, 20, "TOPLEFT", bg, "TOPLEFT", 5, -5)
	bgtab:Point("TOPRIGHT", bg, "TOPRIGHT", -5, -5)
	bgtab:CreateShadow("Default")
	
	if C.chat.rightchatbackground then
		-- Use Chatsize if there is the rightchatbackground
		bg:ClearAllPoints()
		bg:Point("TOPLEFT", _G["ChatFrame"..C.chat.rightchatnumber], "TOPLEFT", -5, 29)
		bg:Point("BOTTOMRIGHT", _G["ChatFrame"..C.chat.rightchatnumber], "BOTTOMRIGHT", 5, -5)

		bgtab:ClearAllPoints()
		bgtab:Point("TOPLEFT", bg, "TOPLEFT", 5, -5)
		bgtab:Point("TOPRIGHT", bg, "TOPRIGHT", -28, -5)
		
		local bgc = CreateFrame("Frame", nil, bgtab)
		bgc:CreatePanel("Transparent", 20, 20, "LEFT", bgtab, "RIGHT", 3, 0)
		bgc:CreateShadow("Default")
		bgc:SetFrameStrata("HIGH")
		bgc:SetFrameLevel(10)
		
		bgc.t = bgc:CreateFontString(nil, "OVERLAY")
		bgc.t:SetPoint("CENTER")
		bgc.t:SetFont(C.datatext.font, C.datatext.fontsize)
		bgc.t:SetText(T.panelcolor.."T")
		
		bgc:SetScript("OnEnter", function() bgc.t:SetText("T") end)
		bgc:SetScript("OnLeave", function() bgc.t:SetText(T.panelcolor.."T") end)
			
		bgc:SetScript("OnMouseDown", function(self) 
			ChatBG2:Show() 
			_G["ChatFrame"..C.chat.rightchatnumber]:Show()
			_G["ChatFrame"..C.chat.rightchatnumber.."Tab"]:Show()
			bg:Hide()
			if IsAddOnLoaded("Recount") then Recount_MainWindow:Hide() end
			if IsAddOnLoaded("Omen") then OmenAnchor:Hide() end
			if IsAddOnLoaded("Skada") then Skada:SetActive(false) end
		end)
	end

	-- toggle in-/outfight (NOTE: This will only toggle ChatFrameX (chat config))
	bg:RegisterEvent("PLAYER_ENTERING_WORLD")
	if C.Addon_Skins.combat_toggle then
		bg:RegisterEvent("PLAYER_REGEN_ENABLED")
		bg:RegisterEvent("PLAYER_REGEN_DISABLED")
	end
	bg:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			if C.chat.rightchatbackground or C.Addon_Skins.combat_toggle then
				-- Hide
				bg:Hide()
				if IsAddOnLoaded("Recount") then Recount_MainWindow:Hide() end
				if IsAddOnLoaded("Omen") then OmenAnchor:Hide() end
				if IsAddOnLoaded("Skada") then Skada:SetActive(false) end
				if ChatBG2 then ChatBG2:Show() end
				_G["ChatFrame"..C.chat.rightchatnumber]:Show()
				_G["ChatFrame"..C.chat.rightchatnumber.."Tab"]:Show()
				
				-- yeah set all chats again cause we lose them after /rl when chat is hidden ..dunno how to prevent this atm
				ChatFrame_RemoveAllMessageGroups(_G["ChatFrame"..C.chat.rightchatnumber])
				ChatFrame_AddChannel(_G["ChatFrame"..C.chat.rightchatnumber], L.chat_trade)
				ChatFrame_AddMessageGroup(_G["ChatFrame"..C.chat.rightchatnumber], "COMBAT_XP_GAIN")
				ChatFrame_AddMessageGroup(_G["ChatFrame"..C.chat.rightchatnumber], "COMBAT_HONOR_GAIN")
				ChatFrame_AddMessageGroup(_G["ChatFrame"..C.chat.rightchatnumber], "COMBAT_FACTION_CHANGE")
				ChatFrame_AddMessageGroup(_G["ChatFrame"..C.chat.rightchatnumber], "LOOT")
				ChatFrame_AddMessageGroup(_G["ChatFrame"..C.chat.rightchatnumber], "MONEY")
				ChatFrame_AddMessageGroup(_G["ChatFrame"..C.chat.rightchatnumber], "SKILL")
			end
		end
		if C.Addon_Skins.combat_toggle then
			if event == "PLAYER_REGEN_ENABLED" then
				self:Hide()
				if ChatBG2 then ChatBG2:Show() end
				_G["ChatFrame"..C.chat.rightchatnumber]:Show()
				_G["ChatFrame"..C.chat.rightchatnumber.."Tab"]:Show()
				if IsAddOnLoaded("Recount") then Recount_MainWindow:Hide() end
				if IsAddOnLoaded("Omen") then OmenAnchor:Hide() end
				if IsAddOnLoaded("Skada") then Skada:SetActive(false) end
			elseif event == "PLAYER_REGEN_DISABLED" then
				self:Show()
				if ChatBG2 then ChatBG2:Hide() end
				_G["ChatFrame"..C.chat.rightchatnumber]:Hide()
				_G["ChatFrame"..C.chat.rightchatnumber.."Tab"]:Hide()
				if IsAddOnLoaded("Recount") then Recount_MainWindow:Show() end
				if IsAddOnLoaded("Omen") then OmenAnchor:Show() end
				if IsAddOnLoaded("Skada") then Skada:SetActive(true) end
			end
		end
	end)
end