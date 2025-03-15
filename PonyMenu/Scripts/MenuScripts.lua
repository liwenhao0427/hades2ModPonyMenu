local mod = PonyMenu

if not mod.Config.Enabled then return end

--#region BOON SELECTOR

function mod.OpenBoonSelector(screen, button)
	if IsScreenOpen("BoonSelector") then
		return
	end
	mod.UpdateScreenData()
	CloseInventoryScreen(screen, screen.ComponentData.ActionBar.Children.CloseButton)

	screen = DeepCopyTable(ScreenData.BoonSelector)
	screen.Upgrade = button.ItemData.Name
	screen.FirstPage = 0
	screen.LastPage = 0
	screen.CurrentPage = screen.FirstPage

	if screen.Upgrade == "WeaponUpgrade" then
		mod.BoonData.WeaponUpgrade = {}
		mod.PopulateBoonData("WeaponUpgrade")
	end

	if screen.Upgrade == "DiyTraitData" then
		mod.BoonData.DiyTraitData = {}
		mod.PopulateBoonData("DiyTraitData")
	end

	local itemData = button.ItemData
	local components = screen.Components
	local children = screen.ComponentData.Background.Children
	local boons = mod.BoonData[itemData.Name]
	local lColor = mod.GetLootColor(itemData.Name) or Color.White
	if itemData.NoRarity then
		children.CommonButton = nil
		children.RareButton = nil
		children.EpicButton = nil
		children.HeroicButton = nil
	end
	if itemData.NoSpawn then
		children.SpawnButton = nil
	end

	OnScreenOpened(screen)
	CreateScreenFromData(screen, screen.ComponentData)
	-- Boon buttons

	local displayedTraits = {}
	local index = 0
	screen.BoonsList = {}
	local rowOffset = 180
	local columnOffset = 900
	local boonsPerRow = 2
	local rowsPerPage = 4
	local rowoffsetX = -450
	local rowoffsetY = -250
	for i, boon in ipairs(boons) do
		if not Contains(displayedTraits, boon) and not HeroHasTrait(boon) then
			table.insert(displayedTraits, boon)
			local rowIndex = math.floor(index / boonsPerRow)
			local pageIndex = math.floor(rowIndex / rowsPerPage)
			local offsetX = rowoffsetX + columnOffset * (index % boonsPerRow)
			local offsetY = rowoffsetY + rowOffset * (rowIndex % rowsPerPage)
			index = index + 1
			screen.LastPage = pageIndex
			if screen.BoonsList[pageIndex] == nil then
				screen.BoonsList[pageIndex] = {}
			end
			local boonData = TraitData[boon]
			table.insert(screen.BoonsList[pageIndex], {
				index = index,
				Boon = boon,
				BoonData = boonData,
				pageIndex = pageIndex,
				offsetX = offsetX,
				offsetY = offsetY,
			})
		end
	end
	mod.BoonSelectorLoadPage(screen)
	--
	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	wait(0.3)

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
end

function mod.CloseBoonSelector(screen)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters("BoonSelector")
end

function mod.SpawnBoon(screen, button)
	CreateLoot({ Name = screen.Upgrade, OffsetX = 100, SpawnPoint = CurrentRun.Hero.ObjectId })
	mod.CloseBoonSelector(screen)
end

function mod.ChangeBoonSelectorRarity(screen, button)
	if screen.LockedRarityButton ~= nil and screen.LockedRarityButton ~= button then
		ModifyTextBox({ Id = screen.LockedRarityButton.Id, Text = screen.LockedRarityButton.Rarity })
	end
	screen.Rarity = button.Rarity
	screen.LockedRarityButton = button
	ModifyTextBox({ Id = button.Id, Text = ">>" .. button.Rarity .. "<<" })
end

function mod.GiveBoonToPlayer(screen, button)
	local boon = button.Boon
	if not HeroHasTrait(boon) then
		AddTraitToHero({
			TraitData = GetProcessedTraitData({
				Unit = CurrentRun.Hero,
				TraitName = boon,
				Rarity = screen.Rarity
			}),
			SkipNewTraitHighlight = true,
			SkipQuestStatusCheck = true,
			SkipActivatedTraitUpdate = true,
		})
		screen.BoonsList[screen.CurrentPage][button.Index] = nil
		local ids = { button.Id }
		if button.Icon then
			table.insert(ids, button.Icon.Id)
		end
		if button.ElementIcon then
			table.insert(ids, button.ElementIcon.Id)
		end
		Destroy({ Ids = ids })
	end
end

function mod.BoonSelectorLoadPage(screen)
	mod.BoonManagerPageButtons(screen, screen.Name)
	local displayedTraits = {}
	local pageBoons = screen.BoonsList[screen.CurrentPage]
	if pageBoons then
		local components = screen.Components
		for i, boon in pairs(pageBoons) do
			if displayedTraits[boon] then
				--Skip
			else
				local boonData = boon.BoonData
				displayedTraits[boonData.Name] = true
				local color = mod.GetLootColorFromTrait(boonData.Name)
				if boonData.Rarity == nil or boonData.Rarity == "Common" then
					local tdata = TraitData[boonData.Name]
					if tdata.RarityLevels and tdata.RarityLevels.Legendary then
						boonData.Rarity = "Legendary"
					elseif tdata.IsDuoBoon then
						boonData.Rarity = "Duo"
					else
						boonData.Rarity = "Common"
					end
				end
				local screendata = DeepCopyTable(ScreenData.UpgradeChoice)
				local upgradeName = boonData.Name
				local upgradeData = nil
				local upgradeTitle = nil
				local upgradeDescription = nil
				local tooltipData = nil
				upgradeData = GetProcessedTraitData({
					Unit = CurrentRun.Hero,
					TraitName = boonData.Name,
					Rarity = boonData.Rarity
				})
				upgradeTitle = GetTraitTooltipTitle(TraitData[boonData.Name])
				upgradeData.Title = GetTraitTooltipTitle(TraitData[boonData.Name])
				tooltipData = upgradeData
				SetTraitTextData(tooltipData)
				upgradeDescription = GetTraitTooltip(tooltipData, { Default = upgradeData.Title })

				-- Setting button graphic based on boon type
				local purchaseButtonKey = "PurchaseButton" .. boon.index
				local purchaseButton = {
					Name = "ButtonDefault",
					OffsetX = boon.offsetX,
					OffsetY = boon.offsetY,
					Group = "Combat_Menu_TraitTray",
					Color = color,
					ScaleX = 3.2,
					ScaleY = 2.2,
					ToDestroy = true
				}
				components[purchaseButtonKey] = CreateScreenComponent(purchaseButton)
				if upgradeData.Icon ~= nil then
					local icon = screendata.Icon
					icon.Animation = upgradeData.Icon
					icon.Scale = 0.25
					icon.Group = "Combat_Menu_TraitTray"
					icon.ToDestroy = true
					components[purchaseButtonKey .. "Icon"] = CreateScreenComponent(icon)
					components[purchaseButtonKey].Icon = components[purchaseButtonKey .. "Icon"]
				end
				if not IsEmpty(upgradeData.Elements) then
					local elementName = GetFirstValue(upgradeData.Elements)
					local elementIcon = screendata.ElementIcon
					elementIcon.Name = TraitElementData[elementName].Icon
					elementIcon.Scale = 0.5
					elementIcon.Group = "Combat_Menu_TraitTray"
					elementIcon.ToDestroy = true
					components[purchaseButtonKey .. "ElementIcon"] = CreateScreenComponent(elementIcon)
					components[purchaseButtonKey].ElementIcon = components[purchaseButtonKey .. "ElementIcon"]
					if not GameState.Flags.SeenElementalIcons then
						SetAlpha({ Id = components[purchaseButtonKey .. "ElementIcon"].Id, Fraction = 0, Duration = 0 })
					end
				end

				-- Button data setup
				local button = components[purchaseButtonKey]
				button.OnPressedFunctionName = mod.GiveBoonToPlayer
				button.Boon = boonData.Name
				button.Index = boon.index
				button.OnMouseOverFunctionName = mod.MouseOverBoonButton
				button.OnMouseOffFunctionName = mod.MouseOffBoonButton
				button.Data = upgradeData
				button.Screen = screen
				button.UpgradeName = upgradeName
				button.LootColor = boonData.LootColor or Color.White
				button.BoonGetColor = boonData.BoonGetColor or Color.White

				AttachLua({ Id = components[purchaseButtonKey].Id, Table = components[purchaseButtonKey] })
				components[components[purchaseButtonKey].Id] = purchaseButtonKey
				-- Creates upgrade slot text
				local tooltipX = 0
				if boon.offsetX < 0 then
					tooltipX = 700
				else
					tooltipX = -700
				end
				SetInteractProperty({
					DestinationId = components[purchaseButtonKey].Id,
					Property = "TooltipOffsetX",
					Value = tooltipX
				})
				local traitData = TraitData[boonData.Name]
				local rarity = boonData.Rarity
				local text = "Boon_" .. rarity
				if upgradeData.CustomRarityName then
					text = upgradeData.CustomRarityName
				end

				local color = Color["BoonPatch" .. rarity]
				if upgradeData.CustomRarityColor then
					color = upgradeData.CustomRarityColor
				elseif upgradeData.CustomRarityName == "Boon_Infusion" then
					color = Color.BoonPatchElemental
				end
				--#region Text
				local rarityText = ShallowCopyTable(screendata.RarityText)
				rarityText.FontSize = 24
				rarityText.ScaleTarget = 0.8
				rarityText.OffsetY = -40
				rarityText.Id = button.Id
				rarityText.Text = text
				rarityText.Color = color
				CreateTextBox(rarityText)

				local titleText = ShallowCopyTable(screendata.TitleText)
				titleText.FontSize = 24
				titleText.ScaleTarget = 0.8
				titleText.OffsetY = -40
				titleText.OffsetX = -360
				titleText.Id = button.Id
				titleText.Text = upgradeTitle
				titleText.Color = color
				titleText.LuaValue = tooltipData
				CreateTextBox(titleText)

				local descriptionText = ShallowCopyTable(screendata.DescriptionText)
				-- descriptionText.FontSize = 24
				descriptionText.ScaleTarget = 0.8
				descriptionText.OffsetY = -15
				descriptionText.OffsetX = -360
				descriptionText.Width = 800
				descriptionText.Id = button.Id
				descriptionText.Text = upgradeDescription
				descriptionText.LuaValue = tooltipData
				-- 自定义创建文本
				if isInDiyTraitData(boonData.Name) then
					CreateTextBox({ Id = button.Id, Font = "P22UndergroundSCMedium",
									Text = boonData.Description,
									FontSize = 18,
									Width = 800,
									OffsetY = 0,
									OffsetX = -360,
									Justification = "Left",
									Color = Color.Gray })
				else
					CreateTextBoxWithFormat(descriptionText)
				end
				if traitData.StatLines ~= nil then
					local appendToId = nil
					if #traitData.StatLines <= 1 then
						appendToId = descriptionText.Id
					end
					for lineNum, statLine in ipairs(traitData.StatLines) do
						if statLine ~= "" then
							local offsetY = (lineNum - 1) * screendata.LineHeight
							if upgradeData.ExtraDescriptionLine then
								offsetY = offsetY + screendata.LineHeight
							end

							local statLineLeft = ShallowCopyTable(screendata.StatLineLeft)
							statLineLeft.Id = button.Id
							statLineLeft.ScaleTarget = 0.8
							statLineLeft.Text = statLine
							statLineLeft.OffsetX = -360
							statLineLeft.OffsetY = offsetY
							statLineLeft.AppendToId = appendToId
							statLineLeft.LuaValue = tooltipData
							CreateTextBoxWithFormat(statLineLeft)

							local statLineRight = ShallowCopyTable(screendata.StatLineRight)
							statLineRight.Id = button.Id
							statLineRight.ScaleTarget = 0.8
							statLineRight.Text = statLine
							statLineRight.OffsetX = 100
							statLineRight.OffsetY = offsetY
							statLineRight.AppendToId = appendToId
							statLineRight.LuaValue = tooltipData
							CreateTextBoxWithFormat(statLineRight)
						end
					end
				end
				--#endregion
				Attach({
					Id = screen.Components[purchaseButtonKey].Id,
					DestinationId = screen.Components.Background.Id,
					OffsetX = boon.offsetX,
					OffsetY = boon.offsetY
				})
				if components[purchaseButtonKey].Icon then
					Attach({
						Id = screen.Components[purchaseButtonKey .. "Icon"].Id,
						DestinationId = screen.Components[purchaseButtonKey].Id,
						OffsetX = -385,
						OffsetY = -40
					})
				end
				if components[purchaseButtonKey].ElementIcon then
					Attach({
						Id = screen.Components[purchaseButtonKey .. "ElementIcon"].Id,
						DestinationId = screen.Components[purchaseButtonKey].Id,
						OffsetX = -375,
						OffsetY = -50
					})
				end
			end
		end
	end
