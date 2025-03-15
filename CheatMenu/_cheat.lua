-- 击杀时有概率掉落祝福
metaupgradeDropBoonBoost = 0
-- 无限Roll
infiniteRoll = false
-- 额外冲刺次数【仅房间生效，获得祝福】
extraRushCount = 0
-- 默认配置稀有度
RaritySet = 'Rare'
-- CheckRoomExitsReady 不收集资源无法离开
-- SpawnStoreItemInWorld 喀戎商店


function logMessage( message )
	debugShowText(message)
end

-- function displayLogs()
--     local logText = table.concat(logs, "\n")
--     if ScreenAnchors.LogDisplay then
--         ModifyTextBox({ Id = ScreenAnchors.LogDisplay.Id, Text = logText })
--     else
--         ScreenAnchors.LogDisplay = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_UI", X = 100, Y = 100 })
--         CreateTextBox({ Id = ScreenAnchors.LogDisplay.Id, Text = logText, FontSize = 14, Color = Color.White, Font = "AlegreyaSansSCRegular", ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset = {0, 2}, Justification = "Left" })
--     end
-- end

-- 强制英雄
function patchSetTraitsOnLoot( fun )
    function SetTraitsOnLoot( lootData, args )
        fun(lootData, args)
        for k, item in pairs( lootData.UpgradeOptions ) do
            if item.Rarity then 
                item.Rarity = 'Heroic' 
            end
        end
    end
    return SetTraitsOnLoot
end

function patchSetTransformingTraitsOnLoot( fun )
    function SetTransformingTraitsOnLoot( lootData, upgradeChoiceData )
        fun(lootData, upgradeChoiceData)
        for k, item in pairs( lootData.UpgradeOptions ) do
            if item.Rarity then 
                item.Rarity = 'Heroic' 
            end
        end
    end
    return SetTransformingTraitsOnLoot
end



AddRerolled = false
curExtraRushCount = extraRushCount
-- 每轮游戏刚开始时进行的操作
function patchEachRun(fun)
    function newFun(prevRun, args)
        -- 父函数，照常执行
        CurrentRun = fun(prevRun, args)
        
        -- 初始化
        AddRerolled = false
        curExtraRushCount = extraRushCount
        -- for k, debugBoon in pairs( initBoons ) do
        --     CreateLoot({ Name = debugBoon, DestinationId = CurrentRun.Hero.ObjectId, OffsetX = math.random(-500,500), OffsetY = math.random(-500,500) })
        -- end
        -- 击杀时随机获取祝福
        -- Kill = patchKill(Kill)
        return CurrentRun
    end
	return newFun
end




-- 永远返回真的函数
function alwaysTrue()
    return true
end

-- WeaponUpgrade 武器升级 Devotion 双神 RoomMoneyDrop 钱 MaxHealthDrop MaxManaDrop 最大血/蓝 HermesUpgrade 赫尔墨斯 HephaestusUpgrade 锤神 StackUpgrade 祝福升级  TalentDrop 大招 AirBoost  Boon 随机祝福 ArtemisUpgrade 猎神【会报错】
local resource = "GiftDrop,MetaCurrencyDrop,MetaCardPointsCommonDrop,MemPointsCommonDrop"
local replaceList = {
    -- 蜜露
    GiftDrop = {
        target =  'Boon',
        chance = 0.3,
        text =  '蜜露替换为随机祝福',
    },
    Boon = {
        chance = 0.1,
        target = 'WeaponUpgrade',
        text = '随机祝福替换为武器升级',
    },
    -- 三项基本资源
    MetaCurrencyDrop = {
        target = 'MaxHealthDrop',
        text = '骨骸替换为最大生命',
    },
    MetaCardPointsCommonDrop = {
        target = 'MaxManaDrop',
        text = '尘灰替换为最大法力',
    },
    MemPointsCommonDrop = {
        target = 'HermesUpgrade',
        text = '魂魄替换为赫尔墨斯祝福',
    },
}
-- 房间奖励
function patchChooseRoomReward(fun)
    function newFun(run, room, rewardStoreName, previouslyChosenRewards, args)
        -- 父函数，照常执行,获取房间名称
        name = fun(run, room, rewardStoreName, previouslyChosenRewards, args)
        -- 替换为祝福
        if name and replaceList[name] ~= nil and (replaceList[name].chance == nil or RandomChance(replaceList[name].chance)  ) then
            debugShowText(replaceList[name].text)
            name = replaceList[name].target
        end
        return name
    end
	return newFun
end



-- 混沌门必定出现
function patchIsSecretDoorEligible(fun)
    function newFun(currentRun, currentRoom)
        if IsGameStateEligible( currentRun, currentRoom, NamedRequirementsData.ForceSecretDoorRequirements) then
            return true
        end
        return false
    end
	return newFun
end


-- 每次进新房间之前触发
function patchBeforeEachRoom( fun )
    function newFun()
        -- 父函数，照常执行
        fun()

        -- 击杀时随机获取祝福
        -- KillEnemy = patchKill(KillEnemy)
        -- -- 强制出英雄稀有度祝福
        -- if forceHeroic then
        --     SetTraitsOnLoot = patchSetTraitsOnLoot(SetTraitsOnLoot)
        --     SetTransformingTraitsOnLoot = patchSetTransformingTraitsOnLoot(SetTransformingTraitsOnLoot)
        -- end
        -- -- 强制chaos
        -- if forceSecretDoor then
        --     IsSecretDoorEligible = patchIsSecretDoorEligible(IsSecretDoorEligible)
        -- end
        -- -- 不出现资源房间
        -- if forceTraitRoom then
        --     ChooseRoomReward = patchChooseRoomReward(ChooseRoomReward)
        -- end
        -- 额外冲刺次数
        -- if curExtraRushCount > 0 then 
        --     -- TraitData.CheatExtraRush.Name = '额外冲刺次数+' .. extraRushCount
        --     -- TraitData.CheatExtraRush.RarityLevels.Heroic.Multiplier = extraRushCount
        --     AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = 'CheatExtraRush' , Rarity = "Heroic" } ) } )
        --     curExtraRushCount = 0
        -- end
        -- 无限Roll
        if infiniteRoll then
            CurrentRun.NumRerolls = 9
            if not AddRerolled then
				-- 塔罗牌
				AddTraitToHero({
					TraitData = GetProcessedTraitData({
						Unit = CurrentRun.Hero,
						TraitName = "DoorRerollMetaUpgrade"
					}),
					SkipNewTraitHighlight = true,
					SkipQuestStatusCheck = true,
					SkipActivatedTraitUpdate = true,
				})
				-- 塔罗牌
				AddTraitToHero({
					TraitData = GetProcessedTraitData({
						Unit = CurrentRun.Hero,
						TraitName = "PanelRerollMetaUpgrade"
					}),
					SkipNewTraitHighlight = true,
					SkipQuestStatusCheck = true,
					SkipActivatedTraitUpdate = true,
				})
                AddRerolled = true
            end
			-- local trait = GetHeroTrait("MetaToRunMetaUpgrade")
			-- if trait and trait.MetaConversionUses then
			-- 	trait.MetaConversionUses = 3
			-- end 
        end
    end
	return newFun
end

-- AttemptReroll Roll
-- Roll祝福
function patchAttemptReroll( fun )
    function newFun(run, target)
        -- 父函数，照常执行
        local lastRoll = run.NumRerolls 
        fun(run, target)
        run.NumRerolls = lastRoll
		if trait and trait.MetaConversionUses then
			trait.MetaConversionUses = 99
		end 
    end
	return newFun
end
-- Roll 门
function patchAttemptPanelReroll(fun)
    function newFun(screen, button)
        -- 父函数，照常执行
        local lastRoll = CurrentRun.NumRerolls 
        fun(screen, button)
        CurrentRun.NumRerolls = lastRoll
		if trait and trait.MetaConversionUses then
			trait.MetaConversionUses = 99
		end 
    end
	return newFun
end


-- 替换原函数
-- StartNewRun = patchEachRun(StartNewRun)
-- LoadActiveBountyPackages = patchBeforeEachRoom(LoadActiveBountyPackages)



local ShopItems = 
{
    Traits = 
    {
        "TemporaryImprovedSecondaryTrait",
        "TemporaryImprovedCastTrait",
        "TemporaryMoveSpeedTrait",
        "TemporaryBoonRarityTrait",
        "TemporaryImprovedExTrait",
        "TemporaryImprovedDefenseTrait",
        "TemporaryDiscountTrait",
        "TemporaryHealExpirationTrait",
        "TemporaryDoorHealTrait",
    },
    Consumables = 
    {
        "LastStandShopItem",
        "EmptyMaxHealthShopItem",
        "HealDropRange",
        "MetaCurrencyRange",
        "MetaCardPointsCommonRange",
        "MemPointsCommonRange",
        "SeedMysteryRange",
    },
}

-- 按下G/RT时操作
-- Debug
-- 初始化原来的函数一次，用以还原
initPreFun = false
PreSetTraitsOnLoot = nil
PreKillEnemy = nil
PreSetTransformingTraitsOnLoot = nil
PreIsSecretDoorEligible = nil
PreChooseRoomReward = nil
PreAttemptReroll = nil
PreAttemptPanelReroll = nil
PreHasAccessToTool = nil
PreSpendResource = nil
PreSpendResources = nil
PreHasResources = nil


