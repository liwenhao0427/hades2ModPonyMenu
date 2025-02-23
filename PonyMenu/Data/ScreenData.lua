local mod = PonyMenu

if not mod.Config.Enabled then return end

function mod.setupScreenData()
	ModUtil.Table.Merge(ScreenData, {
		BoonSelector = {
			Components = {},
			OpenSound = "/SFX/Menu Sounds/HadesLocationTextAppear",
			Name = "BoonSelector",
			Rarity = "Common",
			RowStartX = -(ScreenCenterX * 0.65),
			RowStartY = -(ScreenCenterY * 0.5),
			ComponentData =
			{
				DefaultGroup = "Combat_Menu_TraitTray_Backing",
				UseNativeScreenCenter = true,

				BackgroundTint =
				{
					Graphic = "rectangle01",
					GroupName = "Combat_Menu_TraitTray_Backing",
					Scale = 10,
					X = ScreenCenterX,
					Y = ScreenCenterY,
				},

				Background =
				{
					AnimationName = "Box_FullScreen",
					GroupName = "Combat_Menu_TraitTray",
					X = ScreenCenterX,
					Y = ScreenCenterY,
					Scale = 1.15,
					Text = mod.Locale.BoonSelectorTitle,
					TextArgs =
					{
						FontSize = 32,
						Width = 750,
						OffsetY = -(ScreenCenterY * 0.825),
						Color = Color.White,
						Font = "P22UndergroundSCHeavy",
						ShadowBlur = 0,
						ShadowColor = { 0, 0, 0, 0 },
						ShadowOffset = { 0, 3 },
					},

					Children =
					{
						SpawnButton =
						{
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.2,
							ScaleX = 1.15,
							OffsetX = 0,
							OffsetY = 420,
							Text = mod.Locale.BoonSelectorSpawnButton,
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.SpawnBoon,
							},
						},
						--Rarity buttons
						CommonButton =
						{
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.2,
							ScaleX = 0.8,
							OffsetX = -650,
							OffsetY = 480,
							Text = mod.Locale.BoonSelectorCommonButton,
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.BoonPatchCommon,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeBoonSelectorRarity,
								Rarity = "Common",
							},
						},
						RareButton =
						{
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.2,
							ScaleX = 0.8,
							OffsetX = -350,
							OffsetY = 480,
							Text = mod.Locale.BoonSelectorRareButton,
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.BoonPatchRare,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeBoonSelectorRarity,
								Rarity = "Rare",
							},
						},
						EpicButton =
						{
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.2,
							ScaleX = 0.8,
							OffsetX = 350,
							OffsetY = 480,
							Text = mod.Locale.BoonSelectorEpicButton,
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.BoonPatchEpic,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeBoonSelectorRarity,
								Rarity = "Epic",
							},
						},
						HeroicButton =
						{
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.2,
							ScaleX = 0.8,
							OffsetX = 650,
							OffsetY = 480,
							Text = mod.Locale.BoonSelectorHeroicButton,
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.BoonPatchHeroic,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeBoonSelectorRarity,
								Rarity = "Heroic",
							},
						},
						CloseButton =
						{
							Graphic = "ButtonClose",
							GroupName = "Combat_Menu_TraitTray",
							Scale = 0.7,
							OffsetX = 0,
							OffsetY = 510,
							Data =
							{
								OnPressedFunctionName = mod.CloseBoonSelector,
								ControlHotkeys = { "Cancel", },
							},
						},
					}
				},
			}
		},

		ResourceMenu = {
			Components = {},
			OpenSound = "/SFX/Menu Sounds/HadesLocationTextAppear",
			Name = "ResourceMenu",
			Rarity = "None",
			Amount = 0,
			RowStartX = -(ScreenCenterX * 0.65),
			RowStartY = -(ScreenCenterY * 0.5),
			ComponentData =
			{
				DefaultGroup = "Combat_Menu_TraitTray_Backing",
				UseNativeScreenCenter = true,

				BackgroundTint =
				{
					Graphic = "rectangle01",
					GroupName = "Combat_Menu_TraitTray_Backing",
					Scale = 10,
					X = ScreenCenterX,
					Y = ScreenCenterY,
				},

				Background =
				{
					AnimationName = "Box_FullScreen",
					GroupName = "Combat_Menu_TraitTray",
					X = ScreenCenterX,
					Y = ScreenCenterY,
					Scale = 1.15,
					Text = mod.Locale.ResourceMenuTitle,
					TextArgs =
					{
						FontSize = 32,
						Width = 750,
						OffsetY = -(ScreenCenterY * 0.825),
						Color = Color.White,
						Font = "P22UndergroundSCHeavy",
						ShadowBlur = 0,
						ShadowColor = { 0, 0, 0, 0 },
						ShadowOffset = { 0, 3 },
					},

					Children =
					{
						-- Amount Buttons
						IncreaseButton1 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = -420,
							OffsetY = 260,
							Text = "+1",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = 1
							},
						},
						IncreaseButton2 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = -150,
							OffsetY = 260,
							Text = "+10",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = 10
							},
						},
						IncreaseButton3 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = 120,
							OffsetY = 260,
							Text = "+100",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = 100
							},
						},
						IncreaseButton4 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = 390,
							OffsetY = 260,
							Text = "+1000",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = 1000
							},
						},

						DecreaseButton1 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = -420,
							OffsetY = 330,
							Text = "-1",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = -1
							},
						},
						DecreaseButton2 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = -150,
							OffsetY = 330,
							Text = "-10",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = -10
							},
						},
						DecreaseButton3 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = 120,
							OffsetY = 330,
							Text = "-100",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = -100
							},
						},
						DecreaseButton4 = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.0,
							ScaleX = 0.8,
							OffsetX = 390,
							OffsetY = 330,
							Text = "-1000",
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.ChangeTargetResourceAmount,
								Amount = -1000
							},
						},
						-- Spawn button
						SpawnButton = {
							Name = "ButtonDefault",
							Group = "Combat_Menu_TraitTray",
							Scale = 1.2,
							ScaleX = 1.15,
							OffsetX = -20,
							OffsetY = 450,
							Text = mod.Locale.ResourceMenuSpawnButton,
							TextArgs =
							{
								FontSize = 22,
								Width = 720,
								Color = Color.White,
								Font = "P22UndergroundSCMedium",
								ShadowBlur = 0,
								ShadowColor = { 0, 0, 0, 1 },
								ShadowOffset = { 0, 2 },
								Justification = "Center"
							},
							Data = {
								OnPressedFunctionName = mod.SpawnResource,
							},
						},
						CloseButton =
						{
							Graphic = "ButtonClose",
							GroupName = "Combat_Menu_TraitTray",
							Scale = 0.7,
							OffsetX = 0,
							OffsetY = 510,
							Data =
							{
								OnPressedFunctionName = mod.CloseBoonSelector,
								ControlHotkeys = { "Cancel", },
							},
						},
					}
				},
			}
		},

		BossSelector = {
			Components = {},
			OpenSound = "/SFX/Menu Sounds/HadesLocationTextAppear",
			Name = "BossSelector",
			RowStartX = 200,
			RowStartY = ScreenCenterY,
			IncrementX = 190,
			ItemOrder = {
				"F_Boss01",
				"G_Boss01",
				"H_Boss01",
				"I_Boss01",
				"N_Boss01",
				"O_Boss01",
			},
			BossData = {
				F_Boss01 = {
					Name = "Hecate_Full",
					Portrait = "Codex_Portrait_Hecate",
				},
				G_Boss01 = {
					Name = "Scylla_Full",
					Portrait = "Codex_Portrait_Scylla",
				},
				H_Boss01 = {
					Name = "InfestedCerberus_Named",
					Portrait = "Codex_Portrait_Cerberus",
				},
				I_Boss01 = {
					Name = "Chronos_Full",
					Portrait = "Codex_Portrait_Chronos",
				},
				N_Boss01 = {
					Name = "Cyclops_Full",
					Portrait = "Codex_Portrait_Polyphemus",
				},
				O_Boss01 = {
					Name = "Eris_Full",
					Portrait = "Codex_Portrait_Eris",
				},
			},
			TitleText =
			{
				FontSize = 21,
				Font = "P22UndergroundSCMedium",
				ShadowBlur = 0,
				ShadowColor = { 0, 0, 0, 1 },
				ShadowOffset = { 0, 2 },
				Justification = "Center",
				Group = "Combat_Menu_TraitTray",
				OffsetY = 150
			},

			ComponentData =
			{
				DefaultGroup = "Combat_Menu_TraitTray",
				UseNativeScreenCenter = true,
				Order = {
					"BackgroundTint",
					"Background"
				},

				BackgroundTint =
				{
					Graphic = "rectangle01",
					GroupName = "Combat_Menu",
					Scale = 10,
					X = ScreenCenterX,
					Y = ScreenCenterY,
				},

				Background =
				{
					AnimationName = "Box_FullScreen",
					GroupName = "Combat_Menu",
					X = ScreenCenterX,
					Y = ScreenCenterY,
					Scale = 1.15,
					Text = mod.Locale.BossSelectorTitle,
					TextArgs =
					{
						FontSize = 32,
						Width = 750,
						OffsetY = -(ScreenCenterY * 0.825),
						Color = Color.White,
						Font = "P22UndergroundSCHeavy",
						ShadowBlur = 0,
						ShadowColor = { 0, 0, 0, 0 },
						ShadowOffset = { 0, 3 },
					},

					Children =
					{
						CloseButton =
						{
							Graphic = "ButtonClose",
							GroupName = "Combat_Menu_TraitTray",
							Scale = 0.7,
							OffsetX = 0,
							OffsetY = ScreenCenterY - 70,
							Data =
							{
								OnPressedFunctionName = "PonyMenu.CloseBossSelectScreen",
								ControlHotkeys = { "Cancel", },
							},
						},
					}
				},
			}
		},

		ConsumableSelector = {
			Components = {},
			OpenSound = "/SFX/Menu Sounds/HadesLocationTextAppear",
			Name = "ConsumableSelector",
			RowStartX = -(ScreenCenterX * 0.65),
			RowStartY = -(ScreenCenterY * 0.5),

			ComponentData =
			{
				DefaultGroup = "Combat_Menu_TraitTray",
				UseNativeScreenCenter = true,
				Order = {
					"BackgroundTint",
					"Background"
				},

				BackgroundTint =
				{
					Graphic = "rectangle01",
					GroupName = "Combat_Menu",
					Scale = 10,
					X = ScreenCenterX,
					Y = ScreenCenterY,
				},

				Background =
				{
					AnimationName = "Box_FullScreen",
					GroupName = "Combat_Menu",
					X = ScreenCenterX,
					Y = ScreenCenterY,
					Scale = 1.15,
					Text = mod.Locale.ConsumableSelectorTitle,
					TextArgs =
					{
						FontSize = 32,
						Width = 750,
						OffsetY = -(ScreenCenterY * 0.825),
						Color = Color.White,
						Font = "P22UndergroundSCHeavy",
						ShadowBlur = 0,
						ShadowColor = { 0, 0, 0, 0 },
						ShadowOffset = { 0, 3 },
					},

					Children =
					{
						CloseButton =
						{
							Graphic = "ButtonClose",
							GroupName = "Combat_Menu_TraitTray",
							Scale = 0.7,
							OffsetX = 0,
							OffsetY = ScreenCenterY - 70,
							Data =
							{
								OnPressedFunctionName = "PonyMenu.CloseConsumableSelector",
								ControlHotkeys = { "Cancel", },
							},
						},
					}
				},
			}
		}
	})
