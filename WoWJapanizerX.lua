WoWJapanizerX = LibStub("AceAddon-3.0"):NewAddon("WoWJapanizerX", "AceConsole-3.0")

WoWJapanizerX.FONT = "Interface\\AddOns\\WoWJapanizerX\\font\\ipagui.ttf"
WoWJapanizerX.DEBUG = true

WoWJapanizerX.property = {}

function WoWJapanizerX:OnInitialize()
    self.debug = WoWJapanizerX.DEBUG
    self.version = C_AddOns.GetAddOnMetadata("WoWJapanizerX", "Version")
    print(string.format("Welcome to WoWJapanizerX Ver: %s.\nSetting is /wjp or /WoWJapanizerX.", self.version))

    -- Initialize AceDB-3.0 database with defaults
    -- Using 'Default' as the default profile for consistency across characters
    local defaults = {
        profile = {
            quest       = { questlog = true, gossip = true, questlog_movable = false, furigana = false },
            item        = { tooltip = true },
            spell       = { tooltip = true },
            achievement = { tooltip = true, advice = true },
            developer   = self.DEBUG,
            development = { debugger = self.DEBUG },
            config      = { fontsize = 0, tooltip = true },
        }
    }

    self.db = LibStub("AceDB-3.0"):New("WoWJapanizerXDB", defaults, true)

    -- Quest --
    WoWJapanizerQuestLog:OnInitialize()
    WoWJapanizerQuestGossip:OnInitialize()

    -- ToolTip --
    WoWJapanizerGameToolTip:OnInitialize()
    WoWJapanizerItemRefTooltip:OnInitialize()

    WoWJapanizerGarrisonToolTip:OnInitialize()

end

function WoWJapanizerX:OnEnable()
    self:DebugLog("WoWJapanizerX: OnEnable.");

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

function WoWJapanizerX:OnDisable()
    self:DebugLog("WoWJapanizerX: OnDisable.");

    -- Quest --
    WoWJapanizerQuestLog:OnDisable()
    WoWJapanizerQuestGossip:OnDisable()

    -- ToolTip --
    WoWJapanizerGameToolTip:OnDisable()
    WoWJapanizerItemRefTooltip:OnDisable()

	WoWJapanizerGarrisonToolTip:OnDisable()

end

function WoWJapanizerX:LoadAddOn(addon)
    return true
end

function WoWJapanizerX:FontSize()
	return self.db.profile.config.fontsize
end

function WoWJapanizerX:isShowQuest()
	return self.db.profile.quest.questlog
end

function WoWJapanizerX:isShowTooltip()
	return self.db.profile.config.tooltip
end

function WoWJapanizerX:uc(str)
    return string.gsub(str, "(%w)", function(s)
        return string.upper(s)
    end, 1)
end

function WoWJapanizerX:lc(str)
    return string.gsub(str, "(%w)", function(s)
        return string.lower(s)
    end, 1)
end

function WoWJapanizerX:SetupOptions()
    function GetOptions()
        return {
            type = "group",
            name = "WoWJapanizerX",
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

    LibStub("AceConfig-3.0"):RegisterOptionsTable("WoWJapanizerX", GetOptions())
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WoWJapanizerX");

    self:RegisterChatCommand("wjp", "ChatCommand")
    self:RegisterChatCommand("WoWJapanizerX", "ChatCommand")
end

function WoWJapanizerX:ChatCommand(input)
    if input == 'debug' then
        -- Debug Window --
        if self.db.profile.development.debugger then
            WoWJapanizerDebugFrame:Show()
        end
    else
        self:OpenConfigDialog()
    end
end

function WoWJapanizerX:OpenConfigDialog()
    LibStub("AceConfigDialog-3.0"):Open("WoWJapanizerX")
end

function WoWJapanizerX:DebugLog(args)
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