function openCheatScreen() 
	-- 初始化原来的函数一次，用以还原
	if not initPreFun then 
		PreSetTraitsOnLoot = SetTraitsOnLoot
		PreKillEnemy = KillEnemy
		PreSetTransformingTraitsOnLoot = SetTransformingTraitsOnLoot
		PreIsSecretDoorEligible = IsSecretDoorEligible
		PreChooseRoomReward = ChooseRoomReward
		PreAttemptReroll = AttemptReroll
		PreAttemptPanelReroll = AttemptPanelReroll
		PreHasAccessToTool = HasAccessToTool
		initPreFun = true
	end
	OpenDebugEnemyCheatScreen()
end


OnControlPressed{ "Gift",
	function( triggerArgs )
		
		-- local target = triggerArgs.UseTarget
		-- -- -- 如果存在敌人，则无法打开
		-- if not IsEmpty( RequiredKillEnemies ) then 
		-- 	debugShowText('附近有敌人')
		-- 	thread( PlayVoiceLines, HeroVoiceLines.ExitBlockedByEnemiesVoiceLines, true )
		-- 	return
		-- end

        if target == nil then
            -- 打开敌人调试面板
            -- openCheatScreen()
            -- 通关页面
            -- OpenRunClearScreen()
            -- 切换饰品
            -- OpenKeepsakeRackScreen( CurrentRun.Hero )
            -- 
            -- OpenDebugConversationScreen()

            -- local newUnit = DeepCopyTable( EnemyData.NPC_Artemis_Field_01 )
            -- local spawnPointId = GetRandomValue( GetIds({ Name = "ArtemisSpawnPoints" }) or GetIdsByType({ Name = "CameraClamp" }) ) or GetRandomValue( GetIdsByType({ Name = "HeroStart" }) )
            -- newUnit.ObjectId = SpawnUnit({ Name = "NPC_Artemis_Field_01", Group = "Standing", DestinationId = spawnPointId })
            -- currentEncounter.ArtemisId = newUnit.ObjectId
            -- -- 特殊召唤阿尔特弥斯
            -- SetupUnit( newUnit, CurrentRun, { IgnoreAI = true, } )
            -- MapState.RoomRequiredObjects[newUnit.ObjectId] = DeepCopyTable( EnemyData.NPC_Artemis_Field_01 )

            

            -- if  CurrentRun.CurrentRoom.Encounter ~= nil and string.find(CurrentRun.CurrentRoom.Encounter.Name, 'Artemis')  then
            --     -- thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = CurrentRun.CurrentRoom.Encounter.Name, Duration = 3.0, ShadowScaleX = 0.7 } )

            --     thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = CurrentRun.RoomHistory[1].Reward.Name, Duration = 3.0, ShadowScaleX = 0.7 } )

            --     local prevRoom = CurrentRun.RoomHistory[1].Reward
            --     CurrentRun.CurrentRoom.Reward =  prevRoom.Reward
            --     CurrentRun.CurrentRoom.ChangeReward =  prevRoom.ChangeReward
            --     CurrentRun.CurrentRoom.ChosenRewardType =  "Story"

            -- end
            -- OpenBountyBoardScreen
            -- HandleEnemySpawns 新一波战斗
            -- RunEventsGeneric( EncounterData['ArtemisCombatG'], EncounterData['ArtemisCombatG'] )	
            -- CheckArtemisSpawn( { FirstWaveArtemisChance = 1 })

            -- addCheatTrait()
            -- 打开商店页面
            -- StartUpStore()
            -- 获取随机商店商品
            -- AwardRandomStoreItem(ShopItems)

            -- AddResource( "Money", 1, "RunStart" )
            
            -- debugShowText("test!")
            -- debugShowText(TraitData["CheatTraitSpeed"] ~= nil)
            -- debugShowText(TraitData["CheatTraitSpeed"].Icon)

            -- AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = "CheatTraitSpeed", Rarity = "Rare" } ) } )

            -- debugShowText( tostring( GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = "CheatTraitSpeed", Rarity = "Rare" } ) ) )
            
            -- debugShowText( tostring( nil ) )
            -- thread( InCombatText, CurrentRun.Hero.ObjectId, text, 0.8, { SkipShadow = true } )

            -- 说话
            -- thread( PlayVoiceLines, GlobalVoiceLines.CannotAffordMemUpgradeVoiceLines, true )

            -- 添加被动
            -- for k, item in pairs( traitList ) do
            --     AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = item.name, Rarity = item.Rarity } ) } )
            -- end

        end
    end
}



