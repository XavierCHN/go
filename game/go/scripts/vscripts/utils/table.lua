function table.count(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end

    return c
end

function table.contains(t, v)
    for _, _v in pairs(t) do
        if _v == v then
            return true
        end
    end
end

function table.has_element_fit(t, func)
    for k, v in pairs(t) do
        if func(t, k, v) then
            return k, v
        end
    end
end

function table.findkey(t, v)
    for k, _v in pairs(t) do
        if _v == v then
            return k
        end
    end
end

function table.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.random(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    local key = keys[RandomInt(1, # keys)]
    return t[key], key
end

function table.shuffle(tbl)
    -- 必须是一个hash表
    local t = table.shallowcopy(tbl)
    for i = # t, 2, - 1 do
        local j    = RandomInt(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function table.random_some(t, count)
    local key_table = table.make_key_table(t)
    key_table       = table.shuffle(key_table)
    local r         = {}
    for i = 1, count do
        local key = key_table[i]
        table.insert(r, t[key])
    end
    return r
end

-- 随机选择一个元素，带条件的
function table.random_with_condition(t, func)
    local keys = {}
    for k, v in pairs(t) do
        if func(t, k, v) then
            table.insert(keys, k)
        end
    end

    local key = keys[RandomInt(1, # keys)]
    return t[key], key
end

-- 带权重的选择某个元素
-- 要求每个元素都必须包含GetWeight()函数
function table.random_with_weight(t)
    local weight_table = {}
    local total_weight = 0
    for k, v in pairs(t) do
        total_weight = total_weight + v:GetWeight()
        table.insert(weight_table, { key = k, total_weight = total_weight })
    end

    local randomValue = RandomFloat(0, total_weight)
    for i = 1, # weight_table do
        if weight_table[i].total_weight >= randomValue then
            local key = weight_table[i].key
            return t[key]
        end
    end
end

-- 过滤一个表
-- 这个表会重新创建一个新的表
function table.filter(t, condition)
    local r = {}
    for k, v in pairs(t) do
        if condition(t, k, v) then
            r[k] = v
        end
    end
    return r
end

-- 将所有key作为一个table返回
function table.make_key_table(t)
    local r = {}
    for k, _ in pairs(t) do
        table.insert(r, k)
    end
    return r
end

-- 如果两个表每个key对应的值都相等，那么认为这两个表相等
function table.is_equal(t1, t2)
    for k, v in pairs(t1) do
        if t2[k] ~= v then
            return false
        end
    end
    return true
end

function table.random_key(t)
    return table.random(table.make_key_table(t))
end

function table.print(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

-- 只保留所有的字符串和数字，并且把所有的数字都转换成字符串
-- 避免在nettable传输过程中产生的bug
function table.safe_table(t)
    local r = {}
    for k,v in pairs(t) do
        if type(v) == "table" and k ~= "_M" then -- 避免module的死循环
            r[k] = table.safe_table(v)
        elseif type(v) == "string" or type(v) == "number" then
            r[k] = tostring(v)
        end
    end

    return r
end