end

--#endregion

--#region RESOURCE MENU

function mod.OpenResourceMenu(screen, button)
	if IsScreenOpen("ResourceMenu") then
		return
	end
	mod.UpdateScreenData()

	screen = DeepCopyTable(ScreenData.ResourceMenu)
	screen.Resource = mod.Locale.ResourceMenuEmpty
	screen.Amount = 0
	screen.FirstPage = 0
	screen.LastPage = 0
	screen.CurrentPage = screen.FirstPage
	local components = screen.Components

	OnScreenOpened(screen)
	CreateScreenFromData(screen, screen.ComponentData)
	--Display
	local displayedResources = {}
	local index = 0
	screen.ResourceList = {}
	for _, category in ipairs(ScreenData.InventoryScreen.ItemCategories) do
		for k, resource in ipairs(category) do
			if type(resource) == 'string' and not Contains(displayedResources, resource) then
				table.insert(displayedResources, resource)
				local rowOffset = 100
				local columnOffset = 400
				local boonsPerRow = 4
				local rowsPerPage = 4
				local rowIndex = math.floor(index / boonsPerRow)
				local pageIndex = math.floor(rowIndex / rowsPerPage)
				local offsetX = screen.RowStartX + columnOffset * (index % boonsPerRow)
				local offsetY = screen.RowStartY + rowOffset * (rowIndex % rowsPerPage)
				index = index + 1
				screen.LastPage = pageIndex
				if screen.ResourceList[pageIndex] == nil then
					screen.ResourceList[pageIndex] = {}
				end
				table.insert(screen.ResourceList[pageIndex], {
					index = index,
					name = resource,
					pageIndex = pageIndex,
					offsetX = offsetX,
					offsetY = offsetY,
				})
			end
		end
	end
	mod.ResourceMenuLoadPage(screen)
	--

	components.ResourceTextbox = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray" })
	Attach({ Id = components.ResourceTextbox.Id, DestinationId = components.Background.Id, OffsetX = -450, OffsetY = 450 })
	CreateTextBox({
		Id = components.ResourceTextbox.Id,
		Text = screen.Resource,
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})
	components.ResourceAmountTextbox = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray" })
	Attach({ Id = components.ResourceAmountTextbox.Id, DestinationId = components.Background.Id, OffsetX = -300, OffsetY = 450 })
	CreateTextBox({
		Id = components.ResourceAmountTextbox.Id,
		Text = screen.Amount,
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})

	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	wait(0.3)

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
end

function mod.CloseResourceMenu(screen)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters("ResourceMenu")
end

function mod.ChangeTargetResource(screen, button)
	screen.Resource = button.Resource
	ModifyTextBox({ Id = screen.Components.ResourceTextbox.Id, Text = button.Resource })
end

function mod.ChangeTargetResourceAmount(screen, button)
	local amount = screen.Amount + button.Amount
	--if amount < 0 then
	--	amount = 0
	--end
	screen.Amount = amount
	ModifyTextBox({ Id = screen.Components.ResourceAmountTextbox.Id, Text = screen.Amount })
end

function mod.SpawnResource(screen, button)
	if screen.Resource == "None" or screen.Amount == 0 then
		return
	end

	--AddResource(screen.Resource, screen.Amount)
	if screen.Amount < 0 then
		local amount = screen.Amount * -1
		if amount > GameState.Resources[screen.Resource] then
			amount = GameState.Resources[screen.Resource]
		end
		SpendResource(screen.Resource, amount)
	else
		AddResource(screen.Resource, screen.Amount)
	end
end

function mod.ResourceMenuLoadPage(screen)
	mod.BoonManagerPageButtons(screen, screen.Name)
	local displayedResources = {}
	local pageResources = screen.ResourceList[screen.CurrentPage]
	if pageResources then
		for i, resourceData in pairs(pageResources) do
			if displayedResources[resourceData] or displayedResources[resourceData] then
				--Skip
			else
				local purchaseButtonKey = "PurchaseButton" .. resourceData.index
				screen.Components[purchaseButtonKey] = CreateScreenComponent({
					Name = "ButtonDefault",
					Group =
					"Combat_Menu_TraitTray",
					Scale = 1.2,
					ScaleX = 1.15,
					ToDestroy = true
				})
				SetInteractProperty({
					DestinationId = screen.Components[purchaseButtonKey].Id,
					Property = "TooltipOffsetY",
					Value = 100
				})
				screen.Components[purchaseButtonKey].OnPressedFunctionName = mod.ChangeTargetResource
				screen.Components[purchaseButtonKey].Resource = resourceData.name
				screen.Components[purchaseButtonKey].Index = resourceData.index

				local data = ResourceData[resourceData.name]
				local icon = {
					Name = "BlankObstacle",
					Animation = data.IconPath or data.Icon,
					Scale = data.IconScale or 0.5,
					Group = "Combat_Menu_TraitTray",
					ToDestroy = true
				}
				screen.Components[purchaseButtonKey .. "Icon"] = CreateScreenComponent(icon)
				screen.Components[purchaseButtonKey].Icon = screen.Components[purchaseButtonKey .. "Icon"]
				Attach({
					Id = screen.Components[purchaseButtonKey].Id,
					DestinationId = screen.Components.Background.Id,
					OffsetX = resourceData.offsetX,
					OffsetY = resourceData.offsetY
				})
				CreateTextBox({
					Id = screen.Components[purchaseButtonKey].Id,
					Text = resourceData.name,
					FontSize = 22,
					OffsetX = 0,
					OffsetY = -5,
					Width = 720,
					Color = Color.White,
					Font = "P22UndergroundSCMedium",
					ShadowBlur = 0,
					ShadowColor = { 0, 0, 0, 1 },
					ShadowOffset = { 0, 2 },
					Justification = "Center"
				})
				Attach({
					Id = screen.Components[purchaseButtonKey .. "Icon"].Id,
					DestinationId = screen.Components[purchaseButtonKey].Id,
					OffsetX = -150
				})
			end
		end
	end
end

--#endregion

--#region BOON MANAGER

function mod.OpenBoonManager(screen, button)
	if IsScreenOpen("BoonManager") then
		return
	end
	-- mod.UpdateScreenData()

	screen = DeepCopyTable(ScreenData.BoonSelector)
	screen.Name = "BoonManager"
	screen.FirstPage = 0
	screen.LastPage = 0
	screen.CurrentPage = screen.FirstPage
	local components = screen.Components
	local children = screen.ComponentData.Background.Children
	screen.ComponentData.Background.Text = mod.Locale.BoonManagerTitle

	-- Display
	children.CommonButton = nil
	children.RareButton = nil
	children.EpicButton = nil
	children.HeroicButton = nil
	children.SpawnButton = nil

	OnScreenOpened(screen)
	CreateScreenFromData(screen, screen.ComponentData)

	mod.LoadPageBoons(screen)
	mod.BoonManagerLoadPage(screen)
	--#region Instructions
	components.ModeDisplay = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray" })
	Attach({ Id = components.ModeDisplay.Id, DestinationId = components.Background.Id, OffsetX = 0, OffsetY = 0 })
	CreateTextBox({
		Id = components.ModeDisplay.Id,
		Text = mod.Locale.BoonManagerModeSelection,
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 450,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})
	CreateTextBox({
		Id = components.ModeDisplay.Id,
		Text = mod.Locale.BoonManagerSubtitle,
		FontSize = 19,
		OffsetX = 0,
		OffsetY = -380,
		Width = 840,
		Color = Color.SubTitle,
		Font = "CaesarDressing",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 1 },
		Justification = "Center"
	})
	--#endregion
	--#region Mode Buttons
	components.LevelModeButton = CreateScreenComponent({ Name = "ButtonDefault", Group = "Combat_Menu_TraitTray", Scale = 1.0 })
	components.LevelModeButton.OnPressedFunctionName = mod.ChangeBoonManagerMode
	components.LevelModeButton.Mode = "Level"
	components.LevelModeButton.Text = mod.Locale.BoonManagerLevelMode
	components.LevelModeButton.Add = true
	components.LevelModeButton.Substract = false
	components.LevelModeButton.Icon = "(+)"
	Attach({ Id = components.LevelModeButton.Id, DestinationId = components.Background.Id, OffsetX = -650, OffsetY = 450 })
	CreateTextBox({
		Id = components.LevelModeButton.Id,
		Text = components.LevelModeButton.Text .. "(+)",
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})
	components.RarityModeButton = CreateScreenComponent({ Name = "ButtonDefault", Group = "Combat_Menu_TraitTray", Scale = 1.0 })
	components.RarityModeButton.OnPressedFunctionName = mod.ChangeBoonManagerMode
	components.RarityModeButton.Mode = "Rarity"
	components.RarityModeButton.Text = mod.Locale.BoonManagerRarityMode
	components.RarityModeButton.Add = true
	components.RarityModeButton.Substract = false
	components.RarityModeButton.Icon = "(+)"
	Attach({ Id = components.RarityModeButton.Id, DestinationId = components.Background.Id, OffsetX = -350, OffsetY = 450 })
	CreateTextBox({
		Id = components.RarityModeButton.Id,
		Text = components.RarityModeButton.Text .. "(+)",
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})
	components.DeleteModeButton = CreateScreenComponent({ Name = "ButtonDefault", Group = "Combat_Menu_TraitTray", Scale = 1.0 })
	components.DeleteModeButton.OnPressedFunctionName = mod.ChangeBoonManagerMode
	components.DeleteModeButton.Mode = "Delete"
	components.DeleteModeButton.Text = mod.Locale.BoonManagerDeleteMode
	Attach({ Id = components.DeleteModeButton.Id, DestinationId = components.Background.Id, OffsetX = 350, OffsetY = 450 })
	CreateTextBox({
		Id = components.DeleteModeButton.Id,
		Text = components.DeleteModeButton.Text,
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})
	components.AllModeButton = CreateScreenComponent({ Name = "ButtonDefault", Group = "Combat_Menu_TraitTray", Scale = 1.0 })
	components.AllModeButton.OnPressedFunctionName = mod.ChangeBoonManagerMode
	components.AllModeButton.Mode = "All"
	components.AllModeButton.Text = mod.Locale.BoonManagerAllModeOff
	Attach({ Id = components.AllModeButton.Id, DestinationId = components.Background.Id, OffsetX = 650, OffsetY = 450 })
	CreateTextBox({
		Id = components.AllModeButton.Id,
		Text = components.AllModeButton.Text,
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.BoonPatchEpic,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})
	--#endregion

	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	wait(0.3)

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
end

function mod.LoadPageBoons(screen)
	local displayedTraits = {}
	local index = 0
	screen.BoonsList = {}
	local rowOffset = 180
	local columnOffset = 900
	local boonsPerRow = 2
	local rowsPerPage = 4
	local rowoffsetX = -450
	local rowoffsetY = -250
	for i, boon in pairs(CurrentRun.Hero.Traits) do
		if not Contains(displayedTraits, boon.Name) and mod.IsBoonManagerValid(boon.Name) then
			table.insert(displayedTraits, boon.Name)
			local rowIndex = math.floor(index / boonsPerRow)
			local pageIndex = math.floor(rowIndex / rowsPerPage)
			local offsetX = rowoffsetX + columnOffset * (index % boonsPerRow)
			local offsetY = rowoffsetY + rowOffset * (rowIndex % rowsPerPage)
			boon.Level = boon.StackNum or 1
			index = index + 1
			screen.LastPage = pageIndex
			if screen.BoonsList[pageIndex] == nil then
				screen.BoonsList[pageIndex] = {}
			end
			table.insert(screen.BoonsList[pageIndex], {
				index = index,
				boon = boon,
				pageIndex = pageIndex,
				offsetX = offsetX,
				offsetY = offsetY,
			})
		end
	end
end

function mod.ChangeBoonManagerMode(screen, button)
	if button.Mode == "All" then
		if screen.AllMode == nil or not screen.AllMode then
			screen.AllMode = true
			ModifyTextBox({ Id = button.Id, Text = mod.Locale.BoonManagerAllModeOn, Color = Color.BoonPatchHeroic })
		else
			screen.AllMode = false
			ModifyTextBox({ Id = button.Id, Text = mod.Locale.BoonManagerAllModeOff, Color = Color.BoonPatchEpic })
		end
		return
	end
	if screen.LockedModeButton ~= nil and screen.LockedModeButton ~= button then
		ModifyTextBox({
			Id = screen.LockedModeButton.Id,
			Text = screen.LockedModeButton.Text .. (screen.LockedModeButton.Icon or "")
		})
	elseif button.Mode ~= "Delete" and screen.LockedModeButton ~= nil and screen.LockedModeButton == button then
		-- Switch add or subtract submode (does nothing for Delete mode)
		if button.Add == false then
			button.Substract = false
			button.Add = true
			button.Icon = "(+)"
		else
			button.Add = false
			button.Substract = true
			button.Icon = "(-)"
		end
	end
	screen.Mode = button.Mode
	screen.LockedModeButton = button
	ModifyTextBox({ Id = button.Id, Text = ">>" .. button.Text .. (button.Icon or "") .. "<<" })
