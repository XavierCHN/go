var n_LocalPlayerID = Players.GetLocalPlayer();
var n_EnemyPlayerID = -1;

function OnPlayerStateChanged() {
    var currentPlayer = CustomNetTables.GetTableValue("player_state", "current_player");
    if (currentPlayer !== undefined){
        var currentPlayerID = currentPlayer.CurrentPlayerID;
        if (currentPlayerID === Players.GetLocalPlayer()){
            $.GetContextPanel().AddClass("Playing");
            $.GetContextPanel().RemoveClass("NotPlaying");
        }else{
            $.GetContextPanel().RemoveClass("Playing");
            $.GetContextPanel().AddClass("NotPlaying");
        }

        var currentColor = currentPlayer.CurrentColor;
        if (currentColor === "black" ){
            $.GetContextPanel().AddClass("BlackPlayerPlaying");
            $.GetContextPanel().RemoveClass("WhitePlayerPlaying");
        }else{
            $.GetContextPanel().AddClass("WhitePlayerPlaying");
            $.GetContextPanel().RemoveClass("BlackPlayerPlaying");
        }
    }

    var randomResult = CustomNetTables.GetTableValue("player_state", "random_result");
    if (randomResult !== undefined){
        if (randomResult.BlackPlayerID === Players.GetLocalPlayer()){
            $.GetContextPanel().AddClass("WhitePlayer");
            n_EnemyPlayerID = randomResult.WhitePlayerID;
        }
        if (randomResult.WhitePlayerID === Players.GetLocalPlayer()){
            $.GetContextPanel().AddClass("BlackPlayer");
            n_EnemyPlayerID = randomResult.BlackPlayerID;
        }
    }
}

function OnGameStateChanged(){

    var gameState = CustomNetTables.GetTableValue("game_state", "game_state");
    if(gameState === undefined) { return };

    var currentState = gameState.state;
    if (currentState === "prepare"){
        // 我们目前不需要让玩家选择规则，都下10分钟30秒一次的快棋吧！
        // $("#mode_selection").RemoveClass("Hidden");
    }
    if (currentState === "start") {
        InitializeStones();
    }
}

function OnClockStateChanged() {
    var clockState = CustomNetTables.GetTableValue("clock_state", "clock_state");
    if (clockState === undefined) return;
    var localClock = clockState[Players.GetLocalPlayer()];
    var enemyClock = clockState[n_EnemyPlayerID];

    $("#base_time_local").text = formatSeconds(localClock.BaseTime);
    $("#bonus_time_local").text = formatSeconds(localClock.BonusTime) + "      " + localClock.BonusCount;
    $("#base_time_enemy").text = formatSeconds(enemyClock.BaseTime);
    $("#bonus_time_enemy").text = formatSeconds(enemyClock.BonusTime) + "      " + localClock.BonusCount;
}

(function(){
    OnGameStateChanged();
    OnPlayerStateChanged();
    OnClockStateChanged();
    CustomNetTables.SubscribeNetTableListener("game_state", OnGameStateChanged);
    CustomNetTables.SubscribeNetTableListener("player_state", OnPlayerStateChanged);
    CustomNetTables.SubscribeNetTableListener("clock_state", OnClockStateChanged);
})();
