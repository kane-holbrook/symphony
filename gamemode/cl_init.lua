include("shared.lua")
include("sh_hooks.lua")


function Symphony.Init()    
    
    GAMEMODE:SuppressHint("OpeningMenu")
    GAMEMODE:SuppressHint("OpeningContext")
    GAMEMODE:SuppressHint("EditingSpawnlists")
    GAMEMODE:SuppressHint("EditingSpawnlistsSave") 
    GAMEMODE:SuppressHint("Annoy1")
    GAMEMODE:SuppressHint("Annoy2")

    RPC.Call("InitializePlayer"):Then(function (data)
        Log.Write(LOG_INFO, "SYM", "Received startup data from server.")

        local lp = LocalPlayer()
        lp.User = data.User
        User = lp.User

        local promises = {}
        hook.Run("Symphony:Initialize", promises, data)
        Promise.AwaitAll(promises):Then(function ()
            local t = math.Round((SysTime() - Symphony.StartTime) * 1000, 1)
            Log.Write(LOG_INFO, "SYM", "Symphony initialized in " .. t .. "ms.", t)
            hook.Run("Symphony:Ready")
        end)
    end)
end

timer.Simple(0, function ()
    Symphony.Init()
end)