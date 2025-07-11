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
	ResourceMenuEmpty = "空",

	BossSelectorTitle = "區域守衛選擇器",
	BossSelectorDescription = "讓您直接去打一位區域守衛，用您的存檔裝備。",
	BossSelectorNoSavedState = "沒有存檔裝備! 請去造一個!",

	KillPlayerTitle = "殺玩家",
	KillPlayerDescription = "殺您而遣送您到三岔路口。",

	SaveStateTitle = "存入裝備",
	SaveStateDescription = "存入您現在的裝備，為了一後加載。 必要為了用區域守衛選擇器。 存入您全部裝備。",
	SaveStateSaved = "裝備存入了!",

	LoadStateTitle = "載入裝備",
	LoadStateDescription = "載入您的存檔裝備。 必要先存入一個裝備。",
	SaveStateLoaded = "裝備加載了!",

	ConsumableSelectorTitle = "耗材選擇器",
	ConsumableSelectorDescription = "自己給您如何耗材。",

	ExtraSelectorTitle = "額外修改內容",
	ExtraSelectorDescription = "一些額外的作弊功能選項。包括無限Roll、必出混沌房間、永遠出現英雄稀有度祝福等",


	BoonSelectorExtraConfirmButton = "啟用修改功能",
	BoonSelectorExtraCancelButton = "取消修改功能",

	ChaosGate = "混沌之門",
	InfiniteRoll = "無限Roll",
	Heroic = "必出英雄祝福",
	NoRewardRoom = "不出現資源房間",

	Extrarush = "衝刺次數+1",
	MoreMoney = "金幣+100",
	RestoreHealth = "給我恢復",
	RestoreMana = "給我充能",

	DropLoot = "擊殺概率掉落祝福",
	StopDropLoot = "關閉擊殺掉落祝福",
	EphyraZoomOut = "房間獎勳預覽",

	DiyTraitDataTitle = "自訂祝福",
	DiyTraitDataDescription = "使用作者創建的自訂祝福，或先前移除的官方祝福（這些祝福可能完全沒有作用）",

	BossHealthLoot = "顯示Boss血量",
	QuitAnywhere = "隨時退出",
	PermanentLocationCount = "始終顯示房間數",
	RepeatableChaosTrials = "混沌祝福可重複",

    FreeToBuy = "0元购",

	GetRavenFamiliar = "解鎖鴉鴉魔寵",
	GetFrogFamiliar = "解鎖蛙蛙魔寵",
	GetCatFamiliar = "解鎖貓貓魔寵",
	GetHoundFamiliar = "解鎖狗狗魔寵",
	GetPolecatFamiliar = "解鎖鼬鼬魔寵",

})
