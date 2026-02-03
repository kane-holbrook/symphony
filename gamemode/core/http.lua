AddCSLuaFile()

if SERVER then
    
    require("maw")
    local cvar = CreateConVar("sym_http_port", "3000", FCVAR_REPLICATED) 

    hook.Add("Symphony:Initialize", function ()
        local router = Maw.Router.New()

        hook.Run("HTTP:RegisterRoutes", router)

        Symphony.MAW = Maw.App.New()
            :Router(router)
            :Listen("0.0.0.0:" .. cvar:GetInt())

        Log.Write(LOG_INFO, "REST_START", "Starting REST server on port " .. cvar:GetInt())
    end)
end