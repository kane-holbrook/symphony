include("shared.lua")
include("sv_hooks.lua")
AddCSLuaFile("cl_hooks.lua")
include("sh_hooks.lua")

function Symphony.Init()
    local promises = {}
    hook.Run("Symphony:Initialize", promises)

    Promise.AwaitAll(promises):Then(function ()
        local t = math.Round((SysTime() - Symphony.StartTime) * 1000, 1)
        Log.Write(LOG_INFO, "SYM", "Symphony initialized in " .. t .. "ms.", t)

        if CLIENT then
            Log.Write(LOG_INFO, "SYM", "Requesting ")
        end

        hook.Run("Symphony:Ready")
    end)
end

RPC.Register("InitializePlayer", function (ply)
    Log.Write(LOG_INFO, "RPC", tostring(ply) .. " is initializing.")

    -- Let's get their user
    local user = Type.User:Select(ply:SteamID64()):Await()
    if #user == 0 then
        user = Type.New(Type.User)
        user:SetSteamID(ply:SteamID64())
        user:SetName(ply:Nick())
        user:SetUsergroups({ user = true })
    else
        user = user[1]
    end
    ply.User = user
    user:SetLastJoin(DateTime())
    user:Commit():Await()

    local data = {}
    data.User = user

    hook.Run("Symphony:InitializePlayer", ply, data)
    
    ply.Initialized = true

    return data
end)

timer.Simple(0, function ()
    Symphony.Init()
end)