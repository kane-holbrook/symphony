include("shared.lua")


--[[concommand.Add("debug", function (ply, cmd, args)
    assert(ply == NULL)

    require("rdb")
    rdb.activate()
end)

hook.Add("OnLuaError", "symphony/init.lua", function (error, realm, stack, name, id)
    print("LuaError")
    require("rdb")
    rdb.activate()
end)--]]

if IsValid(h) then
    httpserver.Destroy(h)
end

-- HTTP test
h = httpserver.FindByName("SymphonyHTTPServer") 
if not h then
    h = httpserver.Create()
    print("Creating")
end

h:SetName("SymphonyHTTPServer")
h:Get("/test", function (req, res)
    print("Boop")
    res:SetContent("Hello world")
end)
h:Start("185.150.191.202", 8080)
print(h:IsRunning())

hook.Add("Think", "HttpThinker", function ()
    if h:IsRunning() then
        h:Think()
    end
end)