local function DoPrecache(c)

    local function p(res)
        PrecacheResource("particle", res, c)
    end
    local function m(res)
        PrecacheResource("model", res, c)
    end
    local function s(res)
        PrecacheResource("soundfile", res, c)
    end
    local function v(res)
        PrecacheResource("voicefile", res, c)
    end
    local function pf(res)
        PrecacheResource("particle_folder", res, c)
    end
    local function pu(res)
        PrecacheUnitByNameSync(res, c, - 1)
    end
    local function pi(res)
        PrecacheItemByNameSync(res, c)
    end

    p "particles/items2_fx/veil_of_discord.vpcf"
    p "particles/phantom_assassin_linear_dagger.vpcf"
    p "particles/econ/events/darkmoon_2017/darkmoon_generic_aoe.vpcf"
    p "particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf"
    p "particles/units/heroes/hero_bloodseeker/bloodseeker_vision.vpcf"
    p "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf"
    p "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf"
    p "particles/frostivus_gameplay/drow_linear_arrow.vpcf"
    p "particles/frostivus_gameplay/drow_linear_frost_arrow.vpcf"
    p "particles/frostivus_gameplay/legion_gladiators_ring.vpcf"
    p "particles/frostivus_herofx/juggernaut_omnislash_ascension.vpcf"
    p "particles/frostivus_gameplay/holdout_juggernaut_omnislash_image.vpcf"
    p "particles/frostivus_herofx/juggernaut_fs_omnislash_slashers.vpcf"
    p "particles/frostivus_herofx/juggernaut_fs_omnislash_tgt.vpcf"
    p "particles/hw_fx/rosh_dismember_impact_droplets.vpcf"
    p "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_blur_impact.vpcf"
    p "particles/units/heroes/hero_invoker/invoker_ghost_walk_debuff.vpcf"
    p "particles/status_fx/status_effect_frost.vpcf"
    p "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf"
    p "particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf"
    p "particles/creatures/clinkz/clinkz_searing_arrow.vpcf"
    p "particles/econ/items/pudge/pudge_scorching_talon/pudge_scorching_talon_meathook.vpcf"
    p "particles/econ/items/pudge/pudge_ti6_immortal/pudge_meathook_witness_impact_ti6.vpcf"
    p "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_loadout_char_fire.vpcf"
    p "particles/creatures/boss_pudge/boss_pudge_fire_hell.vpcf"
    p "particles/holdout_lina/holdout_wildfire_start.vpcf"
    p "particles/creatures/creature_broodking/broodking_hatching.vpcfw"
    p "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_leap_impact.vpcf"
    p "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf"

    s "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts"
    s "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts"
    s "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts"
    s "soundevents/creatures/techies_sounds.vsndevts"

    v "soundevents/voscripts/game_sounds_vo_pudge.vsndevts"
    v "soundevents/voscripts/game_sounds_vo_broodmother.vsndevts"
    v "soundevents/voscripts/game_sounds_vo_mirana.vsndevts"
    v "soundevents/voscripts/game_sounds_vo_puck.vsndevts"
    v "soundevents/voscripts/game_sounds_vo_techies.vsndevts"

    PrecacheEverythingFromKV( c )
end

local function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            PrecacheEverythingFromTable( context, value )
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle", value, context)
                -- print("PRECACHE PARTICLE RESOURCE", value)
            end
            if string.find(value, "vmdl") then
                PrecacheResource( "model", value, context)
                -- print("PRECACHE MODEL RESOURCE", value)
            end
            if string.find(value, "vsndevts") then
                PrecacheResource( "soundfile", value, context)
                -- print("PRECACHE SOUND RESOURCE", value)
            end
        end
    end
end

function PrecacheEverythingFromKV( context )
    local kv_files = {
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_heroes_custom.txt",
        "scripts/npc/npc_abilities_override.txt",
        "scripts/npc/npc_items_custom.txt",
        "scripts/npc/bullet_defination.txt"
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            -- print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end

return DoPrecache