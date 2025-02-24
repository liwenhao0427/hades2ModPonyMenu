local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("zh-CN", {
    PonyMenuCategoryTitle = "幻驹菜单",

    ClearAllBoons = "清除所有祝福",
    ClearAllBoonsDescription = "移除所有祝福效果。",

    BoonSelectorTitle = "祝福选择器",
    BoonSelectorSpawnButton = "原地掉落祝福",
    BoonSelectorCommonButton = "设为普通",
    BoonSelectorRareButton = "设为稀有",
    BoonSelectorEpicButton = "设为史诗",
    BoonSelectorHeroicButton = "设为英雄",

    BoonManagerTitle = "祝福管理器",
    BoonManagerSubtitle = "点击左下角的等级开关或稀有度开关，再次点击可切换升级(+)与降级(-)，最后点击要改变的祝福。",
    BoonManagerDescription = "打开祝福管理器，可删除或升级您已有的祝福。",
    BoonManagerModeSelection = "请先选择两侧的功能",
    BoonManagerLevelMode = "更改等级",
    BoonManagerRarityMode = "更改稀有度",
    BoonManagerDeleteMode = "删除",
    BoonManagerAllModeOff = "全选 : 关",
    BoonManagerAllModeOn = "全选 ： 开",
    BoonManagerLevelDisplay = "等级：",

    ResourceMenuTitle = "材料菜单",
    ResourceMenuDescription = "生成任意数量的材料。",
    ResourceMenuSpawnButton = "生成材料",
    ResourceMenuEmpty = "空",

    BossSelectorTitle = "Boss选择器",
    BossSelectorDescription = "让您以存入的套装，直接挑战区域守卫。",
    BossSelectorNoSavedState = "没有已存入的套装! 请先存一个！",

    KillPlayerTitle = "自杀",
    KillPlayerDescription = "自杀并回到三岔路口。",

    SaveStateTitle = "存入套装",
    SaveStateDescription = "存入您现在的魔宠、祝福、饰品等形成套装，用于区域守卫选择器，或是套装测试。",
    SaveStateSaved = "已存入套装!",

    LoadStateTitle = "加载套装",
    LoadStateDescription = "加载您的存入套装。",
    SaveStateLoaded = "已加载套装!",

    ConsumableSelectorTitle = "物品选择器",
    ConsumableSelectorDescription = "立即获得任意卡戎物品及地图物品，如最大生命、月神祝福、元素等。",

    extraSelectorTitle = "额外修改内容",
    extraSelectorDescription = "立即获得额外的物品，如魔宠、祝福、饰品等。",
})
