if PonyMenu.Config.Enabled then
	table.insert(ScreenData.InventoryScreen.ItemCategories, {
		Name = "PONYMENU",
		Icon = "GUI\\Screens\\Codex\\Icon-Unseen",
		GameStateRequirements =
		{
			-- None
		}
	})
end