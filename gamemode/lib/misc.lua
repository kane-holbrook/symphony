AddCSLuaFile()

REALM_SERVER = 1
REALM_CLIENT = 2
REALM_SHARED = 3
REALM = SERVER and REALM_SERVER or REALM_CLIENT


-- Creates a timer if it doesn't exist
function defer(name, time, func, ...)
    time = time or 0
    if (!timer.Exists(name)) then
        local args = {...}
        timer.Create(name, time, 1, (#args == 0 and func) or function() func(unpack(args)) end)
    end
end

function cancelDefer(name)
    timer.Remove(name)
end

function adjustDefer(name, time)
    timer.Adjust(name, time)
end




function sym.TryInclude(path, realm)
    assert(path, "Path must be provided")
    assert(realm, "Realm must be provided")
    
    if file.Exists(path, "LUA") then
        if SERVER and realm == Realm.Client or realm == Realm.Shared then
            AddCSLuaFile(path)
        end

        if sym.realm == realm or realm == Realm.Shared then
            
            return include(path)
        end
        return true
    end
    return sym.null
end

function sym.Include(path, realm)
    if string.EndsWith(path, "/") then
        print(path .. "*")
        local files, dirs = file.Find(path .. "*.lua", "LUA")
        
        print("Path is a directory")
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
        sym.fine("ADDCSLUAFILE", path)
        AddCSLuaFile(path)
    end

    if isany(realm, sym.realm, Realm.Shared) then
        sym.fine("INCLUDE", path)
        return include(path)
    end
end

function sym.IncludeDir(path, startFunc, endFunc, includePlugins, realm, plugin)
    realm = realm or Realm.Shared

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

function sym.IncludeWeb(endpoint, path, handler)
    if SERVER then
        local newPath = filex.GetRelativePath(path, 1)

        assert(file.Exists(newPath, "GAME"), newPath .. " not found.")

        sym.rdebug(PRINT_HTML, LOG_FINE, "HTTP", "Mapped ", FromPrimitive(endpoint), color_white, " to ", FromPrimitive(newPath))
        HttpServer.Hook(endpoint, function (ply, ctx, path)
            if handler then
                local out = { handler(ply, ctx, path) }
                if #out > 0 then
                    return unpack(out)
                end 
            end

            return file.Read(newPath, "GAME")
        end)
    end
    return HttpServer.GetPath(endpoint)
end

function isany(t, ...)
    for k, v in pairs({...}) do
        if t == v then
            return true
        end
    end
    return false
end

function uuid()
    local data = { math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295))}
    local data2 = string.format("%.8x", data[2])
    local data3 = string.format("%.8x", data[3])
    return string.format("%.8x-%s-%s-%s-%s%.8x", data[1], string.sub(data2, 0, 4), string.sub(data2, 5, 8), string.sub(data3, 0, 4), string.sub(data3, 5, 8), data[4])
end



local Preview = false
function PreviewMaterial(mat, x, y, w, h)
    if Preview then
        Preview = false
        hook.Remove("HUDPaint", "PreviewMaterial")
        return
    end    

    x = x or 0
    y = y or 0
    w = w or mat:Width()
    h = h or mat:Height()

    hook.Add("HUDPaint", "PreviewMaterial", function ()
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x, y, w, h)
        
        local sw, sh = ScrW(), ScrH()
        local sz = ScreenScale(5)
        draw.NoTexture()
        surface.SetDrawColor(0, 255, 0, 255)
        surface.DrawTexturedRectRotated(sw-sz, sh-sz, sz, sz, -CurTime()*200)
    end)
    Preview = true
end


--[[---------------------------------------------------------
	AccessorFunc
	Quickly make Get/Set accessor fuctions on the specified table
-----------------------------------------------------------]]
function AccessorFunc( tab, varname, name, iForce )

	if ( !tab ) then debug.Trace() end

	tab[ "Get" .. name ] = function( self ) return self[ varname ] end

	if ( iForce == FORCE_STRING ) then
		tab[ "Set" .. name ] = function( self, v ) self[ varname ] = tostring( v ) return self end
	return end

	if ( iForce == FORCE_NUMBER ) then
		tab[ "Set" .. name ] = function( self, v ) self[ varname ] = tonumber( v ) return self end
	return end

	if ( iForce == FORCE_BOOL ) then
		tab[ "Set" .. name ] = function( self, v ) self[ varname ] = tobool( v ) return self end
	return end

	if ( iForce == FORCE_ANGLE ) then
		tab[ "Set" .. name ] = function( self, v ) self[ varname ] = Angle( v ) return self end
	return end

	if ( iForce == FORCE_COLOR ) then
		tab[ "Set" .. name ] = function( self, v )
			if ( type( v ) == "Vector" ) then self[ varname ] = v:ToColor()
			else self[ varname ] = string.ToColor( tostring( v ) ) end
            return self
		end
	return end

	if ( iForce == FORCE_VECTOR ) then
		tab[ "Set" .. name ] = function( self, v )
			if ( IsColor( v ) ) then self[ varname ] = v:ToVector()
			else self[ varname ] = Vector( v ) end
            return self
		end
	return end

	tab[ "Set" .. name ] = function( self, v ) self[ varname ] = v return self end

end


function ExternalAccessorFunc(tab, key, name, func, iForce)
    if not tab then debug.Trace() end

    func = func or name

    -- Getter function
    tab["Get" .. name] = function(self, ...) 
        local p = self[key]
        return p["Get" .. func](p, ...) 
    end

    -- Default setter
    tab["Set" .. name] = function(self, ...)
        local p = self[key]
        p["Set" .. func](p, ...)
        return self
    end
end
