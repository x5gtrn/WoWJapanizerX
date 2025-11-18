WoWJapanizerGameToolTip = WoWJapanizerToolTip:New("WoWJapanizerGameToolTip")
WoWJapanizerGameToolTip.Tooltip = GameTooltip

function WoWJapanizerGameToolTip:OnEnable()
    self:Enable()

	self._achievement = false

	hooksecurefunc("AchievementFrame_LoadUI", function()
		-- Wait for Achievement UI to fully load before hooking
		C_Timer.After(0.5, function()
			-- Check if AchievementFrameAchievementsContainer exists and has buttons
			if AchievementFrameAchievementsContainer and AchievementFrameAchievementsContainer.buttons then
				for _, button in next, AchievementFrameAchievementsContainer.buttons do
					if button then
						button:HookScript("OnEnter", function(_button)
							self:OnAchievement(_button)
						end)
						button:HookScript("OnLeave", function(_button)
							if self.Tooltip:IsShown() then
								self.Tooltip:Hide()
							end
						end)
					end
				end
			end

			-- Check if AchievementFrameStats exists and has buttons
			if AchievementFrameStats and AchievementFrameStats.buttons then
				for _, button in next, AchievementFrameStats.buttons do
					if button then
						button:HookScript("OnEnter", function(_button)
							if _button.isHeader then
								return
							end

							self:OnAchievement(_button)
						end)
						button:HookScript("OnLeave", function(_button)
							if self.Tooltip:IsShown() then
								self.Tooltip:Hide()
							end
						end)
					end
				end
			end

			-- Check if AchievementFrameSummary exists
			if AchievementFrameSummary then
				AchievementFrameSummary:HookScript("OnShow", function()
					if not self._achievement then
						-- Check if ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS and buttons exist
						if ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS and AchievementFrameSummaryAchievements and AchievementFrameSummaryAchievements.buttons then
							for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
								local button = AchievementFrameSummaryAchievements.buttons[i]
								if button then
									button:HookScript("OnEnter", function(_button)
										self:OnAchievementSummary(_button)
									end)
									button:HookScript("OnLeave", function(_button)
										if self.Tooltip:IsShown() then
											self.Tooltip:Hide()
										end
									end)
								end
							end
						end
						self._achievement = true
					end
				end)
			end
		end)
	end)
end

function WoWJapanizerGameToolTip:OnAchievement(button)
    if not WoWJapanizerX.db.profile.achievement.tooltip then return end

    local id, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(button.id)

    local achievement = WoWJapanizer_Achievement:Get(button.id)

    if not achievement then
        return
    end

    self.selected.type  = self.TOOLTIP_ACHIEVEMENT

    self.Tooltip:SetOwner(button, "ANCHOR_RIGHT", 0, 0)
    self.Tooltip:ClearLines()
    self.Tooltip:AddLine(name, 1, 1, 1)
    self.Tooltip:AddLine(description)

    local text = string.gsub(achievement.text, "\n", "")

    if achievement.title ~= "" then
        local player_name = UnitName("player")
        text = text .. "\n|cffffffff" .. WoWJapanizerX.L["TitleReward"] .. "|r\n" .. string.gsub(achievement.title, "<name>",  player_name)
    end

    if achievement.advice ~= "" and WoWJapanizerX.db.profile.achievement.advice then
        text = text .. "\n|cffffffff" .. WoWJapanizerX.L["Advice"] .. "|r\n" .. string.gsub(achievement.advice, "\n", "")
    end

    self:AddText(text)
    self:DeveloperText("AchievementID", button.id)
    self.Tooltip:Show()
end

function WoWJapanizerGameToolTip:OnAchievementSummary(button)
    if not WoWJapanizerX.db.profile.achievement.tooltip then return end

    local id, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(button.id)

    if completed then
        self:OnAchievement(button)
--    else
--        self:AddText(WoWJapanizerX.L["AchievementRequirements"])
--        self:Resize(self.Tooltip:GetWidth() + 75, self.Tooltip:GetHeight() + 20)
    end
end

function WoWJapanizerGameToolTip:Resize(width, height)
    if self.selected.type == self.TOOLTIP_ACHIEVEMENT then
        if width > 280 then
            local target = _G[self.Tooltip:GetName() .. "TextLeft1"]
            local h = height
            local w = math.floor(target:GetWidth())
            if w < 280 then w = 280 end

            for i=2, self.Tooltip:NumLines() do
                target = _G[self.Tooltip:GetName() .. "TextLeft" .. i]
                h = h - target:GetHeight()
                target:SetWidth(w)
                h = h + target:GetHeight()
            end

            self.Tooltip:SetWidth(w + 20)
            self.Tooltip:SetHeight(h)
        end
    end
end
