AddCSLuaFile()

Realm = {
    Server = 1,
    Client = 2,
    Shared = 3
}
Realm.Current = SERVER and Realm.Server or Realm.Client

function isany(t, ...)
    for k, v in pairs({...}) do
        if t == v then
            return true
        end
    end
    return false
end

function IncludeEx(path, realm)
    if string.EndsWith(path, "/") then
        local files, dirs = file.Find(path .. "*.lua", "LUA")
        
        -- Path is a directory
        for k, v in pairs(files) do
            sym.Include(path .. v)
        end

        return
    end
    
    local fname = string.GetFileFromFilename(path)
    if not realm then
        if string.StartsWith(fname, "sv_") then
            realm = Realm.Server
        elseif string.StartsWith(fname, "cl_") then
            realm = Realm.Client
        elseif string.StartsWith(fname, "sh_") then
            realm = Realm.Shared
        end
    end
    assert(realm, "Realm must be provided if the file does not start with cl_ or sh_  or sv_")
    
    if isany(realm, Realm.Client, Realm.Shared) then
        AddCSLuaFile(path)
    end

    if isany(realm, Realm.Current, Realm.Shared) then
        local absPath = engine.ActiveGamemode() .. "/gamemode/" .. path

        if not file.Exists(absPath, "LUA") then
            sym.log("LUA_INCLUDE", "Failed to include \"<code>" .. path .. "</code>\"")
            --MsgC(color_white, os.date("%X"), "|", PRINT_ERROR, color_white, PRINT_ERROR, "ERROR", color_white, "|", PRINT_ERROR, "Failed to include: ", COL_STD, path, "\n")
            return false
        else
            sym.log("LUA_INCLUDE", "Including \"<code>" .. path .. "</code>\"")
            --MsgC(color_white, os.date("%X"), "|", PRINT_COL, color_white, PRINT_COL, "INFO", color_white, "|", color_white, "Including: ", COL_STD, path, "\n")	
            return include(path)
        end
    end
end
