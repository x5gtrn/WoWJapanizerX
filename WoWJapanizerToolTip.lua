WoWJapanizerToolTip = {}
WoWJapanizerToolTip.Tooltip = nil
WoWJapanizerToolTip.Store = nil

WoWJapanizerToolTip.TOOLTIP_NONE        = 0
WoWJapanizerToolTip.TOOLTIP_ITEM        = 1
WoWJapanizerToolTip.TOOLTIP_SPELL       = 2
WoWJapanizerToolTip.TOOLTIP_QUEST       = 3
WoWJapanizerToolTip.TOOLTIP_ACHIEVEMENT = 4

function WoWJapanizerToolTip:New(base)
    local obj = {}
    obj.base = base
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function WoWJapanizerToolTip:OnInitialize()
    WoWJapanizer:DebugLog(self.base .. ":OnInitialize");
    self:Initialize()
end

function WoWJapanizerToolTip:OnEnable()
    WoWJapanizer:DebugLog(self.base .. ":OnEnable");
    self:Enable()
end

function WoWJapanizerToolTip:OnDisable()
    WoWJapanizer:DebugLog(self.base .. ":OnDisable");
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
    WoWJapanizer:DebugLog(self.base .. ":Enable");

	-- Store self reference for closures
	local tooltipObj = self

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
		if tooltip ~= tooltipObj.Tooltip then
			return
		end

		local name, link = tooltip:GetItem()
		if not link then
			return
		end

		local _, _, itemID = link:find("Hitem:(%d+):")
		if not itemID then
			return
		end

		tooltipObj:DebugPrint('ITEM', itemID, name, tooltipObj.Tooltip)

		if WoWJapanizer.db.profile.item.tooltip then
			local item = WoWJapanizer_Item:Get(itemID)
			if item then
				tooltipObj.selected.type = tooltipObj.TOOLTIP_ITEM
				tooltipObj:AddText(item.text)
			end
		end

		tooltipObj:DeveloperText("ItemID", itemID)
	end)

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
		if tooltip ~= tooltipObj.Tooltip then
			return
		end

		local spellName, spellRank, spellID = tooltip:GetSpell()
		if not spellID then
			return
		end

		tooltipObj:DebugPrint('SPELL', spellID, spellName, tooltipObj.Tooltip)

		if WoWJapanizer.db.profile.spell.tooltip then
			if not tooltipObj:CheckEnhancedTooltips() then
				tooltipObj:AddText(WoWJapanizer.L.NotEnhancedTooltips)
				return
			end

			local spell = WoWJapanizer_Spell:GetTooltipText(spellID, tooltipObj.Tooltip)
			if spell then
				tooltipObj.selected.type = tooltipObj.TOOLTIP_SPELL
				if spell.next == nil then
					tooltipObj:AddText(spell.text)
				else
					tooltipObj:AddText(spell.text .. "\n|cffffffff" .. WoWJapanizer.L["NextRank"] .. "|r\n" .. spell.next)
				end
			end
		end

		tooltipObj:DeveloperText("SpellID", spellID)
	end)

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

    target:SetFont(WoWJapanizer.FONT, 12 + WoWJapanizer:FontSize())

	--    target:SetTextColor(1, 0.4, 0, 1)
end

function WoWJapanizerToolTip:DeveloperText(text, id)

	if id == nil then
		return
	end

    if WoWJapanizer.db.profile.developer then
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

function WoWJapanizerToolTip:CheckEnhancedTooltips()
    if tonumber(GetCVar("UberTooltips")) == 1 then
        return true
    else
        return false
    end
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
