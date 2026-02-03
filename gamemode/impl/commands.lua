AddCSLuaFile()

local CMD = Type.Register("Command")
CMD:CreateProperty("Name", Type.String)
CMD:CreateProperty("Description", Type.String)
CMD:CreateProperty("Parameters", Type.Table, { Default = {} })

function CMD.Prototype:GetParameters()
    return self.Parameters
end

function CMD.Prototype:CanRun(ply, args)
    --if not ply:HasPermission("Command." .. self:GetName()) then
    --    return false, "You do not have permission to run this command."
    --end
    return true
end

function CMD.Prototype:Run(ply, args)
    error("Not implemented")
end

function CMD.Prototype:AddAlias(name)
    Command.Registry[name] = self
end


Command = {}
Command.Registry = {}
Command.ParameterRegistry = {}

function Command.Register(name, description, parameters, func)
    local cmd = Type.New(CMD)
    cmd:SetName(name)
    cmd:SetDescription(description)
    cmd:SetParameters(parameters or {})
    cmd.Run = func
    
    Command.Registry[name] = cmd
    return cmd
end

function Command.RegisterParameterType(type, t)
    Command.ParameterRegistry[type] = t
end

if SERVER then
    function Command.Run(ply, argStr)
        local args = string.Split(argStr, " ")
        local name = args[1]

        local cmd = Command.Registry[name]
        if not cmd then return false, "Command not found." end

        args = stringex.ParseArgs(string.sub(argStr, #name + 2, -1), #cmd:GetParameters())
        local out = {}
        for k, v in pairs(cmd:GetParameters()) do
            local pt = v.Type
            local arg = args[k]
            
            if stringex.IsBlank(arg) and not v.Optional then
                return false, "Missing argument for parameter '" .. v.Name .. "'."
            end

            if isstring(pt) then
                local pr = Command.ParameterRegistry[pt]
                if pr then
                    local parsed = pr.Parse(ply, arg or "", v, cmd)
                    if parsed == nil then
                        return false, "Invalid argument for parameter '" .. v.Name .. "'."
                    end
                    out[v.Name] = parsed
                    continue
                end

                -- It's a type rather than a param parser
                pt = Type.GetByName(pt)
            end

            if not pt then
                return false, "Invalid parameter type for parameter '" .. v.Name .. "'."
            end

            local parsed = pt.Parse(ply, arg)
            if parsed == nil then
                return false, "Invalid argument for parameter '" .. v.Name .. "'."
            end
            out[v.Name] = parsed
        end

        local succ, msg = cmd:CanRun(ply, out)
        if succ == false then
            return false, msg
        end

        return cmd:Run(ply, out)
    end
    RPC.Register("Command.Run", Command.Run)
end

Command.RegisterParameterType("players", {
    Parse = function (ply, arg, data, cmd)
        local out = setmetatable({}, { __tostring = function (self)
            if #self < 5 then
                local names = {}
                for k, v in pairs(self) do
                    table.insert(names, v:Nick())
                end
                return table.concat(names, ", ")
            else
                return #self .. " players"
            end
        end })

        if arg == "*" then            
            if data.IgnoreSelf then
                for k, v in pairs(player.GetAll()) do
                    if v ~= ply then
                        table.insert(out, v)
                    end
                end
            else
                table.Add(out, player.GetAll())
            end

            return out
        end

        if not data.IgnoreSelf and arg == "^" then
            table.insert(out, ply)
            return out
        end

        for k, v in pairs(player.GetAll()) do

            if data.IgnoreSelf and v == ply then
                continue
            end

            if string.find(string.lower(v:Nick()), string.lower(arg), 1, true) then
                table.insert(out, v)
            end
        end

        -- Sort them by how close they are to the argument
        table.sort(out, function (a, b)
            return stringex.GetLevenshteinDistance(string.lower(a:Nick()), string.lower(arg)) <
                stringex.GetLevenshteinDistance(string.lower(b:Nick()), string.lower(arg))
        end)
        
        return out
    end,

    Suggest = function (ply, arg, data, cmd)
        local out = {}
        if not data.IgnoreSelf and arg == "^" then
            table.insert(out, "^")
        end
        table.insert(out, "*")

        for k, v in pairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()), string.lower(arg), 1, true) then
                table.insert(out, v:Nick())
            end
        end

        -- Sort them by how close they are to the argument
        table.sort(out, function (a, b)
            return stringex.GetLevenshteinDistance(string.lower(a), string.lower(arg)) <
                   stringex.GetLevenshteinDistance(string.lower(b), string.lower(arg))
        end)

        return out
    end
})

