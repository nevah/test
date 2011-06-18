local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3 
---------------------------------------------------------------------------

local leftbar = TukuiBarLeft
local rightbar = TukuiBarRight

MultiBarBottomRight:SetParent(leftbar)

for i= 1, 6 do
	local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton"..i-1]
	b:SetSize(T.buttonsize, T.buttonsize)
	b:ClearAllPoints()
	b:SetFrameStrata("MEDIUM")
	b:SetFrameLevel(15)
	
	if i == 1 then
		b:SetPoint("BOTTOMLEFT", leftbar, 3, 3)
	else
		b:SetPoint("BOTTOM", b2, "TOP", 0, 2)
	end
end

for i= 7, 12 do
	local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton"..i-1]
	b:SetSize(T.buttonsize, T.buttonsize)
	b:ClearAllPoints()
	b:SetFrameStrata("MEDIUM")
	b:SetFrameLevel(15)
	
	if i == 7 then
		b:SetPoint("BOTTOMLEFT", rightbar, 3, 3)
	else
		b:SetPoint("BOTTOM", b2, "TOP", 0, 2)
	end
end