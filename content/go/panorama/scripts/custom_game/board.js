m_Stones = [];

function OnPlayerClickStone(x, y){
    // $.Msg("player clicked on position", x, y);
}

(function(){

    $.GetContextPanel().AddClass("BlackPlayer");
    $.GetContextPanel().AddClass("Playing");

    var stone_layer = $("#stone_layer");
    stone_layer.RemoveAndDeleteChildren();

    for (var y = 19; y >= 1; y--){
        m_Stones[y] = [];
        for (var x = 1; x <= 19; x++){
            m_Stones[y][x] = $.CreatePanel("Panel", stone_layer, "");
            m_Stones[y][x].AddClass("Stone");
            m_Stones[y][x].style.marginLeft = (25 + 50 * (x - 1)) + "px";
            m_Stones[y][x].style.marginTop = (25 + 50 * (19 - y)) + "px";
            (function(i, j){
                m_Stones[j][i].SetPanelEvent("onactivate", function(){ OnPlayerClickStone(i, j) })
            })(x, y);
        }
    }
})();