
Colors = {Empty = -1, Black = 0, White = 1}

---一块棋子
---@class Group
Group = class({})

function Group:constructor()
    self.vStones = {}
    self.vSurrounding = {}
end

function Group:AddStone(stone)
    table.insert(self.vStones, stone)
end

function Group:GetLiberty()
    local count = 0
    for _, stone in pairs(self.vSurrounding) do
        if stone:GetColor() == Colors.Empty then
            count = count + 1
        end
    end
end

function Group:GetStones()
    return self.vStones
end

function Group:GetSurroundingColors()
    local colors = {}
    local color = Colors.Empty
    for _, stone in pairs(self.vSurrounding) do
        if stone:GetColor() == Colors.Black then
            colors.black = true
            color = Colors.Black
        end
        if stone:GetColor() == Colors.White then
            colors.white = true
            color = Colors.White

        end
    end

    return table.count(colors), color
end

function Group:GetSurrounding()
    return self.vSurrounding
end

function Group:HasStoneAtPosition(pos)
    for _, stone in pairs(self.vStones) do
        if stone:GetPosition() == pos then
            return true
        end
    end
end

function Group:AddSurrounding(stone)
    table.insert(self.vSurrounding, stone)
end

---棋子
---@class Stone
Stone = class({})

function Stone:constructor(x, y, color)
    self.color = color
    self.x     = x
    self.y     = y
end

function Stone:GetPosition()
    return Position(self.x, self.y)
end

function Stone:SetColor(color)
    self.color = color
end

function Stone:GetColor()
    return self.color
end

---@class Board
Board = class({})

function Board:constructor(size)
    self.size = size
    self.vStones = {}
    for x = 1, self.size do
        self.vStones[x] = {}
        for y = 1, self.size do
            self.vStones[x][y] = Stone(x, y, Colors.Empty)
        end
    end
end

function Board:HasStoneAtPosition(pos)
    local stone = self.vStones[pos.x][pos.y]
    return stone:GetColor() ~= Colors.Empty
end

function Board:IsPositionInBounds(pos)
    local x, y = pos.x, pos.y
    return x >= 1 and y >= 1 and x <= self.size and y <= self.size
end

function Board:GetNeighbors(pos)
    local delta = {{0,1}, {0, -1}, {1,0}, {-1, 0}}
    local r = {}
    for _, coord in pairs(delta) do
        local pos = Position(pos.x + coord[1], pos.y + coord[2])
        if self:IsPositionInBounds(pos) then
            table.insert(r, pos)
        end
    end
    return r
end

function Board:RemoveGroup(group)
    for stone in pairs(group:GetStones()) do
        stone:SetColor(Colors.Empty)
    end
end

function Board:GetStoneAtPosition(pos)
    return self.vStones[pos.x][pos.y]
end

---获取某个位置的一整块棋子
---进行一次广度优先搜索，将相连的同色棋子放入队列，将所有非同色棋子和空地加入surrounding
---@param pos 棋子的位置
function Board:GetGroupAtPosition(pos)
    local group = Group()
    local color = self:GetStoneAtPosition(pos):GetColor()
    local visited = {}
    local queue = {pos}

    local function search()

        -- 如果搜索队列为空，则搜索完成
        if table.count(queue) == 0 then return end

        local pos = queue[1]
        table.remove(queue, 1)

        if table.contains(visited, pos) then
            return search()
        end

        local neighbors = self:GetNeighbors(pos)
        for _, neighbor in pairs(neighbors) do
            local stone = self:GetStoneAtPosition(neighbor)
            if stone:GetColor() == color then
                table.insert(queue, neighbor)
            else
                group:AddSurrounding(stone)
            end
        end

        table.insert(visited, pos)

        -- 将同色（可能是空的）
        group:AddStone(self:GetStoneAtPosition(pos))

        -- 进行递归搜索
        return search()
    end
    search()

    return group
end

