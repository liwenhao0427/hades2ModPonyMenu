local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("zh-CN", {
    PonyMenuCategoryTitle = "小马选单",

    ClearAllBoons = "清除所有祝福",
    ClearAllBoonsDescription = "移除所有祝福效果。",

    BoonSelectorTitle = "祝福选择器",
    BoonSelectorSpawnButton = "召唤祝福",
    BoonSelectorCommonButton = "普通",
    BoonSelectorRareButton = "稀有",
    BoonSelectorEpicButton = "史诗",
    BoonSelectorHeroicButton = "英雄",

    BoonManagerTitle = "祝福管理器",
    BoonManagerSubtitle = "点击选择加法(+)或剑法(-)，然后选择级别或稀有度模式。",
    BoonManagerDescription = "打开祝福管理器，方便您管理和升级祝福。",
    BoonManagerModeSelection = "请选择运作模式",
    BoonManagerLevelMode = "级别模式",
    BoonManagerRarityMode = "稀有度模式",
    BoonManagerDeleteMode = "移除模式",
    BoonManagerAllModeOff = "所有模式：关闭",
    BoonManagerAllModeOn = "所有模式：开启",
    BoonManagerLevelDisplay = "级别：",

    ResourceMenuTitle = "资源选单",
    ResourceMenuDescription = "生成任意数量的资源。",
    ResourceMenuSpawnButton = "生成资源",
    ResourceMenuEmpty = "空",

    BossSelectorTitle = "Boss选择器",
    BossSelectorDescription = "直接挑战Boss，使用您当前的存档装备。",
    BossSelectorNoSavedState = "没有存档装备！请先创建装备！",

    KillPlayerTitle = "自杀",
    KillPlayerDescription = "击杀玩家并将其传送到三岔路口。",

    SaveStateTitle = "存储装备",
    SaveStateDescription = "保存您当前的装备，以便后续加载。用于区域守卫选择器，保存所有装备。",
    SaveStateSaved = "装备已保存！",

    LoadStateTitle = "加载装备",
    LoadStateDescription = "加载您的存档装备。必须先保存装备才能加载。",
    SaveStateLoaded = "装备已加载！",

    ConsumableSelectorTitle = "消耗品选择器",
    ConsumableSelectorDescription = "生成消耗品，如最大生命、月神祝福等。"
})
