LinkLuaModifier("modifier_debug_undead", "modifiers/debug/modifier_debug_undead.lua", LUA_MODIFIER_MOTION_NONE)

function CEDGameMode:_DebugChatCommand(keys)
    if not IsInToolsMode() then
        return
    end

    local c   = string.split(keys.text)
    local cmd = c[1]

    -- for k,v in pairs(c) do print(k,v) end

    -- debug test room
    if cmd == "dtr" then
        self:_DebugTestRoom(c[1], c[2])
    end

    if cmd == "undead" then
        for _, hero in pairs(self:GetAllHeroes()) do
            hero:AddNewModifier(hero, nil, "modifier_debug_undead", {})
        end
    end
    if cmd == "srm" then
        GameRules.gamemode:GetCurrentMap():_ShowRoomMessage()
    end

    -- debug force finish room
    if cmd == "dff" then
        GameRules.gamemode:GetCurrentRoom().bForceFinished = true -- debug command
    end

    if cmd == "moveto" then
        local x           = c[2]
        local y           = c[3]
        local currentRoom = GameRules.gamemode:GetCurrentRoom()
        if currentRoom then
            currentRoom:ExitRoom()
        end
        local room = GameRules.gamemode:GetCurrentMap():GetRoomAtCoord(tonumber(x), tonumber(y))
        if room then
            print("entering new room")
            room:EnterRoom()
        end
    end

    -- debug test prop
    if cmd == "dtp" then
        local x    = tonumber(c[2])
        local y    = tonumber(c[3])
        local name = c[4]
        if not ( x and y and name ) then
            Say(nil, string.format("%s, %s, %s", x, y, name), false)
            Say(nil, "Invalid debug test prop command", false)
        else
            local room = GameRules.gamemode:GetCurrentRoom()
            print(string.format("inserting props %s in [%d,%d]", name, x, y))
            room:InsertProp(name, x, y)
        end
    end

    -- debug save room
    -- save the room to the directory
    if cmd == "dsr" then
        local name = c[2]
        if require("rooms.traps." .. name) then
            Say(nil, "Save failed, file already exists", false)
        else
            local file = io.open("../../dota_addons/ed/scripts/vscripts/rooms/traps/" .. name .. ".lua", "w")
            -- 获取房间内的所有陷阱
        end
    end

    -- debug load prop map
    if cmd == "dlpm" then
        local filename = c[2]
        GameRules.gamemode:GetCurrentRoom():LoadPropMap(filename)
    end
end