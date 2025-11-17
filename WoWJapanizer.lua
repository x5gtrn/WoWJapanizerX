WoWJapanizer = LibStub("AceAddon-3.0"):NewAddon("WoWJapanizer", "AceConsole-3.0")

WoWJapanizer.FONT = "Interface\\AddOns\\WoWJapanizer\\font\\ipagui.ttf";
WoWJapanizer.DEBUG = false

WoWJapanizer.property = {}

function WoWJapanizer:OnInitialize()
    self.debug = WoWJapanizer.DEBUG
    self.version = C_AddOns.GetAddOnMetadata("WoWJapanizer", "Version")
    print(string.format("Welcome to WoWJapanizer Ver: %s.\nSetting is /cj or /WoWJapanizer.", self.version))

    self.db = LibStub('AceDB-3.0'):New("WoWJapanizerDB")
	self.db:RegisterDefaults({
        profile = {
            quest       = { questlog = true, gossip = true, questlog_movable = false, furigana = false },
            item        = { tooltip = true },
            spell       = { tooltip = true },
            achievement = { tooltip = true, advice = true },
            developer   = self.DEBUG,
            development = { debugger = self.DEBUG },
			config      = {fontsize = 0, tooltip = true},
        }
    })

    -- Quest --
    WoWJapanizerQuestLog:OnInitialize()
    WoWJapanizerQuestGossip:OnInitialize()

    -- ToolTip --
    WoWJapanizerGameToolTip:OnInitialize()
    WoWJapanizerItemRefTooltip:OnInitialize()

    WoWJapanizerGarrisonToolTip:OnInitialize()

end

function WoWJapanizer:OnEnable()
    self:DebugLog("WoWJapanizer: OnEnable.");

    -- Option --
    self:SetupOptions()

    -- Quest --
    WoWJapanizerQuestLog:OnEnable()
    WoWJapanizerQuestGossip:OnEnable()

    -- ToolTip --
    WoWJapanizerGameToolTip:OnEnable()
    WoWJapanizerItemRefTooltip:OnEnable()

	WoWJapanizerGarrisonToolTip:OnEnable()

end

function WoWJapanizer:OnDisable()
    self:DebugLog("WoWJapanizer: OnDisable.");

    -- Quest --
    WoWJapanizerQuestLog:OnDisable()
    WoWJapanizerQuestGossip:OnDisable()

    -- ToolTip --
    WoWJapanizerGameToolTip:OnDisable()
    WoWJapanizerItemRefTooltip:OnDisable()

	WoWJapanizerGarrisonToolTip:OnDisable()

end

function WoWJapanizer:LoadAddOn(addon)
    return true
end

function WoWJapanizer:FontSize()
	return self.db.profile.config.fontsize
end

function WoWJapanizer:isShowQuest()
	return self.db.profile.quest.questlog
end

function WoWJapanizer:isShowTooltip()
	return self.db.profile.config.tooltip
end

function WoWJapanizer:uc(str)
    return string.gsub(str, "(%w)", function(s)
        return string.upper(s)
    end, 1)
end

function WoWJapanizer:lc(str)
    return string.gsub(str, "(%w)", function(s)
        return string.lower(s)
    end, 1)
end

function WoWJapanizer:SetupOptions()
    function GetOptions()
        return {
            type = "group",
            name = "WoWJapanizer",
			order = 1,
            args = {         
				Header1 = {
					type = "header",
					name = "Plugin Options - Please /reload to apply change.",
					order = 2,
				},
				ShowQuestLog = {
					type = "toggle",
					name = "Show Quest Log",
					order = 10,
					set = function(info, value)
						self.db.profile.quest.questlog = value;
					end,
					get = function(info)
						return self.db.profile.quest.questlog;
					end,					
				},
				Spacer2 = {
					type = "description",
					name = "Show Japanese Quest Log",
					fontSize = "medium",
					order = 15,
				},
				ShowToolTip = {
					type = "toggle",
					name = "Show Tool Tip",
					order = 20,
					set = function(info, value)
						self.db.profile.config.tooltip = value;
						self.db.profile.item.tooltip = value;
						self.db.profile.spell.tooltip = value;
						self.db.profile.achievement.tooltip = value;
					end,
					get = function(info)
						return self.db.profile.config.tooltip;
					end,					
				},
				Spacer3 = {
					type = "description",
					name = "Show Japanese Tool Tip for Item/Spell/Achievement",
					fontSize = "medium",
					order = 25,
				},
				FuriganaMode = {
					type = "toggle",
					name = "Furigana Mode",
					order = 30,
					set = function(info, value)
						self.db.profile.quest.furigana = value;
					end,
					get = function(info)
						return self.db.profile.quest.furigana;
					end,					
				},
				Spacer4 = {
					type = "description",
					name = "Furigana will be added on Quest detail screen.",
					fontSize = "medium",
					order = 35,
				},
				FontSizeSlider = {
					type = "range",
					name = "Font Size",
					min = 0,
					max = 10,
					step = 1,
					order = 40,
					set = function(info, value)
						self.db.profile.config.fontsize = value;
					end,
					get = function(info)
						return self.db.profile.config.fontsize;
					end,					
				},
				Spacer_FontSize = {
					type = "description",
					name = "Make Font Size Bigger in Quest Log and Tool Tip. (0=Default Size)\nPlease /reload to apply change.",
					fontSize = "medium",
					order = 45,
				},
            },
        }
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("WoWJapanizer", GetOptions())	
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WoWJapanizer");

    self:RegisterChatCommand("cj", "ChatCommand")
    self:RegisterChatCommand("WoWJapanizer", "ChatCommand")
end

function WoWJapanizer:ChatCommand(input)
    if input == 'debug' then
        -- Debug Window --
        if self.db.profile.development.debugger then
            WoWJapanizerDebugFrame:Show()
        end
    else
        self:OpenConfigDialog()
    end
end

function WoWJapanizer:OpenConfigDialog()
    LibStub("AceConfigDialog-3.0"):Open("WoWJapanizer")
end

function WoWJapanizer:DebugLog(args)
    if not self.DEBUG then
        return
    end

    if type(args) == 'string' then
        self:Print(args)
        return
    end

    if type(args) == 'number' then
        self:Print(tostring(args))
        return
    end

    if type(args) == 'table' then
        self:Print("----------")
        for n, v in pairs(args) do
            self:Print(n .. ' : ' .. v)
        end
        self:Print("----------")
        return
    end
end
