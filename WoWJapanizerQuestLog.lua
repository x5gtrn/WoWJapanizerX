WoWJapanizerQuestLog = WoWJapanizerQuest:New("WoWJapanizerQuestLog")

WoWJapanizerQuestLog.QUEST_DATA_INFO_TEMPLATE = "Gnome Technology"
WoWJapanizerQuestLog.japaneseFrame = nil
WoWJapanizerQuestLog.toggleButton = nil
WoWJapanizerQuestLog.showJapanese = true
WoWJapanizerQuestLog.eventFrame = nil
WoWJapanizerQuestLog._relayoutTicker = nil
WoWJapanizerQuestLog.detailsFrame = nil

-- Helper function to find the DetailsFrame (try multiple paths)
function WoWJapanizerQuestLog:GetDetailsFrame()
    if self.detailsFrame then
        return self.detailsFrame
    end

    if not QuestMapFrame then
        print("WoWJapanizerX: QuestMapFrame not found")
        return nil
    end

    -- Try path 1: QuestMapFrame.QuestFrame.DetailsFrame
    if QuestMapFrame.QuestFrame and QuestMapFrame.QuestFrame.DetailsFrame then
        print("WoWJapanizerX: Found DetailsFrame at QuestMapFrame.QuestFrame.DetailsFrame")
        self.detailsFrame = QuestMapFrame.QuestFrame.DetailsFrame
        return self.detailsFrame
    end

    -- Try path 2: QuestMapFrame.DetailsFrame (older version)
    if QuestMapFrame.DetailsFrame then
        print("WoWJapanizerX: Found DetailsFrame at QuestMapFrame.DetailsFrame")
        self.detailsFrame = QuestMapFrame.DetailsFrame
        return self.detailsFrame
    end

    print("WoWJapanizerX: DetailsFrame not found in any known location")
    return nil
end

function WoWJapanizerQuestLog:OnInitialize()
    -- Create event frame for handling events
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
        WoWJapanizerQuestLog:OnEvent(event, ...)
    end)

    self:SetChecked(WoWJapanizerX.db.profile.quest.questlog)
    print("WoWJapanizerX: Quest Log initialized")
end

function WoWJapanizerQuestLog:OnEnable()
    WoWJapanizerX:DebugLog("WoWJapanizerQuestLog: OnEnable.")
    print("WoWJapanizerX: Quest Log module enabled")

    -- Try multiple hook methods for Quest selection
    -- Method 1: Hook C_QuestLog events
    self.eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    self.eventFrame:RegisterEvent("QUEST_DETAIL")

    -- Method 2: Hook QuestMapFrame_ShowQuestDetails if it exists
    if QuestMapFrame_ShowQuestDetails then
        hooksecurefunc("QuestMapFrame_ShowQuestDetails", function(questID)
            print("WoWJapanizerX: QuestMapFrame_ShowQuestDetails called with questID:", questID)
            WoWJapanizerQuestLog:ShowQuestDetails(questID)
        end)
    end

    -- Method 3: Hook QuestMapFrame directly (only if method exists)
    if QuestMapFrame and type(QuestMapFrame.ShowQuestDetails) == "function" then
        hooksecurefunc(QuestMapFrame, "ShowQuestDetails", function(self, questID)
            print("WoWJapanizerX: QuestMapFrame:ShowQuestDetails called with questID:", questID)
            WoWJapanizerQuestLog:ShowQuestDetails(questID)
        end)
    end

    -- Method 4: Hook C_QuestLog.SetSelectedQuest
    hooksecurefunc(C_QuestLog, "SetSelectedQuest", function(questID)
        print("WoWJapanizerX: C_QuestLog.SetSelectedQuest called with questID:", questID)
        -- Delay slightly to ensure Blizzard UI has updated
        C_Timer.After(0.1, function()
            WoWJapanizerQuestLog:ShowQuestDetails(questID)
        end)
    end)

    -- Hook DetailsFrame show/hide events to detect when quest details are displayed
    C_Timer.After(1, function()
        local df = self:GetDetailsFrame()
        if df then
            print("WoWJapanizerX: Setting up DetailsFrame hooks")

            df:HookScript("OnShow", function()
                print("WoWJapanizerX: DetailsFrame shown!")
                WoWJapanizerQuestLog:OnDetailsFrameShow()
            end)

            df:HookScript("OnHide", function()
                print("WoWJapanizerX: DetailsFrame hidden!")
                WoWJapanizerQuestLog:HideJapaneseFrame()
            end)

            -- Initialize UI elements if DetailsFrame already exists
            WoWJapanizerQuestLog:OnDetailsFrameShow()
        else
            print("WoWJapanizerX: WARNING - Could not hook DetailsFrame events")
        end
    end)