Command.RegisterParameterType("player", {
    Parse = function (ply, arg, data, cmd)
        local out = {}

        if not data.IgnoreSelf and arg == "^" then
            return ply
        end

        for k, v in pairs(player.GetAll()) do

            if string.find(string.lower(v:Nick()), string.lower(arg), 1, true) then
                table.insert(out, v)
            end
        end

        -- Sort them by how close they are to the argument
        table.sort(out, function (a, b)
            return stringex.GetLevenshteinDistance(string.lower(a:Nick()), string.lower(arg)) <
                   stringex.GetLevenshteinDistance(string.lower(b:Nick()), string.lower(arg))
        end)

        -- Only return the closest match
        return out[1]
    end,

    Suggest = function (ply, arg, data, cmd)
        local out = {}
        for k, v in pairs(player.GetAll()) do

            if string.find(string.lower(v:Nick()), string.lower(arg), 1, true) then
                table.insert(out, v:Nick())
            end
        end

        -- Sort them by how close they are to the argument
        table.sort(out, function (a, b)
            return stringex.GetLevenshteinDistance(string.lower(a), string.lower(arg)) <
                   stringex.GetLevenshteinDistance(string.lower(b), string.lower(arg))
        end)

        return out
    end
})

if CLIENT then
    concommand.Add("sym", function (ply, _, cmd, argStr)
        RPC.Call("Command.Run", argStr):Then(function (succ, msg)
            if msg then
                print(msg)
            end
        end)
    end, function (_, argStr, _)
        local args = stringex.ParseArgs(argStr)
        local cmd = args[1] or ""

        if not args[3] then
            local out = {}
            for k, v in pairs(Command.Registry) do
                if string.StartWith(v:GetName(), cmd) then
                    if not v:CanRun(LocalPlayer(), {}) then
                        continue
                    end

                    table.insert(out, "sym " .. v:GetName())
                end
            end
            return out
        end

        -- If we get to here, args[2] is the command name
        local command = Command.Registry[args[2]]
        if not command then return end

        -- At this point, we need to parse the args against the command parameters
        local params = command:GetParameters()
        argStr = string.Trim(string.sub(argStr, (#args[1] + #args[2]) + 2, -1))

        args = stringex.ParseArgs(argStr, #params)
        
        local idx = #args
        local param = params[idx]
        local pt = param.Type
        local arg = args[idx]

        if isstring(pt) then
            local pr = Command.ParameterRegistry[pt]
            if pr then
                if pr.Suggest then
                    local out = {}

                    for k, v in pairs(pr.Suggest(ply, arg or "", param, command)) do
                        table.insert(out, string.Trim("sym " .. command:GetName() .. " " .. table.concat(args, " ", 1, #args - 1)) .. " " .. v)
                    end
                    return out
                end
            end
        end
    end,
    "Run a Symphony command")
end


-- Some basic admin commands
Command.Register("bring", "Teleport a player to you.",
    {
        { Name = "Target", Type = "players", Description = "The player to teleport to you.", IgnoreSelf = true }
    },
    function (cmd, ply, args)
        local target = args.Target
        
        local pos = ply:GetPos()
        local yaw = ply:EyeAngles().yaw
        
        local playerSpacing = 48 -- Minimum distance between players on the same circle
        local baseRadius = 64
        local radiusIncrement = 64
        
        -- Calculate how many players fit in each layer based on circumference
        local function getPlayersPerLayer(radius)
            local circumference = 2 * math.pi * radius
            return math.max(1, math.floor(circumference / playerSpacing))
        end
        
        -- Find a valid position using trace hull
        local function findValidPosition(idealPos, ply)
            local hullMin = Vector(-16, -16, 0)
            local hullMax = Vector(16, 16, 72)
            
            -- Check if ideal position is clear
            local tr = util.TraceHull({
                start = idealPos,
                endpos = idealPos,
                mins = hullMin,
                maxs = hullMax,
                filter = function(ent) return ent:IsPlayer() end
            })
            
            if not tr.Hit then
                return idealPos
            end
            
            -- Search in a spiral pattern around the ideal position
            local maxSearchRadius = 128
            local searchStep = 16
            
            for searchRadius = searchStep, maxSearchRadius, searchStep do
                for angle = 0, 360, 30 do
                    local offset = Vector(
                        math.cos(math.rad(angle)) * searchRadius,
                        math.sin(math.rad(angle)) * searchRadius,
                        0
                    )
                    local testPos = idealPos + offset
                    
                    tr = util.TraceHull({
                        start = testPos,
                        endpos = testPos,
                        mins = hullMin,
                        maxs = hullMax,
                        filter = function(ent) return ent:IsPlayer() end
                    })
                    
                    if not tr.Hit then
                        return testPos
                    end
                end
            end
            
            -- If all else fails, return ideal position
            return idealPos
        end
        
        -- Distribute players into layers
        local currentPlayer = 1
        local layer = 0
        
        while currentPlayer <= #target do
            local radius = baseRadius + (layer * radiusIncrement)
            local playersInLayer = getPlayersPerLayer(radius)
            local playersToPlace = math.min(playersInLayer, #target - currentPlayer + 1)
            
            for i = 0, playersToPlace - 1 do
                local angleOffset = (360 / playersToPlace) * i
                local angle = math.rad(yaw + angleOffset)
                local idealPos = pos + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
                local targetPos = findValidPosition(idealPos, target[currentPlayer])
                target[currentPlayer]:SetPos(targetPos)
                currentPlayer = currentPlayer + 1
            end
            
            layer = layer + 1
        end
        
        return true, "Brought " .. tostring(target) .. " to you."
    end
)


Command.Register("send", "Teleport player(s) to another player.",
    {
        { Name = "Target", Type = "players", Description = "The players to teleport." },
        { Name = "To", Type = "player", Description = "The player to teleport to." }
    },
    function (cmd, ply, args)
        local target = args.Target
        local to = args.To

        table.RemoveByValue(target, to)

        local pos = to:GetPos()
        local yaw = to:EyeAngles().yaw
        
        local playerSpacing = 48 -- Minimum distance between players on the same circle
        local baseRadius = 64
        local radiusIncrement = 64
        
        -- Calculate how many players fit in each layer based on circumference
        local function getPlayersPerLayer(radius)
            local circumference = 2 * math.pi * radius
            return math.max(1, math.floor(circumference / playerSpacing))
        end
        
        -- Find a valid position using trace hull
        local function findValidPosition(idealPos, ply)
            local hullMin = Vector(-16, -16, 0)
            local hullMax = Vector(16, 16, 72)
            
            -- Check if ideal position is clear
            local tr = util.TraceHull({
                start = idealPos,
                endpos = idealPos,
                mins = hullMin,
                maxs = hullMax,
                filter = function(ent) return ent:IsPlayer() end
            })
            
            if not tr.Hit then
                return idealPos
            end
            
            -- Search in a spiral pattern around the ideal position
            local maxSearchRadius = 128
            local searchStep = 16
            
            for searchRadius = searchStep, maxSearchRadius, searchStep do
                for angle = 0, 360, 30 do
                    local offset = Vector(
                        math.cos(math.rad(angle)) * searchRadius,
                        math.sin(math.rad(angle)) * searchRadius,
                        0
                    )
                    local testPos = idealPos + offset
                    
                    tr = util.TraceHull({
                        start = testPos,
                        endpos = testPos,
                        mins = hullMin,
                        maxs = hullMax,
                        filter = function(ent) return ent:IsPlayer() end
                    })
                    
                    if not tr.Hit then
                        return testPos
                    end
                end
            end
            
            -- If all else fails, return ideal position
            return idealPos
        end
        
        -- Distribute players into layers
        local currentPlayer = 1
        local layer = 0
        
        while currentPlayer <= #target do
            local radius = baseRadius + (layer * radiusIncrement)
            local playersInLayer = getPlayersPerLayer(radius)
            local playersToPlace = math.min(playersInLayer, #target - currentPlayer + 1)
            
            for i = 0, playersToPlace - 1 do
                local angleOffset = (360 / playersToPlace) * i
                local angle = math.rad(yaw + angleOffset)
                local idealPos = pos + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
                local targetPos = findValidPosition(idealPos, target[currentPlayer])
                target[currentPlayer]:SetPos(targetPos)
                currentPlayer = currentPlayer + 1
            end
            
            layer = layer + 1
        end
        
        return true, "Sent " .. tostring(target) .. " to " .. to:Nick() .. "."
    end
)
:AddAlias("tp")


Command.Register("goto", "Teleport to another player.",
    {
        { Name = "Target", Type = "player", Description = "The player to teleport to you.", IgnoreSelf = true }
    },
    function (cmd, ply, args)
        local target = args.Target
        
        local pos = target:GetPos()
        local fwd = target:GetForward()

        ply:SetPos(pos + fwd * 64)
        return true, "Teleported to " .. target:Nick() .. "."
    end
)


Command.Register("sethp", "Set a player's health",
    {
        { Name = "Target", Type = "players", Description = "The players." },
        { Name = "HP", Type = "String", Description = "The health to set." }
    },
    function (cmd, ply, args)
        local target = args.Target
        local hp = tonumber(args.HP)

        if hp then
            for k, v in pairs(target) do
                v:SetHealth(hp)
            end
            return true, "Set health of " .. tostring(target) .. " to " .. hp .. "."
        else
            hp = args.HP
            if isstring(hp) and string.EndsWith(hp, "%") then
                local percent = tonumber(string.sub(hp, 1, -2))
                if percent then
                    for k, v in pairs(target) do
                        local newHP = math.floor(v:GetMaxHealth() * (percent / 100))
                        v:SetHealth(newHP)
                    end
                    return true, "Set health of " .. tostring(target) .. " to " .. hp .. "."
                end
            end
        end
        return false, "Health values must be a number or a %."
    end
)
    :AddAlias("hp")


Command.Register("slay", "Slay a player.",
    {
        { Name = "Target", Type = "players", Description = "The players to slay." }
    },
    function (cmd, ply, args)
        local target = args.Target

        for k, v in pairs(target) do
            v:Kill()
        end

        return true, "Slayed " .. tostring(target) .. "."
    end
)


Command.Register("respawn", "Respawn a player.",
    {
        { Name = "Target", Type = "players", Description = "The players to respawn." }
    },
    function (cmd, ply, args)
        local target = args.Target

        for k, v in pairs(target) do
            v:KillSilent()
            v:Spawn()
        end

        return true, "Respawned " .. tostring(target) .. "."
    end
)


Command.Register("kick", "Kick a player",
    {
        { Name = "Target", Type = "players", Description = "The players to kick." },
        { Name = "Reason", Type = "String", Description = "The reason for the kick.", Optional = true }
    },
    function (cmd, ply, args)
        local target = args.Target
        local reason = args.Reason or "No reason specified."

        for k, v in pairs(target) do
            v:Kick(reason)
        end

        return true, "Kicked " .. tostring(target) .. "."
    end
)