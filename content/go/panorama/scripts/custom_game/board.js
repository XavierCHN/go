m_Stones = [];

m_Colors = {
    Empty: -1,
    Black: 0,
    White: 1
};


function OnPlayerClickStone(_x, _y){
    GameEvents.SendCustomGameEventToServer("player_place_stone", {
        x: _x,
        y: _y
    })
}

function InitializeStones(force) {
    var stone_layer = $("#stone_layer");

    if (!force === true && stone_layer.GetChildCount() > 0) return;

    stone_layer.RemoveAndDeleteChildren();

    for (var y = 19; y >= 1; y--) {
        m_Stones[y] = [];
        for (var x = 1; x <= 19; x++) {
            m_Stones[y][x] = $.CreatePanel("Panel", stone_layer, "");
            m_Stones[y][x].AddClass("Stone");
            m_Stones[y][x].AddClass("NoStone");
            m_Stones[y][x].style.marginLeft = (25 + 50 * (x - 1)) + "px";
            m_Stones[y][x].style.marginTop = (25 + 50 * (19 - y)) + "px";
            (function (i, j) {
                m_Stones[j][i].SetPanelEvent("onactivate", function () {
                    OnPlayerClickStone(i, j)
                })
            })(x, y);
        }
    }
}


function OnBoardDataChanged(){
    var stone_layer = $("#stone_layer");
    if (stone_layer.GetChildCount() <= 0) InitializeStones();

    var board_data = CustomNetTables.GetTableValue("board_data", "board_data");

    if (board_data === undefined) return;
    for (var y = 19; y >= 1; y--) {
        for (var x = 1; x <= 19; x++) {
            var color = board_data[y][x];
            color = parseInt(color);
            if (color === m_Colors.Black) {
                m_Stones[y][x].AddClass("Black");
                m_Stones[y][x].RemoveClass("NoStone")
            }
            if (color === m_Colors.White) {
                m_Stones[y][x].AddClass("White");
                m_Stones[y][x].RemoveClass("NoStone")
            }
            if (color === m_Colors.Empty) {
                m_Stones[y][x].RemoveClass("Black");
                m_Stones[y][x].RemoveClass("White");
                m_Stones[y][x].AddClass("NoStone");
            }
        }
    }
}

(function(){
    OnBoardDataChanged();
    CustomNetTables.SubscribeNetTableListener("board_data", OnBoardDataChanged);
})();
