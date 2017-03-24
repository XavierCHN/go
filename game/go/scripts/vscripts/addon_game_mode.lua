require 'utils.class'
require 'utils.table'
require 'Position'
require 'Go'

---@class Game
Game = class({})

---Global call by engine
function Activate()
	GameRules.gamemode = Game()
	GameRules.gamemode:InitGameMode()
end

---初始化游戏模式
function Game:InitGameMode()
	print "initing"
	GameRules:SetCustomGameSetupTimeout(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:SetPreGameTime(15)
	GameRules:SetPostGameTime(30)
	GameRules:SetTreeRegrowTime(300)
	GameRules:SetHeroMinimapIconScale(0.7)
	GameRules:SetCreepMinimapIconScale(0.7)
	GameRules:SetRuneMinimapIconScale(0.7)
	GameRules:SetGoldTickTime(60)
	GameRules:SetGoldPerTick(0)

	local gamemode = GameRules:GetGameModeEntity()

	gamemode:SetCustomGameForceHero("npc_dota_hero_wisp")
	gamemode:SetAnnouncerDisabled(true)

	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		PlayerResource:SetCustomTeamAssignment( nPlayerID, DOTA_TEAM_GOODGUYS )
	end

	GameRules._gamemode = gamemode
	gamemode:SetThink("ClockTick", self, 1)

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(Game, "OnNpcSpawned"), self)

	self.vPlayerHeroes = {}
	self.vPlayers = {}
end

function Game:ClockTick()
	return 1
end

function Game:OnNpcSpawned(keys)
	local npcSpawned = EntIndexToHScript(keys.entindex)
	if npcSpawned:IsRealHero() and not table.contains(self.vPlayers, npcSpawned) then
		table.insert(self.vPlayerHeroes, npcSpawned)
		table.insert(self.vPlayers, PlayerResource:GetPlayer(npcSpawned:GetPlayerID()))
	end

	if table.count(self.vPlayers) >= 2 and not self.bGameStarted then
		self.bGameStarted = true
		self:StartGame()
	end
end

function Game:StartGame()
	local shuffled = table.shuffle(self.vPlayers)
	self.vBlackPlayer = shuffled[1]
	self.vWhitePlayer = shuffled[2]

	self.vCurrentPlayer = self.vBlackPlayer

	self.vMainBoard = Board(19)

end

function Game:SwitchPlayer()
	-- nil 或者白子，换成黑子
	if self.vCurrentPlayer == self.vWhitePlayer then
		self.vCurrentPlayer = self.vBlackPlayer
	else
		self.vCurrentPlayer = self.vWhitePlayer
	end

	self.vClock = Clock()
end