end

function mod.HandleBoonManagerClick(screen, button)
	if button.Boon == nil or screen.Mode == nil then
		return
	end
	--All mode
	if screen.AllMode ~= nil and screen.AllMode then
		if screen.Mode == "Level" and screen.LockedModeButton.Add == true then
			local upgradableTraits = {}
			local upgradedTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				screen.Traits = CurrentRun.Hero.Traits
				local numTraits = traitData.StackNum or 1
				if numTraits < 100 and traitData.RemainingUses == nil and IsGodTrait(traitData.Name) and not traitData.BlockStacking
					and (not traitData.RequiredFalseTrait or traitData.RequiredFalseTrait ~= traitData.Name) and mod.IsBoonManagerValid(traitData.Name) then
					upgradableTraits[traitData.Name] = true
				end
			end
			if not IsEmpty(upgradableTraits) then
				for _, levelbutton in pairs(screen.Components) do
					if not levelbutton.IsBackground and levelbutton.Boon ~= nil then
						levelbutton.Boon.Level = levelbutton.Boon.Level + 1
						ModifyTextBox({
							Id = levelbutton.Background.Id,
							Text = mod.Locale.BoonManagerLevelDisplay ..
								levelbutton.Boon.Level
						})
					end
				end
				while not IsEmpty(upgradableTraits) do
					local name = RemoveRandomKey(upgradableTraits)
					upgradedTraits[name] = true
					local traitData = GetHeroTrait(name)
					local stacks = GetTraitCount(name)
					stacks = stacks + 1
					IncreaseTraitLevel(traitData, stacks)
				end
			end
			return
		elseif screen.Mode == "Level" and screen.LockedModeButton.Substract == true then
			local upgradableTraits = {}
			local upgradedTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				screen.Traits = CurrentRun.Hero.Traits
				local numTraits = traitData.StackNum or 1
				if numTraits > 1 and IsGodTrait(traitData.Name) and TraitData[traitData.Name] and IsGameStateEligible(CurrentRun, TraitData[traitData.Name]) and traitData.Rarity ~= "Legendary" and mod.IsBoonManagerValid(traitData.Name) then
					upgradableTraits[traitData.Name] = true
				end
			end
			if not IsEmpty(upgradableTraits) then
				for _, levelbutton in pairs(screen.Components) do
					if not levelbutton.IsBackground and levelbutton.Boon ~= nil then
						levelbutton.Boon.Level = levelbutton.Boon.Level - 1
						ModifyTextBox({
							Id = levelbutton.Background.Id,
							Text = mod.Locale.BoonManagerLevelDisplay ..
								levelbutton.Boon.Level
						})
					end
				end
				while not IsEmpty(upgradableTraits) do
					local name = RemoveRandomKey(upgradableTraits)
					upgradedTraits[name] = true
					local traitData = GetHeroTrait(name)
					local stacks = GetTraitCount(name)
					stacks = stacks - 1
					IncreaseTraitLevel(traitData, stacks)
				end
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Add == true then
			local upgradableTraits = {}
			local upgradedTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				if TraitData[traitData.Name] and traitData.Rarity ~= nil and GetUpgradedRarity(traitData.Rarity) ~= nil and traitData.RarityLevels ~= nil
					and traitData.RarityLevels[GetUpgradedRarity(traitData.Rarity)] ~= nil and mod.IsBoonManagerValid(traitData.Name) then
					if Contains(upgradableTraits, traitData) or traitData.Rarity == "Legendary" then
					else
						table.insert(upgradableTraits, traitData)
					end
				end
			end
			if not IsEmpty(upgradableTraits) then
				while not IsEmpty(upgradableTraits) do
					local traitData = RemoveRandomValue(upgradableTraits)
					upgradedTraits[traitData.Name] = true
					local rarity = GetUpgradedRarity(traitData.Rarity)
					RemoveTrait(CurrentRun.Hero, traitData.Name)
					AddTraitToHero({
						TraitData = GetProcessedTraitData({
							Unit = CurrentRun.Hero,
							TraitName = traitData.Name,
							Rarity = rarity,
							StackNum = traitData.StackNum
						}),
						SkipNewTraitHighlight = true,
						SkipQuestStatusCheck = true,
						SkipActivatedTraitUpdate = true,
					})
				end
				local ids = {}
				for i, component in pairs(screen.Components) do
					if component.ToDestroy then
						table.insert(ids, component.Id)
					end
				end
				Destroy({ Ids = ids })
				mod.LoadPageBoons(screen)
				mod.BoonManagerLoadPage(screen)
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Substract == true then
			local upgradableTraits = {}
			local upgradedTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				if TraitData[traitData.Name] and traitData.Rarity ~= nil and GetDowngradedRarity(traitData.Rarity) ~= nil and traitData.RarityLevels ~= nil
					and traitData.RarityLevels[GetDowngradedRarity(traitData.Rarity)] ~= nil and mod.IsBoonManagerValid(traitData.Name) then
					if Contains(upgradableTraits, traitData) or traitData.Rarity == "Legendary" then
					else
						table.insert(upgradableTraits, traitData)
					end
				end
			end
			if not IsEmpty(upgradableTraits) then
				while not IsEmpty(upgradableTraits) do
					local traitData = RemoveRandomValue(upgradableTraits)
					upgradedTraits[traitData.Name] = true
					local rarity = GetDowngradedRarity(traitData.Rarity)
					RemoveTrait(CurrentRun.Hero, traitData.Name)
					AddTraitToHero({
						TraitData = GetProcessedTraitData({
							Unit = CurrentRun.Hero,
							TraitName = traitData.Name,
							Rarity = rarity,
							StackNum = traitData.StackNum
						}),
						SkipNewTraitHighlight = true,
						SkipQuestStatusCheck = true,
						SkipActivatedTraitUpdate = true,
					})
				end
				local ids = {}
				for i, component in pairs(screen.Components) do
					if component.ToDestroy then
						table.insert(ids, component.Id)
					end
				end
				Destroy({ Ids = ids })
				mod.LoadPageBoons(screen)
				mod.BoonManagerLoadPage(screen)
			end
			return
		elseif screen.Mode == "Delete" then
			mod.ClearAllBoons()
			mod.CloseBoonSelector(screen)
			return
		end
	else
		--Individual mode
		if screen.Mode == "Level" and screen.LockedModeButton.Add == true then
			if GetTraitCount(CurrentRun.Hero, button.Boon.Name) < 100 and button.Boon.RemainingUses == nil and IsGodTrait(button.Boon.Name) and not button.Boon.BlockStacking and (not button.Boon.RequiredFalseTrait or button.Boon.RequiredFalseTrait ~= button.Boon.Name) then
				local traitData = GetHeroTrait(button.Boon.Name)
				local stacks = GetTraitCount(CurrentRun.Hero, button.Boon.Name)
				stacks = stacks + 1
				IncreaseTraitLevel(traitData, stacks)
				button.Boon.Level = button.Boon.Level + 1
				ModifyTextBox({
					Id = button.Background.Id,
					Text = mod.Locale.BoonManagerLevelDisplay .. button.Boon
						.Level
				})
			end
			return
		elseif screen.Mode == "Level" and screen.LockedModeButton.Substract == true then
			if GetTraitCount(CurrentRun.Hero, button.Boon) > 1 and button.Boon.RemainingUses == nil and IsGodTrait(button.Boon.Name) and not button.Boon.BlockStacking and (not button.Boon.RequiredFalseTrait or button.Boon.RequiredFalseTrait ~= button.Boon.Name) then
				local traitData = GetHeroTrait(button.Boon.Name)
				local stacks = GetTraitCount(button.Boon.Name)
				stacks = stacks - 1
				IncreaseTraitLevel(traitData, stacks)
				button.Boon.Level = button.Boon.Level - 1
				ModifyTextBox({
					Id = button.Background.Id,
					Text = mod.Locale.BoonManagerLevelDisplay .. button.Boon
						.Level
				})
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Add == true then
			if TraitData[button.Boon.Name] and button.Boon.Rarity ~= nil and GetUpgradedRarity(button.Boon.Rarity) ~= nil and button.Boon.RarityLevels ~= nil and button.Boon.RarityLevels[GetUpgradedRarity(button.Boon.Rarity)] ~= nil then
				local count = GetTraitCount(CurrentRun.Hero, button.Boon)
				button.Boon.Rarity = GetUpgradedRarity(button.Boon.Rarity)
				SetColor({ Id = button.Background.Id, Color = Color["BoonPatch" .. button.Boon.Rarity] })
				RemoveTrait(CurrentRun.Hero, button.Boon.Name)
				AddTraitToHero({
					TraitData = GetProcessedTraitData({
						Unit = CurrentRun.Hero,
						TraitName = button.Boon
							.Name,
						Rarity = button.Boon.Rarity,
						StackNum = count
					}),
					SkipNewTraitHighlight = true,
					SkipQuestStatusCheck = true,
					SkipActivatedTraitUpdate = true,
				})
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Substract == true then
			if TraitData[button.Boon.Name] and button.Boon.Rarity ~= nil and GetDowngradedRarity(button.Boon.Rarity) ~= nil and button.Boon.RarityLevels ~= nil and button.Boon.RarityLevels[GetDowngradedRarity(button.Boon.Rarity)] ~= nil then
				local count = GetTraitCount(CurrentRun.Hero, button.Boon)
				button.Boon.Rarity = GetDowngradedRarity(button.Boon.Rarity)
				SetColor({ Id = button.Background.Id, Color = Color["BoonPatch" .. button.Boon.Rarity] })
				RemoveTrait(CurrentRun.Hero, button.Boon.Name)
				AddTraitToHero({
					TraitData = GetProcessedTraitData({
						Unit = CurrentRun.Hero,
						TraitName = button.Boon
							.Name,
						Rarity = button.Boon.Rarity,
						StackNum = count
					}),
					SkipNewTraitHighlight = true,
					SkipQuestStatusCheck = true,
					SkipActivatedTraitUpdate = true,
				})
			end
			return
		elseif screen.Mode == "Delete" then
			screen.BoonsList[screen.CurrentPage][button.Index] = nil
			RemoveTrait(CurrentRun.Hero, button.Boon.Name)
			local ids = { button.Id, button.Background.Id }
			if button.Icon then
				table.insert(ids, button.Icon.Id)
			end
			if button.ElementIcon then
				table.insert(ids, button.ElementIcon.Id)
			end
			Destroy({ Ids = ids })
			return
		end
	end
end

function mod.BoonManagerChangePage(screen, button)
	if button.Direction == "Left" and screen.CurrentPage > screen.FirstPage then
		screen.CurrentPage = screen.CurrentPage - 1
	elseif button.Direction == "Right" and screen.CurrentPage < screen.LastPage then
		screen.CurrentPage = screen.CurrentPage + 1
	else
		return
	end
	local ids = {}
	for i, component in pairs(screen.Components) do
		if component.ToDestroy then
			table.insert(ids, component.Id)
		end
	end
	Destroy({ Ids = ids })
	if button.Menu == "ResourceMenu" then
		mod.ResourceMenuLoadPage(screen)
	elseif button.Menu == "BoonManager" then
		mod.BoonManagerLoadPage(screen)
	elseif button.Menu == "BoonSelector" then
		mod.BoonSelectorLoadPage(screen)
	elseif button.Menu == "ConsumableSelector" then
		mod.ConsumableSelectorLoadPage(screen)
	elseif button.Menu == "ExtraSelector" then
		mod.ExtraSelectorLoadPage(screen)
	end
end

