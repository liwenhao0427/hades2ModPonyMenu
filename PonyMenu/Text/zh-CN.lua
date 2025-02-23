local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("zh-CN", {
	PonyMenuCategoryTitle = "小马选单",

	ClearAllBoons = "去除一切祝福",
	ClearAllBoonsDescription = "去除每个祝福。",

	BoonSelectorTitle = "祝福选择器",
	BoonSelectorSpawnButton = "召见祝福",
	BoonSelectorCommonButton = "Common",
	BoonSelectorRareButton = "Rare",
	BoonSelectorEpicButton = "Epic",
	BoonSelectorHeroicButton = "Heroic",

	BoonManagerTitle = "祝福经理",
	BoonManagerSubtitle = "为了换加法(+)和剑法(-)，再点击级运作方式或稀有度运作方式。",
	BoonManagerDescription = "打开祝福经理。让您经理您的祝福。您会去除和升级您的祝福。",
	BoonManagerModeSelection = "请选运作方式",
	BoonManagerLevelMode = "级运作方式",
	BoonManagerRarityMode = "稀有度运作方式",
	BoonManagerDeleteMode = "去除运作方式",
	BoonManagerAllModeOff = "全运作方式 : 关",
	BoonManagerAllModeOn = "全运作方式 ： 开",
	BoonManagerLevelDisplay = "级. ",

	ResourceMenuTitle = "资源选单",
	ResourceMenuDescription = "创造任何数量的资源。",
	ResourceMenuSpawnButton = "创造资源",
	ResourceMenuEmpty = "空",

	BossSelectorTitle = "区域守卫选择器",
	BossSelectorDescription = "让您直接去打一位区域守卫，用您的存档装备。",
	BossSelectorNoSavedState = "没有存档装备! 请去造一个!",

	KillPlayerTitle = "杀玩家",
	KillPlayerDescription = "杀您而遣送您到三岔路口。",

	SaveStateTitle = "存入装备",
	SaveStateDescription = "存入您现在的装备，为了一后加载。必要为了用区域守卫选择器。存入您全部装备。",
	SaveStateSaved = "装备存入了!",

	LoadStateTitle = "加载装备",
	LoadStateDescription = "加载您的存档装备。必要先存入一个装备。",
	SaveStateLoaded = "装备加载了!",

	ConsumableSelectorTitle = "耗材选择器",
	ConsumableSelectorDescription = "自己给您如何耗材。"
})
