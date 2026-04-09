# Can I Gather It?
 
A lightweight World of Warcraft TBC Classic addon that enhances tooltips for herb and mining nodes. When you hover over a gathering node — in the world or on the minimap — it instantly shows whether your profession skill is high enough to gather it.

## Features
 
- **Tooltip enhancement** — Hover over any herb or mineral node and see the required skill level, your current skill, and a clear message telling you if you can gather it or not.
- **Minimap support** — Works on minimap tracking dots, not just world objects.
- **Difficulty coloring** — Required skill is color-coded to match WoW's node difficulty colors (orange, yellow, green, gray, red).
- **Full TBC coverage** — Includes all Vanilla herbs (Peacebloom through Black Lotus), all Outland herbs (Felweed through Mana Thistle), and all mining nodes (Copper Vein through Khorium Vein).
- **Zero configuration** — Install it and it just works. No setup needed.

## What It Looks Like
 
When you hover over a node you **can** gather: Coming Soon

## Installation
 
1. Download and extract the `CanIGatherIt` folder.
2. Place it in your `World of Warcraft/_classic_era_/Interface/AddOns/` directory or `World of Warcraft/_anniversary_/Interface/AddOns/` in case of Anniversary edition
3. Restart the game or type `/reload` if you're already logged in.

## Slash Commands
 
| Command | Description |
|---------|-------------|
| `/cigi` | Print your current Herbalism and Mining skill levels in chat. |
| `/canigatherit` | Same as above. |

## Compatibility
 
- **Game version:** Classic Era / Hardcore (1.15.x) and TBC Classic (2.5.x)
- **Language:** English (enUS) client. Node names are hardcoded in English — other locales would need translated node names added to the lookup table.
- **Conflicts:** None known. Works alongside GatherMate2, Questie, AtlasLoot, and other popular addons.

## Contributing
 
Found a missing node or a bug? Open an issue or submit a pull request on GitHub.
 
### Adding support for other languages
 
If you'd like to add support for your language, add translated node names to the `nodeData` table in `CanIGatherIt.lua`. The format is:
 
```lua
["Translated Node Name"] = { skill = 270, type = "herb" },
```
 
## License
 
MIT License — see [LICENSE](LICENSE) for details.
