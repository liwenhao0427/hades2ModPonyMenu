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
		children.LegendaryButton = nil
		children.RareButton = nil
		children.EpicButton = nil
		children.HeroicButton = nil
	elseif itemData.Hammer then
		screen.IsHammer = true
		children.RareButton = nil
		children.EpicButton = nil
		children.HeroicButton = nil
	else
		children.LegendaryButton = nil
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

function mod.BoonSelectorReloadPage(screen)
	local ids = {}
	for i, component in pairs(screen.Components) do
		if component.ToDestroy then
			table.insert(ids, component.Id)
		end
	end
	Destroy({ Ids = ids })
	mod.BoonSelectorLoadPage(screen)
end

function mod.SpawnBoon(screen, button)
	CreateLoot({ Name = screen.Upgrade, OffsetX = 100, SpawnPoint = CurrentRun.Hero.ObjectId })
	mod.CloseBoonSelector(screen)
end

function mod.ChangeBoonSelectorRarity(screen, button)
	if screen.LockedRarityButton ~= nil and screen.LockedRarityButton == button then
		--nothing to change
		return
	elseif screen.LockedRarityButton ~= nil and screen.LockedRarityButton ~= button then
		screen.LockedRarityButton.Text = screen.LockedRarityButton.Text:gsub(">>", "")
		screen.LockedRarityButton.Text = screen.LockedRarityButton.Text:gsub("<<", "")
		ModifyTextBox({ Id = screen.LockedRarityButton.Id, Text = screen.LockedRarityButton.Text })
	end
	screen.Rarity = button.Rarity
	screen.LockedRarityButton = button
	if not string.match(button.Text, ">>") then
		button.Text = ">>" .. button.Text .. "<<"
		ModifyTextBox({ Id = button.Id, Text = button.Text })
	end
	mod.BoonSelectorReloadPage(screen)
end

function mod.GiveBoonToPlayer(screen, button)
	local boon = button.Boon
	if not HeroHasTrait(boon) then
		if TraitData[boon].Slot == "Spell" then
			if mod.DoesPlayerHaveHex() then
				local bool = true
				while bool do
					bool = mod.HandleSpellRemoval()
				end
			end
			local spell = boon:gsub("Trait", "")
			spell = spell:gsub("Spell", "")
			CurrentRun.Hero.SlottedSpell = DeepCopyTable(SpellData[spell])
			CurrentRun.Hero.SlottedSpell.HasDuoTalent = SessionMapState.DuoTalentEligibleSpell[spell]
			CurrentRun.Hero.SlottedSpell.Talents = DeepCopyTable(CreateTalentTree(SpellData[spell]))
			UpdateTalentPointInvestedCache()
		end
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
				local tdata = TraitData[boonData.Name]
				if not screen.IsHammer then
					if tdata.RarityLevels and tdata.RarityLevels.Legendary then
						boonData.Rarity = "Legendary"
					elseif tdata.IsDuoBoon then
						boonData.Rarity = "Duo"
					else
						boonData.Rarity = screen.Rarity
					end
				else
					if tdata.RarityLevels and tdata.RarityLevels.Legendary then
						boonData.Rarity = screen.Rarity
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
				-- if upgradeData.CustomRarityColor then
				-- 	color = upgradeData.CustomRarityColor
				-- else
				if upgradeData.CustomRarityName == "Boon_Infusion" then
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
	-- if amount < 0 then
	-- 	amount = 0
	-- end
	screen.Amount = amount
	ModifyTextBox({ Id = screen.Components.ResourceAmountTextbox.Id, Text = screen.Amount })
end