function mod.BoonManagerLoadPage(screen)
	mod.BoonManagerPageButtons(screen, screen.Name)
	local displayedTraits = {}
	local pageBoons = screen.BoonsList[screen.CurrentPage]
	if pageBoons then
		local components = screen.Components
		for i, boonData in pairs(pageBoons) do
			if displayedTraits[boonData.boon.Name] or displayedTraits[boonData.boon] then
				--Skip
			else
				displayedTraits[boonData.boon.Name] = true
				local color = mod.GetLootColorFromTrait(boonData.boon.Name)
				if boonData.boon.Rarity == nil or boonData.boon.Rarity == "Common" then
					local tdata = TraitData[boonData.boon.Name]
					if tdata.RarityLevels and tdata.RarityLevels.Legendary then
						boonData.boon.Rarity = "Legendary"
					elseif tdata.IsDuoBoon then
						boonData.boon.Rarity = "Duo"
					else
						boonData.boon.Rarity = "Common"
					end
				end
				local purchaseButtonKeyBG = "PurchaseButtonBG" .. boonData.index
				screen.Components[purchaseButtonKeyBG] = CreateScreenComponent({
					Name = "rectangle01",
					Group = "Combat_Menu_TraitTray",
					ScaleX = 1.87,
					ScaleY = 0.65,
					IsBackground = true,
					Boon = boonData.boon,
					ToDestroy = true
				})
				CreateTextBox({
					Id = screen.Components[purchaseButtonKeyBG].Id,
					Text = mod.Locale.BoonManagerLevelDisplay .. boonData.boon.Level,
					FontSize = 20,
					OffsetX = 200,
					OffsetY = -45,
					Width = 720,
					Color = Color.White,
					Font = "P22UndergroundSCMedium",
					ShadowBlur = 0,
					ShadowColor = { 0, 0, 0, 1 },
					ShadowOffset = { 0, 2 },
					Justification = "Center"
				})

				local screendata = DeepCopyTable(ScreenData.UpgradeChoice)
				local upgradeName = boonData.boon.Name
				local upgradeData = nil
				local upgradeTitle = nil
				local upgradeDescription = nil
				local tooltipData = nil
				upgradeData = GetProcessedTraitData({
					Unit = CurrentRun.Hero,
					TraitName = boonData.boon.Name,
					Rarity = boonData.boon.Rarity
				})
				upgradeTitle = GetTraitTooltipTitle(TraitData[boonData.boon.Name])
				upgradeData.Title = GetTraitTooltipTitle(TraitData[boonData.boon.Name])
				tooltipData = upgradeData
				SetTraitTextData(tooltipData)
				upgradeDescription = GetTraitTooltip(tooltipData, { Default = upgradeData.Title })

				-- Setting button graphic based on boon type
				local purchaseButtonKey = "PurchaseButton" .. boonData.index
				local purchaseButton = {
					Name = "ButtonDefault",
					OffsetX = boonData.offsetX,
					OffsetY = boonData.offsetY,
					Group = "Combat_Menu_TraitTray",
					Color = color,
					ScaleX = 3.2,
					ScaleY = 2.2,
					ToDestroy = true
				}
				components[purchaseButtonKey] = CreateScreenComponent(purchaseButton)
				components[purchaseButtonKey].Background = screen.Components[purchaseButtonKeyBG]
				if upgradeData.Icon ~= nil then
					local icon = screendata.Icon
					icon.Animation = upgradeData.Icon
					icon.Scale = 0.25
					icon.Group = "Combat_Menu_TraitTray"
					icon.ToDestroy = true
					components[purchaseButtonKey .. "Icon"] = CreateScreenComponent(icon)
					components[purchaseButtonKey].Icon = components[purchaseButtonKey .. "Icon"]
				end
				if not IsEmpty(upgradeData.Elements) then
					local elementName = GetFirstValue(upgradeData.Elements)
					local elementIcon = screendata.ElementIcon
					elementIcon.Name = TraitElementData[elementName].Icon
					elementIcon.Scale = 0.5
					elementIcon.Group = "Combat_Menu_TraitTray"
					elementIcon.ToDestroy = true
					components[purchaseButtonKey .. "ElementIcon"] = CreateScreenComponent(elementIcon)
					components[purchaseButtonKey].ElementIcon = components[purchaseButtonKey .. "ElementIcon"]
					if not GameState.Flags.SeenElementalIcons then
						SetAlpha({ Id = components[purchaseButtonKey .. "ElementIcon"].Id, Fraction = 0, Duration = 0 })
					end
				end

				-- Button data setup
				local button = components[purchaseButtonKey]
				button.OnPressedFunctionName = mod.HandleBoonManagerClick
				button.Boon = boonData.boon
				button.Index = boonData.index
				button.OnMouseOverFunctionName = mod.MouseOverBoonButton
				button.OnMouseOffFunctionName = mod.MouseOffBoonButton
				button.Data = upgradeData
				button.Screen = screen
				button.UpgradeName = upgradeName
				button.LootColor = boonData.boon.LootColor or Color.White
				button.BoonGetColor = boonData.boon.BoonGetColor or Color.White

				AttachLua({ Id = components[purchaseButtonKey].Id, Table = components[purchaseButtonKey] })
				components[components[purchaseButtonKey].Id] = purchaseButtonKey
				-- Creates upgrade slot text
				local tooltipX = 0
				if boonData.offsetX < 0 then
					tooltipX = 700
				else
					tooltipX = -700
				end
				SetInteractProperty({
					DestinationId = components[purchaseButtonKey].Id,
					Property = "TooltipOffsetX",
					Value = tooltipX
				})
				local traitData = TraitData[boonData.boon.Name]
				local rarity = boonData.boon.Rarity
				local text = "Boon_" .. rarity
				if upgradeData.CustomRarityName then
					text = upgradeData.CustomRarityName
				end

				color = Color["BoonPatch" .. rarity]
				if upgradeData.CustomRarityColor then
					color = upgradeData.CustomRarityColor
				elseif upgradeData.CustomRarityName == "Boon_Infusion" then
					color = Color.BoonPatchElemental
				end
				SetColor({
					Id = screen.Components[purchaseButtonKeyBG].Id,
					Color = color
				})
				--#region Text
				local rarityText = ShallowCopyTable(screendata.RarityText)
				rarityText.FontSize = 24
				rarityText.ScaleTarget = 0.8
				rarityText.OffsetY = -40
				rarityText.Id = button.Id
				rarityText.Text = text
				rarityText.Color = color
				CreateTextBox(rarityText)

				local titleText = ShallowCopyTable(screendata.TitleText)
				titleText.FontSize = 24
				titleText.ScaleTarget = 0.8
				titleText.OffsetY = -40
				titleText.OffsetX = -360
				titleText.Id = button.Id
				titleText.Text = upgradeTitle
				titleText.Color = color
				titleText.LuaValue = tooltipData
				CreateTextBox(titleText)

				local descriptionText = ShallowCopyTable(screendata.DescriptionText)
				-- descriptionText.FontSize = 24
				descriptionText.ScaleTarget = 0.8
				descriptionText.OffsetY = -15
				descriptionText.OffsetX = -360
				descriptionText.Width = 800
				descriptionText.Id = button.Id
				descriptionText.Text = upgradeDescription
				descriptionText.LuaValue = tooltipData

				-- 自定义创建文本
				if isInDiyTraitData(boonData.boon.Name) then
					CreateTextBox({ Id = button.Id, Font = "P22UndergroundSCMedium",
									Text = boonData.boon.Description,
									FontSize = 18,
									Width = 800,
									OffsetY = 0,
									OffsetX = -360,
									Justification = "Left",
									Color = Color.Gray })
				else
					CreateTextBoxWithFormat(descriptionText)
				end
				if traitData.StatLines ~= nil then
					local appendToId = nil
					if #traitData.StatLines <= 1 then
						appendToId = descriptionText.Id
					end
					for lineNum, statLine in ipairs(traitData.StatLines) do
						if statLine ~= "" then
							local offsetY = (lineNum - 1) * screendata.LineHeight
							if upgradeData.ExtraDescriptionLine then
								offsetY = offsetY + screendata.LineHeight
							end

							local statLineLeft = ShallowCopyTable(screendata.StatLineLeft)
							statLineLeft.Id = button.Id
							statLineLeft.ScaleTarget = 0.8
							statLineLeft.Text = statLine
							statLineLeft.OffsetX = -360
							statLineLeft.OffsetY = offsetY
							statLineLeft.AppendToId = appendToId
							statLineLeft.LuaValue = tooltipData
							CreateTextBoxWithFormat(statLineLeft)

							local statLineRight = ShallowCopyTable(screendata.StatLineRight)
							statLineRight.Id = button.Id
							statLineRight.ScaleTarget = 0.8
							statLineRight.Text = statLine
							statLineRight.OffsetX = 100
							statLineRight.OffsetY = offsetY
							statLineRight.AppendToId = appendToId
							statLineRight.LuaValue = tooltipData
							CreateTextBoxWithFormat(statLineRight)
						end
					end
				end
				--#endregion
				Attach({
					Id = screen.Components[purchaseButtonKey].Id,
					DestinationId = screen.Components.Background.Id,
					OffsetX = boonData.offsetX,
					OffsetY = boonData.offsetY
				})
				Attach({
					Id = screen.Components[purchaseButtonKeyBG].Id,
					DestinationId = screen.Components[purchaseButtonKey].Id
				})
				if components[purchaseButtonKey].Icon then
					Attach({
						Id = screen.Components[purchaseButtonKey .. "Icon"].Id,
						DestinationId = screen.Components[purchaseButtonKey].Id,
						OffsetX = -385,
						OffsetY = -40
					})
				end
				if components[purchaseButtonKey].ElementIcon then
					Attach({
						Id = screen.Components[purchaseButtonKey .. "ElementIcon"].Id,
						DestinationId = screen.Components[purchaseButtonKey].Id,
						OffsetX = -375,
						OffsetY = -50
					})
				end
			end
		end
	end
end

function mod.BoonManagerPageButtons(screen, menu)
	local components = screen.Components
	if components.LeftPageButton then
		Destroy({ Ids = { components.LeftPageButton.Id } })
	end
	if components.RightPageButton then
		Destroy({ Ids = { components.RightPageButton.Id } })
	end
	if screen.CurrentPage ~= screen.FirstPage then
		components.LeftPageButton = CreateScreenComponent({
			Name = "ButtonCodexLeft",
			Scale = 1.2,
			Sound =
			"/SFX/Menu Sounds/GeneralWhooshMENU",
			Group = "Combat_Menu_TraitTray"
		})
		Attach({ Id = components.LeftPageButton.Id, DestinationId = components.Background.Id, OffsetX = -650, OffsetY = -380 })
		components.LeftPageButton.OnPressedFunctionName = mod.BoonManagerChangePage
		components.LeftPageButton.Menu = menu
		components.LeftPageButton.Direction = "Left"
		components.LeftPageButton.ControlHotkeys = { "MenuLeft", "Left" }
	end
	if screen.CurrentPage ~= screen.LastPage then
		components.RightPageButton = CreateScreenComponent({
			Name = "ButtonCodexRight",
			Scale = 1.2,
			Sound =
			"/SFX/Menu Sounds/GeneralWhooshMENU",
			Group = "Combat_Menu_TraitTray"
		})
		Attach({ Id = components.RightPageButton.Id, DestinationId = components.Background.Id, OffsetX = 650, OffsetY = -380 })
		components.RightPageButton.OnPressedFunctionName = mod.BoonManagerChangePage
		components.RightPageButton.Menu = menu
		components.RightPageButton.Direction = "Right"
		components.RightPageButton.ControlHotkeys = { "MenuRight", "Right" }
	end
end

function mod.IsBoonManagerValid(traitName)
	if traitName == "GodModeTrait" or traitName == "AltarBoon" then
		return false
	elseif TraitData[traitName] ~= nil then
		local trait = TraitData[traitName]
		if
			trait.MetaUpgrade
			or trait.Hidden
			or trait.AddResources ~= nil
			or trait.Slot == "Aspect"
			or trait.Slot == "Familiar"
			or trait.Slot == "Keepsake"
		then
			return false
		end
	end
	return true
end

function mod.MouseOverBoonButton(button)
	local screen = button.Screen
	if screen.Closing then
		return
	end

	GenericMouseOverPresentation(button)

	local components = screen.Components
	local buttonHighlight = CreateScreenComponent({
		Name = "InventorySlotHighlight",
		Scale = 1.0,
		Group =
		"Combat_Menu_Overlay",
		DestinationId = button.Id
	})
	components.InventorySlotHighlight = buttonHighlight
	button.HighlightId = buttonHighlight.Id
	Attach({ Id = buttonHighlight.Id, DestinationId = button.Id })
end

function mod.MouseOffBoonButton(button)
	Destroy({ Id = button.HighlightId })
	local components = button.Screen.Components
	components.InventorySlotHighlight = nil
	SetScale({ Id = button.Id, Fraction = 1.0, Duration = 0.1, SkipGeometryUpdate = true })
	StopFlashing({ Id = button.Id })
end

--#endregion

--#region BOSS SELECTOR