end

function WoWJapanizerQuestLog:OnDisable()
    WoWJapanizerX:DebugLog("WoWJapanizerQuestLog: OnDisable.")
end

function WoWJapanizerQuestLog:OnEvent(event, ...)
    if event == "QUEST_LOG_UPDATE" then
        -- Quest log was updated, only process if DetailsFrame is visible
        local df = self:GetDetailsFrame()
        if df and df:IsShown() then
            local questID = C_QuestLog.GetSelectedQuest()
            if questID and questID > 0 then
                print("WoWJapanizerX: QUEST_LOG_UPDATE - Selected quest:", questID)
                self:ShowQuestDetails(questID)
            end
        end
    elseif event == "QUEST_DETAIL" then
        print("WoWJapanizerX: QUEST_DETAIL event fired")
    end
end

function WoWJapanizerQuestLog:OnDetailsFrameShow()
    print("WoWJapanizerX: OnDetailsFrameShow called")

    -- Create toggle button if it doesn't exist yet
    if not self.toggleButton then
        self:CreateToggleButton()
    end

    -- Create Japanese frame if it doesn't exist yet
    if not self.japaneseFrame then
        self:CreateJapaneseFrame()
    end

    -- Try initial layout when DetailsFrame is shown
    self:LayoutJapaneseFrame()

    -- Get the currently selected quest
    local questID = C_QuestLog.GetSelectedQuest()
    if questID and questID > 0 then
        print("WoWJapanizerX: Quest detail shown for questID:", questID)
        self:ShowQuestDetails(questID)
    else
        print("WoWJapanizerX: No quest selected")
    end
end