function mod.SpawnResource(screen, button)
	if screen.Resource == "None" or screen.Amount == 0 then
		return
	end

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
	children.LegendaryButton = nil
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
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				screen.Traits = CurrentRun.Hero.Traits
				local numTraits = traitData.StackNum or 1
				if numTraits < 100 and traitData.RemainingUses == nil and IsGodTrait(traitData.Name) and not traitData.BlockStacking and (not traitData.RequiredFalseTrait or traitData.RequiredFalseTrait ~= traitData.Name) and mod.IsBoonManagerValid(traitData.Name) then
					upgradableTraits[traitData.Name] = true
				end
			end
			if not IsEmpty(upgradableTraits) then
				while not IsEmpty(upgradableTraits) do
					local name = RemoveRandomKey(upgradableTraits)
					local traitData = GetHeroTrait(name)
					local stacks = GetTraitCount(name)
					stacks = stacks + 1
					IncreaseTraitLevel(traitData, stacks)
				end
			end
			mod.BoonManagerReloadPage(screen)
			return
		elseif screen.Mode == "Level" and screen.LockedModeButton.Substract == true then
			local upgradableTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				screen.Traits = CurrentRun.Hero.Traits
				local numTraits = traitData.StackNum or 1
				if numTraits > 1 and IsGodTrait(traitData.Name) and TraitData[traitData.Name] and IsGameStateEligible(CurrentRun, TraitData[traitData.Name]) and traitData.Rarity ~= "Legendary" and mod.IsBoonManagerValid(traitData.Name) then
					upgradableTraits[traitData.Name] = true
				end
			end
			if not IsEmpty(upgradableTraits) then
				while not IsEmpty(upgradableTraits) do
					local name = RemoveRandomKey(upgradableTraits)
					local traitData = GetHeroTrait(name)
					local stacks = GetTraitCount(name)
					stacks = stacks - 1
					IncreaseTraitLevel(traitData, stacks)
				end
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Add == true then
			local upgradableTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				if TraitData[traitData.Name] and traitData.Rarity ~= nil and not traitData.CostumeTrait then
					local sanityCheck = false
					if not traitData.IsHammerTrait and GetUpgradedRarity(traitData.Rarity) and traitData.RarityLevels ~= nil and traitData.RarityLevels[GetUpgradedRarity(traitData.Rarity)] ~= nil then
						sanityCheck = true
					elseif traitData.IsHammerTrait and GetUpgradedRarity(traitData.Rarity, mod.HammerRarityUpgradeOrder) and traitData.RarityLevels ~= nil and traitData.RarityLevels[GetUpgradedRarity(traitData.Rarity, mod.HammerRarityUpgradeOrder)] ~= nil then
						sanityCheck = true
					end
					if sanityCheck then
						if Contains(upgradableTraits, traitData) or traitData.Rarity == "Legendary" then
							-- do nothing
						else
							table.insert(upgradableTraits, traitData)
						end
					end
				end
			end
			if not IsEmpty(upgradableTraits) then
				while not IsEmpty(upgradableTraits) do
					local traitData = RemoveRandomValue(upgradableTraits)
					local rarity = nil
					if not traitData.IsHammerTrait then
						rarity = GetUpgradedRarity(traitData.Rarity)
					else
						rarity = GetUpgradedRarity(traitData.Rarity, mod.HammerRarityUpgradeOrder)
					end
					RemoveWeaponTrait(traitData.Name)
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
						SkipAddToHUD = true
					})
				end
				mod.BoonManagerReloadPage(screen)
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Substract == true then
			local upgradableTraits = {}
			for i, traitData in pairs(CurrentRun.Hero.Traits) do
				if TraitData[traitData.Name] and traitData.Rarity ~= nil and not traitData.CostumeTrait then
					local sanityCheck = false
					if not traitData.IsHammerTrait and mod.GetDowngradedRarity(traitData.Rarity) and traitData.RarityLevels ~= nil and traitData.RarityLevels[mod.GetDowngradedRarity(traitData.Rarity)] ~= nil then
						sanityCheck = true
					elseif traitData.IsHammerTrait and mod.GetDowngradedRarity(traitData.Rarity, mod.HammerRarityUpgradeOrder) and traitData.RarityLevels ~= nil and traitData.RarityLevels[mod.GetDowngradedRarity(traitData.Rarity, mod.HammerRarityUpgradeOrder)] ~= nil then
						sanityCheck = true
					end
					if sanityCheck then
						if Contains(upgradableTraits, traitData) then
							-- do nothing
						elseif traitData.Rarity == "Legendary" and not traitData.IsHammerTrait then
							-- do nothing
						else
							table.insert(upgradableTraits, traitData)
						end
					end
				end
			end
			if not IsEmpty(upgradableTraits) then
				while not IsEmpty(upgradableTraits) do
					local traitData = RemoveRandomValue(upgradableTraits)
					local rarity = nil
					if not traitData.IsHammerTrait then
						rarity = mod.GetDowngradedRarity(traitData.Rarity)
					else
						rarity = mod.GetDowngradedRarity(traitData.Rarity, mod.HammerRarityUpgradeOrder)
					end
					RemoveWeaponTrait(traitData.Name)
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
						SkipAddToHUD = true
					})
				end
				mod.BoonManagerReloadPage(screen)
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
				mod.BoonManagerReloadPage(screen)
			end
			return
		elseif screen.Mode == "Level" and screen.LockedModeButton.Substract == true then
			if GetTraitCount(CurrentRun.Hero, button.Boon) > 1 and button.Boon.RemainingUses == nil and IsGodTrait(button.Boon.Name) and not button.Boon.BlockStacking and (not button.Boon.RequiredFalseTrait or button.Boon.RequiredFalseTrait ~= button.Boon.Name) then
				local traitData = GetHeroTrait(button.Boon.Name)
				local stacks = GetTraitCount(button.Boon.Name)
				stacks = stacks - 1
				IncreaseTraitLevel(traitData, stacks)
				mod.BoonManagerReloadPage(screen)
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Add == true then
			if TraitData[button.Boon.Name] and button.Boon.Rarity ~= nil and not button.Boon.CostumeTrait then
				local sanityCheck = false
				if not button.Boon.IsHammerTrait and GetUpgradedRarity(button.Boon.Rarity) and button.Boon.RarityLevels ~= nil and button.Boon.RarityLevels[GetUpgradedRarity(button.Boon.Rarity)] ~= nil then
					sanityCheck = true
				elseif button.Boon.IsHammerTrait and GetUpgradedRarity(button.Boon.Rarity, mod.HammerRarityUpgradeOrder) and button.Boon.RarityLevels ~= nil and button.Boon.RarityLevels[GetUpgradedRarity(button.Boon.Rarity, mod.HammerRarityUpgradeOrder)] ~= nil then
					sanityCheck = true
				end
				if sanityCheck then
					if not button.Boon.IsHammerTrait then
						button.Boon.Rarity = GetUpgradedRarity(button.Boon.Rarity)
					else
						button.Boon.Rarity = GetUpgradedRarity(button.Boon.Rarity, mod.HammerRarityUpgradeOrder)
					end
					local count = GetTraitCount(CurrentRun.Hero, button.Boon)
					RemoveWeaponTrait(button.Boon.Name)
					AddTraitToHero({
						TraitData = GetProcessedTraitData({
							Unit = CurrentRun.Hero,
							TraitName = button.Boon.Name,
							Rarity = button.Boon.Rarity,
							StackNum = count
						}),
						SkipNewTraitHighlight = true,
						SkipQuestStatusCheck = true,
						SkipActivatedTraitUpdate = true,
						SkipAddToHUD = true
					})
					mod.BoonManagerReloadPage(screen)
				end
			end
			return
		elseif screen.Mode == "Rarity" and screen.LockedModeButton.Substract == true then
			if TraitData[button.Boon.Name] and button.Boon.Rarity ~= nil and not button.Boon.CostumeTrait then
				local sanityCheck = false
				if not button.Boon.IsHammerTrait and mod.GetDowngradedRarity(button.Boon.Rarity) and button.Boon.RarityLevels ~= nil and button.Boon.RarityLevels[mod.GetDowngradedRarity(button.Boon.Rarity)] ~= nil then
					sanityCheck = true
				elseif button.Boon.IsHammerTrait and mod.GetDowngradedRarity(button.Boon.Rarity, mod.HammerRarityUpgradeOrder) and button.Boon.RarityLevels ~= nil and button.Boon.RarityLevels[mod.GetDowngradedRarity(button.Boon.Rarity, mod.HammerRarityUpgradeOrder)] ~= nil then
					sanityCheck = true
				end
				if sanityCheck then
					if not button.Boon.IsHammerTrait then
						button.Boon.Rarity = mod.GetDowngradedRarity(button.Boon.Rarity)
					else
						button.Boon.Rarity = mod.GetDowngradedRarity(button.Boon.Rarity, mod.HammerRarityUpgradeOrder)
					end
					local count = GetTraitCount(CurrentRun.Hero, button.Boon)
					RemoveWeaponTrait(button.Boon.Name)
					AddTraitToHero({
						TraitData = GetProcessedTraitData({
							Unit = CurrentRun.Hero,
							TraitName = button.Boon.Name,
							Rarity = button.Boon.Rarity,
							StackNum = count
						}),
						SkipNewTraitHighlight = true,
						SkipQuestStatusCheck = true,
						SkipActivatedTraitUpdate = true,
						SkipAddToHUD = true
					})
					mod.BoonManagerReloadPage(screen)
				end
			end
			return
		elseif screen.Mode == "Delete" then
			screen.BoonsList[screen.CurrentPage][button.Index] = nil
			if button.Boon.Slot == "Spell" then
				local bool = true
				-- only way to get rid of the talents
				while bool do
					bool = mod.HandleSpellRemoval()
				end
				return
			end
			RemoveWeaponTrait(button.Boon.Name)
			mod.BoonManagerReloadPage(screen)
			return
		end
	end