function mod.OpenBossSelector()
	if IsScreenOpen("BossSelector") then
		return
	end

	local screen = DeepCopyTable(ScreenData.BossSelector)
	screen.SelectedGod = mod.Data.SelectedGod or "No God selected"
	local components = screen.Components
	local children = screen.ComponentData.Background.Children
	HideCombatUI(screen.Name)
	OnScreenOpened(screen)
	CreateScreenFromData(screen, screen.ComponentData)

	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })

    --Save state 第一次如果没有保存的情况，默认先保存
	if not mod.Data.SavedState then
        mod.SaveState()
    end

	--Display

	if mod.Data.SavedState then
		local index = 0
		local rowOffset = 400
		local columnOffset = 400
		local boonsPerRow = 4
		local rowsPerPage = 99
		local rowoffsetX = 350
		local rowoffsetY = 350

		for _, value in ipairs(screen.ItemOrder) do
			if GameState.RoomCountCache[value] then
                local boss = screen.BossData[value]
                boss.Room = DeepCopyTable(RoomData[value])

                local key = "Boss" .. index
                local buttonKey = "Button" .. index
                local fraction = 0.1
                local rowIndex = math.floor(index / boonsPerRow)
                local offsetX = rowoffsetX + columnOffset * (index % boonsPerRow)
                local offsetY = rowoffsetY + rowOffset * (rowIndex % rowsPerPage)
                index = index + 1

                components[buttonKey] = CreateScreenComponent({
                    Name = "ButtonDefault",
                    Scale = 1.0,
                    Group = "Combat_Menu_TraitTray",
                    Color = Color.White
                })
                components[buttonKey].Image = key
                components[buttonKey].Boss = boss
                components[buttonKey].Index = index
                SetScaleX({ Id = components[buttonKey].Id, Fraction = 0.69 })
                SetScaleY({ Id = components[buttonKey].Id, Fraction = 3.8 })
                components[key] = CreateScreenComponent({
                    Name = "BlankObstacle",
                    Scale = 1.2,
                    Group = "Combat_Menu_TraitTray"
                })

                SetThingProperty({ Property = "Ambient", Value = 0.0, DestinationId = components[key].Id })
                components[buttonKey].OnPressedFunctionName = mod.HandleBossSelection
                fraction = 1.0

                SetAlpha({ Ids = { components[key].Id, components[buttonKey].Id }, Fraction = 0 })
                SetAlpha({ Ids = { components[key].Id, components[buttonKey].Id }, Fraction = fraction, Duration = 0.9 })
                SetAnimation({ DestinationId = components[key].Id, Name = boss.Portrait, Scale = 0.4 })
                local delay = RandomFloat(0.1, 0.5)
                Move({
                    Ids = { components[key].Id, components[buttonKey].Id },
                    OffsetX = offsetX,
                    OffsetY = offsetY,
                    Duration = delay
                })
                local titleText = ShallowCopyTable(screen.TitleText)
                titleText.Id = components[buttonKey].Id
                titleText.Text = boss.Name
                CreateTextBox(titleText)
			end
		end
	else
		local txt = mod.Locale.BossSelectorNoSavedState

		components.Infobox = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray" })
		Attach({ Id = components.Infobox.Id, DestinationId = components.Background.Id, OffsetX = 0, OffsetY = 0 })
		CreateTextBox({
			Id = components.Infobox.Id,
			Text = txt,
			FontSize = 80,
			OffsetX = 0,
			OffsetY = 0,
			-- Width = 720,
			Color = Color.Red,
			Font = "P22UndergroundSCMedium",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Center"
		})
	end

	--

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
end

function mod.HandleBossSelection(screen, button)
	if mod.Data.SavedState == nil then
		return
	end
	local boss = button.Boss
	mod.CloseBossSelectScreen(screen)

	boss.Room.KillHeroOnCompletion = true

	boss.Room.NoReward = true
	boss.Room.ForcedReward = nil
	boss.Room.HasHarvestPoint = false
	boss.Room.HasShovelPoint = false
	boss.Room.HasPickaxePoint = false
	boss.Room.HasFishingPoint = false
	boss.Room.HasExorcismPoint = false
	boss.Room.TimeChallengeSwitchSpawnChance = 0.0
	boss.Room.WellShopSpawnChance = 0.0
	boss.Room.SecretSpawnChance = 0.0
	mod.StartNewCustomRun(boss.Room)
end

function mod.CloseBossSelectScreen(screen)
	ShowCombatUI(screen.Name)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters("BossSelector")
end

--#endregion

--#region CONSUMABLE SELECTOR

function mod.OpenConsumableSelector()
	if IsScreenOpen("ConsumableSelector") then
		return
	end
	mod.UpdateScreenData()

	local screen = DeepCopyTable(ScreenData.ConsumableSelector)
	screen.Amount = 0
	screen.FirstPage = 0
	screen.LastPage = 0
	screen.CurrentPage = screen.FirstPage
	local components = screen.Components

	OnScreenOpened(screen)
	HideCombatUI(screen.Name)
	CreateScreenFromData(screen, screen.ComponentData)
	--Display
	local displayedConsumables = {}
	local index = 0
	screen.ConsumableList = {}
	for k, consumable in pairs(mod.ConsumableData) do
		if not Contains(displayedConsumables, consumable) then
			table.insert(displayedConsumables, consumable)
			local rowOffset = 100
			local columnOffset = 400
			local boonsPerRow = 4
			local rowsPerPage = 7
			local rowIndex = math.floor(index / boonsPerRow)
			local pageIndex = math.floor(rowIndex / rowsPerPage)
			local offsetX = screen.RowStartX + columnOffset * (index % boonsPerRow)
			local offsetY = screen.RowStartY + rowOffset * (rowIndex % rowsPerPage)
			index = index + 1
			screen.LastPage = pageIndex
			if screen.ConsumableList[pageIndex] == nil then
				screen.ConsumableList[pageIndex] = {}
			end
			table.insert(screen.ConsumableList[pageIndex], {
				index = index,
				consumable = consumable,
				pageIndex = pageIndex,
				offsetX = offsetX,
				offsetY = offsetY,
				key = k
			})
		end
	end
	mod.ConsumableSelectorLoadPage(screen)
	--

	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	wait(0.3)

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
end

function mod.CloseConsumableSelector(screen)
	ShowCombatUI(screen.Name)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters("ConsumableSelector")
end

function mod.ConsumableSelectorLoadPage(screen)
	mod.BoonManagerPageButtons(screen, screen.Name)
	local displayedConsumables = {}
	local pageConsumables = screen.ConsumableList[screen.CurrentPage]
	if pageConsumables then
		for i, consumableData in pairs(pageConsumables) do
			if displayedConsumables[consumableData] or displayedConsumables[consumableData] then
				--Skip
			else
				local purchaseButtonKey = "PurchaseButton" .. consumableData.index
				consumableData.consumable.ObjectId = purchaseButtonKey
				screen.Components[purchaseButtonKey] = CreateScreenComponent({
					Name = "ButtonDefault",
					Group = "Combat_Menu_TraitTray",
					Scale = 1.2,
					ScaleX = 1.15,
					ToDestroy = true
				})
				SetInteractProperty({
					DestinationId = screen.Components[purchaseButtonKey].Id,
					Property = "TooltipOffsetY",
					Value = 100
				})
				screen.Components[purchaseButtonKey].OnPressedFunctionName = mod.GiveConsumableToPlayer
				screen.Components[purchaseButtonKey].Consumable = consumableData.consumable
				screen.Components[purchaseButtonKey].Index = consumableData.index

				-- local data = ResourceData[consumableData.consumable]
				if consumableData.consumable.DoorIcon then
					local icon = {
						Name = "BlankObstacle",
						Animation = consumableData.consumable.DoorIcon,
						Scale = 0.5,
						Group = "Combat_Menu_TraitTray",
						ToDestroy = true
					}
					screen.Components[purchaseButtonKey .. "Icon"] = CreateScreenComponent(icon)
					screen.Components[purchaseButtonKey].Icon = screen.Components[purchaseButtonKey .. "Icon"]
				end
				Attach({
					Id = screen.Components[purchaseButtonKey].Id,
					DestinationId = screen.Components.Background.Id,
					OffsetX = consumableData.offsetX,
					OffsetY = consumableData.offsetY
				})

				-- local text = consumableData.consumable.UseText
				-- text = text:gsub("Use", ""):gsub("Drop", "")
				local text = consumableData.key

				CreateTextBox({
					Id = screen.Components[purchaseButtonKey].Id,
					Text = text,
					FontSize = 22,
					OffsetX = 0,
					OffsetY = -5,
					Width = 720,
					Color = Color.White,
					Font = "P22UndergroundSCMedium",
					ShadowBlur = 0,
					ShadowColor = { 0, 0, 0, 1 },
					ShadowOffset = { 0, 2 },
					Justification = "Center"
				})
				if consumableData.consumable.DoorIcon then
					Attach({
						Id = screen.Components[purchaseButtonKey .. "Icon"].Id,
						DestinationId = screen.Components[purchaseButtonKey].Id,
						OffsetX = -150
					})
				end
			end
		end
	end
end

mod.flags = { }

function mod.updateExtraSelectorText()
	local screen = DeepCopyTable(ScreenData.ExtraSelector)
	for i, button in pairs(ScreenData.ExtraSelector.ComponentData.Background.Children) do
		if mod.flags[i] then
			if mod.flags[i] == "ON" then
				button.TextArgs.Color = Color.Blue
				button.Text = "已启用" .. button.Data.OriText
				CreateScreenFromData(screen, button)
			else
				button.TextArgs.Color = Color.Red
				button.Text = "取消" .. button.Data.OriText
				CreateScreenFromData(screen, button)
			end
		else
			if button.Data.OriText then
				button.TextArgs.Color = Color.White
				button.Text = button.Data.OriText
			end
		end
	end
end

function mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		mod.flags[button.Key] = nil
		ModifyTextBox({ Id = button.Id, Text = button.OriText, Color = Color.White })
		debugShowText("取消" .. button.OriText)
		PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
	else
		mod.flags[button.Key] = button.Id
		ModifyTextBox({ Id = button.Id, Text = "取消" .. button.OriText, Color = Color.Red })
		debugShowText(button.OriText)
		PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	end
end


function mod.setOnForButton(button)
	if not mod.flags[button.Key] then
		mod.flags[button.Key] = "ON"
		ModifyTextBox({ Id = button.Id, Text = "已启用" .. button.OriText, Color = Color.Blue })
		debugShowText(button.OriText)
		PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	end
end

-- 设置必出混沌门
function mod.setChaosGate(screen, button)
	mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		IsSecretDoorEligible = patchIsSecretDoorEligible(IsSecretDoorEligible)
	else
		IsSecretDoorEligible = PreIsSecretDoorEligible
	end
end

-- 必定出英雄稀有度祝福
function mod.setHeroic(screen, button)
	mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		SetTraitsOnLoot = patchSetTraitsOnLoot(SetTraitsOnLoot)
		SetTransformingTraitsOnLoot = patchSetTransformingTraitsOnLoot(SetTransformingTraitsOnLoot)
	else
		SetTraitsOnLoot = PreSetTraitsOnLoot
		SetTransformingTraitsOnLoot = PreSetTransformingTraitsOnLoot
	end
end

-- 不再出现资源房间
function mod.setNoRewardRoom(screen, button)
	mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		ChooseRoomReward = patchChooseRoomReward(ChooseRoomReward)
	else
		ChooseRoomReward = PreChooseRoomReward
	end
end

-- 设置无限掷骰
function mod.setInfiniteRoll(screen, button)
	mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		infiniteRoll = true
		AttemptReroll = patchAttemptReroll(AttemptReroll)
		AttemptPanelReroll = patchAttemptPanelReroll(AttemptPanelReroll)
		RunStateInit = patchBeforeEachRoom(RunStateInit)
		RerollCosts.Hammer = 1
	else
		infiniteRoll = false
		AttemptReroll = PreAttemptReroll
		AttemptPanelReroll = PreAttemptPanelReroll
		RerollCosts.Hammer = -1
		--RemoveTrait(CurrentRun.Hero, "DoorRerollMetaUpgrade")
		--RemoveTrait(CurrentRun.Hero, "PanelRerollMetaUpgrade")
	end
end

-- 本轮额外冲刺次数+1
function mod.setExtrarush(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = 'CheatExtraRush' , Rarity = "Common" } ) } )
	curExtraRushCount = 0
end