function WoWJapanizerQuestLog:CreateToggleButton()
    if self.toggleButton then
        print("WoWJapanizerX: Toggle button already exists")
        return
    end

    print("WoWJapanizerX: Creating toggle button...")

    local df = self:GetDetailsFrame()
    if not df then
        print("WoWJapanizerX: ERROR - Cannot create button, DetailsFrame not found")
        return
    end

    local parent = df
    local anchorPoint = "TOPLEFT"
    local anchorX, anchorY = 10, -10

    -- Try to find BackFrame and use it as parent
    if df.BackFrame then
        print("WoWJapanizerX: BackFrame found, using it as parent")
        parent = df.BackFrame

        -- Debug: List all children of BackFrame
        local children = {parent:GetChildren()}
        print(string.format("WoWJapanizerX: Found %d children in BackFrame", #children))
        for i, child in ipairs(children) do
            local name = child:GetName() or "unnamed"
            local objType = child:GetObjectType()
            print(string.format("  Child %d: %s (%s)", i, name, objType))
        end

        -- Try to anchor to the first child
        if children[1] then
            print(string.format("WoWJapanizerX: Anchoring to first child: %s", children[1]:GetName() or "unnamed"))
            local toggleBtn = CreateFrame("Button", "WoWJapanizerToggleButton", parent, "UIPanelButtonTemplate")
            toggleBtn:SetSize(110, 22)
            toggleBtn:SetPoint("LEFT", children[1], "RIGHT", 5, 0)
            toggleBtn:SetText(self.showJapanese and "Japanese ON" or "Japanese OFF")
            toggleBtn:SetScript("OnClick", function()
                WoWJapanizerQuestLog:ToggleJapanese()
            end)
            self.toggleButton = toggleBtn
            print("WoWJapanizerX: Toggle button created in BackFrame!")
            print("WoWJapanizerX: Button details - IsShown:", toggleBtn:IsShown(), "Enabled:", toggleBtn:IsEnabled())
            toggleBtn:Show()  -- Explicitly show the button
            return
        end
    else
        print("WoWJapanizerX: BackFrame not found, using DetailsFrame as parent")

        -- Debug: List all children of DetailsFrame
        local children = {df:GetChildren()}
        print(string.format("WoWJapanizerX: Found %d children in DetailsFrame", #children))
        for i, child in ipairs(children) do
            local name = child:GetName() or "unnamed"
            local objType = child:GetObjectType()
            print(string.format("  Child %d: %s (%s)", i, name, objType))
        end
    end

    -- Create button in parent frame
    local toggleBtn = CreateFrame("Button", "WoWJapanizerToggleButton", parent, "UIPanelButtonTemplate")
    toggleBtn:SetSize(110, 22)
    toggleBtn:SetPoint(anchorPoint, parent, anchorPoint, anchorX, anchorY)
    toggleBtn:SetText(self.showJapanese and "Japanese ON" or "Japanese OFF")
    toggleBtn:SetScript("OnClick", function()
        WoWJapanizerQuestLog:ToggleJapanese()
    end)

    self.toggleButton = toggleBtn
    print("WoWJapanizerX: Toggle button created at default position!")
    print("WoWJapanizerX: Button details - IsShown:", toggleBtn:IsShown(), "Enabled:", toggleBtn:IsEnabled())
    print("WoWJapanizerX: Button size:", toggleBtn:GetWidth(), "x", toggleBtn:GetHeight())
    toggleBtn:Show()  -- Explicitly show the button
end

function WoWJapanizerQuestLog:CreateJapaneseFrame()
    if self.japaneseFrame then
        print("WoWJapanizerX: Japanese frame already exists")
        return
    end

    print("WoWJapanizerX: Attempting to create Japanese frame...")

    local df = self:GetDetailsFrame()
    if not df then
        print("WoWJapanizerX: ERROR - Cannot create Japanese frame, DetailsFrame not found")
        return
    end

    print("WoWJapanizerX: DetailsFrame found, creating frame...")

    -- Create frame for Japanese translation
    local frame = CreateFrame("Frame", "WoWJapanizerQuestDetailsFrame", df)

    -- Try to position to the right of ScrollFrame if it exists
    if df.ScrollFrame then
        print("WoWJapanizerX: Anchoring to ScrollFrame")
        frame:SetPoint("BOTTOMLEFT", df.ScrollFrame, "BOTTOMRIGHT", 10, 0)
        frame:SetPoint("TOPRIGHT", df, "TOPRIGHT", -10, -60)
    else
        print("WoWJapanizerX: ScrollFrame not found, using default anchors")
        frame:SetPoint("TOPLEFT", df, "TOPLEFT", 10, -60)
        frame:SetPoint("BOTTOMRIGHT", df, "BOTTOMRIGHT", -10, 10)
    end

    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(false) -- do not block clicks on Blizzard UI by default
    frame:Hide()

    print("WoWJapanizerX: Base frame created")

    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.7)

    -- Scroll frame for Japanese text
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    -- Text content
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 1)
    scrollFrame:SetScrollChild(content)

    local text = content:CreateFontString(nil, "OVERLAY")
    local fontSet = text:SetFont(WoWJapanizerX.FONT, 12 + WoWJapanizerX:FontSize())
    if not fontSet then
        print("WoWJapanizerX: WARNING - Failed to set Japanese font, using default font")
        text:SetFont("Fonts\\FRIZQT__.TTF", 12 + WoWJapanizerX:FontSize())
    else
        print("WoWJapanizerX: Japanese font set successfully:", WoWJapanizerX.FONT)
    end

    text:SetPoint("TOPLEFT")
    text:SetPoint("TOPRIGHT")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetTextColor(1, 1, 1)
    text:SetSpacing(3)
    text:SetWordWrap(true)
    text:SetNonSpaceWrap(true)  -- Allow wrapping on Japanese characters

    frame.scrollFrame = scrollFrame
    frame.content = content
    frame.text = text

    self.japaneseFrame = frame
    print("WoWJapanizerX: Japanese frame created successfully!")
end

-- Helper: compute if two frames overlap on screen
function WoWJapanizerQuestLog:FramesOverlap(a, b)
    if not a or not b or not a.GetLeft or not b.GetLeft then return false end
    local aL, aB, aW, aH = a:GetRect()
    local bL, bB, bW, bH = b:GetRect()
    if not aL or not bL then return false end
    local aR, aT = aL + aW, aB + aH
    local bR, bT = bL + bW, bB + bH
    return not (aR <= bL or bR <= aL or aT <= bB or bT <= aB)
end

-- Helper: set default anchors relative to DetailsFrame
function WoWJapanizerQuestLog:SetDefaultJapaneseAnchors()
    if not self.japaneseFrame then return end

    local df = self:GetDetailsFrame()
    if not df then return end

    local jf = self.japaneseFrame
    jf:ClearAllPoints()
    jf:SetParent(df)

    if df.ScrollFrame then
        jf:SetPoint("BOTTOMLEFT", df.ScrollFrame, "BOTTOMRIGHT", 10, 0)
        jf:SetPoint("TOPRIGHT", df, "TOPRIGHT", -10, -60)
    else
        jf:SetPoint("TOPLEFT", df, "TOPLEFT", 10, -60)
        jf:SetPoint("BOTTOMRIGHT", df, "BOTTOMRIGHT", -10, 10)
    end

    jf:SetFrameStrata("HIGH")
    jf:SetFrameLevel(df:GetFrameLevel() + 20)
end

-- Layout logic: if a DetailsFrame child window overlaps our area, place the Japanese frame to its right
-- otherwise keep default; if no space on the right, float above in front.
function WoWJapanizerQuestLog:LayoutJapaneseFrame()
    local jf = self.japaneseFrame
    if not jf then return end

    local df = self:GetDetailsFrame()
    if not df then return end

    -- Start with default anchors inside DetailsFrame
    self:SetDefaultJapaneseAnchors()

    -- Identify potential blocking child in DetailsFrame
    local children = { df:GetChildren() }
    local blocking = nil
    for _, child in ipairs(children) do
        if child ~= jf and child:IsShown() and child.GetRect then
            -- ignore tiny elements like buttons/scrollbars
            local l, b, w, h = child:GetRect()
            if l and w and h and w > 80 and h > 80 then
                if self:FramesOverlap(jf, child) then
                    blocking = child
                    break
                end
            end
        end
    end

    if blocking then
        -- Try to place to the right of the blocking frame in screen space
        local bL, bB, bW, bH = blocking:GetRect()
        if bL and bW then
            local screenW, screenH = UIParent:GetSize()
            local desiredLeft = bL + bW + 10
            -- If there is room to the right, place there using UIParent as parent
            if desiredLeft + 300 < screenW - 10 then
                jf:ClearAllPoints()
                jf:SetParent(UIParent)
                jf:SetFrameStrata("DIALOG")
                jf:SetFrameLevel(UIParent:GetFrameLevel() + 200)
                -- Keep height similar to default; width up to 360 or remaining space
                local width = math.min(360, screenW - desiredLeft - 10)
                local top = math.min(bB + bH, screenH - 60)
                jf:SetSize(width, df:GetHeight() - 60)
                jf:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", desiredLeft, top)
            else
                -- No space: keep inside DetailsFrame but bring to front
                jf:ClearAllPoints()
                jf:SetParent(df)
                jf:SetFrameStrata("DIALOG")
                jf:SetFrameLevel(df:GetFrameLevel() + 200)
                jf:SetPoint("BOTTOMLEFT", df.ScrollFrame, "BOTTOMRIGHT", 10, 0)
                jf:SetPoint("TOPRIGHT", df, "TOPRIGHT", -10, -60)
            end
        end
    end

    -- Ensure text width recalculates after potential parent/size change
    C_Timer.After(0, function()
        if self.japaneseFrame and self.japaneseFrame.text and self.japaneseFrame.content and self.japaneseFrame.scrollFrame then
            -- Update content and text width to match scrollFrame
            local scrollWidth = self.japaneseFrame.scrollFrame:GetWidth()
            local textWidth = math.max(scrollWidth - 40, 100)  -- Account for padding and scrollbar, minimum 100
            self.japaneseFrame.content:SetWidth(textWidth)
            self.japaneseFrame.text:SetWidth(textWidth)

            -- Then recalculate height
            local textHeight = self.japaneseFrame.text:GetStringHeight()
            self.japaneseFrame.content:SetHeight(math.max(textHeight + 20, self.japaneseFrame.scrollFrame:GetHeight()))
            print(string.format("WoWJapanizerX: Layout updated - Text width: %d, height: %d", textWidth, textHeight))
        end
    end)
end

function WoWJapanizerQuestLog:ShowQuestDetails(questID)
    print("WoWJapanizerX: ShowQuestDetails called with questID:", questID)

    -- Only process if DetailsFrame is actually shown
    local df = self:GetDetailsFrame()
    if not df or not df:IsShown() then
        print("WoWJapanizerX: DetailsFrame is not visible, skipping")
        return
    end

    -- Ensure toggle button exists
    if not self.toggleButton then
        print("WoWJapanizerX: Creating toggle button on demand")
        self:CreateToggleButton()
    end

    if not self.showJapanese or not WoWJapanizerX:isShowQuest() then
        print("WoWJapanizerX: Japanese display disabled")
        self:HideJapaneseFrame()
        return
    end

    if not questID then
        print("WoWJapanizerX: No questID provided")
        return
    end

    print("WoWJapanizerX: Looking up Japanese translation for quest", questID)

    -- Check if WoWJapanizer_Quest module is loaded
    if not WoWJapanizer_Quest then
        print("WoWJapanizerX: ERROR - WoWJapanizer_Quest module not loaded!")
        if not self.japaneseFrame then
            self:CreateJapaneseFrame()
        end
        if self.japaneseFrame then
            local msg = "エラー: WoWJapanizer_Quest データモジュールがロードされていません。\nアドオンを再インストールしてください。"
            self.japaneseFrame.text:SetText(msg)
            self:LayoutJapaneseFrame()
            local textHeight = self.japaneseFrame.text:GetStringHeight()
            self.japaneseFrame.content:SetHeight(math.max(textHeight + 20, self.japaneseFrame.scrollFrame:GetHeight()))
            self.japaneseFrame:Show()
            print("WoWJapanizerX: Frame should be visible now - IsShown:", self.japaneseFrame:IsShown())
        end
        return
    end

    local quest = WoWJapanizer_Quest:Get(questID)
    if not quest then
        print("WoWJapanizerX: No Japanese translation found for quest", questID)
        -- Fallback: show a short message instead of hiding the frame entirely
        if not self.japaneseFrame then
            self:CreateJapaneseFrame()
        end
        if self.japaneseFrame then
            local msg = string.format("このクエスト (ID: %d) の日本語データが見つかりません。", questID)
            self.japaneseFrame.text:SetText(msg)
            self:LayoutJapaneseFrame()
            local textHeight = self.japaneseFrame.text:GetStringHeight()
            self.japaneseFrame.content:SetHeight(math.max(textHeight + 20, self.japaneseFrame.scrollFrame:GetHeight()))
            self.japaneseFrame:Show()
            print("WoWJapanizerX: Frame should be visible now - IsShown:", self.japaneseFrame:IsShown())
        end
        return
    end

    print("WoWJapanizerX: Japanese translation found!")

    -- Build Japanese text
    local player_name = UnitName("player")
    local player_class = UnitClass("player")
    local player_race = UnitRace("player")

    local japaneseText = ""

    -- Title
    if quest.title and quest.title ~= "" then
        japaneseText = japaneseText .. "|cFFFFD700" .. quest.title .. "|r\n\n"
        print("WoWJapanizerX: Title:", quest.title)
    end

    -- Objective
    if quest.objective and quest.objective ~= "" then
        local obj = string.gsub(quest.objective, "<name>", player_name)
        obj = string.gsub(obj, "<class>", player_class)
        obj = string.gsub(obj, "<race>", player_race)
        japaneseText = japaneseText .. "|cFFFFFFFF目的:|r\n" .. obj .. "\n\n"
        print("WoWJapanizerX: Objective:", obj)
    end

    -- Description
    if quest.description and quest.description ~= "" then
        local desc = string.gsub(quest.description, "<name>", player_name)
        desc = string.gsub(desc, "<class>", player_class)
        desc = string.gsub(desc, "<race>", player_race)
        japaneseText = japaneseText .. "|cFFFFFFFF説明:|r\n" .. desc .. "\n\n"
        print("WoWJapanizerX: Description:", desc)
    end

    -- Progress
    if quest.progress and quest.progress ~= "" then
        local prog = string.gsub(quest.progress, "<name>", player_name)
        prog = string.gsub(prog, "<class>", player_class)
        prog = string.gsub(prog, "<race>", player_race)
        japaneseText = japaneseText .. "|cFFFFFFFF進行:|r\n" .. prog .. "\n\n"
        print("WoWJapanizerX: Progress:", prog)
    end

    -- Completion
    if quest.completion and quest.completion ~= "" then
        local comp = string.gsub(quest.completion, "<name>", player_name)
        comp = string.gsub(comp, "<class>", player_class)
        comp = string.gsub(comp, "<race>", player_race)
        japaneseText = japaneseText .. "|cFFFFFFFF完了:|r\n" .. comp .. "\n"
        print("WoWJapanizerX: Completion:", comp)
    end

    print("WoWJapanizerX: Full Japanese text length:", string.len(japaneseText))

    if japaneseText ~= "" then
        -- For now, just print to chat - no UI frame
        print("WoWJapanizerX: ========== Quest Translation ==========")
        print(japaneseText)
        print("WoWJapanizerX: =======================================")

        -- Create frame if it doesn't exist yet
        if not self.japaneseFrame then
            print("WoWJapanizerX: Creating Japanese frame...")
            self:CreateJapaneseFrame()
        end

        if self.japaneseFrame then
            print("WoWJapanizerX: Displaying Japanese frame")

            -- Set the text
            self.japaneseFrame.text:SetText(japaneseText)
            print("WoWJapanizerX: Text set, length:", string.len(japaneseText))

            -- Re-layout around any blocking UI each time we show
            self:LayoutJapaneseFrame()

            -- Ensure text width is set correctly after layout
            C_Timer.After(0.1, function()
                if self.japaneseFrame and self.japaneseFrame.text then
                    local scrollWidth = self.japaneseFrame.scrollFrame:GetWidth()
                    local textWidth = scrollWidth - 40  -- Account for padding and scrollbar
                    self.japaneseFrame.content:SetWidth(textWidth)

                    -- Force text to update its dimensions
                    self.japaneseFrame.text:SetWidth(textWidth)

                    -- Now get the actual height needed
                    local textHeight = self.japaneseFrame.text:GetStringHeight()
                    print(string.format("WoWJapanizerX: Text dimensions - Width: %d, Height: %d", textWidth, textHeight))

                    self.japaneseFrame.content:SetHeight(math.max(textHeight + 40, self.japaneseFrame.scrollFrame:GetHeight()))
                end
            end)

            -- Initial height calculation
            local textHeight = self.japaneseFrame.text:GetStringHeight()
            self.japaneseFrame.content:SetHeight(math.max(textHeight + 20, self.japaneseFrame.scrollFrame:GetHeight()))

            self.japaneseFrame:Show()
            print("WoWJapanizerX: Japanese frame is now shown - IsShown:", self.japaneseFrame:IsShown())
            print("WoWJapanizerX: Frame details - Width:", self.japaneseFrame:GetWidth(), "Height:", self.japaneseFrame:GetHeight())
            print("WoWJapanizerX: Frame parent:", self.japaneseFrame:GetParent():GetName() or "unknown")
            print("WoWJapanizerX: Frame level:", self.japaneseFrame:GetFrameLevel(), "Strata:", self.japaneseFrame:GetFrameStrata())

            -- While visible, re-check layout a few times in case Blizzard UI animates in
            if self._relayoutTicker then self._relayoutTicker:Cancel() end
            self._relayoutTicker = C_Timer.NewTicker(0.5, function()
                if not self.japaneseFrame or not self.japaneseFrame:IsShown() then
                    if self._relayoutTicker then self._relayoutTicker:Cancel() end
                    self._relayoutTicker = nil
                    return
                end
                self:LayoutJapaneseFrame()
            end, 6) -- run a few times then stop
        else
            print("WoWJapanizerX: ERROR - Could not create Japanese frame")
        end
    else
        print("WoWJapanizerX: No Japanese text to display")
        self:HideJapaneseFrame()
    end
end

function WoWJapanizerQuestLog:HideJapaneseFrame()
    if self.japaneseFrame then
        self.japaneseFrame:Hide()
    end
    if self._relayoutTicker then
        self._relayoutTicker:Cancel()
        self._relayoutTicker = nil
    end
end

function WoWJapanizerQuestLog:ToggleJapanese()
    self.showJapanese = not self.showJapanese
    print("WoWJapanizerX: Toggle Japanese -", self.showJapanese and "ON" or "OFF")

    -- Update button text
    if self.toggleButton then
        if self.showJapanese then
            self.toggleButton:SetText("Japanese ON")
        else
            self.toggleButton:SetText("Japanese OFF")
        end
    end

    if self.showJapanese then
        -- Refresh current quest
        local questID = C_QuestLog.GetSelectedQuest()
        if questID and questID > 0 then
            print("WoWJapanizerX: Refreshing quest", questID)
            self:ShowQuestDetails(questID)
        else
            print("WoWJapanizerX: No quest selected")
        end
    else
        self:HideJapaneseFrame()
    end
end

function WoWJapanizerQuestLog:SetChecked(check)
    self.showJapanese = check
    if self.toggleButton then
        self.toggleButton:SetText(self.showJapanese and "Japanese ON" or "Japanese OFF")
    end
end
