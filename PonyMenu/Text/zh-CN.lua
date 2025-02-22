local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("zh-CN", {
	PonyMenuCategoryTitle = "作弊菜单",

	ClearAllBoons = "删除一切祝福",
	ClearAllBoonsDescription = "删除所有祝福。",

	BoonSelectorTitle = "祝福选择器",
	BoonSelectorSpawnButton = "生成祝福",
	BoonSelectorCommonButton = "Common",
	BoonSelectorRareButton = "Rare",
	BoonSelectorEpicButton = "Epic",
	BoonSelectorHeroicButton = "Heroic",

	BoonManagerTitle = "祝福管理",
	BoonManagerSubtitle = "先点击您要选择的项目切换+/-，然后点击您要管理的祝福。",
	BoonManagerDescription = "打开祝福管理，去除和升级您的祝福。",
	BoonManagerModeSelection = "请选择",
	BoonManagerLevelMode = "等级",
	BoonManagerRarityMode = "稀有度",
	BoonManagerDeleteMode = "取消选择&删除",
	BoonManagerAllModeOff = "全选 : 关",
	BoonManagerAllModeOn = "全选 ： 开",
	BoonManagerLevelDisplay = "等级. ",

	ResourceMenuTitle = "资源菜单",
	ResourceMenuDescription = "生成任何数量的资源。",
	ResourceMenuSpawnButton = "生成资源",
	ResourceMenuEmpty = "空"
})
