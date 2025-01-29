include("shared.lua")

Database.Connect()


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