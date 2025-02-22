local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("fr", {
	PonyMenuCategoryTitle = "Menu Pony",

	ClearAllBoons = "Supprimer tous les bienfaits",
	ClearAllBoonsDescription = "Supprime tous vos bienfaits.",

	BoonSelectorTitle = "Sélectionneur de bienfaits",
	BoonSelectorSpawnButton = "Invoquer un bienfait",
	BoonSelectorCommonButton = "Common",
	BoonSelectorRareButton = "Rare",
	BoonSelectorEpicButton = "Epic",
	BoonSelectorHeroicButton = "Heroic",

	BoonManagerTitle = "Gestionnaire de bienfaits",
	BoonManagerSubtitle = "Cliquez le mode Niveau ou Rareté à nouveau pour changer entre Addition(+) et Soustraction(-).",
	BoonManagerDescription = "Ouvre le gestionnaire de bienfaits. Vous permet de gérer vos bienfaits. Vous pouvez supprimer et améliorer tous vos bienfaits.",
	BoonManagerModeSelection = "Choisissez un mode",
	BoonManagerLevelMode = "Mode Niveau",
	BoonManagerRarityMode = "Mode Rareté",
	BoonManagerDeleteMode = "Mode Suppression",
	BoonManagerAllModeOff = "Mode tous : ON",
	BoonManagerAllModeOn = "Mode tous : OFF",
	BoonManagerLevelDisplay = "Nv. ",

	ResourceMenuTitle = "Menu des Ressources",
	ResourceMenuDescription = "Créer n'importe quelle ressource au nombre que vous souhaitez.",
	ResourceMenuSpawnButton = "Créer Ressource",
	ResourceMenuEmpty = "Rien"
})
