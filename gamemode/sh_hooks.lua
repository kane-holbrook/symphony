AddCSLuaFile()

CreateConVar("sym_rdb", "0", FCVAR_ARCHIVE) -- I want a convar for both client and server independently.
if util.IsBinaryModuleInstalled("rdb") then
    require("rdb")
    hook.Add("OnLuaError", "RDB", function (err, realm, stack, name, id)
        if GetConVar("sym_rdb"):GetBool() then
            print("Error caught, activating RDB...")
            rdb.activate(CLIENT and 21112)
        end
    end)
end