-- -- 主神列表
-- initBoons = { "ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "ApolloUpgrade", "DemeterUpgrade", "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade" }

-- 击杀敌人时触发
function patchKill( fun )
    function newFun(victim, triggerArgs)
        -- 父函数，照常执行
        fun(victim, triggerArgs)
        local debugBoons = { "ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "ApolloUpgrade", "DemeterUpgrade", "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade" }
        if victim ~= CurrentRun.Hero and metaupgradeDropBoonBoost > 0 and EnemyData[victim.Name] ~= nil then
            if( RandomChance(metaupgradeDropBoonBoost) )  then
                warningShowTest("击杀掉落祝福!")
                CreateLoot({ Name = debugBoons[math.random(1,#debugBoons)], DestinationId = CurrentRun.Hero.ObjectId, OffsetX = math.random(-500,500), OffsetY = math.random(-500,500)}) 
            end
        end
    end
	return newFun
end


function debugShowText( text )
    thread( InCombatText, CurrentRun.Hero.ObjectId, text, 0.8, { SkipShadow = true } )
end


function warningShowTest(text)
    thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = text, Duration = 1.0, ShadowScaleX = 0.7 } )
end




function isInDiyTraitData(str)
	for _, value in ipairs(DiyTraitData) do
		if value == str then
			return true
		end
	end
	return false
end


-- 自定义祝福列表
OverwriteTableKeys( TraitData,
{
    CheatExtraRush = {
        Name= 'CheatExtraRush',
		CustomTitle= "额外冲刺",
		Description = "获得额外冲刺次数，普通1、稀有2、史诗3、英雄4",
		InheritFrom = { "BaseTrait", "LegacyTrait", "AirBoon" },
		BlockStacking = true,
		Icon = "Boon_Poseidon_36",
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.00,
			},
			Rare =
			{
				Multiplier = 2.00,
			},
			Epic =
			{
				Multiplier = 3.00,
			},
			Heroic =
			{
				Multiplier = 10.00,
			}
		},
		PropertyChanges =
		{
			{
				WeaponNames = WeaponSets.HeroBlinkWeapons,
				WeaponProperty = "ClipSize",
				BaseValue = 1,
				ChangeType = "Add",
				ReportValues = { ReportedBonusSprint = "ChangeValue"},
			},
		},
	},
    CheatTraitSpeed = {
        Name = "CheatTraitSpeed",
		CustomTitle= "额外移速",
		Description = "获得额外移速，普通1.0、稀有1.5、史诗2.0、英雄2.5",
		InheritFrom = { "BaseTrait", "LegacyTrait", "WaterBoon" },
		Icon = "Boon_Poseidon_36",
		BlockStacking = true,
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			}
		},
        -- DamageOnFireWeapons =
		-- {
		-- 	WeaponNames = WeaponSets.HeroRangedWeapons,
		-- 	ExcludeLinked = true,
		-- 	Damage =
		-- 	{
		-- 		BaseMin = 3,
		-- 		BaseMax = 6,
		-- 		AsInt = true,
		-- 	},
		-- 	ReportValues =
		-- 	{
		-- 		ReportedDamage = "Damage"
		-- 	},
		-- },
        PropertyChanges =
		{
			{
				UnitProperty = "Speed",
				ChangeType = "Multiply",
				ChangeValue = 2,
				SourceIsMultiplier = true,
				ReportValues = { ReportedBaseSpeed = "ChangeValue" },
			},
		},

    },

	DaggerSpecialFanTraitOld =
	{
		Name = "DaggerSpecialFanTraitOld",
		CustomTitle= "八面神锋",
		Description = "匕首专属改造，你的特技造成20%额外伤害，且你的武器额外发射16把飞刀。",

		InheritFrom = { "WeaponTrait", "DaggerHammerTrait" },
		Icon = "Hammer_Daggers_34",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponDagger", },
			},
			{
				Path = { "CurrentRun", "Hero", "TraitDictionary", },
				HasNone = { "DaggerSpecialLineTrait", },
			},
		},
		AddOutgoingDamageModifiers =
		{
			ValidWeaponMultiplier =
			{
				BaseValue = 1.2,
				SourceIsMultiplier = true,
			},
			ValidWeapons = { "WeaponDaggerThrow" },
			ReportValues = { ReportedWeaponMultiplier = "ValidWeaponMultiplier"},
			ExcludeLinked = true,
		},
		WeaponDataOverride =
		{
			WeaponDaggerThrow =
			{
				ChargeWeaponStages =
				{
					{ ManaCost = 6, WeaponProperties = { Projectile = "ProjectileDaggerThrowCharged", FireGraphic = "Melinoe_Dagger_SpecialEx_Fire", NumProjectiles = 4}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.32, ChannelSlowEventOnEnter = true },
					{ ManaCost = 8, WeaponProperties = { NumProjectiles = 6 }, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 10, WeaponProperties = { NumProjectiles = 8}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 12, WeaponProperties = { NumProjectiles  = 10}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 14, WeaponProperties = { NumProjectiles  = 12}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 16, WeaponProperties = { NumProjectiles  = 13}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 18, WeaponProperties = { NumProjectiles  = 15}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 20, WeaponProperties = { NumProjectiles  = 16, ReportValues = { ReportedAmount = "NumProjectiles" } }, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.06, },
				},
			}
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponDaggerThrow",
				WeaponProperties =
				{
					ProjectileAngleOffset = math.rad(22.5),
					ProjectileInterval = 0.015,
				},
				ProjectileProperties =
				{
					DrawDuringPause = false,
				},
				ExcludeLinked = true
			},
		},
		ExtractValues =
		{
			{
				Key = "ReportedAmount",
				ExtractAs = "Amount",
			},
			{
				Key = "ReportedWeaponMultiplier",
				ExtractAs = "DamageIncrease",
				Format = "PercentDelta",
			},
		}
	},


	AxeComboSwingTraitOld = 
	{
		Name = "AxeComboSwingTraitOld",
		CustomTitle= "斧头连击",
		Description = "斧头专属改造,攻击速度提升",

		InheritFrom = { "WeaponTrait", "AxeHammerTrait" },
		Icon = "Hammer_Axe_32",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponAxe", },
			},
		},
		OnWeaponFiredFunctions = 
		{
			ValidWeapons = { "WeaponAxe2" },
			ExcludeLinked = true,
			FunctionName = "SpeedUpSpecial",
			FunctionArgs = 
			{
				ChargeMultiplier = 0.1,
				Window = 0.8,
			}

		},

	},


	AxeConsecutiveStrikeTraitOld = 
	{
		Name = "AxeConsecutiveStrikeTraitOld",
		CustomTitle= "执念旋风",
		Description = "斧专属改造,连续命中时伤害提升",
		InheritFrom = { "WeaponTrait", "AxeHammerTrait" },
		Icon = "Hammer_Axe_31",	
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponAxe", },
			},
			{
				Path = { "CurrentRun", "Hero", "TraitDictionary", },
				HasNone = { "AxeAttackRecoveryTrait" },
			},
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponAxeSpin",
				ProjectileProperties = 
				{
					ConsecutiveHitWindow = 0.25,
					DamagePerConsecutiveHit = 2,
					ReportValues = { ReportedDamage = "DamagePerConsecutiveHit"},
				},
			}
		},
		
		ExtractValues =
		{
			{
				Key = "ReportedDamage",
				ExtractAs = "Damage",
			},
		}
	},

	ApolloMissStrikeBoonOld =
	{
		Name = "ApolloMissStrikeBoonOld",
		CustomTitle= "技高一筹",
		Description = "阿波洛祝福,闪避时造成致命一击",
		Icon = "Boon_Apollo_38",
		InheritFrom = { "BaseTrait", "AirBoon" },
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			},
		},
		OnDodgeFunction = 
		{
			FunctionName = "ApolloBlindStrike",
			RunOnce = true,
			FunctionArgs =
			{
				ValidActiveEffectGenus = "Blind",
				ProjectileName = "ApolloPerfectDashStrike",
				DamageMultiplier = { 
					BaseValue = 1,
					MinMultiplier = 0.1,
					IdenticalMultiplier =
					{
						Value = -0.5,
						DiminishingReturnsMultiplier = 0.8,
					}, 
				},
				Cooldown = 0.2,
				ReportValues = { ReportedMultiplier = "DamageMultiplier"},
			},
		},
		
	},


	DaggerSpecialRangeTraitOld = 
	{
		Name = "DaggerSpecialRangeTraitOld",
		CustomTitle= "远射",
		Description = "匕首专属改造，你的特技距离更远，并且超出650码后造成双倍伤害。",
		InheritFrom = { "WeaponTrait", "DaggerHammerTrait" },
		Icon = "Hammer_Daggers_37",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponDagger", },
			},
		},
		AddOutgoingDamageModifiers =
		{
			ValidWeapons = { "WeaponDaggerThrow" },
			ExcludeLinked = true,
			DistanceThreshold = 650,
			DistanceMultiplier =
			{
				BaseValue = 2,
				SourceIsMultiplier = true,
			},
			ReportValues = { ReportedWeaponMultiplier = "DistanceMultiplier"},
		},
		ChargeStageModifiers = 
		{
			ValidWeapons = { "WeaponDaggerThrow", },
			RevertProjectileProperties = 
			{
				Range = true,
			},
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponDaggerThrow",
				ProjectileName = "ProjectileDaggerThrow",
				ProjectileProperties = 
				{
					Range = 1400,
				},
			},
		},
	},
	DaggerRepeatStrikeTraitOld = 
	{
		Name = "DaggerRepeatStrikeTraitOld",
		CustomTitle= "自动攻击",
		Description = "匕首专属改造，长安自动攻击",
		InheritFrom = { "WeaponTrait", "DaggerHammerTrait" },
		Icon = "Hammer_Daggers_37",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponDagger", },
			},
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponDaggerMultiStab",
				ExcludeLinked = true,
				WeaponProperties = 
				{
					FullyAutomatic = true,
					ControlWindow = 0.6,
					SwapOnFire = "WeaponDaggerMultiStab",
					AddOnFire = "null",
					LoseControlIfNotCharging = true,
					ForceReleaseOnSwap = false,
				}
			},
		},
	},

	RandomDuoBoon = 
	{
		Name = "RandomDuoBoon",
		CustomTitle= "觥筹交错",
		Description = "获得一个今夜你接受过的奥林匹斯神的随机双重祝福。",
		InheritFrom = { "BaseTrait", "WaterBoon" },
		Icon = "Boon_Dionysus_33",
		
		AcquireFunctionName = "GrantEligibleDuo",
		AcquireFunctionArgs = 
		{
			SkipRequirements = true,		-- Skip prereq traits
			Count = 1,
			BlockedTraits = 
			{
				SuperSacrificeBoonHera = true,
				SuperSacrificeBoonZeus = true,
			},
			ReportValues = { ReportedCount = "Count"}
		},
	},


	CoverRegenerationBoonOld = -- Apollo x Hestia
	{
		Name = "CoverRegenerationBoonOld",
		CustomTitle= "凤凰涅槃",
		Description = "牺牲100最大生命。如果你在一段时间内没有造成伤害，也没有受到伤害，快速恢复生命。",
		InheritFrom = {"SynergyTrait"},
		Icon = "Boon_Hestia_42",
		
		OnEnemyDamagedAction = 
		{
			ValidWeapons = WeaponSets.HeroAllWeapons,
			FunctionName = "InterruptRegen",
		},
		SetupFunction = 
		{
			Name = "OutOfCombatRegenSetup",
			Args = 
			{
				Timeout = 3, -- Time before regen kicks in
				Regen = 3, -- Per second regen
				RegenStartFx = nil,
				RegenStartSound = nil,
				ReportValues =
				{
					ReportedTimeout = "Timeout",
					ReportedRegen = "Regen",
				}
			}
		},
		PropertyChanges =
		{
			{
				LuaProperty = "MaxHealth",
				ChangeValue = -100,
				ChangeType = "Add",
				AsInt = true,
				ReportValues = { ReportedHealthPenalty = "ChangeValue"},
			},
		},
		StatLines = 
		{
			"CoverRegenStatDisplay1",
		},
		CustomStatLinesWithShrineUpgrade = 
		{
			ShrineUpgradeName = "HealingReductionShrineUpgrade",
			StatLines = 
			{
				"CoverRegenStatDisplay1",
				"HealingReductionNotice",
			},
		},
	},

	EchoRepeatKeepsakeBoonOld = 
	{
		Name = "EchoRepeatKeepsakeBoonOld",
		CustomTitle= "信物{#Echo1}信物{#Prev}{#Echo2}信物",
		Description = "在下一个{$Keywords.Biome}中，获得你当前{$Keywords.KeepsakeAlt}的全部效果{#ItalicLightFormat}（即使你之后更换了信物）。",
		InheritFrom = { "BaseEcho" },
		Icon = "Boon_Echo_07",
		TrayStatLines = 
		{
			"RepeatKeepsakeStatDisplay",
		},
		ActivatedTrayText = "EchoRepeatKeepsakeBoon_Inactive",
		RepeatedKeepsake = "",
		AcquireFunctionName = "EchoRepeatKeepsake",
	},

	ElementalDodgeBoonOld = 
	{
		Name = "ElementalDodgeBoonOld",
		CustomTitle= "轻盈如风",
		Description = "每有一个{!Icons.CurseAir}系祝福，获得{$Keywords.Dodge}概率。",
		InheritFrom = {"UnityTrait"},
		Icon = "Boon_Aphrodite_33",
		GameStateRequirements = 
		{
			{
				Path = { "CurrentRun", "Hero", "Elements", "Air" },
				Comparison = ">=",
				Value = 2,
			},
		},
		ElementalMultipliers = 
		{
			Air = true,
		},		
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1
			},
		},
		PropertyChanges = 
		{
			{
				LifeProperty = "DodgeChance",
				BaseValue = 0.03,
				ChangeType = "Add",
				MultipliedByElement = "Air",
				DataValue = false,
				ReportValues = 
				{ 
					ReportedTotalDodgeBonus = "ChangeValue",
					ReportedDodgeBonus = "BaseValue",
				},
			},
		},
		StatLines =
		{
			"ElementalDodgeStatDisplay1",
		},
		TrayStatLines = 
		{
			"TotalDodgeChanceStatDisplay1",
		},
		ExtractValues =
		{
			{
				Key = "ReportedTotalDodgeBonus",
				ExtractAs = "TooltipTotalDodgeBonus",
				Format = "Percent",
				SkipAutoExtract = true,
			},
			{
				Key = "ReportedDodgeBonus",
				ExtractAs = "TooltipDodgeBonus",
				Format = "Percent",
			},
		},
	},

	HadesLaserThresholdBoonOld = 
	{
		Name = "HadesLaserThresholdBoonOld",
		CustomTitle= "愤怒叱喝",
		Description = "每当你受到 {$TooltipData.ExtractData.Threshold} 点伤害后，进入{$Keywords.Invulnerable}状态并向四周发射光束，持续 {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} 秒{#Prev}。",
		InheritFrom = { "InPersonOlympianTrait" },
		Icon = "Boon_Hades_08",
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			},
		},
		BlockInRunRarify = true,
		OnSelfDamagedFunction = 
		{
			NotDamagingRetaliate = true,
			Name = "CheckRadialLaserRetaliate",
			FunctionArgs = 
			{
				HealthThreshold = 100,
				ProjectileName = "HadesCastBeam",
				ProjectileCount = 4,
				InvulnerabilityDuration = 5,
				ReportValues = 
				{ 
					ReportedThreshold = "HealthThreshold",
					ReportedCount = "ProjectileCount",
					ReportedDuration = "InvulnerabilityDuration",
				}
			}
		},
		StatLines =
		{
			"LaserDamageStatDisplay",
		},
		ExtractValues =
		{
			{
				ExtractAs = "Damage",
				External = true,
				BaseType = "ProjectileBase",
				BaseName = "HadesCastBeam",
				BaseProperty = "Damage",
			},
			{
				ExtractAs = "Interval",
				SkipAutoExtract = true,
				External = true,
				BaseType = "ProjectileBase",
				BaseName = "HadesCastBeam",
				BaseProperty = "ImmunityDuration",
				DecimalPlaces = 2,
			},
			{
				Key = "ReportedThreshold",
				ExtractAs = "Threshold",
				SkipAutoExtract = true,
			},
			{
				Key = "ReportedCount",
				ExtractAs = "Count",
				SkipAutoExtract = true,
			},
			{
				Key = "ReportedDuration",
				ExtractAs = "Duration",
				SkipAutoExtract = true,
			},
		},
	},

	HexCooldownBuffBoonOld = 
	{
		Name = "HexCooldownBuffBoonOld",
		CustomTitle= "夜色阑珊",
		Description = "当你的{$Keywords.Spell}已就绪时，你的移动和武器速度加快。",
		InheritFrom = {"AirBoon"},
		Icon = "Boon_Hermes_32",
		HexCooldownSpeedBuff = { BaseValue = 0.85, SourceIsMultiplier = true },
		GameStateRequirements =
		{
			{
				PathTrue = { "CurrentRun", "Hero", "SlottedTraits", "Spell", },
			},
			{
				Path = { "CurrentRun", "Hero", "TraitDictionary", },
				HasNone = { "SpellPotionTrait" },
			},
		},
		
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.34,
			},
			Epic =
			{
				Multiplier = 1.67,
			},
			Heroic =
			{
				Multiplier = 2.00,
			},
		},
		
	},
})


