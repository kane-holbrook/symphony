AddCSLuaFile()

sym.logging = {}

PrintTableRaw = PrintTableRaw or PrintTable

LOG_ERROR = 0
LOG_WARN = 1
LOG_MESSAGE = 2
LOG_DEBUG = 3
LOG_FINE = 4
LOG_FINER = 5
LOG_FINEST = 6


local LogCvar = sym.proxy(6)


LAST_COLOR = color_white

local TypeFuncs = {

	[TYPE_BOOL] = function (v)
        return Color(184, 184, 255), v, LAST_COLOR
    end,

	[TYPE_FUNCTION] = function (v)
        return Color(255, 109, 236), v, LAST_COLOR
    end,
    
    [TYPE_VECTOR] = function (v)
        return Color(151, 222, 255), v, LAST_COLOR
    end,

	[TYPE_STRING] = function (v)
        return Color(151, 222, 255), "\"", Color(255, 128, 0, 255), v, Color(151, 222, 255), "\"", LAST_COLOR
    end,
    
    [TYPE_NUMBER] = function (v)
        return Color(128, 255, 128, 255), v, LAST_COLOR
    end,

    [TYPE_ENTITY] = function (v)
        if v:IsPlayer() then
            return Color(151, 222, 255), v:Name(), LAST_COLOR
        else
            return Color(151, 222, 255), "Entity[" .. v:EntIndex() .. "]", LAST_COLOR

        end
    end,

    ["default"] = function (v)
        return COL_PRIM, v
    end
}
sym.logging.TypeFuncs = TypeFuncs

function sym.LogLevel(level)
    level = level or LOG_DEBUG
    return LogCvar:Get() >= level
end
local PRINT_N = 0

local function Modify(inp, gap)
    return color_white
	--[[local n = math.mod(PRINT_N, 2)
	if n == 0 then
		PRINT_N = 1
		return inp
	end

	local c = inp:Brighten(gap * n)
	PRINT_N = PRINT_N + 1

	return c--]]
end

local function ParseArgs(...)
    local out = {}
    for k, v in pairs({...}) do        
        if IsColor(v) then
            table.insert(out, v)
        elseif sym.IsType(v, sym.types.primitive) then
            local v2 = ToPrimitive(v)
            local typ = TypeID(v2)
            local tf = TypeFuncs[typ]
            if tf then
                table.Add(out, { tf(v2) })
            else
                table.Add(out, { TypeFuncs["default"](v2) })
            end
                
        else
            table.insert(out, (v and tostring(v) or "nil"))
        end
    end
    table.insert(out, "\n")

    return out
end

function sym.print(...)
	local args = ParseArgs(...)

    if LogCvar:Get() >= LOG_MESSAGE then
	    MsgC(color_white, sym.datetime():toTimeString(), "|", PRINT_COL, color_white, PRINT_COL:Darken(0.3), "INFO", color_white, "|", Modify(PRINT_COL, 0.3), unpack(args))	
    end
end

function sym.error(...)
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= LOG_ERROR then
	    MsgC(PRINT_ERROR, sym.datetime():toTimeString(), "|", PRINT_COL, color_white, PRINT_ERROR:Darken(0.1), "ERROR", color_white, "|", Modify(PRINT_ERROR, 0.3), unpack(args))
    end	
end

function sym.warn(...)
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= LOG_WARN then
	    MsgC(PRINT_WARN, sym.datetime():toTimeString(), color_white, "|", PRINT_COL, color_white, PRINT_WARN:Darken(0.1), "WARN", color_white, "|", Modify(PRINT_WARN, 0.2), unpack(args))	
    end
end


function sym.rdebug(col, level, msg, ...)
    col = col or PRINT_DEBUG
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= level then
	    MsgC(color_white, sym.datetime():toTimeString(), "|", PRINT_DEBUG, color_white, col:Darken(0.3), msg, color_white, "|", Modify(col, 0.3), unpack(args))	
    end
end

function sym.debug(msg, ...)
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= LOG_DEBUG then
	    MsgC(color_white, sym.datetime():toTimeString(), "|", PRINT_DEBUG, color_white, PRINT_DEBUG:Darken(0.3), msg, color_white, "|", Modify(PRINT_DEBUG, 0.3), unpack(args))	
    end
end

function sym.fine(msg, ...)
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= LOG_FINE then
	    MsgC(color_white, sym.datetime():toTimeString(), "|", PRINT_DEBUG, color_white, PRINT_DEBUG:Darken(0.3), msg, color_white, "|", Modify(PRINT_DEBUG, 0.3), unpack(args))	
    end