end

function mod.BoonManagerReloadPage(screen)
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

-- removed from base game in Unseen update
function mod.GetDowngradedRarity(baseRarity, rarityUpgradeOrder)
	local rarityTable = rarityUpgradeOrder or TraitRarityData.RarityUpgradeOrder

	if HasHeroTraitValue("ReplaceUpgradedRarityTable") then
		rarityTable = GetHeroTraitValues("ReplaceUpgradedRarityTable")[1]
	end
	local key = GetKey( rarityTable, baseRarity )
	if key and rarityTable[key - 1] then
		return rarityTable[key - 1]
	end
end

function mod.HandleSpellRemoval()
	local deletedSomething = false
	for i, traitData in pairs(CurrentRun.Hero.Traits) do
		if traitData.IsTalent then
			deletedSomething = true
			RemoveWeaponTrait(traitData.Name)
		elseif traitData.Slot == "Spell" then
			deletedSomething = true
			for _, weapon in pairs(traitData.PreEquipWeapons) do
				UnequipWeapon({ DestinationId = CurrentRun.Hero.ObjectId, Name = weapon, UnloadPackages = false })
			end
			RemoveWeaponTrait(traitData.Name)
			CurrentRun.Hero.SlottedSpell = nil
			UpdateTalentPointInvestedCache()
		end
	end
	return deletedSomething
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
				local tdata = TraitData[boonData.boon.Name]
				if boonData.boon.Rarity == nil or boonData.boon.Rarity == "Common" then
					if tdata.RarityLevels and tdata.RarityLevels.Legendary and not tdata.IsHammerTrait then
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
					Rarity = boonData.boon.Rarity,
					StackNum = boonData.boon.StackNum or tdata.StackNum
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
				-- if upgradeData.CustomRarityColor then
				-- 	color = upgradeData.CustomRarityColor
				-- else
				if upgradeData.CustomRarityName == "Boon_Infusion" then
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
				CreateTextBoxWithFormat(descriptionText)
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
			Name = "ButtonCodexUp",
			Scale = 1.2,
			Sound = "/SFX/Menu Sounds/GeneralWhooshMENU",
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
			Name = "ButtonCodexDown",
			Scale = 1.2,
			Sound = "/SFX/Menu Sounds/GeneralWhooshMENU",
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

function mod.GiveConsumableToPlayer(screen, button)
	-- MapState.RoomRequiredObjects = {}
	if button.Consumable.UseFunctionName and button.Consumable.UseFunctionName == "OpenTalentScreen" then
		if not CurrentRun.ConsumableRecord["SpellDrop"] and not mod.DoesPlayerHaveHex() then
			PlaySound({ Name = "/Leftovers/SFX/OutOfAmmo" })
			return
		end
		mod.CloseConsumableSelector(screen)
	end
	UseConsumableItem(button.Consumable, {}, CurrentRun.Hero)
end

function mod.DoesPlayerHaveHex()
	for i, traitData in pairs (CurrentRun.Hero.Traits) do
		if traitData.Slot and traitData.Slot == "Spell" and CurrentRun.Hero.SlottedSpell ~= nil then
			return true
		end
	end
	return false
end

--#endregion
