WoWJapanizerToolTip = {}
WoWJapanizerToolTip.Tooltip = nil
WoWJapanizerToolTip.Store = nil

WoWJapanizerToolTip.TOOLTIP_NONE        = 0
WoWJapanizerToolTip.TOOLTIP_QUEST       = 1

function WoWJapanizerToolTip:New(base)
    local obj = {}
    obj.base = base
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function WoWJapanizerToolTip:OnInitialize()
    WoWJapanizerX:DebugLog(self.base .. ":OnInitialize");
    self:Initialize()
end

function WoWJapanizerToolTip:OnEnable()
    WoWJapanizerX:DebugLog(self.base .. ":OnEnable");
    self:Enable()
end

function WoWJapanizerToolTip:OnDisable()
    WoWJapanizerX:DebugLog(self.base .. ":OnDisable");
end

function WoWJapanizerToolTip:Initialize()
    self.selected  = { setup = false, type = self.TOOLTIP_NONE }
    self.developer = { setup = false }
    self.Store = nil

    self.Tooltip:HookScript("OnHide", function(tooltip)
--        self.selected.type  = self.TOOLTIP_NONE
        self:Restore()
    end)

    self.Tooltip:HookScript("OnTooltipCleared", function(tooltip)
        self.selected.setup  = false
        self.developer.setup = false
    end)

    self.Tooltip:HookScript("OnSizeChanged", function(tooltip, width, height)
        self:Resize(width, height)
    end)
end

function WoWJapanizerToolTip:Enable()
    WoWJapanizerX:DebugLog(self.base .. ":Enable");
end

function WoWJapanizerToolTip:AddText(text)
    if text == '' then
        return
    end

    if not self:AddCheck(self.selected) then
        return
    end

    self:Restore()
    -- self.Tooltip:AddLine(text, 1, 0.4, 0)
    self.Tooltip:AddLine(text, 1, 1, 1)

    local num = self.Tooltip:NumLines()
    local target = _G[self.Tooltip:GetName() .. "TextLeft" .. num]
    local filename, fontHeight, flags =  target:GetFont()

    self.Store = {
        ["FontString"] = target,
        ["Font"]       = filename,
        ["Size"]       = fontHeight,
    }

    target:SetFont(WoWJapanizerX.FONT, 12 + WoWJapanizerX:FontSize())

	--    target:SetTextColor(1, 0.4, 0, 1)
end

function WoWJapanizerToolTip:DeveloperText(text, id)

	if id == nil then
		return
	end

    if WoWJapanizerX.db.profile.developer then
        if not self:AddCheck(self.developer) then
            return
        end

        self.Tooltip:AddLine(text .. ": " .. id, 0.6, 0.6, 0.6)
--        self.Tooltip:AddLine(string.format("|cff999999%s: %d|r", text, id))
    end
end

function WoWJapanizerToolTip:Restore()
    if self.Store then
        self.Store.FontString:SetFont(
            self.Store.Font,
            self.Store.Size
        )
        self.Store = nil
    end
end

function WoWJapanizerToolTip:AddCheck(t)
    if t.setup then
        return false
    else
        t.setup = true
        return true
    end
end

function WoWJapanizerToolTip:AddSeparator()
    self.Tooltip:AddLine(" ")
end

function WoWJapanizerToolTip:Resize(width, height)
end

function WoWJapanizerToolTip:DebugPrint(base, id, name, tooltip)
    if WoWJapanizerDebugFrame:IsShown() then
        local num = tooltip:NumLines()
        local target = _G[tooltip:GetName() .. "TextLeft" .. num]

        local editbox = WoWJapanizerDebugFrameScrollFrameText
        base = base .. ":" .. tostring(id)

        editbox:SetText(editbox:GetText() .. "\nBEGIN:" .. base .. "\n" .. name .. "\n" .. target:GetText() .. "\nEND:" .. base .. "\n")
    end
end
