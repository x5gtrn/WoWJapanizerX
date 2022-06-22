WoWJapanizerQuestGossip = WoWJapanizerQuest:New("WoWJapanizerQuestGossip")

WoWJapanizerQuestGossip.QUEST_DATA_INFO_TEMPLATE = "QuestData: |cffffffff%s|r"

function WoWJapanizerQuestGossip:OnInitialize()
    local obj = _G[self.base .. "TitleText"]
    obj:SetText("WoWJapanizer ("  .. WoWJapanizer.version .. ")")
    obj = _G[self.base .. "DataFrameText"]
    obj:SetFormattedText(self.QUEST_DATA_INFO_TEMPLATE, "unknown")

    self:Initialize()
    self.ScrollFrame = _G[self.Frame:GetName() .. "ScrollFrame"]

    self.QuestID =  _G[self.Frame:GetName() .. "QuestIdText"]
    self.QuestID:SetPoint("TOPLEFT", 0, -3)

    QuestFrameGreetingPanel:HookScript("OnShow", function()
        WoWJapanizerQuestGossip.Frame:Hide()
    end)
    QuestFrameDetailPanel:HookScript("OnShow", function()
        WoWJapanizerQuestGossip:QuestInfo(QUEST_DETAIL)
    end)
    QuestFrameProgressPanel:HookScript("OnShow", function()
        WoWJapanizerQuestGossip.Frame:Hide()
    end)
    QuestFrameRewardPanel:HookScript("OnShow", function()
        WoWJapanizerQuestGossip:QuestInfo(QUEST_COMPLETE)
    end)
end

function WoWJapanizerQuestGossip:OnEnable()
    WoWJapanizer:DebugLog("WoWJapanizerQuestGossip: OnEnable.");

    local obj = _G[self.base .. "DataFrameText"]
    obj:SetFormattedText(self.QUEST_DATA_INFO_TEMPLATE, WoWJapanizer.version)
end

function WoWJapanizerQuestGossip:OnDisable()
    WoWJapanizer:DebugLog("WoWJapanizerQuestGossip: OnDisable.");
end

function WoWJapanizerQuestGossip:QuestInfo(event)
    if not WoWJapanizer.db.profile.quest.gossip then
        self.Frame:Hide()
        return
    end

    WoWJapanizer:DebugLog("WoWJapanizerQuestGossip:QuestInfo")

    self:Clear()

    local index = self:GetID(event)

    if index.error or index.questID == 0 then
        self.Frame:Hide()
        return
    end

    if event == QUEST_DETAIL then
        self:ShowDetail(index.questID)
    elseif event == QUEST_COMPLETE then
        self:ShowComplete(index.questID)
    end

    if self.WoWJapanizer_Quest_Version == "unknown" and IsAddOnLoaded("WoWJapanizer_Quest") then
        self.WoWJapanizer_Quest_Version = WoWJapanizer.property.quest.version
        local obj = _G[self.base .. "DataFrameText"]
        obj:SetFormattedText(self.QUEST_DATA_INFO_TEMPLATE, self.WoWJapanizer_Quest_Version)
    end

    if QuestNPCModel:IsShown() then
        local point, relativeTo, relativePoint, xOffset, yOffset = QuestNPCModel:GetPoint(1) 
        QuestNPCModel:SetPoint(point, self.Frame, relativePoint, 0, yOffset)
    end
end

function WoWJapanizerQuestGossip:ShowDetail(questID)
    self:Show(questID, {
        { type = 1, empty = false, target = "title",       text = "" },
        { type = 2, empty = true,  target = "description", text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizer.L["Objectives"] },
        { type = 2, empty = true,  target = "objective",   text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizer.L["Translation"] },
        { type = 2, empty = true,  target = "translation", text = "" },
    })
end

function WoWJapanizerQuestGossip:ShowComplete(questID)
    self:Show(questID, {
        { type = 1, empty = false, target = "title",       text = "" },
        { type = 2, empty = false, target = "completion",  text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizer.L["Translation"] },
        { type = 2, empty = true,  target = "translation", text = "" },
    })
end
