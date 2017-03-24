-- 处理各种奖励
-- 掉落金币
function DropBagOfGold(position, amount, radius, duration)

    duration = duration or 10
    amount   = amount or 1
    if not position then
        error("Position is not defined")
    end

    local gold = DropLootItem("item_bag_of_gold", position, radius, duration)
    gold:SetCurrentCharges(amount)
end

-- 掉落物品
function DropLootItem(itemname, position, radius, duration)
    local newItem = CreateItem(itemname, nil, nil)
    newItem:SetPurchaseTime(0)
    local drop       = CreateItemOnPositionSync(position, newItem)
    local dropTarget = position + RandomVector(RandomFloat(0, radius))
    local autouse    = false
    if itemname == "item_bag_of_gold" then
        autouse = true
    end
    local height, time = 200, 0.75
    if radius < 10 then
        height, time = 0, 0.05
    end
    newItem:LaunchLoot(autouse, height, time, dropTarget)
    return newItem
end

-- 在某个位置掉落一堆金币袋子
-- center 掉落的中心点
-- radius 掉落的范围
-- amount 掉落的总数量
-- 
function DropBagsOfGold(center, radius, amount, duration)
    local playerCount    = GameRules.gamemode:GetPlayerCount()
    local basicValue     = playerCount * 50

    local goldLeftToDrop = amount
    while (goldLeftToDrop > 0) do
        local singleGoldAmount = RandomInt(basicValue * 0.9, basicValue * 1.1)
        goldLeftToDrop         = goldLeftToDrop - singleGoldAmount
        if goldLeftToDrop < 0 then
            singleGoldAmount = singleGoldAmount + goldLeftToDrop
        end
        DropBagOfGold(center, singleGoldAmount, radius, duration)
    end
end