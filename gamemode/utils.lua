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
        return include(path)
    end
end

function nticks(n, func, ...)
    local id = uuid()
    local args = {...}
    hook.Add("Tick", id, function()
        n = n - 1
        if n == 0 then
            func(unpack(args))
            hook.Remove("Tick", uuid)
        end
    end)
end

-- Creates a timer if it doesn't exist
local debouncers = {}
function debounce(name, time, func, ...)
    time = time or 0
    debouncers[name] = { func, { ... } }

    if not timer.Exists(name) then
        local args = {...}
        timer.Create(name, time, 1, function ()
            local func = debouncers[name][1]
            local args = debouncers[name][2]
            func(unpack(args))
            debouncers[name] = nil
        end)
    end
end

function cancelDebounce(name)
    timer.Remove(name)
end

function adjustDebounce(name, time)
    timer.Adjust(name, time)
end

local function immuteError()
    error("Table is immutable")
end

function immutable(t)
    local mt = getmetatable(t) or {}
    if mt.__newindex then
        return false
    end

    mt.__newindex = immuteError
    setmetatable(t, mt)
end