WoWJapanizerQuest = {}
WoWJapanizerQuest.TEXT_MAX = 5

function WoWJapanizerQuest:New(base)
    local obj = {}
    obj.base = base
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function WoWJapanizerQuest:OnInitialize()
    WoWJapanizerX:DebugLog("WoWJapanizerQuest: OnInitialize.");
end

function WoWJapanizerQuest:OnEnable()
    WoWJapanizerX:DebugLog("WoWJapanizerQuest: OnEnable.");
end

function WoWJapanizerQuest:OnDisable()
    WoWJapanizerX:DebugLog("WoWJapanizerQuest: OnDisable.");
end

function WoWJapanizerQuest:Initialize()
    local base = self.base
    self.Frame = _G[base .. "Frame"]

    local obj
    base = base .. "DetailFrame"
    for i=1, self.TEXT_MAX do
        obj = "Title" .. tostring(i)
        self[obj] = _G[base .. obj]
        self[obj]:SetFont(WoWJapanizerX.FONT, 14 +  WoWJapanizerX:FontSize())

        obj = "Text" .. tostring(i)
        self[obj] = _G[base .. obj]
        self[obj]:SetFont(WoWJapanizerX.FONT, 12 +  WoWJapanizerX:FontSize())
	end
end

function WoWJapanizerQuest:LoadAddOn()
    if not WoWJapanizerX:LoadAddOn("WoWJapanizer_Quest") then
        return {
            ["error"] = true,
            ["text"]  = WoWJapanizerX.L["ErrorAddonQuest"],
        }
    end

    return {
        ["error"] = false,
    }
end

function WoWJapanizerQuest:Get(questID)
    --[[
	addon = self:LoadAddOn()
    if addon.error then
        return addon
    end
	]]
    local quest = WoWJapanizer_Quest:Get(questID)

    if not quest then
        return {
            ["error"] = true,
            ["text"]  = WoWJapanizerX.L["UnknownQuest"] .. "\n\n" .. 'QuestID:' .. tostring(questID),
        }
    end
	
	-- WoWJapanizer_Quest.FuriganaData
    
	local player_name = UnitName("player")
    local player_class = UnitClass("player")
    local player_race  = UnitRace("player")

    function convert(text)
        local str = string.gsub(text, "  ", "\n")
        str = string.gsub(str, "<name>",  player_name)
        str = string.gsub(str, "<class>", player_class)
        str = string.gsub(str, "<race>",  player_race)
        return str
    end

    local status = quest.status == '1' and WoWJapanizerX.L["WikiTranslation"] or WoWJapanizerX.L["ExciteTranslation"]
    local translator = string.gsub(quest.translator, "  ", "\n    ")

    local translation = ""
    if translator ~= "" then
        translation = WoWJapanizerX.L["Translator"] .. "\n    " .. translator .. "\n\n"
    end

    return {
        ["title"]       = WoWJapanizerX.L["BracketLeft"] .. quest.title .. WoWJapanizerX.L["BracketRight"],
        ["objective"]   = convert(quest.objective),
        ["description"] = convert(quest.description),
        ["completion"]  = convert(quest.completion),
        ["translation"] = translation,

        --["translation"] = translation .. WoWJapanizerX.L["Source"] .. "\n    " .. status,
    }
end


function WoWJapanizerQuest:GetID(event)
    addon = self:LoadAddOn()
    if addon.error then
        return addon
    end

    local questID = WoWJapanizer_Quest:GetID(event)

    if questID == 0 then
        return {
            ["error"] = true,
            ["text"]  = "error",
        }
    end

    return {
        ["questID"] = questID,
    }
end

function WoWJapanizerQuest:SetAdjustText(container, text)
    container:SetHeight(1024)
    container:SetText(text)
    container:SetHeight(container:GetStringHeight() + 4)
end

function WoWJapanizerQuest:Layout(top, container)
    before = 0

    for i, v in ipairs(container) do
        if before > 0 then
            if before == 1 then
                top = top + 5
            elseif before == 2 then
                top = top + 15
            end
        end

        v.container:SetPoint("TOPLEFT", 0, 0 - top)
        top = top + v.container:GetHeight()
        before = v.type
    end
end

function WoWJapanizerQuest:Show(questID, list, isOnMap)
    local quest = self:Get(questID)

    if quest.error then
        self:Error(quest.text)
        return
    end


    self:Clear()

    local container, text
    local t = {}
    local num1 = 1
    local num2 = 1
    local ng = false
    for i, v in ipairs(list) do
        if v.target == '' then
            text = v.text
        else
            text = quest[v.target]
        end

        if not v.empty and text == '' then
            ng = true
        end

        if v.type == 1 then
            container = self["Title" .. tostring(num1)]
            container:SetText(text)
            num1 = num1 + 1
        else
            container = self["Text" .. tostring(num2)]
            self:SetAdjustText(container, text)
            num2 = num2 + 1
        end

        table.insert(t, { ["type"] = v.type, ["container"] = container })
    end


    if ng then
        if self.Frame:IsShown() then
            self.Frame:Hide()
        end
        return
    end

    self:Layout(4, t)

    if self.QuestID then
        self.QuestID:SetFormattedText("QuestID: |cffffffff%-6s|r", tostring(questID))
    end

	if isOnMap == false then
		local bar
		if self.ScrollFrame then
			bar = _G[self.ScrollFrame:GetName() .. "ScrollBar"]
		else
			bar = _G[self.Frame:GetName() .. "ScrollBar"]
		end
		bar:SetValue(0)
	end
	
	WoWJapanizerX:DebugLog(quest["description"]);

    if not self.Frame:IsShown() then
		self.Frame:Show()
    end
end

function WoWJapanizerQuest:ShowDefault(questID)
    self:Show(questID, {
        { type = 1, empty = false, target = "title",       text = "" },
        { type = 2, empty = true,  target = "objective",   text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizerX.L["Description"] },
        { type = 2, empty = true,  target = "description", text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizerX.L["Translation"] },
        { type = 2, empty = true,  target = "translation", text = "" },
    }, false)
end

function WoWJapanizerQuest:ShowOnMap(questID)
    self:Show(questID, {
        { type = 1, empty = false, target = "title",       text = "" },
        { type = 2, empty = true,  target = "objective",   text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizerX.L["Description"] },
        { type = 2, empty = true,  target = "description", text = "" },
        { type = 1, empty = false, target = "",            text = WoWJapanizerX.L["Translation"] },
        { type = 2, empty = true,  target = "translation", text = "" },
    }, true)
end



function WoWJapanizerQuest:Error(message)
    self:Clear()

    self.Title1:SetText(WoWJapanizerX.L["BracketLeft"] .. WoWJapanizerX.L["Error"] .. WoWJapanizerX.L["BracketRight"])
    self:SetAdjustText(self.Text1, message)

    self:Layout(4, {
        { ["type"] = 1, ["container"] = self.Title1 },
        { ["type"] = 2, ["container"] = self.Text1 },
    })

    if not self.Frame:IsShown() then
        self.Frame:Show()
    end
end

function WoWJapanizerQuest:Clear()
    local obj
    for i=1, self.TEXT_MAX do
        self["Title" .. tostring(i)]:SetText("")
        self["Text" .. tostring(i)]:SetText("")
    end
end