DiyTraitData = {
	"CheatExtraRush",
	"CheatTraitSpeed",
	"DaggerSpecialFanTraitOld",
	-- "AxeComboSwingTraitOld",
	-- "AxeConsecutiveStrikeTraitOld",
	"ApolloMissStrikeBoonOld",
	-- "DaggerSpecialRangeTraitOld",
	-- "DaggerRepeatStrikeTraitOld",
	-- "RandomDuoBoon",
	"CoverRegenerationBoonOld",
	"EchoRepeatKeepsakeBoonOld",
	"ElementalDodgeBoonOld",
	-- "HadesLaserThresholdBoonOld",
	"HexCooldownBuffBoonOld",
	-- "SpeedRunBossKeepsake",
	-- "RevengeManaTrait",
	-- "ManaInsideCastTrait",
	-- "StaffSlowExTrait",
	-- "StaffReserveManaBoostTrait",
	-- "TemporaryImprovedWeaponTrait",
	-- "MinorManaDiscountTalent",
	-- "ManaDiscountTalent",
	-- "ChargeSpeedTalent",
	-- "SpellChargeBonusTalent",
	-- "TimeSlowDashTalent",
	-- "LaserPatienceTalent",
	-- "LaserSpeedTalent",
	-- "PolymorphAoETalent",
	-- "TorchSpinAttackAltTrait",
	-- "TorchHomingAttackTrait",
	-- "TorchConsecutiveStrikeTrait",
	-- "TorchOrbitDistanceTrait",	
}







































-- 具体功能，划分全部放在这里
function DebugEnemySpawnButton( screen, button )

	debugShowText(button.EnemyName)

	if button.EnemyName == '开启采集不需要工具' then
		HasAccessToTool = alwaysTrue
	elseif button.EnemyName == '开启必出混沌门' then
		IsSecretDoorEligible = patchIsSecretDoorEligible(IsSecretDoorEligible)
	elseif button.EnemyName == '开启无限Roll' then
		infiniteRoll = true
		AttemptReroll = patchAttemptReroll(AttemptReroll)
		AttemptPanelReroll = patchAttemptPanelReroll(AttemptPanelReroll)
	elseif button.EnemyName == '击杀加1%概率掉落祝福' then
		metaupgradeDropBoonBoost = metaupgradeDropBoonBoost + 0.01
		warningShowTest('                                                      当前概率' .. metaupgradeDropBoonBoost)
		KillEnemy = patchKill(KillEnemy)
	elseif button.EnemyName == '不再出现资源房间' then
		ChooseRoomReward = patchChooseRoomReward(ChooseRoomReward)
	elseif button.EnemyName == '本轮额外冲刺次数+1' then
		AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = 'CheatExtraRush' , Rarity = "Common" } ) } )
		curExtraRushCount = 0
	elseif button.EnemyName == '必定出英雄稀有度祝福' then
		SetTraitsOnLoot = patchSetTraitsOnLoot(SetTraitsOnLoot)
		SetTransformingTraitsOnLoot = patchSetTransformingTraitsOnLoot(SetTransformingTraitsOnLoot)
	elseif button.EnemyName == '金币+100' then
		AddResource( "Money", 100, "RunStart" )
	elseif button.EnemyName == '最大生命+25' then
		CurrentRun.Hero.MaxHealth =  CurrentRun.Hero.MaxHealth + 25
		thread( UpdateHealthUI, triggerArgs )
		thread( UpdateManaMeterUI, triggerArgs )

	elseif button.EnemyName == '最大法力+25' then
		CurrentRun.Hero.MaxMana =  CurrentRun.Hero.MaxMana + 25
		thread( UpdateHealthUI, triggerArgs )
		thread( UpdateManaMeterUI, triggerArgs )

	elseif button.EnemyName == '给我恢复' then
		Heal( CurrentRun.Hero, {HealAmount = 1000 })
	elseif button.EnemyName == '给我充能' then
		CurrentRun.Hero.Mana =  CurrentRun.Hero.MaxMana
		thread( UpdateHealthUI, triggerArgs )
		thread( UpdateManaMeterUI, triggerArgs )



	elseif button.EnemyName == '关闭采集不需要工具' then
		HasAccessToTool = PreHasAccessToTool
	elseif button.EnemyName == '关闭必出混沌门' then
		IsSecretDoorEligible = PreIsSecretDoorEligible
	elseif button.EnemyName == '关闭无限Roll' then
		infiniteRoll = false
		AttemptReroll = PreAttemptReroll
		AttemptPanelReroll = PreAttemptPanelReroll
	elseif button.EnemyName == '关闭击杀概率掉落祝福' then
		metaupgradeDropBoonBoost = 0
		KillEnemy = PreKillEnemy
	elseif button.EnemyName == '恢复出现资源房间' then
		ChooseRoomReward = PreChooseRoomReward
	-- elseif button.EnemyName == '额外冲刺次数归0' then
	-- 	AddResource( "Money", 3, "RunStart" )
	elseif button.EnemyName == '不再必定出英雄稀有度祝福' then
		SetTraitsOnLoot = PreSetTraitsOnLoot
		SetTransformingTraitsOnLoot = PreSetTransformingTraitsOnLoot
   	elseif button.EnemyName == '金币-100' then
		AddResource( "Money", 3, "RunStart" )
	elseif button.EnemyName == '最大生命-25' then
		CurrentRun.Hero.MaxHealth =  CurrentRun.Hero.MaxHealth - 25
		thread( UpdateHealthUI, triggerArgs )
		thread( UpdateManaMeterUI, triggerArgs )
	elseif button.EnemyName == '最大法力-25' then
		CurrentRun.Hero.MaxMana =  CurrentRun.Hero.MaxMana - 25
		thread( UpdateHealthUI, triggerArgs )
		thread( UpdateManaMeterUI, triggerArgs )
	elseif button.EnemyName == '自杀' then
		CloseScreen( GetAllIds( screen.Components ), 0, screen )
		Kill( CurrentRun.Hero )
	elseif button.EnemyName == '法力倾泻' then
		CurrentRun.Hero.Mana =  0
		thread( UpdateHealthUI, triggerArgs )
		thread( UpdateManaMeterUI, triggerArgs )            
	elseif button.EnemyName == 'WorldUpgradeAltRunDoor'  then
		AddWorldUpgrade("WorldUpgradeAltRunDoor")
		AddWorldUpgrade("WorldUpgradeSurfacePenaltyCure")

	elseif button.EnemyName == '普通'  then
		RaritySet = 'Common'
	elseif button.EnemyName == '稀有'  then
		RaritySet = 'Rare'
	elseif button.EnemyName == '史诗'  then
		RaritySet = 'Epic'
	elseif button.EnemyName == '英雄'  then
		RaritySet = 'Heroic'
	elseif button.EnemyName == '传奇'  then
		RaritySet = 'Legendary'

	elseif button.EnemyName == 'OpenDebugEnemySpawnScreen'  then
		CloseScreen( GetAllIds( screen.Components ), 0, screen )
		OpenDebugEnemySpawnScreen()
	elseif button.EnemyName == '刷新祝福'  then
		ReloadAllTraits()
	elseif button.pageIndex == 4 then
		warningShowTest('创造祝福                                   ')
		CreateLoot({ Name = button.EnemyName, DestinationId = CurrentRun.Hero.ObjectId, OffsetX = math.random(-500,500), OffsetY = math.random(-500,500)}) 
	elseif button.EnemyName == '下一幕'  then
		ForceNextRoom = "G_Story01"

		-- Stomp any rooms already assigned to doors
		for doorId, door in pairs( MapState.OfferedExitDoors ) do
			local room = door.Room
			if room ~= nil then
				ForceNextEncounter = "Story_Narcissus_01"

				if ForceNextRoom ~= nil then
					DebugPrint({ Text = "ForceNextRoom = "..tostring(ForceNextRoom) })
				end

				local forcedRoomData = RoomData[ForceNextRoom]
				local forcedRoom = CreateRoom( forcedRoomData )
				AssignRoomToExitDoor( door, forcedRoom )
			end
		end
	elseif (button.pageIndex > 4 and button.pageIndex < 16) or (button.pageIndex == 20) then
		-- warningShowTest('添加祝福                                   '..button.RawText)
		-- warningShowTest('添加祝福                                   '..button.RawText)
		-- 添加祝福
		AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = button.EnemyName , Rarity = RaritySet } ) } )
	elseif button.pageIndex > 15 and button.pageIndex < 20  then
		-- 添加资源
		AddResource( button.EnemyName, 10, "RunStart" )
	-- elseif button.pageIndex == 20  then
	-- 	-- thread( KeepsakeLevelUpPresentation, button.EnemyName )
	-- 	warningShowTest('饰品                                   '..button.EnemyName)
	-- 	AdvanceKeepsake()
	end
	
	-- thread( DebugSpawnEnemy, screen, { Name = button.EnemyName, Active = true } )
	PlaySound({ Name = "/SFX/Menu Sounds/VictoryScreenBoonToggle", Id = button.Id })
	Flash({ Id = button.Id, Speed = 2, MinFraction = 0, MaxFraction = 0.8, Color = Color.Black, Duration = 0.1 })