end

function mod.setupCommandData()
	mod.CommandData = {
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Zeus",
			IconScale = 0.4,
			Name = "ZeusUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Poseidon",
			IconScale = 0.4,
			Name = "PoseidonUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Aphrodite",
			IconScale = 0.4,
			Name = "AphroditeUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Ares",
			IconScale = 0.4,
			Name = "AresUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Apollo",
			IconScale = 0.4,
			Name = "ApolloUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Demeter",
			IconScale = 0.4,
			Name = "DemeterUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Hephaestus",
			IconScale = 0.4,
			Name = "HephaestusUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Hestia",
			IconScale = 0.4,
			Name = "HestiaUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Artemis",
			IconScale = 0.4,
			Name = "ArtemisUpgrade",
			Type = "Boon",
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Hermes",
			IconScale = 0.4,
			Name = "HermesUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Hera",
			IconScale = 0.4,
			Name = "HeraUpgrade",
			Type = "Boon"
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Chaos",
			IconScale = 0.4,
			Name = "TrialUpgrade",
			Type = "Boon"
		},
		{
			Icon = "SpellDropPreview",
			IconScale = 0.6,
			Name = "SpellDrop",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			Icon = "WeaponUpgradeSymbol",
			IconScale = 0.6,
			Name = "WeaponUpgrade",
			Type = "Boon",
			NoRarity = true
		},
		{
			Icon = "ArmorBoost",
			IconScale = 0.6,
			Name = "NPC_Arachne_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Icons\\GhostEmote\\Smile",
			IconScale = 0.6,
			Name = "NPC_Narcissus_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Icons\\GhostEmote\\Grief",
			IconScale = 0.6,
			Name = "NPC_Echo_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Hades",
			IconScale = 0.4,
			Name = "NPC_LordHades_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Icons\\Mana",
			IconScale = 1.0,
			Name = "NPC_Medea_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Icons\\Attributes\\Timeless",
			IconScale = 0.7,
			Name = "NPC_Icarus_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Icons\\ManaCrystal",
			IconScale = 1.0,
			Name = "NPC_Circe_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Athena",
			IconScale = 0.4,
			Name = "NPC_Athena_01",
			Type = "Boon",
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Screens\\BoonSelectSymbols\\Dionysus",
			IconScale = 0.4,
			Name = "NPC_Dionysus_01",
			Type = "Boon",
			NoSpawn = true
		},
		{
			IconPath = "GUI\\Icons\\Hades_Symbol_01",
			IconScale = 0.4,
			Name = "NPC_LordHades_01",
			Type = "Boon",
			NoRarity = true,
			NoSpawn = true
		},
		{
			Icon = "TrashButtonFlash",
			IconScale = 0.6,
			Name = mod.Locale.ClearAllBoons,
			Description = mod.Locale.ClearAllBoonsDescription,
			Type = "Command",
			Function = "PonyMenu.ClearAllBoons"
		},
		{
			Icon = "CharonPointsDrop",
			IconScale = 0.6,
			Name = mod.Locale.BoonManagerTitle,
			Description = mod.Locale.BoonManagerDescription,
			Type = "Command",
			Function = "PonyMenu.OpenBoonManager"
		},
		{
			IconPath = "GUI\\Screens\\Inventory\\Icon-Resources",
			IconScale = 0.6,
			Name = mod.Locale.ResourceMenuTitle,
			Description = mod.Locale.ResourceMenuDescription,
			Type = "Command",
			Function = "PonyMenu.OpenResourceMenu"
		},
		{
			Icon = "GUI\\HUD\\Badges\\UI_PlayerBadge_Warden_Delta",
			IconScale = 0.3,
			Name = '修改选项',
			Description = '开启一些功能修改',
			Type = "Command",
			Function = "openCheatScreen"
		},
		{
			Icon = "TrashButtonFlash",
			IconScale = 0.6,
			Name = mod.Locale.ClearAllBoons,
			Description = mod.Locale.ClearAllBoonsDescription,
			Type = "Command",
			Function = "PonyMenu.ClearAllBoons"
		},
		{
			Icon = "CharonPointsDrop",
			IconScale = 0.6,
			Name = mod.Locale.BoonManagerTitle,
			Description = mod.Locale.BoonManagerDescription,
			Type = "Command",
			Function = "PonyMenu.OpenBoonManager"
		},
		{
			IconPath = "GUI\\Screens\\Inventory\\Icon-Resources",
			IconScale = 0.6,
			Name = mod.Locale.ResourceMenuTitle,
			Description = mod.Locale.ResourceMenuDescription,
			Type = "Command",
			Function = "PonyMenu.OpenResourceMenu"
		},
		{
			IconPath = "Items\\Loot\\MaxHealthDrop_Preview",
			IconScale = 0.3,
			Name = mod.Locale.ConsumableSelectorTitle,
			Description = mod.Locale.ConsumableSelectorDescription,
			Type = "Command",
			Function = "PonyMenu.OpenConsumableSelector"
		},
		{
			IconPath = "GUI\\Icons\\Boss",
			IconScale = 0.6,
			Name = mod.Locale.BossSelectorTitle,
			Description = mod.Locale.BossSelectorDescription,
			Type = "Command",
			Function = "PonyMenu.OpenBossSelector"
		},
		{
			IconPath = "GUI\\Icons\\NoCanDo",
			IconScale = 0.6,
			Name = mod.Locale.KillPlayerTitle,
			Description = mod.Locale.KillPlayerDescription,
			Type = "Command",
			Function = "PonyMenu.KillPlayer"
		},
		{
			IconPath = "GUI\\Shell\\CloudSyncConflict",
			IconScale = 0.6,
			Name = mod.Locale.SaveStateTitle,
			Description = mod.Locale.SaveStateDescription,
			Type = "Command",
			Function = "PonyMenu.SaveState"
		},
		{
			IconPath = "GUI\\Shell\\CloudSuccess",
			IconScale = 0.6,
			Name = mod.Locale.LoadStateTitle,
			Description = mod.Locale.LoadStateDescription,
			Type = "Command",
			Function = "PonyMenu.LoadState"
		},
	}
end

mod.Internal = ModUtil.UpValues(function()
	return mod.setupScreenData, mod.setupCommandData
end)

mod.setupCommandData()
mod.setupScreenData()
