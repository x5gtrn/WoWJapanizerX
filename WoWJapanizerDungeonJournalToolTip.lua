WoWJapanizerDungeonJournalToolTip = WoWJapanizerToolTip:New("WoWJapanizerDungeonJournalToolTip")
WoWJapanizerDungeonJournalToolTip.Tooltip = WoWJapanizerAssistTooltip

function WoWJapanizerDungeonJournalToolTip:OnEnable()
	hooksecurefunc("EncounterJournal_LoadUI", function()	
	
		hooksecurefunc("EncounterJournal_DisplayEncounter", function(encounterID, noButton)
			self:OnShow(encounterID, noButton);
		end)					
 
		EncounterJournal.encounter:HookScript("OnHide", function()
		    -- WoWJapanizerX:DebugLog("WoWJapanizerDungeonJournalToolTip: OnHide");
			self:OnHide();
		end)

	end)
	

end

function WoWJapanizerDungeonJournalToolTip:OnShow(encounterID, _button)
    
	local w = GameTooltip:GetWidth()
	
	self.Tooltip:SetOwner(EncounterJournal.encounter.info.overviewTab, "ANCHOR_TOPRIGHT", 530 , -200)
    
	w = w - 20
    self.Tooltip:ClearLines()
    self.Tooltip:SetMinimumWidth(w)
	
	local txt = WoWJapanizer_DungeonJournal:Get(encounterID) 
	
	if txt == nil then	
		-- return 
		txt = "翻訳データがありません"
		self:AddText("(" .. encounterID .. ")" .. "\n\n" .. txt)	
	else
		self:AddText(txt)
	end
	
	self.Tooltip:SetWidth(600)


    self.Tooltip:Show()

end

function WoWJapanizerDungeonJournalToolTip:OnHide()
    if self.Tooltip:IsShown() then
        self.Tooltip:Hide()
        self.Tooltip:SetWidth(0)
        -- self.Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
end

function WoWJapanizerDungeonJournalToolTip:DebugPrint(txt)
    if WoWJapanizerDebugFrame:IsShown() then
        local editbox = WoWJapanizerDebugFrameScrollFrameText

        editbox:SetText(editbox:GetText() .. "\n" .. txt)
    end
end	




