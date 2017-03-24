require 'utils.class'
require 'utils.table'
require 'Position'
require 'Go'
require 'Clock'

---@class Game
Game = class({})

---Global call by engine
function Activate()
	GameRules.gamemode = Game()
	GameRules.gamemode:InitGameMode()
end

---初始化游戏模式
function Game:InitGameMode()

	self.vPlayerHeroes = {}
	self.vPlayers = {}
	self.vOpponents = {}

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

	self.nPlayerCount = 0
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		PlayerResource:SetCustomTeamAssignment( nPlayerID, DOTA_TEAM_GOODGUYS )
	end

	GameRules._gamemode = gamemode
	gamemode:SetThink("ClockTick", self, 1)

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(Game, "OnNpcSpawned"), self)
	ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(Game, "OnGameRulesStateChange"),self)

	CustomGameEventManager:RegisterListener("player_place_stone", function(_, keys) self:OnPlayerPlaceStone(keys) end)
end

---客户端的事件监听，玩家在某个位置尝试放一个棋子
function Game:OnPlayerPlaceStone(keys)
	local playerID = keys.PlayerID
	local x = keys.x
	local y = keys.y

	if playerID ~= self.vOpponents[self.nCurrentColor]:GetPlayerID() then return end

	local success = self.vMainBoard:PlayStone(x, y, self.nCurrentColor)
	-- 如果成功放置了棋子，那么换另一个玩家下
	if success then
		self:SwitchPlayer()
	end
end

---全局时钟
function Game:ClockTick()
	if self.vBlackPlayerClock and self.vWhitePlayerClock then
		self.vWhitePlayerClock:Tick()
		self.vBlackPlayerClock:Tick()
		CustomNetTables:SetTableValue("clock_state", "clock_state", {
			[self.vBlackPlayer:GetPlayerID()] = {
				BaseTime = self.vBlackPlayerClock:GetBaseTime(),
				BonusTime = self.vBlackPlayerClock:GetBonusTime(),
				BonusCount = self.vBlackPlayerClock:GetBonusCount(),
			},
			[self.vWhitePlayer:GetPlayerID()] = {
				BaseTime = self.vWhitePlayerClock:GetBaseTime(),
				BonusTime = self.vWhitePlayerClock:GetBonusTime(),
				BonusCount = self.vWhitePlayerClock:GetBonusCount(),
			}
		})
	end

	return 1
end

---获取玩家数量
function Game:GetPlayerCount()
	local count = 0
	for i = 1, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidTeamPlayerID(i) then
			count = count + 1
		end
	end
	return count
end

---当玩家进入游戏（玩家全部连接成功之后，就开始游戏）
function Game:OnGameRulesStateChange()
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules._gamemode:SetContextThink("Start game delay", function()
			self:Prepare()
			return nil
		end, 3) -- 延迟3秒，用来保证UI载入完成
	end
end

---储存玩家
function Game:OnNpcSpawned(keys)
	local npcSpawned = EntIndexToHScript(keys.entindex)
	if npcSpawned:IsRealHero() and not table.contains(self.vPlayerHeroes, npcSpawned) then
		table.insert(self.vPlayerHeroes, npcSpawned)
		local player = PlayerResource:GetPlayer(npcSpawned:GetPlayerID())
		table.insert(self.vPlayers, player)
	end
end

---游戏准备开始
function Game:Prepare()
	self:SetGameState("prepare")
	-- todo 这里应该是还需要设置一下游戏规则什么的

	if not self.bGameStarted then
		self.bGameStarted = true
		self:StartGame()
	end
end

function Game:StartGame()

	-- 自动猜先
	local shuffled = table.shuffle(self.vPlayers)
	self.vBlackPlayer = shuffled[1]
	self.vWhitePlayer = shuffled[2] or shuffled[1] -- 如果只有一个玩家，那么同时执黑白
	-- 储存猜先结果
	self.vOpponents[Colors.White] = self.vWhitePlayer
	self.vOpponents[Colors.Black] = self.vBlackPlayer
	-- 告知客户端猜先结果
	CustomNetTables:SetTableValue("player_state", "random_result", {
		BlackPlayerID = self.vBlackPlayer:GetPlayerID(),
		WhitePlayerID = self.vWhitePlayer:GetPlayerID(),
	})

	-- 初始化计时器
	self.vBlackPlayerClock = Clock(600,30,3)
	self.vWhitePlayerClock = Clock(600,30,3)

	-- 初始化棋盘
	self.vMainBoard = Board(19)

	-- 黑棋先走
	self:SwitchPlayer()

	-- 设置游戏状态
	self:SetGameState("start")
end

---切换玩家
---如果当前玩家不是黑（白或者nil），到黑棋，否则到白棋
function Game:SwitchPlayer()
	local currentColor = "black"
	if  self.nCurrentColor ~= Colors.Black then
		self.nCurrentColor = Colors.Black
		self.vBlackPlayerClock:Start()
		self.vWhitePlayerClock:Stop()
	else
		self.nCurrentColor = Colors.White
		currentColor = "white"
		self.vWhitePlayerClock:Start()
		self.vBlackPlayerClock:Stop()
	end

	-- 告知客户端当前玩家
	-- 有点重复的原因是因为，需要让单人的时候也能玩
	CustomNetTables:SetTableValue("player_state", "current_player", {
		CurrentPlayerID = self.vOpponents[self.nCurrentColor]:GetPlayerID(),
		CurrentColor = currentColor
	})
end

function Game:SetGameState(state)
	CustomNetTables:SetTableValue("game_state", "game_state", {state = state})
end


