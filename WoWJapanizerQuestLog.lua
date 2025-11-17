WoWJapanizerQuestLog = WoWJapanizerQuest:New("WoWJapanizerQuestLog")

WoWJapanizerQuestLog.QUEST_DATA_INFO_TEMPLATE = "Gnome Technology"

isCarbonInitialized = false

function WoWJapanizerQuestLog:OnInitialize()
    WoWJapanizerQuestLogTitleText:SetText("WoWJapanizer")
    WoWJapanizerQuestLogDataFrameText:SetFormattedText(self.QUEST_DATA_INFO_TEMPLATE, "unknown")

    self:Initialize()
    self.ScrollFrame = _G[self.Frame:GetName() .. "ScrollFrame"]

    self.QuestID =  _G[self.Frame:GetName() .. "QuestIdText"]
    self.QuestID:SetPoint("TOPLEFT", 0, -3)
	
    self:SetChecked(WoWJapanizer.db.profile.quest.questlog)

end

function WoWJapanizerQuestLog:OnEnable()
    WoWJapanizer:DebugLog("WoWJapanizerQuestLog: OnEnable.");
    WoWJapanizerQuestLogDataFrameText:SetFormattedText(self.QUEST_DATA_INFO_TEMPLATE, "")

    self:SetMovable(WoWJapanizer.db.profile.quest.questlog_movable)

    if C_AddOns.IsAddOnLoaded("Carbonite") then
		self:OnEnableCarbonite()
        return
    end

    if self:IsOldQuestGuru() then
        self:OnEnableQuestGuru()
    else
         hooksecurefunc("QuestLogPopupDetailFrame_Show", function(questLogIndex)
			WoWJapanizerQuestLog:QuestInfo()
         end)
		
    end
	
end

function WoWJapanizerQuestLog:OnDisable()
    WoWJapanizer:DebugLog("WoWJapanizerQuestLog: OnDisable.");
end

function WoWJapanizerQuestLog:OnEnableCarbonite()

    hooksecurefunc("QuestInfo_Display", function(quest_template, ...)
        if quest_template == QUEST_TEMPLATE_LOG then
            WoWJapanizerQuestLog:QuestInfo()
        end
    end)
end

function WoWJapanizerQuestLog:CarboniteCheck()

	if isCarbonInitialized == true then
		return
	end
	
	if NXQuestLogDetailScrollChildFrame ~= nil then 
		self.Frame:SetParent(NxQuestD)
		self.Frame:SetPoint("TOPLEFT", NXQuestLogDetailScrollChildFrame, NXQuestLogDetailScrollChildFrame:GetWidth() + 75, 42)
		self:ResizeFrame(512)
		isCarbonInitialized = true
	end
end

function WoWJapanizerQuestLog:QuestInfo()

	self:CarboniteCheck()
	
    if not WoWJapanizerQuestLogShowJapanese:GetChecked() then
        self.Frame:Hide()
        return
    end

    local index = C_QuestLog.GetSelectedQuest()
    if not index then
        return
    end

	local info = C_QuestLog.GetInfo(index)
	if not info then
	    return
	end

	WoWJapanizer:DebugLog("WoWJapanizerQuestLog:QuestInfo: " .. info.questID)

    if info.isHeader then
        return
    end

    self:ShowDefault(info.questID)

    if QuestNPCModel:IsShown() then
        local point, relativeTo, relativePoint, xOffset, yOffset = QuestNPCModel:GetPoint(1) 
        QuestNPCModel:SetPoint(point, self.Frame, relativePoint, 0, yOffset)
    end
end

function WoWJapanizerQuestLog:OnClickShowJapanese()
    self:SetChecked(WoWJapanizerQuestLogShowJapanese:GetChecked())
    if WoWJapanizerQuestLogShowJapanese:GetChecked() then
        self:QuestInfo()
    else
        self.Frame:Hide()
    end
end

function WoWJapanizerQuestLog:IsOldQuestGuru()
    if C_AddOns.IsAddOnLoaded("QuestGuru") then
        local version = C_AddOns.GetAddOnMetadata("QuestGuru", "Version")

        if string.match(version, "^[01]") then
            return true
        end
    end

    return false
end

function WoWJapanizerQuestLog:OnEnableQuestGuru()
    self.Frame:SetParent(QuestGuru_QuestLogDetailScrollFrame)
    self.Frame:SetPoint("TOPLEFT", QuestGuru_QuestLogDetailScrollFrame, 330, 53);

    WoWJapanizerQuestLogShowJapanese:SetParent(QuestGuru_QuestFrameOptionsButton)
    WoWJapanizerQuestLogShowJapanese:SetPoint("BOTTOMRIGHT", QuestGuru_QuestFrameOptionsButton, "BOTTOMRIGHT", -120 - WoWJapanizerQuestLogShowJapaneseText:GetWidth(), -2)

    self:ResizeFrame(QuestGuru_QuestLogFrame:GetHeight())

    for i=1, QUESTGURU_QUESTS_DISPLAYED do
        button = _G["QuestGuru_QuestLogTitle" .. i]
        button:HookScript("OnClick", function()
            WoWJapanizerQuestLog:QuestInfo()
        end)
    end
end

function WoWJapanizerQuestLog:ResizeFrame(height)
    if height > 512 then
        height = 512
    end

    self.Frame:SetHeight(height)
    self.ScrollFrame:SetHeight(height - 104)

    height = height - 256
    local bl = _G[self.Frame:GetName() .. "BottomLeft"]
    bl:SetHeight(height)
    bl:SetTexCoord(0, 1, ((256 - height) / 256), 1)

    local br = _G[self.Frame:GetName() .. "BottomRight"]
    br:SetHeight(height)
    br:SetTexCoord(0, 1, ((256 - height) / 256), 1)
end

function WoWJapanizerQuestLog:SetChecked(check)
    WoWJapanizerQuestLogShowJapanese:SetChecked(check)
end

function WoWJapanizerQuestLog:SetMovable(movable)
    self.Frame:SetMovable(movable)
    if movable then
        self.Frame:RegisterForDrag("LeftButton")
    end
end

function WoWJapanizerQuestLog:OnDragStart()
    if self.Frame:IsMovable() then
        self.Frame:StartMoving()
    end
end

function WoWJapanizerQuestLog:OnDragStop()
    if self.Frame:IsMovable() then
        self.Frame:StopMovingOrSizing()
        ValidateFramePosition(self.Frame)
    end
end
