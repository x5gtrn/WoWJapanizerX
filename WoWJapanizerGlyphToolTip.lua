WoWJapanizerGlyphToolTip = WoWJapanizerToolTip:New("WoWJapanizerGlyphToolTip")
WoWJapanizerGlyphToolTip.Tooltip = WoWJapanizerAssistTooltip

WoWJapanizerGlyphToolTip.GlyphStore = nil

function WoWJapanizerGlyphToolTip:OnEnable()
-- remain as comment just in case
-- need some replacement code to fill glyph feature?
--	hooksecurefunc("GlyphFrame_LoadUI", function()
--		for _, button in next, GlyphFrameScrollFrame.buttons do
--			button:HookScript("OnEnter", function(_button)
--				if _button.isHeader then
--					return
--				end

--				local name, glyphType, isKnown, icon, glyphID = GetGlyphInfo(_button.glyphIndex)

--				if not WoWJapanizerX.db.profile.spell.tooltip then return end
--				if not WoWJapanizerX:LoadAddOn("WoWJapanizer_Spell") then return end

--				local spell = WoWJapanizer_Spell:GetGlyphByName(name)
--
--				self:OnShow(spell, glyphID)
--			end)

--			button:HookScript("OnLeave", function(_button)
--				self:OnHide()
--			end)
--		end

--		hooksecurefunc("GlyphFrameGlyph_OnEnter", function(_button)
--			local enabled, glyphType, glyphTooltipIndex, glyphSpell, icon = GetGlyphSocketInfo(_button:GetID())
--
--			if not glyphSpell then return end
--			if not WoWJapanizerX.db.profile.spell.tooltip then return end
--			if not WoWJapanizerX:LoadAddOn("WoWJapanizer_Spell") then return end

--			local spell = WoWJapanizer_Spell:Get(glyphSpell)
--
--			self:OnShow(spell, nil)
--		end)

--		hooksecurefunc("GlyphFrameGlyph_OnLeave", function(_button)
--			self:OnHide()
--		end)
--	end)
end

function WoWJapanizerGlyphToolTip:OnShow(spell, glyphID)
--    if not WoWJapanizerX.db.profile.spell.tooltip then return end

--    local w = GameTooltip:GetWidth()
--    self.Tooltip:SetOwner(GameTooltip, "ANCHOR_BOTTOMLEFT", w, 0)
--    w = w - 20
--    self.Tooltip:ClearLines()
--    self.Tooltip:SetMinimumWidth(w)

--    local num = 1

--   if spell then
--       local target = _G["WoWJapanizerAssistTooltipTextLeft" .. num]
--        target:SetWidth(w)
--        self:AddText(spell.text)
--        num = num + 1
--    end

--    local target = _G["WoWJapanizerAssistTooltipTextLeft" .. num]
--    target:SetWidth(w)

--    if num == 1 then
--        local filename, fontHeight, flags =  target:GetFont()

--        self.GlyphStore = {
--            ["FontString"] = target,
--            ["Font"]       = filename,
--            ["Size"]       = fontHeight,
--        }

--        target:SetFont(filename, 12)
--    end

--    if spell then
--        self:DeveloperText("SpellID", spell.id)
--    end

--   if glyphID then
--        self.developer.setup = false
--        self:DeveloperText("GlyphID", glyphID)
--    end

--   self.Tooltip:SetWidth(w)
--    self.Tooltip:Show()
end

function WoWJapanizerGlyphToolTip:OnHide()
--    if self.Tooltip:IsShown() then
--        self.Tooltip:Hide()

--        if self.GlyphStore then
--            self.GlyphStore.FontString:SetFont(
--                self.GlyphStore.Font,
--                self.GlyphStore.Size
--            )
--            self.GlyphStore = nil
--        end

--        for i=1, 8 do
--            _G["WoWJapanizerAssistTooltipTextLeft" .. i]:SetWidth(0)
--        end

--        self.Tooltip:SetWidth(0)
--        self.Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
--    end
end