-- 金币+100
function mod.setMoreMoney(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	AddResource( "Money", 100, "RunStart" )
end

-- 给我恢复
function mod.setRestoreHealth(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	Heal( CurrentRun.Hero, {HealAmount = 1000 })
end

-- 给我充能
function mod.setRestoreMana(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	CurrentRun.Hero.Mana =  CurrentRun.Hero.MaxMana
	thread( UpdateHealthUI, triggerArgs )
	thread( UpdateManaMeterUI, triggerArgs )
end

-- 击杀加1%概率掉落祝福
function mod.setDropLoot(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
	metaupgradeDropBoonBoost = metaupgradeDropBoonBoost + 0.01
	if metaupgradeDropBoonBoost > 0.1 then
		metaupgradeDropBoonBoost = 0.1
	end
	warningShowTest('当前概率' .. metaupgradeDropBoonBoost*1000 .. '%')
	KillEnemy = patchKill(KillEnemy)
end

-- 关闭击杀概率掉落祝福
function mod.setStopDropLoot(screen, button)
	PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
	metaupgradeDropBoonBoost = 0
	KillEnemy = PreKillEnemy
end

-- Boss 显示血量
function mod.BossHealthLoot(screen, button)
	mod.setOnForButton(button)
	ModUtil.Path.Override("CreateBossHealthBar", function(boss)
		local encounter = CurrentRun.CurrentRoom.Encounter
		if encounter ~= nil and encounter.UseGroupHealthBar ~= nil then
			if not boss.HasHealthBar then
				local offsetY = -155
				boss.HasHealthBar = true
				if boss.Scale ~= nil then
					offsetY = offsetY * boss.Scale
				end
				if boss.HealthBarOffsetY then
					offsetY = boss.HealthBarOffsetY
				end
				-- Invisible health bar for effect purposes
				local screenId = SpawnObstacle({ Name = "BlankObstacle", Group = "Combat_UI_World", DestinationId = boss.ObjectId, Attach = true, OffsetY = offsetY, TriggerOnSpawn = false })
				EnemyHealthDisplayAnchors[boss.ObjectId] = screenId
			end
			if not encounter.HasHealthBar then
				CreateGroupHealthBar(encounter)
			end
			return
		end
		if boss.HasHealthBar then
			return
		end
		boss.HasHealthBar = true

		if ScreenAnchors.BossHealthTitles == nil then
			ScreenAnchors.BossHealthTitles = {}
		end
		local index = TableLength(ScreenAnchors.BossHealthTitles)
		local numBars = GetNumBossHealthBars()
		local yOffset = 0
		local xScale = 1 / numBars
		boss.BarXScale = xScale
		local totalWidth = ScreenWidth * xScale
		local xOffset = (totalWidth / (2 * numBars)) * (1 + index * 2) + (ScreenWidth - totalWidth) / 2

		if numBars == 0 then
			return
		end

		ScreenAnchors.BossHealthBack = CreateScreenObstacle({ Name = "BossHealthBarBack", Group = "Combat_UI", X = xOffset, Y = 70 + yOffset })
		ScreenAnchors.BossHealthTitles[boss.ObjectId] = ScreenAnchors.BossHealthBack

		local fallOffBar = CreateScreenObstacle({ Name = "BossHealthBarFillFalloff", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })
		SetColor({ Id = fallOffBar, Color = Color.HealthFalloff })
		SetAnimationFrameTarget({ Name = "EnemyHealthBarFillSlowBoss", Fraction = 0, DestinationId = fallOffBar, Instant = true })

		ScreenAnchors.BossHealthFill = CreateScreenObstacle({ Name = "BossHealthBarFill", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })

		CreateAnimation({ Name = "BossNameShadow", DestinationId = ScreenAnchors.BossHealthBack })

		SetScaleX({ Ids = { ScreenAnchors.BossHealthBack, ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = xScale, Duration = 0 })

		local bossName = boss.HealthBarTextId or boss.Name

		if boss.AltHealthBarTextIds ~= nil then
			local eligibleTextIds = {}
			for k, altTextIdData in pairs(boss.AltHealthBarTextIds) do
				if IsGameStateEligible(CurrentRun, altTextIdData.Requirements) then
					table.insert(eligibleTextIds, altTextIdData.TextId)
				end
			end
			if not IsEmpty(eligibleTextIds) then
				bossName = GetRandomValue(eligibleTextIds)
			end
		end

		CreateTextBox({
			Id = ScreenAnchors.BossHealthBack,
			Text = bossName,
			Font = "CaesarDressing",
			FontSize = 22,
			ShadowRed = 0,
			ShadowBlue = 0,
			ShadowGreen = 0,
			OutlineColor = { 0, 0, 0, 1 },
			OutlineThickness = 2,
			ShadowAlpha = 1.0,
			ShadowBlur = 0,
			ShadowOffsetY = 3,
			ShadowOffsetX = 0,
			Justification = "Center",
			OffsetY = -30,
			OpacityWithOwner = false,
			AutoSetDataProperties = true,
		})
		--Mod start
		boss.NumericHealthbar = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Combat_UI", X = xOffset, Y = 112 + yOffset })
		CreateTextBox({
			Id = boss.NumericHealthbar,
			Text = boss.Health .. "/" .. boss.MaxHealth,
			FontSize = 18,
			ShadowRed = 0,
			ShadowBlue = 0,
			ShadowGreen = 0,
			OutlineColor = { 0, 0, 0, 1 },
			OutlineThickness = 2,
			ShadowAlpha = 1.0,
			ShadowBlur = 0,
			ShadowOffsetY = 3,
			ShadowOffsetX = 0,
			Justification = "Center",
			OffsetY = 0,
			OpacityWithOwner = false,
			AutoSetDataProperties = true,
		})
		--Mod end

		ModifyTextBox({ Id = ScreenAnchors.BossHealthBack, FadeTarget = 0, FadeDuration = 0 })
		SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 0.01, Duration = 0.0 })
		SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 1.0, Duration = 2.0 })
		EnemyHealthDisplayAnchors[boss.ObjectId .. "back"] = ScreenAnchors.BossHealthBack

		boss.HealthBarFill = "EnemyHealthBarFillBoss"
		SetAnimationFrameTarget({ Name = "EnemyHealthBarFillBoss", Fraction = boss.Health / boss.MaxHealth, DestinationId = screenId })
		SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 0.01, Duration = 0.0 })
		SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 1, Duration = 2.0 })
		EnemyHealthDisplayAnchors[boss.ObjectId] = ScreenAnchors.BossHealthFill
		EnemyHealthDisplayAnchors[boss.ObjectId .. "falloff"] = fallOffBar
		--Mod start
		EnemyHealthDisplayAnchors[boss.ObjectId .. "numeric"] = boss.NumericHealthbar
		--Mod end
		thread(BossHealthBarPresentation, boss)
	end)

	ModUtil.Path.Override("CreateGroupHealthBar", function(encounter)
		encounter.HasHealthBar = true

		local xOffset = ScreenWidth / 2
		local yOffset = 0
		if ScreenAnchors.BossHealthTitles == nil then
			ScreenAnchors.BossHealthTitles = {}
		end

		ScreenAnchors.BossHealthBack = CreateScreenObstacle({ Name = "BossHealthBarBack", Group = "Combat_UI", X = xOffset, Y = 70 + yOffset })
		ScreenAnchors.BossHealthTitles[encounter.Name] = ScreenAnchors.BossHealthBack

		local fallOffBar = CreateScreenObstacle({ Name = "BossHealthBarFillFalloff", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })
		SetColor({ Id = fallOffBar, Color = Color.HealthFalloff })
		SetAnimationFrameTarget({ Name = "EnemyHealthBarFillSlowBoss", Fraction = 0, DestinationId = fallOffBar, Instant = true })

		ScreenAnchors.BossHealthFill = CreateScreenObstacle({ Name = "BossHealthBarFill", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })

		CreateAnimation({ Name = "BossNameShadow", DestinationId = ScreenAnchors.BossHealthBack })

		SetScaleX({ Ids = { ScreenAnchors.BossHealthBack, ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 1, Duration = 0 })

		local barName = EncounterData[encounter.Name].HealthBarTextId or encounter.Name

		CreateTextBox({
			Id = ScreenAnchors.BossHealthBack,
			Text = barName,
			Font = "CaesarDressing",
			FontSize = 22,
			ShadowRed = 0,
			ShadowBlue = 0,
			ShadowGreen = 0,
			OutlineColor = { 0, 0, 0, 1 },
			OutlineThickness = 2,
			ShadowAlpha = 1.0,
			ShadowBlur = 0,
			ShadowOffsetY = 3,
			ShadowOffsetX = 0,
			Justification = "Center",
			OffsetY = -30,
			OpacityWithOwner = false,
			AutoSetDataProperties = true,
		})
		--Mod start
		ScreenAnchors.NumericHealthbar = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Combat_UI", X = xOffset, Y = 112 + yOffset })
		CreateTextBox({
			Id = ScreenAnchors.NumericHealthbar,
			Text = encounter.GroupHealth .. "/" .. encounter.GroupMaxHealth,
			FontSize = 18,
			ShadowRed = 0,
			ShadowBlue = 0,
			ShadowGreen = 0,
			OutlineColor = { 0, 0, 0, 1 },
			OutlineThickness = 2,
			ShadowAlpha = 1.0,
			ShadowBlur = 0,
			ShadowOffsetY = 3,
			ShadowOffsetX = 0,
			Justification = "Center",
			OffsetY = 0,
			OpacityWithOwner = false,
			AutoSetDataProperties = true,
		})
		--Mod end

		ModifyTextBox({ Id = ScreenAnchors.BossHealthBack, FadeTarget = 0, FadeDuration = 0 })
		SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 0.01, Duration = 0.0 })
		SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 1.0, Duration = 2.0 })
		EnemyHealthDisplayAnchors[encounter.Name .. "back"] = ScreenAnchors.BossHealthBack

		encounter.HealthBarFill = "EnemyHealthBarFillBoss"
		SetAnimationFrameTarget({ Name = "EnemyHealthBarFillBoss", Fraction = 1, DestinationId = ScreenAnchors.BossHealthFill })
		SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 0.01, Duration = 0.0 })
		SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 1, Duration = 2.0 })
		EnemyHealthDisplayAnchors[encounter.Name] = ScreenAnchors.BossHealthFill
		EnemyHealthDisplayAnchors[encounter.Name .. "falloff"] = fallOffBar
		--Mod start
		EnemyHealthDisplayAnchors[encounter.Name .. "numeric"] = ScreenAnchors.NumericHealthbar
		--Mod end
		thread(GroupHealthBarPresentation, encounter)
	end)

	ModUtil.Path.Override("UpdateHealthBarReal", function(args)
		local enemy = args[1]

		if enemy.UseGroupHealthBar then
			UpdateGroupHealthBarReal(args)
			return
		end

		local screenId = args[2]
		local scorchId = args[3]
		--Mod start
		local numericHealthBar = EnemyHealthDisplayAnchors[enemy.ObjectId .. "numeric"]
		--Mod end

		if enemy.IsDead then
			if enemy.UseBossHealthBar then
				CurrentRun.BossHealthBarRecord[enemy.Name] = 0
			end
			SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1, DestinationId = scorchId, Instant = true })
			SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1, DestinationId = screenId, Instant = true })
			--Mod start
			if numericHealthBar ~= nil then
				Destroy({ Id = numericHealthBar })
			end
			--Mod end
			return
		end


		local maxHealth = enemy.MaxHealth
		local currentHealth = enemy.Health
		if currentHealth == nil then
			currentHealth = maxHealth
		end

		UpdateHealthBarIcons(enemy)

		if enemy.UseBossHealthBar then
			local healthFraction = currentHealth / maxHealth
			CurrentRun.BossHealthBarRecord[enemy.Name] = healthFraction
			SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - healthFraction, DestinationId = screenId, Instant = true })
			--Mod start
			ModifyTextBox({ Id = numericHealthBar, Text = round(currentHealth) .. "/" .. maxHealth })
			--Mod end
			if enemy.HitShields > 0 then
				SetColor({ Id = screenId, Color = Color.HitShield })
			else
				SetColor({ Id = screenId, Color = Color.Red })
			end
			thread(UpdateBossHealthBarFalloff, enemy)
			return
		end

		local displayedHealthPercent = 1
		local predictedHealthPercent = 1

		if enemy.CursedHealthBarEffect then
			if enemy.HitShields ~= nil and enemy.HitShields > 0 then
				SetColor({ Id = screenId, Color = Color.CurseHitShield })
			elseif enemy.HealthBuffer ~= nil and enemy.HealthBuffer > 0 then
				SetColor({ Id = screenId, Color = Color.CurseHealthBuffer })
			else
				SetColor({ Id = screenId, Color = Color.CurseHealth })
			end
			SetColor({ Id = backingScreenId, Color = Color.CurseFalloff })
		elseif enemy.Charmed then
			SetColor({ Id = screenId, Color = Color.CharmHealth })
			SetColor({ Id = backingScreenId, Color = Color.HealthBufferFalloff })
		else
			if enemy.HitShields ~= nil and enemy.HitShields > 0 then
				SetColor({ Id = screenId, Color = Color.HitShield })
			elseif enemy.HealthBuffer ~= nil and enemy.HealthBuffer > 0 then
				SetColor({ Id = screenId, Color = Color.HealthBuffer })
				SetColor({ Id = backingScreenId, Color = Color.HealthBufferFalloff })
			else
				SetColor({ Id = screenId, Color = Color.Red })
				SetColor({ Id = backingScreenId, Color = Color.HealthFalloff })
			end
		end

		if enemy.HitShields ~= nil and enemy.HitShields > 0 then
			displayedHealthPercent = 1
			predictedHealthPercent = 1
		elseif enemy.HealthBuffer ~= nil and enemy.HealthBuffer > 0 then
			displayedHealthPercent = enemy.HealthBuffer / enemy.MaxHealthBuffer
			if enemy.ActiveEffects and enemy.ActiveEffects.BurnEffect then
				predictedHealthPercent = math.max(0, enemy.HealthBuffer - enemy.ActiveEffects.BurnEffect) / enemy.MaxHealthBuffer
			else
				predictedHealthPercent = displayedHealthPercent
			end
		else
			displayedHealthPercent = currentHealth / maxHealth
			if enemy.ActiveEffects and enemy.ActiveEffects.BurnEffect then
				predictedHealthPercent = math.max(0, currentHealth - enemy.ActiveEffects.BurnEffect) / maxHealth
			else
				predictedHealthPercent = displayedHealthPercent
			end
		end
		enemy.DisplayedHealthFraction = displayedHealthPercent
		SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - predictedHealthPercent, DestinationId = screenId, Instant = true })
		SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - displayedHealthPercent, DestinationId = scorchId, Instant = true })
		thread(UpdateEnemyHealthBarFalloff, enemy)
	end)

	ModUtil.Path.Override("UpdateGroupHealthBarReal", function(args)
		local enemy = args[1]
		local screenId = args[2]
		local encounter = CurrentRun.CurrentRoom.Encounter
		local backingScreenId = EnemyHealthDisplayAnchors[encounter.Name .. "falloff"]

		local maxHealth = encounter.GroupMaxHealth
		local currentHealth = 0
		--Mod start
		local numericHealthBar = ScreenAnchors.NumericHealthbar
		--Mod end

		for k, unitId in pairs(encounter.HealthBarUnitIds) do
			local unit = ActiveEnemies[unitId]
			if unit ~= nil then
				currentHealth = currentHealth + unit.Health
			end
		end
		encounter.GroupHealth = currentHealth

		local healthFraction = currentHealth / maxHealth
		CurrentRun.BossHealthBarRecord[encounter.Name] = healthFraction
		--Mod start
		ModifyTextBox({ Id = numericHealthBar, Text = round(currentHealth) .. "/" .. maxHealth })
		--Mod end

		SetAnimationFrameTarget({ Name = encounter.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - healthFraction, DestinationId = screenId, Instant = true })
		thread(UpdateGroupHealthBarFalloff, encounter)
	end)

	ModUtil.Path.Wrap("BossChillKillPresentation", function(base, unit)
		if EnemyHealthDisplayAnchors[unit.ObjectId .. "numeric"] ~= nil then
			local numericHealthBar = EnemyHealthDisplayAnchors[unit.ObjectId .. "numeric"]
			Destroy({ Id = numericHealthBar })
		end
		base(unit)
	end)