function Board:PlayStone(x, y, color)
    local pos = Position(x, y)
    if not self:IsPositionInBounds(pos) then return false end

    if self:HasStoneAtPosition(pos) then return false end

    -- 复制现在的棋盘，尝试放一个棋子
    local newBoard = self:Clone()
    newBoard:AddStone(pos, color)
    local groupAfterRemoval = newBoard:GetGroupAtPosition(pos)
    if groupAfterRemoval:GetLiberty() == 0 then
        return false
    end

    -- 成功放上棋子
    self:AddStone(pos, color)

    -- 放上了棋子，更新到客户端
    self:UpdateToClient()
    return true
end

function Board:Clone()
    local newBoard = Board(self.size)
    for x = 1, self.size do
        for y = 1, self.size do
            local pos = Position(x, y)
            newBoard:AddStone(pos, self:GetStoneAtPosition(pos):GetColor())
        end
    end
    return newBoard
end

function Board:AddStone(pos, color)
    local stone = self:GetStoneAtPosition(pos)
    stone:SetColor(color)

    local neighborCoords = self:GetNeighbors(pos)
    local neighborEnemyStones = {}
    local neighborEnemyGroups = {}

    for _, pos in pairs(neighborCoords) do
        local neighborStone = self:GetStoneAtPosition(pos)
        if neighborStone and neighborStone:GetColor() ~= Colors.Empty and neighborStone:GetColor() ~= moveColor then
            table.insert(neighborEnemyStones, neighborStone)
            table.insert(neighborEnemyGroups, self:GetGroupAtPosition(pos))
        end
    end
    -- 判断附近的棋死掉了的有几个
    local deadEnemyGroups = table.filter(neighborEnemyGroups, function(_,_, group)
        return group:GetLiberty() == 0
    end)
    -- 移除这次放置棋子之后的所有死子
    for _, group in pairs(deadEnemyGroups) do
        for _, stone in pairs((group:GetStones())) do
            self:RemoveStone(stone)
        end
    end
end

function Board:RemoveStone(stone)
    stone:SetColor(Colors.Empty)
end

function Board:GetAllPositions()
    local r = {}
    for x = 1, self.size do
        for y = 1, self.size do
            table.insert(r, Position(x, y))
        end
    end

    return r
end

function Board:CalculateScore()
    local visited = {}
    local positions = self:GetAllPositions()

    local score = {}
    score[Colors.White] = 0
    score[Colors.Black] = 0
    score[Colors.Empty] = 0

    for _, pos in pairs(positions) do
        if not table.contains(visited, pos) then
            local stone = self:GetStoneAtPosition(pos)
            local group = self:GetGroupAtPosition(pos)
            local groupStones = group:GetStones()
            local surroundingColorCount, surroundingColor = group:GetSurroundingColors()
            if stone:GetColor() == Colors.Empty and surroundingColorCount == 1 then
                score[surroundingColor] = score[surroundingColor] + table.count(groupStones)
            else
                score[stone:GetColor()] = score[stone:GetColor()] + table.count(groupStones)
            end

            for _, stone in pairs(groupStones) do
                table.insert(visited, stone:GetPosition())
            end
        end
    end
    return score
end

---打印出棋盘现在的状态
function Board:Show()
    local stoneStr = {
        [Colors.Empty] = "+ ",
        [Colors.Black] = "x ",
        [Colors.White] = "○ ",
    }
    for y = self.size, 1, -1 do
        local line = string.format("%2d ", y)
        for x = 1, self.size do
            local stone = self:GetStoneAtPosition(Position(x, y))
            local specialPoint =
            (x ==  4 and y == 16) or
            (x == 16 and y ==  4) or
            (x == 16 and y == 16) or
            (x == 16 and y == 10) or
            (x == 10 and y == 16) or
            (x ==  4 and y == 10) or
            (x == 10 and y ==  4) or
            (x == 10 and y == 10)

            if stone then
                line = line .. stoneStr[stone:GetColor()]
            else
                line = line .. (specialPoint and "▪ " or "+ ")
            end
        end

        print(line)
    end
end

function Board:UpdateToClient()
    local data = {}
    for x = 1, self.size do
        data[x] = {}
        for y = 1, self.size do
            local colorStr = tostring(self:GetStoneAtPosition(Position(x, y)):GetColor()) -- 做成字符串，避免BUG
            data[x][y] = colorStr
        end
    end

    CustomNetTables:SetTableValue("game_data", "board_state", data)
end