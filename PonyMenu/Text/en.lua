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
	ResourceMenuEmpty = "None",

	BossSelectorTitle = "Boss Selector",
	BossSelectorDescription = "Let's you go straight to a boss and fight them, using your currently selected loadout.",
	BossSelectorNoSavedState = "NO SAVED STATE! GO MAKE ONE!",

	KillPlayerTitle = "Kill Player",
	KillPlayerDescription = "Kills you and sends you back to the crossroads.",

	SaveStateTitle = "Save State",
	SaveStateDescription = "Save your current state to load it later, required to use boss selector. Saves everything you have currently equipped.",
	SaveStateSaved = "State saved!",

	LoadStateTitle = "Load State",
	LoadStateDescription = "Loads your saved state. Cannot be used if you don't have a saved state.",
	SaveStateLoaded = "State loaded!",

	ConsumableSelectorTitle = "Consumable Selector",
	ConsumableSelectorDescription = "Give yourself any consumable item."

})