end


-- 修改弹窗页面
function DebugSpawnEnemy( source, args )
	
	args = args or {}
	args.Name = args.Name

	SessionState.LastDebugSpawnEnemyArgs = args

	local enemyData = EnemyData[args.Name]
	local newEnemy = DeepCopyTable( enemyData )

	if newEnemy.IsUnitGroup then
		return SpawnUnitGroup( newEnemy, nil, nil)
	end

	if not args.Active then
		newEnemy.DisableAIWhenReady = true
	end

	if args.HealthBuffer ~= nil then
		newEnemy.HealthBuffer = args.HealthBuffer
	end
	newEnemy.BlocksLootInteraction = false

	local invaderSpawnPoint = nil
	if GetConfigOptionValue({ Name = "DebugEnemySpawnAtHero" }) and CurrentRun.Hero ~= nil then
		invaderSpawnPoint = CurrentRun.Hero.ObjectId
	else
		invaderSpawnPoint = args.SpawnPointId or SelectSpawnPoint( CurrentRun.CurrentRoom, newEnemy, {}, { CycleSpawnPoints = true } ) or CurrentRun.Hero.ObjectId
	end
	
	newEnemy.ObjectId = SpawnUnit({
			Name = enemyData.Name,
			Group = "Standing",
			DestinationId = invaderSpawnPoint, OffsetX = args.OffsetX, OffsetY = args.OffsetY })

	if GetConfigOptionValue({ Name = "DebugEnemySpawnIdle" }) then
		args.SkipAISetup = true
	end

	newEnemy.OccupyingSpawnPointId = invaderSpawnPoint
	SetupUnit( newEnemy, CurrentRun, args )

	if args.Health ~= nil then
		newEnemy.MaxHealth = args.Health
		newEnemy.Health = args.Health
	end

	if args.SkipAISetup then
		Track({ Ids = { newEnemy.ObjectId }, DestinationIds = { CurrentRun.Hero.ObjectId } })
	end

	return newEnemy
end


