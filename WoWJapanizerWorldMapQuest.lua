WoWJapanizerWorldMapQuest = WoWJapanizerQuest:New("WoWJapanizerWorldMapQuestScroll")

function WoWJapanizerWorldMapQuest:OnInitialize()
    self:Initialize()

    self.selected = 0
    --self.WorldMapQuestScrollFrameHeight = WorldMapQuestScrollFrame:GetHeight()
    self.WorldMapScrollFrameHeight = WorldMapScrollFrame:GetHeight()

    --self:SetChecked(WoWJapanizerX.db.profile.quest.worldmap)

	hooksecurefunc("QuestMapFrame_ShowQuestDetails", function(questId)
        self.selected = questId
        WoWJapanizerWorldMapQuest:QuestInfo(questId)
	end)
end

function WoWJapanizerWorldMapQuest:OnEnable()
    WoWJapanizerX:DebugLog("WoWJapanizerWorldMapQuest: OnEnable.");
end

function WoWJapanizerWorldMapQuest:OnDisable()
    WoWJapanizerX:DebugLog("WoWJapanizerWorldMapQuest: OnDisable.");
end

function WoWJapanizerWorldMapQuest:QuestInfo(questID)

	if WoWJapanizerX:isShowQuest() == false then
		return 
	end

	WoWJapanizerX:DebugLog("WoWJapanizerWorldMapQuest: " .. questID);
    --self:ShowDefault(questID)
    self:ShowOnMap(questID)

    if QuestNPCModel:IsShown() then
        local point, relativeTo, relativePoint, xOffset, yOffset = QuestNPCModel:GetPoint(1) 
        QuestNPCModel:SetPoint(point, self.Frame, relativePoint, 0, yOffset)
    end
end