end

function sym.finer(msg, ...)
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= LOG_FINER then
	    MsgC(color_white, sym.datetime():toTimeString(), "|", PRINT_DEBUG, color_white, PRINT_DEBUG:Darken(0.3), msg, color_white, "|", Modify(PRINT_DEBUG, 0.3), unpack(args))	
    end
end

function sym.finest(msg, ...)
	local args = ParseArgs(...)
    
    if LogCvar:Get() >= LOG_FINEST then
	    MsgC(color_white, sym.datetime():toTimeString(), "|", PRINT_DEBUG, color_white, PRINT_DEBUG:Darken(0.3), msg, color_white, "|", Modify(PRINT_DEBUG, 0.3), unpack(args))	
    end
end

function sym.trace(...)
    local d = debug.getinfo(2)
    sym.finest("TRACE", PRINT_COL, d.short_src, color_white, ":", PRINT_COL, d.currentline, color_white, "|", ...)
end


function sym.log(level, type, message, data, player, time, sessionId)
    assert(level, "Must provide a logging level.")
    assert(type, "Must provide a type")

    sessionId = sessionId or (sym.session and sym.session:GetId())
    if not sessionId then
        sym.trace("LOG", level, " ", type, " ", message, " ", data, " ", player, " ", time, " ", sessionId)
        return
    end

    local log = sym.CreateInstance(LOG)
    log:SetSessionId(sessionId or sym.session:GetId())
    log:SetLevel(level)
    log:SetLogType(type)
    log:SetMessage(message)
    log:SetData(data)
    log:SetTime(time or sym.datetime())

    if IsValid(player) then
        log:SetSteamId(player:SteamID64())
        
        local pos = player:GetPos()
        log:SetX(pos.x)
        log:SetY(pos.y)
        log:SetZ(pos.z)
    elseif isstring(player) then
        log:SetSteamId(player)
    end

    if SERVER then
        return log, log:DbInsert()
    end

    --sym.logging.OnLog:Invoke(log)

    return log
end


function PrintTable( t, indent, done, options)
    if istable(indent) then
        options = indent
        indent = nil
        done = nil
    end

    options = options or {}
    local MsgC = options.MsgC or MsgC
    local dontIgnoreMetaMethods = options.dontIgnoreMetaMethods

	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )

	table.sort( keys, function( a, b )
		if ( isnumber( a ) and isnumber( b ) ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	done[ t ] = true

	for i = 1, #keys do
		local key = keys[ i ]
        local ktf = TypeFuncs[TypeID(key)] or TypeFuncs["default"]

		if not dontIgnoreMetaMethods and isstring(key) and string.StartsWith(key, "__") then
			continue
		end

		local value = t[ key ]
		MsgC( COL_STD, string.rep( "  ", indent ) )

		if  ( istable( value ) and !done[ value ] ) then
			done[ value ] = true
            local mt = getmetatable(value)
            if mt and mt.__printtable then
                local args = {}
                table.insert(args, COL_STD)
                table.insert(args, "[")
                table.Add(args, { ktf(key) })
                table.insert(args, COL_STD)
                table.insert(args, "]: ")
                MsgC(unpack(args))
                mt.__printtable(value, indent, done, options)
                MsgC("\n")
            else
                if isstring(key) and key == "[\"__super\"]" then
                    local args = {}
                    table.insert(args, COL_STD)
                    table.insert(args, "[")
                    table.Add(args, { ktf(key) })
                    table.insert(args, COL_STD)
                    table.insert(args, "]: ")
                    table.insert(args, COL_TYPE)
                    table.insert(args, " Type[" .. stringex.TitleCase(value.__type) .. "]")
                    table.insert(args, "\n")

                    MsgC(unpack(args))
                else
                    
                    local args = {}
                    table.insert(args, COL_STD)
                    table.insert(args, "[")
                    table.Add(args, { ktf(key) })
                    table.insert(args, COL_STD)
                    table.insert(args, "]: ")
                    table.insert(args, "\n")
                    
                    MsgC(unpack(args))
                    PrintTable ( value, indent + 2, done, options )
                end
            end

			done[ value ] = nil

		else

            local tf = TypeFuncs[TypeID(value)] or TypeFuncs["default"]
            
            local args = {}
            table.insert(args, COL_STD)
            table.insert(args, "[")
            table.Add(args, { ktf(key) })
            table.insert(args, COL_STD)
            table.insert(args, "]: ")
            table.Add(args, { tf(value) })
            table.insert(args, "\n")
            MsgC(unpack(args))

		end

	end
    return ""
end