-- 弹窗参数
ScreenData.DebugCheatSpawn =
{
	Name = "DebugCheatSpawn",
	BlockPause = true,
	Components = {},
	
	ButtonsPerRow = 6,
	SpacingX = 280,
	SpacingY = 86,
	
	PagesPerRow = 7,
	PageStartX = 200,
	PageSpacingX = 240,
	PageSpacingY = 100,
	PageHighlightColor = { 0, 128, 128, 255 },
	
	FadeOutTime = 0.0,

	Pages =
	{
		{
			Name = "开启修改",
			Biomes = {},
			ManualEnemies =
			{
				"开启采集不需要工具",
				"开启必出混沌门",
				"开启无限Roll",
				"击杀加1%概率掉落祝福",
				-- "开启0元购",
				"不再出现资源房间",
				"本轮额外冲刺次数+1",
				"必定出英雄稀有度祝福",
				"金币+100",
				-- "最大生命+25",
				-- "最大法力+25",
				"给我恢复",
				"给我充能",
			},
		},
		{
			Name = "关闭修改",
			Biomes = {},
			ManualEnemies =
			{
				"关闭采集不需要工具",
				"关闭必出混沌门",
				"关闭无限Roll",
				"关闭击杀概率掉落祝福",
				-- "关闭0元购",
				"恢复出现资源房间",
				-- "额外冲刺次数归0",
				"不再必定出英雄稀有度祝福",
				-- "金币-100",
				-- "最大生命-25",
				-- "最大法力-25",
				"自杀",
				"法力倾泻",
			},
		},
		-- {
		-- 	Name = "稀有度",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"普通",
		-- 		"稀有",
		-- 		"史诗",
		-- 		"英雄",
		-- 		"传奇",
		-- 	},
		-- },
		-- {
		-- 	Name = "随机祝福",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "ApolloUpgrade", "DemeterUpgrade", "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade" 
		-- 	},
		-- },
		-- {
		-- 	Name = "ApolloUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"ApolloWeaponBoon",
		-- 		"ApolloSpecialBoon",
		-- 		"ApolloCastBoon",
		-- 		"ApolloSprintBoon",
		-- 		"ApolloManaBoon",

		-- 		"ApolloRetaliateBoon",
		-- 		"PerfectDamageBonusBoon",
		-- 		"BlindChanceBoon",
		-- 		"ApolloBlindBoon",
		-- 		"ApolloMissStrikeBoon",
		-- 		"ApolloCastAreaBoon",
		-- 		"DoubleStrikeChanceBoon",

		-- 		-- Legendary
		-- 		"DoubleExManaBoon",
				
		-- 		-- Elemental			
		-- 		"ElementalRallyBoon",
				
		-- 		-- Duos
		-- 		"ApolloSecondStageCastBoon",
		-- 		"RaiseDeadBoon",
		-- 		"PoseidonSplashSprintBoon",
		-- 		"CastRampBoon",
		-- 		"ManaBurstCountBoon",
		-- 		"CoverRegenerationBoonOld",
		-- 		"MassiveAoEIncrease",
		-- 	},
		-- },
		-- {
		-- 	Name = "ChaosBlessingFormat",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"ChaosWeaponBlessing", "ChaosSpecialBlessing", "ChaosCastBlessing", "ChaosHealthBlessing", 
		-- 	"ChaosRarityBlessing", "ChaosMoneyBlessing", "ChaosLastStandBlessing", "ChaosManaBlessing", 
		-- 	"ChaosManaOverTimeBlessing", 
		-- 	"ChaosWeaponBaseBlessing", "ChaosSpecialBaseBlessing",
		-- 	"ChaosExSpeedBlessing", "ChaosElementalBlessing", "ChaosManaCostBlessing",
		-- 	"ChaosSpeedBlessing", "ChaosDoorHealBlessing", "ChaosHarvestBlessing",
		-- 	"ChaosOmegaDamageBlessing","ChaosNoMoneyCurse", "ChaosHealthCurse", "ChaosHiddenRoomRewardCurse", 
		-- 	"ChaosDamageCurse", "ChaosPrimaryAttackCurse", "ChaosSecondaryAttackCurse",
		-- 	"ChaosDeathWeaponCurse", "ChaosSpeedCurse", "ChaosExAttackCurse",
		-- 	"ChaosCommonCurse", "ChaosCastCurse", "ChaosDashCurse", "ChaosManaFocusCurse",
		-- 	"ChaosRestrictBoonCurse", "ChaosStunCurse", "ChaosTimeCurse", "ChaosMetaUpgradeCurse"
		-- 	},
		-- },
		-- {
		-- 	Name = "DemeterUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"DemeterWeaponBoon",
		-- 	"DemeterSpecialBoon",
		-- 	"DemeterCastBoon",
		-- 	"DemeterSprintBoon",
		-- 	"DemeterManaBoon",
		-- 	"CastNovaBoon",
		-- 	"PlantHealthBoon",
		-- 	"BoonGrowthBoon",
		-- 	"ReserveManaHitShieldBoon",
		-- 	"SlowExAttackBoon",
		-- 	"CastAttachBoon",
		-- 	"RootDurationBoon",

		-- 	-- Legendary
		-- 	"InstantRootKill",

		-- 	-- Elemental
		-- 	"ElementalDamageCapBoon",

		-- 	-- Duos
		-- 	"EchoAllBoon",
		-- 	"KeepsakeLevelBoon",
		-- 	"GoodStuffBoon",
		-- 	"CastRampBoon",
		-- 	"MaxHealthDamageBoon",
		-- 	"DoubleBurnBoon",
		-- 	"ClearRootBoon",
		-- 	},
		-- },
		-- {
		-- 	Name = "AphroditeUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"AphroditeWeaponBoon",
		-- 		"AphroditeSpecialBoon",
		-- 		"AphroditeCastBoon",
		-- 		"AphroditeSprintBoon",
		-- 		"AphroditeManaBoon",

		-- 		"HighHealthOffenseBoon",
		-- 		"HealthRewardBonusBoon",
		-- 		"DoorHealToFullBoon",
		-- 		"WeakPotencyBoon",
		-- 		"WeakVulnerabilityBoon",
		-- 		"ManaBurstBoon",
		-- 		"FocusRawDamageBoon",

		-- 		-- Legendary
		-- 		"CharmCrowdBoon",

		-- 		-- Elemental
		-- 		"ElementalDodgeBoonOld",
				
		-- 		-- Duos
		-- 		"SprintEchoBoon",
		-- 		"MaximumShareBoon",
		-- 		"AllCloseBoon",
		-- 		"MaxHealthDamageBoon",
		-- 		"ManaBurstCountBoon",
		-- 		"ShadeMercFireballBoon",
		-- 		"FirstHitHealBoon",
				
		-- 	},
		-- },
		-- {
		-- 	Name = "HephaestusUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"HephaestusWeaponBoon",
		-- 	"HephaestusSpecialBoon",
		-- 	"HephaestusCastBoon",
		-- 	"HephaestusSprintBoon",
		-- 	"HephaestusManaBoon",

		-- 	"ChargeCounterBoon",
		-- 	"AntiArmorBoon",
		-- 	"HeavyArmorBoon",
		-- 	"ArmorBoon",
		-- 	"EncounterStartDefenseBuffBoon",
		-- 	"ManaToHealthBoon",
		-- 	"MassiveKnockupBoon",

		-- 	-- Legendary
		-- 	"WeaponUpgradeBoon",

		-- 	-- Elemental
		-- 	"ElementalDamageBoon",

		-- 	-- Duos
		-- 	"EmptySlotDamageBoon",
		-- 	"ReboundingSparkBoon",
		-- 	"MassiveCastBoon",
		-- 	"ClearRootBoon",
		-- 	"MassiveAoEIncrease",
		-- 	"FirstHitHealBoon",
		-- 	"DoubleMassiveAttackBoon",
				
		-- 	},
		-- },
		-- {
		-- 	Name = "HeraUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"HeraWeaponBoon",
		-- 	"HeraSpecialBoon",
		-- 	"HeraCastBoon",
		-- 	"HeraSprintBoon",
		-- 	"HeraManaBoon",
		-- 	"DamageShareRetaliateBoon",
		-- 	"SwapBonusBoon",
		-- 	"BoonDecayBoon",
		-- 	"DamageSharePotencyBoon",
		-- 	"LinkedDeathDamageBoon",
		-- 	"FullManaExBoostBoon",
		-- 	"CommonGlobalDamageBoon",

		-- 	-- Legendary
		-- 	"HeraManaShieldBoon",

		-- 	-- Elemental
		-- 	"ElementalRarityUpgradeBoon", 

		-- 	-- Duos
		-- 	"SuperSacrificeBoonHera",
		-- 	"MoneyDamageBoon",
		-- 	"KeepsakeLevelBoon",
		-- 	"RaiseDeadBoon",
		-- 	"MaximumShareBoon",
		-- 	"BurnOmegaBoon",
		-- 	"EmptySlotDamageBoon",
		-- 	},
		-- },
		-- {
		-- 	Name = "HermesUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 	"HermesWeaponBoon",
		-- 	"HermesSpecialBoon",
		-- 	"DodgeChanceBoon",
		-- 	"SorcerySpeedBoon",
		-- 	"HermesCastDiscountBoon",
		-- 	"ElementalUnifiedBoon",
		-- 	"SlowProjectileBoon",
		-- 	"HexCooldownBuffBoonOld",
		-- 	"MoneyMultiplierBoon",
		-- 	"TimedKillBuffBoon",
		-- 	"SprintShieldBoon",

		-- 	-- Legendary
		-- 	"TimeStopLastStandBoon",
		-- 	},
		-- },
		-- {
		-- 	Name = "HestiaUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"HestiaWeaponBoon",
		-- 	"HestiaSpecialBoon",
		-- 	"HestiaCastBoon",
		-- 	"HestiaSprintBoon",
		-- 	"HestiaManaBoon",
		-- 	"SacrificeBoon",
		-- 	"OmegaZeroBurnBoon",
		-- 	"CastProjectileBoon",
		-- 	"FireballManaSpecialBoon",
		-- 	"BurnExplodeBoon",
		-- 	"BurnConsumeBoon",
		-- 	"BurnArmorBoon",

		-- 	-- Legendary
		-- 	"BurnStackBoon",

		-- 	-- Elemental
		-- 	"ElementalBaseDamageBoon",

		-- 	-- Duos
		-- 	"EchoBurnBoon",
		-- 	"BurnOmegaBoon",
		-- 	"SteamBoon",
		-- 	"DoubleBurnBoon",
		-- 	"CoverRegenerationBoonOld",
		-- 	"ShadeMercFireballBoon",
		-- 	"DoubleMassiveAttackBoon",
		-- 	},
		-- },
		-- {
		-- 	Name = "PoseidonUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"PoseidonWeaponBoon",
		-- 	"PoseidonSpecialBoon",
		-- 	"PoseidonCastBoon",
		-- 	"PoseidonSprintBoon",
		-- 	"PoseidonManaBoon",
		-- 	"EncounterStartOffenseBuffBoon",
		-- 	"MinorLootBoon",
		-- 	"RoomRewardBonusBoon",
		-- 	"FocusDamageShaveBoon",
		-- 	"SlamExplosionBoon",
		-- 	"DoubleRewardBoon",
		-- 	"PoseidonStatusBoon",

		-- 	-- Legendary
		-- 	"AmplifyConeBoon",

		-- 	-- Elemental
		-- 	"ElementalHealthBoon",

		-- 	-- Duos
		-- 	"LightningVulnerabilityBoon",
		-- 	"MoneyDamageBoon",
		-- 	"GoodStuffBoon",
		-- 	"PoseidonSplashSprintBoon",
		-- 	"AllCloseBoon",
		-- 	"SteamBoon",
		-- 	"MassiveCastBoon",
		-- 	},
		-- },
		-- {
		-- 	Name = "ZeusUpgrade",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"ZeusWeaponBoon",
		-- 	"ZeusSpecialBoon",
		-- 	"ZeusCastBoon",
		-- 	"ZeusSprintBoon",
		-- 	"ZeusManaBoon",
		-- 	"ZeusManaBoltBoon",
		-- 	"BoltRetaliateBoon",
		-- 	"CastAnywhereBoon",
		-- 	"FocusLightningBoon",
		-- 	"DoubleBoltBoon",
		-- 	"EchoExpirationBoon",
		-- 	"LightningDebuffGeneratorBoon",

		-- 	-- Legendary
		-- 	"SpawnKillBoon",

		-- 	-- Elemental
		-- 	"ElementalDamageFloorBoon",

		-- 	-- Duos
		-- 	"SuperSacrificeBoonZeus",
		-- 	"LightningVulnerabilityBoon",
		-- 	"EchoAllBoon","ApolloSecondStageCastBoon",
		-- 	"SprintEchoBoon",
		-- 	"EchoBurnBoon",
		-- 	"ReboundingSparkBoon",
		-- 	},
		-- },
		
		-- {
		-- 	Name = "武器改造1",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
				
		-- 		"StaffDoubleAttackTrait", "StaffLongAttackTrait", "StaffDashAttackTrait", "StaffTripleShotTrait", "StaffJumpSpecialTrait", "StaffExAoETrait", "StaffAttackRecoveryTrait", "StaffFastSpecialTrait", "StaffExHealTrait", "StaffSecondStageTrait", "StaffPowershotTrait", "StaffOneWayAttackTrait",
		-- 		"DaggerBlinkAoETrait", "DaggerSpecialJumpTrait", "DaggerSpecialLineTrait", "DaggerRapidAttackTrait", "DaggerSpecialConsecutiveTrait", "DaggerBackstabTrait", "DaggerSpecialReturnTrait", "DaggerSpecialFanTrait", "DaggerAttackFinisherTrait", "DaggerFinalHitTrait", "DaggerChargeStageSkipTrait",
		-- 		"AxeSpinSpeedTrait", "AxeChargedSpecialTrait", "AxeAttackRecoveryTrait", "AxeMassiveThirdStrikeTrait", "AxeThirdStrikeTrait", "AxeRangedWhirlwindTrait", "AxeFreeSpinTrait", "AxeArmorTrait", "AxeConsecutiveStrikeTrait", "AxeBlockEmpowerTrait", "AxeSecondStageTrait", "AxeDashAttackTrait", "AxeSturdyTrait",
		-- 	},
		-- },
		-- {
		-- 	Name = "武器改造2",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
				
		-- 		"TorchExSpecialCountTrait", "TorchSpecialSpeedTrait", "TorchAttackSpeedTrait", "TorchSpecialLineTrait", "TorchSpecialImpactTrait", "TorchMoveSpeedTrait", "TorchSplitAttackTrait", "TorchEnhancedAttackTrait", "TorchDiscountExAttackTrait", "TorchLongevityTrait", "TorchOrbitPointTrait", --[["TorchSpinAttackTrait", ]]
		-- 		"LobAmmoTrait", "LobAmmoMagnetismTrait", "LobRushArmorTrait", "LobSpreadShotTrait", "LobSpecialSpeedTrait", "LobSturdySpecialTrait", "LobOneSideTrait", "LobInOutSpecialExTrait", "LobStraightShotTrait", "LobPulseAmmoTrait", "LobPulseAmmoCollectTrait", "LobGrowthTrait",
				
		-- 	},
		-- },
		-- -- {
		-- -- 	Name = "特殊调试",
		-- -- 	Biomes = {},
		-- -- 	ManualEnemies =
		-- -- 	{
		-- -- 		"下一幕",
		-- -- 		"WorldUpgradeAltRunDoor",
		-- -- 		-- "OpenDebugEnemySpawnScreen",
		-- -- 		"刷新祝福",
		-- -- 	},
		-- -- },

		-- {
		-- 	Name = "资源1",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"MetaCurrency", 
		-- 		"OreFSilver",
		-- 		"OreGLime",
		-- 		"OreHGlassrock",
		-- 		"OreIMarble",
		-- 		"OreNBronze",
		-- 		"OreOIron",
		-- 		"OreChaosProtoplasm",
		-- 		"MetaCardPointsCommon",
		-- 		"MemPointsCommon",
		-- 		"MixerFBoss",
		-- 		"MetaFabric",
		-- 		"MixerGBoss",
		-- 		"MixerHBoss",
		-- 		"MixerIBoss",
		-- 		"MixerNBoss",
		-- 		"CardUpgradePoints",
		-- 		"Mixer5Common",
		-- 		"MixerShadow",
		-- 		"Mixer6Common",
		-- 		"MixerMythic",
		-- 		"WeaponPointsRare",
		-- 		"CosmeticsPointsCommon",
		-- 		"CosmeticsPointsRare",
		-- 		"CosmeticsPointsEpic",

		-- 		"GiftPoints",
		-- 		"GiftPointsRare",
		-- 		"GiftPointsEpic",
		-- 		"SuperGiftPoints",
		-- 		"FamiliarPoints",

		-- 	},
		-- },

		-- {
		-- 	Name = "资源2",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
				
		-- 		"PlantFMoly",
		-- 		"PlantMoney",
		-- 		"PlantGLotus",
		-- 		"PlantHMyrtle",
		-- 		"PlantIShaderot",
		-- 		"PlantNMoss",
		-- 		"PlantODriftwood",
		-- 		"PlantFNightshadeSeed",
		-- 		"PlantFNightshade",
		-- 		"PlantGCattailSeed",
		-- 		"PlantGCattail",
		-- 		"PlantHWheatSeed",
		-- 		"PlantHWheat",
		-- 		"PlantIPoppySeed",
		-- 		"PlantIPoppy",
		-- 		"PlantNGarlicSeed",
		-- 		"PlantNGarlic",
		-- 		"PlantOMandrakeSeed",
		-- 		"PlantOMandrake",
		-- 		"PlantChaosThalamusSeed",
		-- 		"PlantChaosThalamus",
		-- 		"SeedMystery",
		-- 		"PlantGrowthAccelerant",
		-- 		"MixerOBoss",

				
		-- 	},
		-- },

		-- {
		-- 	Name = "资源3",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
				
		-- 		"FishFCommon",
		-- 		"FishFRare",
		-- 		"FishFLegendary",
		-- 		"FishGCommon",
		-- 		"FishGRare",
		-- 		"FishGLegendary",
		-- 		"FishHCommon",
		-- 		"FishHRare",
		-- 		"FishHLegendary",
		-- 		"FishICommon",
		-- 		"FishIRare",
		-- 		"FishILegendary",
		-- 		"FishNCommon",
		-- 		"FishNRare",
		-- 		"FishNLegendary",
		-- 		"FishOCommon",
		-- 		"FishORare",
		-- 		"FishOLegendary",
		-- 		"FishPCommon",
		-- 		"FishPRare",
		-- 		"FishPLegendary",
		-- 		"FishBCommon",
		-- 		"FishBRare",
		-- 		"FishBLegendary",
		-- 		"FishChaosCommon",
		-- 		"FishChaosRare",
		-- 		"FishChaosLegendary",

		-- 		"MysteryResource",
		-- 		"CharonPoints",
		-- 		"TrashPoints",

		-- 		"MetaPoints", 
		-- 		"Gems", 
		-- 		"LockKeys", 
		-- 		"SuperLockKeys", 
		-- 		"SuperGems",
		-- 	},
		-- },


		-- {
		-- 	Name = "NPC祝福",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
		-- 		"SupportingFireBoon", 
		-- 		"CritBonusBoon", 
		-- 		"DashOmegaBuffBoon", 
		-- 		"HighHealthCritBoon", 
		-- 		"InsideCastCritBoon",
		-- 		"OmegaCastVolleyBoon",
		-- 		"TimedCritVulnerabilityBoon",

		-- 		"EchoLastReward",
		-- 		"EchoLastRunBoon",
		-- 		"EchoDeathDefianceRefill",
		-- 		"DiminishingDodgeBoon",
		-- 		"DiminishingHealthAndManaBoon",


		-- 		"HadesLifestealBoon", "HadesCastProjectileBoon", "HadesPreDamageBoon", "HadesChronosDebuffBoon", "HadesInvisibilityRetaliateBoon", "HadesDeathDefianceDamageBoon",


		-- 		"FocusAttackDamageTrait",
		-- 		"FocusSpecialDamageTrait",
		-- 		"OmegaExplodeBoon",
		-- 		"CastHazardBoon",
		-- 		"BreakInvincibleArmorBoon",
		-- 		"BreakExplosiveArmorBoon",
		-- 		"SupplyDropBoon",
		-- 	},
		-- },

		-- {
		-- 	Name = "饰品升级",
		-- 	Biomes = {},
		-- 	ManualEnemies =
		-- 	{
				
		-- 		"ManaOverTimeRefundKeepsake",
		-- 		"BossPreDamageKeepsake",
		-- 		"DoorHealReserveKeepsake",
		-- 		"ReincarnationKeepsake",
		-- 		"DeathVengeanceKeepsake",
		-- 		"BlockDeathKeepsake",
		-- 		"EscalatingKeepsake",
		-- 		"SpellTalentKeepsake",
		-- 		"BonusMoneyKeepsake",
		-- 		"DamagedDamageBoostKeepsake",
		-- 		"RandomBlessingKeepsake",
		-- 		"ForceZeusBoonKeepsake",
		-- 		"ForceHeraBoonKeepsake",
		-- 		"ForcePoseidonBoonKeepsake",
		-- 		"ForceApolloBoonKeepsake",
		-- 		"ForceDemeterBoonKeepsake",
		-- 		"ForceAphroditeBoonKeepsake",
		-- 		"ForceHephaestusBoonKeepsake",
		-- 		"ForceHestiaBoonKeepsake",
		-- 		"TimedBuffKeepsake",
		-- 		"LowHealthCritKeepsake",
		-- 		"DecayingBoostKeepsake",
		-- 		"ArmorGainKeepsake",
		-- 		"FountainRarityKeepsake",
		-- 		"UnpickedBoonKeepsake",
		-- 		"BossMetaUpgradeKeepsake",
		-- 		"TempHammerKeepsake",
		-- 	},
		-- },

		


	},
	PageIds = {},

	GamepadNavigation =
	{
		FreeFormSelectWrapY = false,
		FreeFormSelectStepDistance = 8,
		FreeFormSelectSuccessDistanceStep = 1,
		FreeFormSelectRepeatDelay = 0.6,
		FreeFormSelectRepeatInterval = 0.1,
		FreeFormSelecSearchFromId = 0,
	},

	ComponentData =
	{
		DefaultGroup = "Combat_Menu_Overlay",
		BackgroundTint = 
		{
			Graphic = "rectangle01",
			GroupName = "Combat_Menu_Backing",
			Scale = 10,
			X = ScreenCenterX,
			Y = ScreenCenterY,
			Color = { 0.15, 0.15, 0.15, 0.85 },
			Children = 
			{
				TitleText = 
				{
					Text = "作弊菜单",
					TextArgs =
					{
						FontSize = 32,
						OffsetX = 0, OffsetY = -480,
						Color = Color.White,
						Font = "SpectralSCLightTitling",
						ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 3},
						Justification = "Center",
						FadeOpacity = 1.0,
					},
				},

				-- 切换菜单
				-- ToggleSpawnIdle =
				-- {
				-- 	Graphic = "ToggleButton",
				-- 	GroupName = "Combat_Menu_Overlay",
				-- 	Scale = 0.8,
				-- 	OffsetX = -900,
				-- 	OffsetY = -400,
				-- 	Text = "DebugEnemySpawnIdle",
				-- 	TextArgs =
				-- 	{
				-- 		FontSize = 24,
				-- 		OffsetX = 36, OffsetY = 0,
				-- 		Color = Color.White,
				-- 		Font = "LatoBold",
				-- 		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
				-- 		Justification = "Left",
				-- 		FadeOpacity = 1.0,
				-- 	},
				-- 	Data =
				-- 	{
				-- 		OnPressedFunctionName = "ToggleDebugEnemySpawnIdle",
				-- 	},
				-- },

				-- ToggleSpawnAtHero =
				-- {
				-- 	Graphic = "ToggleButton",
				-- 	GroupName = "Combat_Menu_Overlay",
				-- 	Scale = 0.8,
				-- 	OffsetX = -900,
				-- 	OffsetY = -340,
				-- 	Text = "DebugEnemySpawnAtHero",
				-- 	TextArgs =
				-- 	{
				-- 		FontSize = 24,
				-- 		OffsetX = 36, OffsetY = 0,
				-- 		Color = Color.White,
				-- 		Font = "LatoBold",
				-- 		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
				-- 		Justification = "Left",
				-- 		FadeOpacity = 1.0,
				-- 	},
				-- 	Data =
				-- 	{
				-- 		OnPressedFunctionName = "ToggleDebugEnemySpawnAtHero",
				-- 	},
				-- },

				CloseButton = 
				{
					Graphic = "ButtonClose",
					GroupName = "Combat_Menu_Overlay",
					Scale = 0.5,
					OffsetX = 900,
					OffsetY = 500,
					Data =
					{
						OnPressedFunctionName = "CloseScreenButton",
						ControlHotkeys = { "Cancel", },
					},
				},
			},
		},
	},
}


