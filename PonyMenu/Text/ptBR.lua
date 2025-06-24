local mod = PonyMenu

if not mod.Config.Enabled then return end

mod.AddLocale("pt-BR", {
	PonyMenuCategoryTitle = "Pony Menu",

	ClearAllBoons = "Limpar todas as Bênçãos",
	ClearAllBoonsDescription = "Remove todas as bênçãos equipadas.",

	BoonSelectorTitle = "Seletor de Bênçãos",
	BoonSelectorSpawnButton = "Gerar Bênção Aleatória",
	BoonSelectorCommonButton = "Comum",
	BoonSelectorRareButton = "Rara",
	BoonSelectorEpicButton = "Épica",
	BoonSelectorHeroicButton = "Heróica",

	BoonManagerTitle = "Gerenciador de Bênçãos",
	BoonManagerSubtitle = "Selecione o Modo Nível ou Modo Raridade novamente para alternar entre os submodos Evoluir(+) e Diminuir(-)",
	BoonManagerDescription = "Abre o gerenciamento de bênçãos. Permite você a gerenciar suas bênçãos. Você pode remover e melhorar qualquer bênção que possui.",
	BoonManagerModeSelection = "Escolha um Modo",
	BoonManagerLevelMode = "Modo Nível",
	BoonManagerRarityMode = "Modo Raridade",
	BoonManagerDeleteMode = "Modo Remover",
	BoonManagerAllModeOff = "Modo-Todos : OFF",
	BoonManagerAllModeOn = "Modo-Todos : ON",
	BoonManagerLevelDisplay = "Nv. ",

	ResourceMenuTitle = "Menu dos Recursos",
	ResourceMenuDescription = "Gera qualquer recurso em qualquer quantia.",
	ResourceMenuSpawnButton = "Gerar Recurso",
	ResourceMenuEmpty = "Nada",

	BossSelectorTitle = "Seletor de Chefes",
	BossSelectorDescription = "Te permite ir direto a uma luta de chefe e lutar contra eles, usando seu arsenal atual.",
	BossSelectorNoSavedState = "SEM ESTADO SALVO! VÁ FAZER UM!",

	KillPlayerTitle = "Matar o Jogador",
	KillPlayerDescription = "Te mata e envia você de volta para a Encruzilhada.",

	SaveStateTitle = "Salvar",
	SaveStateDescription = "Salva seu estado atual para ser carregado depois, é um requerimento do seletor de chefes. Salva tudo que você tem equipado.",
	SaveStateSaved = "Seu estado atual foi salvo!",

	LoadStateTitle = "Carregar",
	LoadStateDescription = "Carrega seu estado salvo. Não pode ser utilizado se não tiver um estado salvo.",
	SaveStateLoaded = "Seu salvamento anterior foi carregado!",

	ConsumableSelectorTitle = "Seletor de Consumível",
	ConsumableSelectorDescription = "Te dá qualquer item consumível.",

	ExtraSelectorTitle = "Modificação Extra",
	ExtraSelectorDescription = "Algumas opções adicionais de trapaça. Inclui Rolagem Infinita, Sala do Caos garantida, sempre Blessings Raros Heroicos, etc.",


	BoonSelectorExtraConfirmButton = "Ativar Modificação",
	BoonSelectorExtraCancelButton = "Cancelar Modificação",

	ChaosGate = "Portão do Caos",
	InfiniteRoll = "Rolagem Infinita",
	Heroic = "Bênção Heroica Garantida",
	NoRewardRoom = "Sem Sala de Recompensas",

	Extrarush = "Contagem de Corrida +1",
	MoreMoney = "Ouro +100",
	RestoreHealth = "Restaurar Saúde",
	RestoreMana = "Restaurar Mana",

	DropLoot = "Bênção de Morte ao Derrubar",
	StopDropLoot = "Desativar Bênção de Morte ao Derrubar",
	EphyraZoomOut = "Prévia de Recompensas da Sala",

	DiyTraitDataTitle = "Bênção Personalizada",
	DiyTraitDataDescription = "Use bênçãos personalizadas criadas pelo autor, ou bênçãos removidas oficialmente anteriormente (essas bênçãos podem não ter efeito algum)",

	BossHealthLoot = "Exibir Vida do Boss",
	QuitAnywhere = "Sair a Qualquer Momento",
	PermanentLocationCount = "Exibir Sempre o Número de Salas",

	RepeatableChaosTrials = "Bênçãos do Caos Repetíveis",

	FreeToBuy = "Grátis para Comprar",

	GetRavenFamiliar = "Desbloquear Familiar Corvo",
	GetFrogFamiliar = "Desbloquear Familiar Sapo",
	GetCatFamiliar = "Desbloquear Familiar Gato",
	GetHoundFamiliar = "Desbloquear Familiar Cão",
	GetPolecatFamiliar = "Desbloquear Familiar Doninha",
})
