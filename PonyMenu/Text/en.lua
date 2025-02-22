local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("en", {
	PonyMenuCategoryTitle = "Pony Menu",

	ClearAllBoons = "Clear all boons",
	ClearAllBoonsDescription = "Removes all equipped boons.",

	BoonSelectorTitle = "Boon Selector",
	BoonSelectorSpawnButton = "Spawn regular boon",
	BoonSelectorCommonButton = "Common",
	BoonSelectorRareButton = "Rare",
	BoonSelectorEpicButton = "Epic",
	BoonSelectorHeroicButton = "Heroic",

	BoonManagerTitle = "Boon Manager",
	BoonManagerSubtitle = "Click Level Mode or Rarity Mode again to switch Add(+) and Substract(-) submodes",
	BoonManagerDescription = "Opens the boon manager. Let's you manage your boons. You can delete and upgrade any boon you have.",
	BoonManagerModeSelection = "Choose Mode",
	BoonManagerLevelMode = "Level Mode",
	BoonManagerRarityMode = "Rarity Mode",
	BoonManagerDeleteMode = "Delete Mode",
	BoonManagerAllModeOff = "All Mode : OFF",
	BoonManagerAllModeOn = "All Mode : ON",
	BoonManagerLevelDisplay = "Lv. ",

	ResourceMenuTitle = "Resource Menu",
	ResourceMenuDescription = "Spawn any resource in any amount.",
	ResourceMenuSpawnButton = "Spawn Resource",
	ResourceMenuEmpty = "None"
})