-- 开关按钮
function ToggleDebugEnemySpawnIdle( screen, button )
	if ToggleConfigOption( "DebugEnemySpawnIdle" ) then
		SetAnimation({ DestinationId = button.Id, Name = "GUI\\Shell\\settings_toggle_on" })
	else
		SetAnimation({ DestinationId = button.Id, Name = "GUI\\Shell\\settings_toggle_off" })
	end
end

function ToggleDebugEnemySpawnAtHero( screen, button )
	if ToggleConfigOption( "DebugEnemySpawnAtHero" ) then
		SetAnimation({ DestinationId = button.Id, Name = "GUI\\Shell\\settings_toggle_on" })
	else
		SetAnimation({ DestinationId = button.Id, Name = "GUI\\Shell\\settings_toggle_off" })
	end
end

-- 打开作弊菜单
function OpenDebugEnemyCheatScreen()

	local screen = DeepCopyTable( ScreenData.DebugCheatSpawn )

	if IsScreenOpen( screen.Name ) then
		return
	end
	OnScreenOpened( screen )
	CreateScreenFromData( screen, screen.ComponentData )

	local components = screen.Components
	
	local buttonLocationX = screen.PageStartX
	local buttonLocationY = 150

	SessionMapState.DebugEnemySpawnBiomeIndex = SessionMapState.DebugEnemySpawnBiomeIndex or 1

	for i, page in ipairs( screen.Pages ) do
		local pageButton = CreateScreenComponent({ Name = "DebugEnemySpawnButton",
			X = buttonLocationX,
			Y = buttonLocationY,
			Scale = 1.0,
			Sound = "/SFX/Menu Sounds/GeneralWhooshMENU",
			Group = "Combat_Menu" })
		pageButton.OnPressedFunctionName = "DebugEnemySpawnPageButton"
		pageButton.Page = page
		page.Index = i
		screen.Components["PageButton"..page.Name] = pageButton
		local pageTextColor = Color.White

		local currentBiome = false
		for biomeIndex, biomeName in ipairs( page.Biomes ) do
			if CurrentRun.CurrentRoom.RoomSetName == page.RoomSetName or stringends( biomeName, CurrentRun.CurrentRoom.RoomSetName ) then
				currentBiome = true
				break
			end
		end
		SetThingProperty({ Property = "AddColor", Value = "true", DestinationId = pageButton.Id })
		if currentBiome then
			SessionMapState.DebugEnemySpawnBiomeIndex = i
			TeleportCursor({ DestinationId = pageButton.Id, ForceUseCheck = true })
			SetColor({ Id = pageButton.Id, Color = screen.PageHighlightColor })
		else
			SetColor({ Id = pageButton.Id, Color = Color.Black })
		end

		if page.Index < 5 then 
			CreateTextBox({ Id = pageButton.Id,
				RawText = page.Name,
				FontSize = 24,
				Color = pageTextColor,
				Font = "LatoBold",
				ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
				Justification = "Center",
				FadeOpacity = 1.0,
			})
		else 
			CreateTextBox({ Id = pageButton.Id,
				Text = page.Name,
				FontSize = 24,
				Color = Color.Yellow,
				Font = "LatoBold",
				ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
				Justification = "Center",
				FadeOpacity = 1.0,
			})
			-- CreateTextBox({ Id = pageButton.Id,
			-- 	Text = page.Name,
			-- 	FontSize = 20,
			-- 	OffsetX = 0,
			-- 	OffsetY = 30,
			-- 	Color = Color.Yellow,
			-- 	Font = "LatoMedium",
			-- 	ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
			-- 	Justification = "Center"
			-- })
		end
		if i % screen.PagesPerRow == 0 then
			buttonLocationY = buttonLocationY + screen.PageSpacingY
			buttonLocationX = screen.PageStartX
		else
			buttonLocationX = buttonLocationX + screen.PageSpacingX
		end
	end
	CreateDebugEnemySpawnPage( screen, screen.Pages[SessionMapState.DebugEnemySpawnBiomeIndex] )

	-- if GetConfigOptionValue({ Name = "DebugEnemySpawnIdle" }) then
	-- 	SetAnimation({ DestinationId = components.ToggleSpawnIdle.Id, Name = "GUI\\Shell\\settings_toggle_on" })
	-- else
	-- 	SetAnimation({ DestinationId = components.ToggleSpawnIdle.Id, Name = "GUI\\Shell\\settings_toggle_off" })
	-- end
	-- if GetConfigOptionValue({ Name = "DebugEnemySpawnAtHero" }) then
	-- 	SetAnimation({ DestinationId = components.ToggleSpawnAtHero.Id, Name = "GUI\\Shell\\settings_toggle_on" })
	-- else
	-- 	SetAnimation({ DestinationId = components.ToggleSpawnAtHero.Id, Name = "GUI\\Shell\\settings_toggle_off" })
	-- end

	screen.KeepOpen = true
	-- thread( HandleWASDInput, screen )
	HandleScreenInput( screen )
	return screen
