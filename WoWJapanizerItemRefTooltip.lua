WoWJapanizerItemRefTooltip = WoWJapanizerToolTip:New("WoWJapanizerItemRefTooltip")
WoWJapanizerItemRefTooltip.Tooltip = ItemRefTooltip

function WoWJapanizerItemRefTooltip:OnInitialize()
    self:Initialize()

    -- Store self reference for closures
    local tooltipObj = self

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function(tooltip, data)
        if tooltip ~= tooltipObj.Tooltip then
            return
        end
        tooltipObj:OnQuest()
    end)

end

function WoWJapanizerItemRefTooltip:OnQuest()
    if not WoWJapanizerX.db.profile.quest.tooltip then
        return
    end

    local questID = WoWJapanizer_Quest:GetID_ItemRefTooltip(self.Tooltip)

    if questID == 0 then
        return
    end

    local quest = WoWJapanizer_Quest:Get(questID)

    if not quest then
        return
    end

    if quest.objective == '' then
        return
    end

    self.selected.type  = self.TOOLTIP_QUEST

    local player_name = UnitName("player")
    local player_class = UnitClass("player")
    local player_race  = UnitRace("player")

    local str = string.gsub(quest.objective, "  ", "\n")
    str = string.gsub(str, "<name>",  player_name)
    str = string.gsub(str, "<class>", player_class)
    str = string.gsub(str, "<race>",  player_race)

    function StringAppend(text, str, i, j)
        if text ~= "" and ( j - i ) > 6 then
            text = text .. "\n"
        end
        return text .. string.sub(str, i, j)
    end

    local b, i, j, k = 0, 1, 1, 1
    local text = ''
    local ascii = false
    while i < #str do
        b = string.byte(str, i)

        if 0 < b then
            if b < 128 then
                if j > 32 and ( not ascii ) then
                    text = StringAppend(text, str, k, i - 1)
                    j = 1
                    k = i
                end

                if string.sub(str, i, i) == "\n" then
                    j = 1
                else
                    j = j + 1
                end

                i = i + 1
                ascii = true
            elseif 192 < b then
                if j > 32 then
                    text = StringAppend(text, str, k, i - 1)
                    j = 1
                    k = i
                end

                if b < 224 then
                    i = i + 2
                elseif b < 240 then
                    i = i + 3
                elseif b < 248 then
                    i = i + 4
                elseif b < 252 then
                    i = i + 5
                elseif b < 254 then
                    i = i + 6
                end

                j = j + 2
                ascii = false
            end
        end
    end

    if k < i then
        text = StringAppend(text, str, k, i)
    end

    self:AddSeparator()
    self:AddText(text)
    self:DeveloperText("QuestID", questID)
end

function WoWJapanizerItemRefTooltip:Resize(width, height)
end
