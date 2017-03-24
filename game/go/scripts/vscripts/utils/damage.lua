-- 对玩家造成伤害用的函数
-- @params damage_amount 伤害数量，心的数量，一颗心就是1，半颗心就0.5
-- 
function DealDamage(source, target, damage_amount, ability)
    local damage_value = damage_amount * 10
    ApplyDamage({
                    attacker    = source,
                    victim      = target,
                    damage      = damage_value,
                    damage_type = DAMAGE_TYPE_PURE,
                    ability     = ability
                })

    target:AddNewModifier(target, nil, "modifier_player_invunerable_after_damage", { Duration = 0.3 })
end

function KVDealDamage(keys)
    local source        = keys.caster
    local target        = keys.target
    local damage_amount = keys.DamageAmount
    DealDamage(source, target, damage_amount, keys.ability)
end

function DamageEnemy(source, target, damage_amount, ability)
    ApplyDamage({
                    attacker    = source,
                    victim      = target,
                    damage      = damage_amount,
                    ability     = ability,
                    damage_type = DAMAGE_TYPE_PURE,
                })
end