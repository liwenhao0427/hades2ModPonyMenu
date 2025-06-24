if PonyMenu.Config.Enabled then
	table.insert(ScreenData.InventoryScreen.ItemCategories, {
		Name = "PONYMENU",
		Icon = "GUI\\Screens\\Codex\\Icon-Unseen",
		OpenAnimation = "InventoryScreenInGrid",
		CloseAnimation = "InventoryScreenOutGrid",
		GameStateRequirements =
		{
			-- None
		}
	})
end