end

-- 分页按钮
function DebugEnemySpawnPageButton( screen, button )
	PlaySound({ Name = "/SFX/Menu Sounds/VictoryScreenBoonToggle", Id = button.Id })
	--Flash({ Id = button.Id, Speed = 2, MinFraction = 0, MaxFraction = 0.8, Color = Color.Black, Duration = 0.1 })
	for i, page in ipairs( screen.Pages ) do
		local buttonId = screen.Components["PageButton"..page.Name].Id
		SetColor({ Id = buttonId, Color = Color.Black })
	end
	SetColor({ Id = button.Id, Color = screen.PageHighlightColor })
	CreateDebugEnemySpawnPage( screen, button.Page )
end

-- 页面中的内容
function CreateDebugEnemySpawnPage( screen, page )

	Destroy({ Ids = screen.PageIds })
	screen.PageIds = {}
	SessionMapState.DebugEnemySpawnBiomeIndex = page.Index

	local buttonLocationY = 500

	local biomeName = GetFirstValue( page.Biomes ) or ""
	local currentBiome = false
	if biomeName ~= nil and stringends( biomeName, CurrentRun.CurrentRoom.RoomSetName ) then
		currentBiome = true
	end

	local buttonLocationX = 110
	local buttonStartX = buttonLocationX + 150
	buttonLocationX = buttonStartX

	local dedupedEnemies = {}
	if EnemySets[biomeName] ~= nil then
		for enemyIndex, enemyName in ipairs( EnemySets[biomeName] ) do
			if not Contains( dedupedEnemies, enemyName ) then
				table.insert( dedupedEnemies, enemyName )
			end
		end
	end
	if page.ManualEnemies ~= nil then
		for enemyIndex, enemyName in ipairs( page.ManualEnemies ) do
			table.insert( dedupedEnemies, enemyName )
		end
	end

	for enemyIndex, enemyName in ipairs( dedupedEnemies ) do
		local spawnButton = CreateScreenComponent({ Name = "DebugEnemySpawnButton",
			X = buttonLocationX,
			Y = buttonLocationY,
			Scale = 1.0, Sound = "/SFX/Menu Sounds/GeneralWhooshMENU", Group = "Combat_Menu" })
		screen.Components["Spawn"..biomeName..enemyIndex..enemyName] = spawnButton
		table.insert( screen.PageIds, spawnButton.Id )
		spawnButton.OnPressedFunctionName = "DebugEnemySpawnButton"
		spawnButton.EnemyName = enemyName
		spawnButton.pageIndex = page.Index
		local enemyNameCodex = GetDisplayName({ Text = enemyName })
		if page.Index < 4 then 
			CreateTextBox({ Id = spawnButton.Id,
				RawText = enemyName,
				FontSize = 20,
				OffsetY = -10,
				Color = Color.White,
				Font = "LatoMedium",
				ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
				Justification = "Center",
				FadeOpacity = 1.0,
			})
		else
			CreateTextBox({ Id = spawnButton.Id,
				Text = enemyName,
				FontSize = 20,
				OffsetY = -10,
				Color = Color.Yellow,
				Font = "LatoMedium",
				ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
				Justification = "Center",
				FadeOpacity = 1.0,
			})
			-- CreateTextBox({ Id = spawnButton.Id,
			-- 	Text = enemyName,
			-- 	FontSize = 20,
			-- 	OffsetY = 26,
			-- 	Color = Color.Yellow,
			-- 	Font = "LatoMedium",
			-- 	Justification = "Center",
			-- 	FadeOpacity = 1.0,
			-- })
		end
		if enemyIndex % screen.ButtonsPerRow == 0 then
			buttonLocationX = buttonStartX
			buttonLocationY = buttonLocationY + screen.SpacingY
		else
			buttonLocationX = buttonLocationX + screen.SpacingX
		end
	end

end

