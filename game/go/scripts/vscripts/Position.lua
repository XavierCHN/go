Position   = {x = 0, y = 0}

Position.__index = Position

function Position.new(x, y)
    local self = setmetatable({}, Position)
    if (type(x) == "table") then
        for k, v in pairs(x) do
            self[k] = v
        end
    elseif (type(x) == "number" and type(y) == "number") then
        self['x'] = x
        self['y'] = y
    end
    return self
end

-- 两点相加
function Position.__add(p1, p2)
    local p3 = Position.new({x = p1.x + p2.x, y = p1.y + p2.y})
    return p3
end

-- 两点相减
function Position.__sub(p1, p2)
    return Position.new({x = p1.x - p2.x, y = p1.y - p2.y})
end

-- 两点相乘
function Position.__mul(p1, p2)
    return Position.new({x = p1.x * p2.x, y = p1.y * p2.y})
end

-- 两点相除
function Position.__div(p1, p2)
    return Position.new({x = p1.x / p2.x, y = p1.y / p2.y})
end

-- 相等
function Position.__eq(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

-- 两点距离
function Position:distance(p2)
    return math.sqrt(math.pow(self.x - p2.x, 2) + math.pow(self.y - p2.y, 2))
end

function Position.__tostring(p1)
    return "x="..p1.x.." y="..p1.y
end

setmetatable(Position, {
    __call = function(_, x, y)
        return Position.new(x, y)
    end
})