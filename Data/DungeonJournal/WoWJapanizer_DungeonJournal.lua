WoWJapanizer_DungeonJournal = { }

function WoWJapanizer_DungeonJournal:Get(id)	
	id = tostring(id)

    WoWJapanizerX:DebugLog("WoWJapanizer_DungeonJournal:Get " .. id);

	if not self.Data[id] then
		return nil
	end
	
	text = "概要:\n" .. self.Data[id][1] .. "\n\n" ..
		   "DPS:\n" .. self.Data[id][2] .. "\n\n" ..
		   "Healer:\n" .. self.Data[id][3] .. "\n\n" .. 
		   "Tank:\n" .. self.Data[id][4] .. "\n"

    return text
end

