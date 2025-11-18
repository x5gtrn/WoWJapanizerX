WoWJapanizerArtifactToolTip = WoWJapanizerToolTip:New("WoWJapanizerArtifactToolTip")
WoWJapanizerArtifactToolTip.Tooltip = GameTooltip

local function GetPowerInfoMaps()
	local powers = C_ArtifactUI.GetPowers();
	if not powers then return nil end
	local powerInfo, spellInfo = {}, {}
	-- get powers info
	for i, powerID in ipairs(powers) do
		local spellID, _, currentRank, maxRank, bonusRanks, x, y = C_ArtifactUI.GetPowerInfo(powerID);
		powerInfo[powerID] = {}
		powerInfo[powerID].spellID = spellID
		powerInfo[powerID].powerID = powerID
		powerInfo[powerID].buttonIndex = i
		powerInfo[powerID].currentRank = currentRank
		powerInfo[powerID].maxRank = maxRank
		powerInfo[powerID].bonusRanks = bonusRanks
		powerInfo[powerID].x = x
		powerInfo[powerID].y = y
		powerInfo[powerID].isFinished = currentRank == maxRank;
		spellInfo[spellID] = powerInfo[powerID]
	end
	return powers, powerInfo, spellInfo
end

function WoWJapanizerArtifactToolTip:GetTooltipText(id)
    local spell = WoWJapanizer_Spell:Get(id)

    if not spell then
        return nil
    end

    if string.match(spell.text, "$N%d+") then
		local engText = ""
		local num = GameTooltip:NumLines()

		local l4 = _G[GameTooltip:GetName() .. "TextLeft" .. 4]
		
		-- Active Skill, start parse from line 6
		-- Pasive Skill, start parse from line 5
		local startIndex = 6

		if l4:GetText() == 'Passive' then
			startIndex = 5
		end
		if l4:GetText() == 'Channeled' then
			startIndex = 5
		end
		if l4:GetText() == 'Instant' then
			startIndex = 5
		end
		
		for i = startIndex, num do
		
			local tip = _G[GameTooltip:GetName() .. "TextLeft" .. i]
			engText = engText ..  tip:GetText()
		
		end
		
        spell.text = WoWJapanizer_Spell:convertMacro(spell.text, engText)
    end

    return spell
end
hooksecurefunc("ArtifactFrame_LoadUI", function()	
	local orgOnEnter = ArtifactPowerButtonMixin.OnEnter

	local powers, powerInfo, spellInfo = GetPowerInfoMaps()

	function ArtifactPowerButtonMixin:OnEnter(button)
	
		orgOnEnter(self, button)
		
		if WoWJapanizerX.db.profile.spell.tooltip then
			spellID = self.spellID
			spell = WoWJapanizerArtifactToolTip:GetTooltipText(spellID)
			
			if spell then
				text = spell.text
				
				GameTooltip:AddLine("\n" .. text, 1, 1, 1)

				local num = GameTooltip:NumLines()
				local target = _G[GameTooltip:GetName() .. "TextLeft" .. num]
				local filename, fontHeight, flags =  target:GetFont()

				self.Store = {
					["FontString"] = target,
					["Font"]       = filename,
					["Size"]       = fontHeight,
				}

				target:SetFont(WoWJapanizerX.FONT, 12 + WoWJapanizerX:FontSize())
				GameTooltip:Show()

			end
		end

		
	end

end)