end

-- 混沌祝福可以重复
function mod.RepeatableChaosTrials(screen, button)
	mod.setOnForButton(button)
	ModUtil.Path.Override("BountyBoardScreenDisplayCategory", function(screen, categoryIndex)
		BountyBoardScreenDisplayCategory_override(screen, categoryIndex)
	end)

	ModUtil.Path.Wrap("MouseOverBounty", function(base, button)
		base(button)
		if GameState.BountiesCompleted[button.Data.Name] then
			SetAlpha({ Id = button.Screen.Components.SelectButton.Id, Fraction = 1.0, Duration = 0.2 })
		end
	end)
end

function patchSpendResource( fun )
	function newFun(name, amount, source, args)
		-- return true
		-- 父函数，照常执行
		fun(name, 0, source, args)
	end
	return newFun
end
function patchSpendResources( fun )
	function newFun(resourceCosts, source, args )
		-- 父函数，照常执行
		fun(nil, source, args )
	end
	return newFun
end
function patchHasResources( fun )
	function newFun(resourceCost )
		return true
	end
	return newFun
end
function patchHasResource( fun )
	function newFun( name, amount )
		return true
	end
	return newFun
end
function patchHasResourceCost( fun )
	function newFun( resourceCosts )
		return true
	end
	return newFun
end

function patchRequireAffordableMetaUpgrade(fun)
	function newFun( source, args )
		return true
	end
	return newFun
end

function patchGetCurrentMetaUpgradeCost( upgradeName )
	function newFun( )
		return 0
	end
	return newFun
end

PreRequireAffordableMetaUpgrade = nil
PreGetCurrentMetaUpgradeCost = nil

-- 免费购买
function mod.FreeToBuy(screen, button)
	mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		SpendResource = patchSpendResource(SpendResource)
		-- SpendResources = patchSpendResources(SpendResources)
		HasResources = patchHasResources(HasResources)
		HasResource = patchHasResource(HasResource)
		HasResourceCost = patchHasResourceCost(HasResourceCost)
		RequireAffordableMetaUpgrade = patchRequireAffordableMetaUpgrade(RequireAffordableMetaUpgrade)
		GetCurrentMetaUpgradeCost = patchGetCurrentMetaUpgradeCost(GetCurrentMetaUpgradeCost)
	else
		SpendResource = PreSpendResource
		-- SpendResources = PreSpendResources
		HasResources = PreHasResources
		HasResource = PreHasResource
		HasResourceCost = PreHasResourceCost
		RequireAffordableMetaUpgrade = PreRequireAffordableMetaUpgrade
		GetCurrentMetaUpgradeCost = PreGetCurrentMetaUpgradeCost
	end
end

function mod.PermanentLocationCount(screen, button)
	mod.setOnForButton(button)
	ModUtil.Path.Wrap("ShowHealthUI", function(base)
		base()
		ShowDepthCounter()
	end)

	ModUtil.Path.Wrap("TraitTrayScreenClose", function(base, ...)
		base(...)
		ShowDepthCounter()
	end)
end

function mod.QuitAnywhere(screen, button)
	mod.setOnForButton(button)
	ModUtil.Path.Override("InvalidateCheckpoint", function()
		ValidateCheckpoint({ Value = true })
	end)
end

function ShowDepthCounter()
	local screen = { Name = "RoomCount", Components = {} }
	screen.ComponentData = {
		RoomCount = DeepCopyTable(ScreenData.TraitTrayScreen.ComponentData.RoomCount)
	}
	CreateScreenFromData(screen, screen.ComponentData)
end

function mod.setEphyraZoomOut(screen, button)
	mod.setFlagForButton(button)
	if mod.flags[button.Key] then
		EphyraZoomOut = EphyraZoomOut_override
	else
		EphyraZoomOut = EphyraZoomOutPre
	end
end

PreHasResource = nil
PreHasResourceCost = nil

-- 打开我的修改页面
function mod.ExtraSelectorLoadPage()
	if not initPreFun then
		PreSetTraitsOnLoot = SetTraitsOnLoot
		PreKillEnemy = KillEnemy
		PreSetTransformingTraitsOnLoot = SetTransformingTraitsOnLoot
		PreIsSecretDoorEligible = IsSecretDoorEligible
		PreChooseRoomReward = ChooseRoomReward
		PreAttemptReroll = AttemptReroll
		PreAttemptPanelReroll = AttemptPanelReroll
		PreHasAccessToTool = HasAccessToTool
		PreSpendResource = SpendResource
		PreSpendResources = SpendResources
		PreHasResources = HasResources
		PreHasResource = HasResource
		PreHasResourceCost = HasResourceCost
		PreRequireAffordableMetaUpgrade = RequireAffordableMetaUpgrade
		PreGetCurrentMetaUpgradeCost = GetCurrentMetaUpgradeCost
		initPreFun = true
		EphyraZoomOutPre = EphyraZoomOut
	end

	if IsScreenOpen("ExtraSelector") then
		return
	end
	local screen = DeepCopyTable(ScreenData.ExtraSelector)

	mod.BoonManagerPageButtons(screen, screen.Name)
	mod.UpdateScreenData()
	--CloseInventoryScreen(screen, screen.ComponentData.ActionBar.Children.CloseButton)

	screen.FirstPage = 0
	screen.LastPage = 0
	screen.CurrentPage = screen.FirstPage

	local components = screen.Components

	OnScreenOpened(screen)
	CreateScreenFromData(screen, screen.ComponentData)
	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	wait(0.3)

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
	mod.updateExtraSelectorText()
end

function mod.GiveConsumableToPlayer(screen, button)
	-- MapState.RoomRequiredObjects = {}
	if button.Consumable.UseFunctionName and button.Consumable.UseFunctionName == "OpenTalentScreen" then
        DropMinorConsumable( button.Consumable.key )
--     	if not CurrentRun.ConsumableRecord["SpellDrop"] then
--             PlaySound({ Name = "/Leftovers/SFX/OutOfAmmo" })
-- 			return
-- 		end
-- 		mod.CloseConsumableSelector(screen)
	end
	UseConsumableItem(button.Consumable, {}, CurrentRun.Hero)
end

--#endregion

