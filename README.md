# WoWJapanizerX

A World of Warcraft addon that translates game content (Quests, Items, Spells, Achievements) into Japanese.

## Overview

WoWJapanizerX is a modernized version of the original WoWJapanizer addon, updated to support World of Warcraft 11.x (The War Within expansion) and later versions. This addon provides Japanese translations for:

- **Quest Log**: Quest titles, descriptions, objectives, progress, and completion text
- ~~**Item Tooltips**: Item names and descriptions~~ _WIP_
- ~~**Spell Tooltips**: Spell names and descriptions~~ _WIP_
- ~~**Achievement Tooltips**: Achievement names and descriptions~~ _WIP_

## Features

- 🗺️ **Integrated Quest UI**: Works with WoW 11.x's integrated Map & Quest Log window
- 🎚️ **Toggle Display**: Easy on/off toggle button for Japanese translations
- 📜 **Scrollable Interface**: Clean, scrollable display for long quest texts
- ⚙️ **Customizable**: Adjustable font size and display options
- 🔄 **Non-intrusive**: Can be installed alongside the original WoWJapanizer without conflicts

## Requirements

- World of Warcraft 11.0.2 or later (The War Within expansion)
- No other dependencies are required (Ace3 libraries are embedded)

## Installation

### Via CurseForge Client (Recommended)
1. Install the CurseForge client
2. Search for "WoWJapanizerX"
3. Click Install

### Manual Installation
1. Download the latest release from [Releases](https://github.com/x5gtrn/WoWJapanizerX/releases)
2. Extract the archive
3. Copy the `WoWJapanizer` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - macOS: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
4. Restart World of Warcraft

## Usage

### In-Game Commands

- `/wjp` - Open settings panel
- `/WoWJapanizerX` - Open settings panel

### Quest Translations

1. Open the Quest Log (default key: `L`)
2. Select a quest from the list
3. The Japanese translation will appear in a panel to the right of the quest details
4. Use the "Japanese ON/OFF" toggle button to show/hide translations

### Settings

Access the settings panel via:
- `/wjp` or `/WoWJapanizerX` command
- Interface Options → AddOns → WoWJapanizerX

Available options:
- **Show Quest Log**: Enable/disable quest translations
- **Show Tool Tip**: Enable/disable tooltip translations for items, spells, and achievements
- **Font Size**: Adjust the font size (0-10, where 0 is default)
- **Furigana Mode**: Add furigana readings to kanji (experimental)

## Version History

### 5.0.1
- Complete rewrite for WoW 11.x (The War Within)
- New integrated Map & Quest Log UI support
- Migrated to modern WoW APIs (C_QuestLog, C_AddOns, TooltipDataProcessor)
- Updated Ace3 libraries to Release r1377 (October 2025) for WoW 11.x/12.0 compatibility
- Added dynamic frame detection for better compatibility
- Removed deprecated systems (Glyph, Artifact, Buff tooltips, World Map Quest)
- Rebranded as WoWJapanizerX for a separate CurseForge release

### 4.19 (Legacy)
- Last version supporting WoW 7.1.0 (Legion expansion)
- Original WoWJapanizer by milai

## Development

### Project Structure

```
WoWJapanizer/
├── Data/                      # Translation data files
│   ├── Quest/                 # Quest translations
│   ├── Item/                  # Item translations
│   ├── Spell/                 # Spell translations
│   ├── Achievement/           # Achievement translations
│   └── Garrison/              # Garrison translations
├── font/                      # Japanese font files
├── libs/                      # Embedded libraries (Ace3)
├── locales/                   # Localization files
├── WoWJapanizerX.lua          # Core addon file
├── WoWJapanizerQuestLog.lua  # Quest log module
├── WoWJapanizerToolTip.lua   # Tooltip module
└── WoWJapanizerX.toc          # Addon metadata
```

### Building from Source

No build process is required. Simply clone the repository into your AddOns folder:

```bash
cd "World of Warcraft/_retail_/Interface/AddOns/"
git clone https://github.com/x5gtrn/WoWJapanizerX.git WoWJapanizerX
```

### Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:

- Bug reports
- New translations
- Feature requests
- Code improvements

## Technical Details

### API Migration (7.x → 11.x)

This addon was updated from WoW 7.1.0 to 11.x with the following major API changes:

- **Quest API**: `GetQuestLogSelection()` → `C_QuestLog.GetSelectedQuest()`
- **AddOn API**: `GetAddOnMetadata()` → `C_AddOns.GetAddOnMetadata()`
- **Tooltip API**: `OnTooltipSetItem` hooks → `TooltipDataProcessor.AddTooltipPostCall()`
- **UI Structure**: Quest UI completely redesigned in modern WoW

### Database

Settings are saved per-character in `WoWJapanizerXDB` (separate from original WoWJapanizer).

## Known Issues

- Some quest translations may be incomplete or outdated
- Furigana mode is experimental and may not work correctly for all text

## Credits

We would like to express our deepest gratitude and respect to the following individuals and communities who made this addon possible:

### Addon Authors
- **[milai](https://x.com/milai_wow)** - Maintained [WoWJapanizer](https://www.curseforge.com/wow/addons/wowjapanizer) up to v4.19, bringing Japanese translations to countless players
- **[midoridge](https://x.com/midoridge)** - Created [CraftJapanizer](https://legacy.curseforge.com/wow/addons/CraftJapanizer), the predecessor that laid the foundation for WoWJapanizer
- **[lalha](https://x.com/lalha2)** - Developed [QuestJapanizer](https://legacy.curseforge.com/wow/addons/qjp), the very first Japanese localization addon in World of Warcraft history

### Special Thanks
[See Readme.txt](./Readme.txt)
- **Translation Contributors** - Volunteers who contributed and continue to contribute Japanese translations
- **Community Testers** - Players who reported bugs, provided feedback, and helped improve the addon

### Libraries & Resources
- **Ace3** (Release r1377, October 2025) - Embedded addon framework with WoW 11.x/12.0 support
  - AceAddon-3.0, AceConfig-3.0, AceConsole-3.0, AceDB-3.0, AceGUI-3.0
  - CallbackHandler-1.0, LibStub
- **IPA Gothic UI Font** - Japanese font

## License

This project continues the work of the original WoWJapanizer addon. Please respect the original author's work.

## Links

- [CurseForge](https://www.curseforge.com/wow/addons/wowjapanizerx) (coming soon)
- [Original WoWJapanizer](https://www.curseforge.com/wow/addons/wowjapanizer) (legacy)
- [Report Issues](https://github.com/x5gtrn/WoWJapanizerX/issues)

---

**Note**: This addon requires Japanese language font support. The font is included with the addon.
