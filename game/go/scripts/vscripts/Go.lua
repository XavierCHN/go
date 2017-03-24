
-- 围棋的颜色，空，黑色，白色
Colors = {Empty = -1, Black = 0, White = 1}

---一块棋子
---@class Group
Group = class({})

-- 构造函数
function Group:constructor()
    self.vStones = {} -- 所有的同色棋子（空也是一种色）
    self.vSurrounding = {} -- 所有环绕在旁边的不同颜色的棋子
end

---给这块棋子加上一个棋子
---@param stone Stone
function Group:AddStone(stone)
    table.insert(self.vStones, stone)
end

---获取气的数量
---@return number
function Group:GetLiberty()
    local count = 0
    for _, stone in pairs(self.vSurrounding) do
        if stone:GetColor() == Colors.Empty then
            count = count + 1
        end
    end
    return count
end

function Group:GetStones()
    return self.vStones
end

-- 获取这块棋旁边有几种颜色包围，这个颜色是什么？（用来获取空的区域属于谁）
---@return number, Colors
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

---某个位置是否有棋子
---@param pos Position
---@return boolean
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
---棋子有三种三色，空，黑色和白色
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

---棋盘
---@class Board
Board = class({})

function Board:constructor(size)
    self.size = size -- 尺寸
    self.vStones = {}
    for x = 1, self.size do
        self.vStones[x] = {}
        for y = 1, self.size do
            self.vStones[x][y] = Stone(x, y, Colors.Empty) -- 所有的棋子（361个），全部初始化为空棋子
        end
    end
end

---判断某个位置是否有棋子
---@param pos Position
function Board:HasStoneAtPosition(pos)
    local stone = self.vStones[pos.x][pos.y]
    return stone:GetColor() ~= Colors.Empty
end

---判断某个点是否在边界范围内
---@param pos Position
function Board:IsPositionInBounds(pos)
    local x, y = pos.x, pos.y
    return x >= 1 and y >= 1 and x <= self.size and y <= self.size
end

---获取某个点周围的四个相邻的点
---@param pos Position
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

---移除一整块棋子
---@param group Group
function Board:RemoveGroup(group)
    for stone in pairs(group:GetStones()) do
        stone:SetColor(Colors.Empty)
    end
end

---获取某个点上的棋子
---@param pos Position
function Board:GetStoneAtPosition(pos)
    return self.vStones[pos.x][pos.y]
end

---获取某个位置的一整块棋子
---@param pos Position 开始的棋子的位置
function Board:GetGroupAtPosition(pos)
    local group = Group()
    local color = self:GetStoneAtPosition(pos):GetColor()
    local visited = {}
    local queue = {pos}

    -- 原理是，进行一次广度优先搜索
    -- 将当前队列第一位的棋子加入到这块棋中
    -- 之后获取这个棋子周围的所有棋子
    -- 在周围的棋子中：
    --     1 如果棋子的颜色相同，将其放置到队列的最后
    --     2 如果棋子的颜色不同，将其加入到这块棋的周边棋子中
    -- 直到队列为空，结束搜索
    local function search()
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
        group:AddStone(self:GetStoneAtPosition(pos))
        return search()
    end
    search()
    return group
end

---引擎调用的函数
---在[x,y]的位置尝试放一个棋子
---@param x number X坐标
---@param y number Y坐标
---@param color Colors 颜色
---@return boolean 是否放置成功
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

---返回一个新的棋盘，复制了当前棋盘上的所有棋子
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

---在某个位置放一个棋子，并移除这个棋子周围所有的死子（之后自己活没活不属于这里判定）
---@param pos Position 放棋子的位置
---@param color Colors 颜色
function Board:AddStone(pos, color)
    local stone = self:GetStoneAtPosition(pos)
    stone:SetColor(color)

    local neighborCoords = self:GetNeighbors(pos)
    local neighborEnemyStones = {}
    local neighborEnemyGroups = {}

    for _, pos in pairs(neighborCoords) do
        local neighborStone = self:GetStoneAtPosition(pos)
        if neighborStone and neighborStone:GetColor() ~= Colors.Empty and neighborStone:GetColor() ~= color then
            if pos.x == 8 and pos.y == 14 then
            end
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
            local pos = stone:GetPosition()
            if stone:GetColor() ~= Colors.Empty then
            end
            self:RemoveStone(stone)
        end
    end
end

--- 移除棋子
function Board:RemoveStone(stone)
    stone:SetColor(Colors.Empty)
end

--- 获取棋盘上的所有点
function Board:GetAllPositions()
    local r = {}
    for x = 1, self.size do
        for y = 1, self.size do
            table.insert(r, Position(x, y))
        end
    end

    return r
end

---计算分数
---循环围棋盘上的所有点，将和这个点连成一块的棋子进行判定
---如果这块棋是一块空地，那么如果这块空地只被一种颜色包围，则这块空地的大小的分数属于这个颜色
---如果这块棋是什么颜色的，那么为这个颜色增加对应的分数（如果不算这个分数则为点目法，算了就是数子规则）
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

---将棋盘的状态发送到客户端，来更新UI
function Board:UpdateToClient()
    local data = {}
    for y = 1, self.size do
        data[y] = {}
        for x = 1, self.size do
            local colorStr = tostring(self:GetStoneAtPosition(Position(x, y)):GetColor()) -- 做成字符串，避免BUG
            data[y][x] = colorStr
        end
    end

    CustomNetTables:SetTableValue("board_data", "board_data", data)
end