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
	ResourceMenuEmpty = "Rien",

	BossSelectorTitle = "Sélecteur de Boss",
	BossSelectorDescription = "Vous permet d'aller directement à un boss, équippé de votre kit sauvegardé.",
	BossSelectorNoSavedState = "PAS DE KIT SAUVEGARDÉ! ALLEZ EN FAIRE UN!",

	KillPlayerTitle = "Tuer le Joueur",
	KillPlayerDescription = "Vous tue et vous renvoie à la croisée des chemins.",

	SaveStateTitle = "Sauvegarder Kit",
	SaveStateDescription = "Sauvegarde votre kit actuel pour l'équiper plus tard, requis pour utiliser le sélecteur de boss. Sauvegarde tout ce que vous avez équippé actuellement.",
	SaveStateSaved = "Kit sauvegardé!",

	LoadStateTitle = "Équiper kit",
	LoadStateDescription = "Équippe votre kit sauvegardé. Ne peut-être utilisé si vous n'en avez pas.",
	SaveStateLoaded = "Kit équippé!",

	ConsumableSelectorTitle = "Sélecteur de consommables.",
	ConsumableSelectorDescription = "Donnez vous n'importe quel objet consommable.",

	ExtraSelectorTitle = "Modification supplémentaire",
	ExtraSelectorDescription = "Quelques options supplémentaires de triche. Inclut la Roue infinie, la chambre du Chaos garantie, toujours des bénédictions héroïques rares, etc.",


	BoonSelectorExtraConfirmButton = "Activer la modification",
	BoonSelectorExtraCancelButton = "Annuler la modification",

	ChaosGate = "Portail du Chaos",
	InfiniteRoll = "Roulette infinie",
	Heroic = "Bénédiction héroïque garantie",
	NoRewardRoom = "Pas de salle de récompenses",

	Extrarush = "Compteur de sprint +1",
	MoreMoney = "Or +100",
	RestoreHealth = "Restaurer la santé",
	RestoreMana = "Restaurer la mana",

	DropLoot = "Bénédiction tombant à la mort",
	StopDropLoot = "Désactiver la bénédiction tombant à la mort",
	EphyraZoomOut = "Aperçu des récompenses de la salle",

	DiyTraitDataTitle = "Bénédiction personnalisée",
	DiyTraitDataDescription = "Utilisez des bénédictions personnalisées créées par l'auteur, ou des bénédictions précédemment supprimées par les développeurs (ces bénédictions peuvent ne pas avoir d'effet du tout)",

	BossHealthLoot = "Afficher la santé du boss",
	QuitAnywhere = "Quitter à tout moment",
	PermanentLocationCount = "Afficher toujours le nombre de pièces",

	RepeatableChaosTrials = "Bénédictions du Chaos répétables",
	FreeToBuy = "Gratuit à acheter",

	GetRavenFamiliar = "Déverrouiller le familier corbeau",
	GetFrogFamiliar = "Déverrouiller le familier grenouille",
	GetCatFamiliar = "Déverrouiller le familier chat",
	GetHoundFamiliar = "Déverrouiller le familier chien",
	GetPolecatFamiliar = "Déverrouiller le familier putois",

})
