WoWJapanizer_Quest = { }

function WoWJapanizer_Quest:Get(id)
    if type(id) == 'number' then
        id = tostring(id)
    end

	if WoWJapanizer.db.profile.quest.furigana then
		if not self.FuriganaData[id] then
			return nil
		end

		return {
		  ["title"]       = self.FuriganaData[id][1],
		  ["objective"]   = self.FuriganaData[id][2],
		  ["description"] = self.FuriganaData[id][3],
		  ["progress"]    = self.FuriganaData[id][4],
		  ["reward"]      = self.FuriganaData[id][5],
		  ["completion"]  = self.FuriganaData[id][6],
		  ["translator"]  = self.FuriganaData[id][7],
		  ["status"]      = self.FuriganaData[id][8],
		}
	else
		if not self.Data[id] then
			return nil
		end

		return {
			["title"]       = self.Data[id][1],
			["objective"]   = self.Data[id][2],
			["description"] = self.Data[id][3],
			["progress"]    = self.Data[id][4],
			["reward"]      = self.Data[id][5],
			["completion"]  = self.Data[id][6],
			["translator"]  = self.Data[id][7],
			["status"]      = self.Data[id][8],
		}	
	end
end

function WoWJapanizer_Quest:GetID(event)
    local title = GetTitleText()
    local questID = 0

    if event == QUEST_COMPLETE then
        questID = self:GetID_QuestLog(title)
    end

    if questID > 0 then
        return questID
    end

--    local questgiver = UnitName("questnpc")

    if not self.Index[title] then
        return 0
    end

    local side = UnitFactionGroup("player") == 'Alliance' and 1 or 2

    questID = self:GetID_Side(side, self.Index[title])
    if questID > 0 then
        return questID
    end

    local text = nil
    local magic_index = 0
    if event == QUEST_DETAIL then
        text = GetObjectiveText()
        magic_index = 2
    elseif event == QUEST_COMPLETE then
        text = GetRewardText()
        magic_index = 3
    end

    local magic_text = self:GetMagicData(text)
    questID = self:GetID_MagicData(magic_text, magic_index, side, self.Index[title])

    return questID
end

function WoWJapanizer_Quest:GetID_ItemRefTooltip(tooltip)
    local title = _G[tooltip:GetName() .. "TextLeft1"]:GetText()
    local onquest = false
    local text = nil

    for i=2,tooltip:NumLines() do
        text = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()

        if text == 'You are on this quest' then
            onquest = true
        end

        if text:match("^%s+$") then
            text = _G[tooltip:GetName() .. "TextLeft" .. (i + 1)]:GetText()
            break
        end
    end

    local questID = 0

    if onquest then
        questID = self:GetID_QuestLog(title)
        if questID > 0 then
            return questID
        end
    end

    if not self.Index[title] then
        return 0
    end

    local side = UnitFactionGroup("player") == 'Alliance' and 1 or 2

    questID = self:GetID_Side(side, self.Index[title])
    if questID > 0 then
        return questID
    end

    local magic_text = self:GetMagicData(text)
    questID = self:GetID_MagicData(magic_text, 2, side, self.Index[title])

    return questID
end

function WoWJapanizer_Quest:GetID_Side(side, index)
    local questID = 0
    local count = 0
    for id, line in pairs(index) do
        if line[1] == side or line[1] == 3 then
            questID = id
            count = count + 1
        end
    end

    if count == 1 then
        return tonumber(questID)
    else
        return 0
    end
end

function WoWJapanizer_Quest:GetID_MagicData(magic_text, magic_index, side, index)
    local magic_id = 0
    local magic_count = 0
    local questID = 0
    local count = 0

    for id, line in pairs(index) do
        if line[1] == side or line[1] == 3 then
            questID = id
            count = count + 1

            if line[magic_index] == magic_text then
                magic_id = id
                magic_count = magic_count + 1
            end
        end
    end

    if count > 1 then
        if magic_count > 1 then
            return 0
        else
            return magic_id
        end
    else
        return questID
    end
end

function WoWJapanizer_Quest:GetMagicData(text)
    function split(str, sep)
--	    p, nrep = str:gsub("%s*"..sep.."%s*", "")
--	    return { str:match((("%s*(.-)%s*"..sep.."%s*"):rep(nrep).."(.*)")) }

        local t = {}
        for w in string.gmatch(str, "[^%s]+") do
            table.insert(t, w)
        end
        return t
    end 

    local player_name = string.lower(UnitName("player"))
    local player_class = string.lower(UnitClass("player"))
    local player_race  = string.lower(UnitRace("player"))

    local words = split(string.gsub(text, "\n", " "), " ")

    local lword
    local magic = ''
    for i=1, #words do
        lword = string.lower(words[i])
        if not ( string.match(lword, player_name) or string.match(lword, player_class) or string.match(lword, player_race) ) then
            magic = magic .. words[i]:sub(0,1)

            if string.len(magic) > 9 then
                break
            end
        end
    end

    return magic
end

function WoWJapanizer_Quest:GetID_QuestLog(title)
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local questID = 0

    for i=1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and title == info.title then
            questID = info.questID
            break
        end
    end

    if type(questID) == 'number' then
        return questID
    else
        return 0
    end
end
