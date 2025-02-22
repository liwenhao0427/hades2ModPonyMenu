local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("zh-TW", {
	PonyMenuCategoryTitle = "小馬選單",

	ClearAllBoons = "去除一切祝福",
	ClearAllBoonsDescription = "去除每個祝福。",

	BoonSelectorTitle = "祝福選擇器",
	BoonSelectorSpawnButton = "召見祝福",
	BoonSelectorCommonButton = "Common",
	BoonSelectorRareButton = "Rare",
	BoonSelectorEpicButton = "Epic",
	BoonSelectorHeroicButton = "Heroic",

	BoonManagerTitle = "祝福經理",
	BoonManagerSubtitle = "為了換加法(+)和劍法(-)，再點選級運作方式或稀有度運作方式。",
	BoonManagerDescription = "打開祝福經理。 讓您經理您的祝福。 您將去除和升級您的祝福。",
	BoonManagerModeSelection = "請選運作方式",
	BoonManagerLevelMode = "級運作方式",
	BoonManagerRarityMode = "稀有度運作方式",
	BoonManagerDeleteMode = "去除運作方式",
	BoonManagerAllModeOff = "全運作方式 : 關",
	BoonManagerAllModeOn = "全運作方式 ： 開",
	BoonManagerLevelDisplay = "級. ",

	ResourceMenuTitle = "資源選單",
	ResourceMenuDescription = "創造任何數量的資源。",
	ResourceMenuSpawnButton = "創造資源",
	ResourceMenuEmpty = "空"
})
