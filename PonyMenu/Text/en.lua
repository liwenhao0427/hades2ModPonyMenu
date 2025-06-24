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
	ConsumableSelectorDescription = "Give yourself any consumable item.",

	ExtraSelectorTitle = "Extra Modification",
	ExtraSelectorDescription = "Some additional cheat options. Includes Infinite Roll, guaranteed Chaos Room, always available Heroic Rare Blessings, etc.",


	BoonSelectorExtraConfirmButton = "Enable Modification",
	BoonSelectorExtraCancelButton = "Cancel Modification",

	ChaosGate = "Chaos Gate",
	InfiniteRoll = "Infinite Roll",
	Heroic = "Guaranteed Heroic Blessing",
	NoRewardRoom = "No Reward Rooms",

	Extrarush = "Sprint Count +1",
	MoreMoney = "Gold +100",
	RestoreHealth = "Restore Health",
	RestoreMana = "Restore Mana",

	DropLoot = "Blessing Drop on Kill",
	StopDropLoot = "Disable Blessing Drop on Kill",
	EphyraZoomOut = "Room Reward Preview",

	DiyTraitDataTitle = "Custom Blessing",
	DiyTraitDataDescription = "Use custom blessings created by the author, or previously removed official blessings (these blessings may have no effect at all)",

	BossHealthLoot = "Show Boss Health",
	QuitAnywhere = "Quit Anytime",
	PermanentLocationCount = "Always Show Room Count",

	RepeatableChaosTrials = "Chaos Blessings Repeatable",
	FreeToBuy = "Free to Buy",

	GetRavenFamiliar = "Unlock Raven Familiar",
	GetFrogFamiliar = "Unlock Frog Familiar",
	GetCatFamiliar = "Unlock Cat Familiar",
	GetHoundFamiliar = "Unlock Hound Familiar",
	GetPolecatFamiliar = "Unlock Polecat Familiar",
})
