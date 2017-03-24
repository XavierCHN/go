function ShowError(msg, player_id)
    Notifications:Bottom(PlayerResource:GetPlayer(player_id), { text = msg, duration = 1, style = { color = "red", ["font-size"] = "40px", border = "0px" } })
end

function IncreaseModifierStack(caster, target, ability, modififerName, maxStack)
    local modifier = target:FindModifierByName(modififerName)
    if not modifier then
        target:AddNewModifier(caster, ability, modififerName, {})
        modifier = target:FindModifierByName(modififerName)
    end
    local stackCount = target:GetModifierStackCount(modififerName, caster)
    stackCount       = math.min(maxStack or 999, stackCount + 1)
    target:SetModifierStackCount(modififerName, caster, stackCount)
    if modifier then
        modifier:ForceRefresh()
    end
end

function IsValidAlive(entity)
    return entity and not entity:IsNull() and IsValidEntity(entity) and entity:IsAlive()
end

local pain_sound = {
    "puck_puck_pain_01",
    "puck_puck_pain_02",
    "puck_puck_pain_03",
    "puck_puck_pain_04",
    "puck_puck_pain_05",
    "mirana_mir_pain_01",
    "mirana_mir_pain_02",
    "mirana_mir_pain_03",
    "mirana_mir_pain_04",
    "mirana_mir_pain_05",
    "mirana_mir_pain_06",
    "mirana_mir_pain_07",
    "mirana_mir_pain_08",
    "mirana_mir_pain_09",
    "mirana_mir_pain_10",
}

function PlayPainSound()
    local sound = table.random(pain_sound)
    print("emm=it pain soudn ", sound)
    EmitAnnouncerSound(sound)
end

-- 击退
function Knockback(caster, target, center, distance, height, duration, should_stun)
    -- local pos1 = origin + direction * 10
    local knockback_data = {
        should_stun        = should_stun,
        knockback_duration = duration,
        duration           = duration,
        distance           = distance,
        knockback_height   = height,
        center_x           = center.x,
        center_y           = center.y,
        center_z           = center.z
    }
    target:AddNewModifier(caster, ability, "modifier_knockback", knockback_data)
end

function RoundOff(num, n)
    n = n or 0
    if n > 0 then
        local scale = math.pow(10, n - 1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end

if GameRules then
    return
end

math.randomseed(tostring(os.time()):reverse():sub(1, 7))

function RandomInt(min, max)
    return math.random(min, max)
end

function RandomFloat(min, max)
    return min + math.random() * (max - min)
end

require 'table'

local t = { 1, 2, 3, 4 }

-- table.shuffle(t)

for k, v in pairs(t) do
    print(k, v)
end