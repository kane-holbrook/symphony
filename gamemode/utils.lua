AddCSLuaFile()

-- Realms
sym.realms = {
	server = 1,
	client = 2,
	shared = 3, -- bit.bor(server, client)
}
sym.realm = SERVER and sym.realms.server or sym.realms.client

function isany(t, ...)
    for k, v in pairs({...}) do
        if t == v then
            return true
        end
    end
    return false
end

function sym.Include(path, realm)
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
            realm = sym.realms.server
        elseif string.StartsWith(fname, "cl_") then
            realm = sym.realms.client
        elseif string.StartsWith(fname, "sh_") then
            realm = sym.realms.shared
        end
    end
    assert(realm, "Realm must be provided if the file does not start with cl_ or sh_  or sv_")
    
    if isany(realm, sym.realms.client, sym.realms.shared) then
        AddCSLuaFile(path)
    end

    if isany(realm, sym.realm, sym.realms.shared) then
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

function sym.IncludeDir(path, startFunc, endFunc, includePlugins, realm, plugin)
    realm = realm or sym.realms.shared

    if includePlugins then
        for k, v in pairs(sym.plugins.ordered) do
            sym.IncludeDir(v:GetPath() .. "/" .. path, startFunc, endFunc, includePlugins, realm, v)
        end
    else
        local files, dirs = file.Find("*", "LUA")
        for k, v in pairs(files) do
            startFunc(path, plugin)
                local r = { sym.TryInclude(path .. v, realm) }
            endFunc(path, plugin, unpack(r))
        end
    end
end