EphyraZoomOutPre = nil
function EphyraZoomOut_override( usee )
	warningShowTest('1')
	AddInputBlock({ Name = "EphyraZoomOut" })
	AddTimerBlock( CurrentRun, "EphyraZoomOut" )
	SessionMapState.BlockPause = true
	thread( HideCombatUI, "EphyraZoomOut", { SkipHideObjectives = true } )
	SetInvulnerable({ Id = CurrentRun.Hero.ObjectId })

	UseableOff({ Id = usee.ObjectId })

	ClearCameraClamp({ LerpTime = 0.8 })
	thread( SendCritters, { MinCount = 20, MaxCount = 20, StartX = 0, RandomStartOffsetX = 1200, StartY = 300, MinAngle = 75, MaxAngle = 115, MinSpeed = 400, MaxSpeed = 2000, MinInterval = 0.001, MaxInterval = 0.001, GroupName = "CrazyDeathBats" } )
	PanCamera({ Id = CurrentRun.Hero.ObjectId, OffsetY = -350, Duration = 1.0, EaseIn = 0, EaseOut = 0, Retarget = true })
	FocusCamera({ Fraction = CurrentRun.CurrentRoom.ZoomFraction * 0.95, Duration = 1, ZoomType = "Ease" })

	wait( 0.50 )

	local groupName = "Combat_Menu_Backing"
	local idsCreated = {}

	ScreenAnchors.EphyraZoomBackground = CreateScreenObstacle({ Name = "rectangle01", Group = "Combat_Menu", X = ScreenCenterX, Y = ScreenCenterY })
	table.insert( idsCreated, ScreenAnchors.EphyraZoomBackground )
	SetScale({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 5 })
	SetColor({ Ids = { ScreenAnchors.EphyraZoomBackground }, Color = Color.Black })
	SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 0, Duration = 0 })
	SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 1.0, Duration = 0.2 })

	local letterboxIds = {}
	if ScreenState.NeedsLetterbox then
		local letterboxId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenCenterX, Y = ScreenCenterY, Group = "Combat_Menu", Animation = "GUI\\Graybox\\NativeAspectRatioFrame", Alpha = 0.0 })
		table.insert( letterboxIds, letterboxId )
		SetAlpha({ Id = letterboxId, Fraction = 1.0, Duration = 0.2, EaseIn = 0.0, EaseOut = 1.0 })
	elseif ScreenState.NeedsPillarbox then
		local pillarboxLeftId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenState.PillarboxLeftX, Y = ScreenCenterY, ScaleX = ScreenState.PillarboxScaleX, Group = "Combat_Menu", Animation = "GUI\\SideBars_01", Alpha = 0.0 })
		table.insert( letterboxIds, pillarboxLeftId )
		SetAlpha({ Id = pillarboxLeftId, Fraction = 1.0, Duration = 0.2, EaseIn = 0.0, EaseOut = 1.0 })
		FlipHorizontal({ Id = pillarboxLeftId })
		local pillarboxRightId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenState.PillarboxRightX, Y = ScreenCenterY, ScaleX = ScreenState.PillarboxScaleX, Group = "Combat_Menu", Animation = "GUI\\SideBars_01", Alpha = 0.0 })
		table.insert( letterboxIds, pillarboxRightId )
		SetAlpha({ Id = pillarboxRightId, Fraction = 1.0, Duration = 0.2, EaseIn = 0.0, EaseOut = 1.0 })
	end

	wait( 0.21 )

	ScreenAnchors.EphyraMapId = CreateScreenObstacle({ Name = "rectangle01", Group = groupName, X = ScreenCenterX, Y = ScreenCenterY })
	table.insert( idsCreated, ScreenAnchors.EphyraMapId )
	SetAnimation({ Name = usee.MapAnimation, DestinationId = ScreenAnchors.EphyraMapId })
	SetHSV({ Id = ScreenAnchors.EphyraMapId, HSV = { 0, -0.15, 0 }, ValueChangeType = "Add" })

	local exitDoorsIPairs = CollapseTableOrdered( MapState.OfferedExitDoors )
	local sortedDoors = {}
	for index, door in ipairs( exitDoorsIPairs ) do
		if not door.SkipUnlock then
			local room = door.Room
			local rawScreenLocation = ObstacleData[usee.Name].ScreenLocations[door.ObjectId]
			if rawScreenLocation ~= nil then
				door.ScreenLocationX = rawScreenLocation.X
				door.ScreenLocationY = rawScreenLocation.Y
				table.insert( sortedDoors, door )
			end
		end
	end
	table.sort( sortedDoors, EphyraZoomOutDoorSort )

	local attachedCircles = {}
	for index, door in ipairs( sortedDoors ) do
		local room = door.Room
		local screenLocation = { X = door.ScreenLocationX + ScreenCenterNativeOffsetX, Y = door.ScreenLocationY + ScreenCenterNativeOffsetY }
		local rewardBackingId = CreateScreenObstacle({ Name = "BlankGeoObstacle", Group = groupName, X = screenLocation.X, Y = screenLocation.Y, Scale = 0.6 })
		if room.RewardStoreName == "MetaProgress" then
			SetAnimation({ Name = "RoomRewardAvailable_Back_Meta", DestinationId = rewardBackingId })
		else
			SetAnimation({ Name = "RoomRewardAvailable_Back_Run", DestinationId = rewardBackingId })
		end
		table.insert( attachedCircles, rewardBackingId )

		local rewardIconId = CreateScreenObstacle({ Name = "RoomRewardPreview", Group = groupName, X = screenLocation.X, Y = screenLocation.Y, Scale = 0.6 })
		SetColor({ Id = rewardIconId, Color = { 0,0,0,1} })
		table.insert( attachedCircles, rewardIconId )
		local rewardHidden = false
		if HasHeroTraitValue( "HiddenRoomReward" ) then
			SetAnimation({ DestinationId = rewardIconId, Name = "ChaosPreview" })
			rewardHidden = true
		elseif room.ChosenRewardType == nil or room.ChosenRewardType == "Story" then
			SetAnimation({ DestinationId = rewardIconId, Name = "StoryPreview", SuppressSounds = true })
		elseif room.ChosenRewardType == "Shop" then
			SetAnimation({ DestinationId = rewardIconId, Name = "ShopPreview", SuppressSounds = true })
		elseif room.ChosenRewardType == "Boon" and room.ForceLootName then
			local previewIcon = LootData[room.ForceLootName].DoorIcon or LootData[room.ForceLootName].Icon
			if room.BoonRaritiesOverride ~= nil and LootData[room.ForceLootName].DoorUpgradedIcon ~= nil then
				previewIcon = LootData[room.ForceLootName].DoorUpgradedIcon
			end
			SetAnimation({ DestinationId = rewardIconId, Name = previewIcon, SuppressSounds = true })
		elseif room.ChosenRewardType == "Devotion" then

			local rewardIconAId = CreateScreenObstacle({ Name = "RoomRewardPreview", Group = groupName, X = screenLocation.X + 12, Y = screenLocation.Y - 11, Scale = 0.6 })
			SetColor({ Id = rewardIconAId, Color = { 0,0,0,1} })
			SetAnimation({ DestinationId = rewardIconAId, Name = LootData[room.Encounter.LootAName].DoorIcon, SuppressSounds = true })
			table.insert( attachedCircles, rewardIconAId )

			local rewardIconBId = CreateScreenObstacle({ Name = "RoomRewardPreview", Group = groupName, X = screenLocation.X - 12, Y = screenLocation.Y + 11, Scale = 0.6 })
			SetColor({ Id = rewardIconBId, Color = { 0,0,0,1} })
			SetAnimation({ DestinationId = rewardIconBId, Name = LootData[room.Encounter.LootBName].DoorIcon, SuppressSounds = true })
			table.insert( attachedCircles, rewardIconBId )
		else
			local animName = room.ChosenRewardType
			local lootData = LootData[room.ChosenRewardType]
			if lootData ~= nil then
				animName = lootData.DoorIcon or lootData.Icon or animName
			end
			local consumableData = ConsumableData[room.ChosenRewardType]
			if consumableData ~= nil then
				animName = consumableData.DoorIcon or consumableData.Icon or animName
			end
			SetAnimation({ DestinationId = rewardIconId, Name = animName, SuppressSounds = true })
		end

		local subIcons = PopulateDoorRewardPreviewSubIcons( door, { ChosenRewardType = chosenRewardType, RewardHidden = rewardHidden } )

		-- MOD Start
		if CurrentRun.PylonRooms and CurrentRun.PylonRooms[room.Name] then
			warningShowTest('PylonRooms')
			table.insert(subIcons, "GUI\\Icons\\GhostPack")
		end
		if Contains(room.LegalEncounters, "HealthRestore") then
			warningShowTest('HealthRestore')
			table.insert(subIcons, "ExtraLifeHeart")
		end
		if room.HarvestPointsAllowed > 0 then
			warningShowTest('HarvestPointsAllowed')
			table.insert(subIcons, "GatherIcon")
		end
		if room.ShovelPointSuccess and HasAccessToTool("ToolShovel") then
			warningShowTest('ToolShovel')
			table.insert(subIcons, "ShovelIcon")
		end
		if room.FishingPointSuccess and HasAccessToTool("ToolFishingRod") then
			warningShowTest('ToolFishingRod')
			table.insert(subIcons, "FishingIcon")
		end
		if room.PickaxePointSuccess and HasAccessToTool("ToolPickaxe") then
			warningShowTest('ToolPickaxe')
			table.insert(subIcons, "PickaxeIcon")
		end
		if room.ExorcismPointSuccess and HasAccessToTool("ToolExorcismBook") then
			warningShowTest('ToolExorcismBook')
			table.insert(subIcons, "ExorcismIcon")
		end

		if room.RewardPreviewIcon ~= nil and not HasHeroTraitValue("HiddenRoomReward") then
			warningShowTest('RewardPreviewIcon')
			table.insert(subIcons, room.RewardPreviewIcon)
		end
		-- MOD End

		local iconSpacing = 30
		local numSubIcons = #subIcons
		local isoOffset = iconSpacing * -0.5 * (numSubIcons - 1)
		for i, iconData in ipairs( subIcons ) do
			local iconId = CreateScreenObstacle({ Name = "BlankGeoObstacle", Group = groupName, Scale = 0.6 })
			local offsetAngle = 330
			if IsHorizontallyFlipped({ Id = door.ObjectId }) then
				offsetAngle = 30
				FlipHorizontal({ Id = iconId })
			end
			local offset = CalcOffset( math.rad( offsetAngle ), isoOffset )
			Attach({ Id = iconId, DestinationId = rewardBackingId, OffsetX = offset.X, OffsetY = offset.Y, OffsetZ = -60, })
			SetAnimation({ DestinationId = iconId, Name = iconData.Animation or iconData.Name })
			table.insert( attachedCircles, iconId )
			isoOffset = isoOffset + iconSpacing
		end

		if IsHorizontallyFlipped({ Id = door.ObjectId }) then
			local ids = ( { rewardBackingId, rewardIconId } )
			if not IsEmpty( ids ) then
				FlipHorizontal({ Ids = ids })
			end
		end

	end

	local melScreenLocation = ObstacleData[usee.Name].ScreenLocations[usee.ObjectId]
	ScreenAnchors.MelIconId = nil
	if melScreenLocation ~= nil then
		ScreenAnchors.MelIconId = CreateScreenObstacle({ Name = "rectangle01", Group = groupName, X = melScreenLocation.X + ScreenCenterNativeOffsetX, Y = melScreenLocation.Y + ScreenCenterNativeOffsetY, Scale = 1.5 })
		table.insert( idsCreated, ScreenAnchors.MelIconId )
		SetAnimation({ Name = "Mel_Icon", DestinationId = ScreenAnchors.MelIconId })
	end

	SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 0.0, Duration = 0.35 })
	PlaySound({ Name = "/Leftovers/World Sounds/MapZoomInShort" })
	wait( 0.5 )

	local zoomOutTime = 0.5

	ScreenAnchors.EphyraZoomBackground = CreateScreenObstacle({ Name = "rectangle01", Group = groupName, X = ScreenCenterX, Y = ScreenCenterY })
	table.insert( idsCreated, ScreenAnchors.EphyraZoomBackground )
	SetScale({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 5 })
	SetColor({ Ids = { ScreenAnchors.EphyraZoomBackground }, Color = Color.Black })
	SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 0, Duration = 0 })

	PlayInteractAnimation( usee.ObjectId )

	--FocusCamera({ Fraction = 0.195, Duration = 1, ZoomType = "Ease" })
	--PanCamera({ Id = 664260, Duration = 1.0, EaseIn = 0.3, EaseOut = 0.3 })

	wait(0.3)
	local notifyName = "ephyraZoomBackIn"
	NotifyOnControlPressed({ Names = { "Use", "Rush", "Shout", "Attack2", "Attack1", "Attack3", "AutoLock", "Cancel", }, Notify = notifyName })
	waitUntil( notifyName )
	PlaySound({ Name = "/Leftovers/World Sounds/MapZoomInShort" })

	--FocusCamera({ Fraction = CurrentRun.CurrentRoom.ZoomFraction * 1.0, Duration = 0.5, ZoomType = "Ease" })
	--PanCamera({ Id = CurrentRun.Hero.ObjectId, Duration = 0.5 })

	Move({ Id = ScreenAnchors.LetterBoxTop, Angle = 90, Distance = 150, EaseIn = 0.99, EaseOut = 1.0, Duration = 0.5 })
	Move({ Id = ScreenAnchors.LetterBoxBottom, Angle = 270, Distance = 150, EaseIn = 0.99, EaseOut = 1.0, Duration = 0.5 })
	SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground, ScreenAnchors.MelIconId, ScreenAnchors.EphyraMapId, }, Fraction = 0, Duration = 0.25 })
	SetAlpha({ Ids = attachedCircles, Fraction = 0, Duration = 0.15 })
	SetAlpha({ Ids = letterboxIds, Fraction = 0, Duration = 0.15 })
	Destroy({ Ids = attachedCircles })

	local exitDoorsIPairs = CollapseTableOrdered( MapState.OfferedExitDoors )
	for index, door in ipairs( exitDoorsIPairs ) do
		if not door.SkipUnlock then
			SetScale({ Id = door.DoorIconId, Fraction = 1, Duration = 0.15 })
			AddToGroup({ Id = door.DoorIconId, Name = "FX_Standing_Top", DrawGroup = true })
		end
	end

	PanCamera({ Id = CurrentRun.Hero.ObjectId, OffsetY = 0, Duration = 0.65, EaseIn = 0, EaseOut = 0, Retarget = true })
	FocusCamera({ Fraction = CurrentRun.CurrentRoom.ZoomFraction, Duration = 0.65, ZoomType = "Ease" })
	local roomData = RoomData[CurrentRun.CurrentRoom.Name]
	if not roomData.IgnoreClamps then
		local cameraClamps = roomData.CameraClamps or GetDefaultClampIds()
		DebugAssert({ Condition = #cameraClamps ~= 1, Text = "Exactly one camera clamp on a map is non-sensical" })
		SetCameraClamp({ Ids = cameraClamps, SoftClamp = roomData.SoftClamp })
	end
	wait(0.45)

	thread( ShowCombatUI, "EphyraZoomOut" )
	--SetAlpha({ Ids = { ScreenAnchors.LetterBoxTop, ScreenAnchors.LetterBoxBottom, }, Fraction = 0, Duration = 0.25 })

	RemoveTimerBlock( CurrentRun, "EphyraZoomOut" )
	RemoveInputBlock({ Name = "EphyraZoomOut" })
	SessionMapState.BlockPause = false

	wait( 0.4 )
	Destroy({ Ids = { ScreenAnchors.LetterBoxTop, ScreenAnchors.LetterBoxBottom, ScreenAnchors.EphyraZoomBackground, ScreenAnchors.MelIconId, ScreenAnchors.EphyraMapId } })

	wait( 0.35 )
	SetVulnerable({ Id = CurrentRun.Hero.ObjectId })
	UseableOn({ Id = usee.ObjectId })

	Destroy({ Ids = idsCreated })
	Destroy({ Ids = letterboxIds })
end