AddCSLuaFile()

if CLIENT then
    local navarea = Type.GetByName("NavArea")
    navarea:CreateProperty("ID", Type.Number)
    navarea:CreateProperty("AttributeBitField", Type.Number)
    navarea:CreateProperty("NorthWestCorner", Type.Vector)
    navarea:CreateProperty("SouthEastCorner", Type.Vector)
    navarea:CreateProperty("NorthEastZ", Type.Number)
    navarea:CreateProperty("SouthWestZ", Type.Number)
    navarea:CreateProperty("Connections", Type.Table)
    navarea:CreateProperty("HidingSpots", Type.Table)
    navarea:CreateProperty("Encounters", Type.Table)
    navarea:CreateProperty("Ladders", Type.Table)
    navarea:CreateProperty("PlaceID", Type.Number)

    function navarea.Prototype:GetPlace()
        return navmesh.places and navmesh.places[self:GetPlaceID()] or nil
    end

    function navarea.Prototype:GetCenter()
        return (self:GetNorthWestCorner() + self:GetSouthEastCorner()) / 2
    end

    function navarea.Prototype:GetCorner(cornerID)
        local nw = self:GetNorthWestCorner()
        local se = self:GetSouthEastCorner()
        
        if cornerID == 0 then -- NW
            return nw
        elseif cornerID == 1 then -- NE
            return Vector(se.x, nw.y, self:GetNorthEastZ())
        elseif cornerID == 2 then -- SE
            return se
        elseif cornerID == 3 then -- SW
            return Vector(nw.x, se.y, self:GetSouthWestZ())
        end
    end

    function navarea.Prototype:GetAdjacentAreas(direction)
        local conn = self:GetConnections()
        if not conn or not conn[direction] then return {} end
        
        local areas = {}
        for i, id in ipairs(conn[direction]) do
            local area = navmesh.GetNavAreaByID(id)
            if area then
                areas[i] = area
            end
        end
        return areas
    end

    function navarea.Prototype:IsConnected(otherArea)
        local conn = self:GetConnections()
        if not conn then return false end
        
        local otherID = otherArea:GetID()
        for dir = 1, 4 do
            if conn[dir] then
                for _, id in ipairs(conn[dir]) do
                    if id == otherID then
                        return true
                    end
                end
            end
        end
        return false
    end

    function navarea.Prototype:Contains(pos)
        local nw = self:GetNorthWestCorner()
        local se = self:GetSouthEastCorner()
        
        return pos.x >= nw.x and pos.x <= se.x and
               pos.y >= nw.y and pos.y <= se.y
    end

    function navarea.Prototype:GetClosestPointOnArea(pos)
        local nw = self:GetNorthWestCorner()
        local se = self:GetSouthEastCorner()
        
        local closest = Vector(
            math.Clamp(pos.x, nw.x, se.x),
            math.Clamp(pos.y, nw.y, se.y),
            0
        )
        
        -- Calculate Z based on position within the area
        local dx = (closest.x - nw.x) / (se.x - nw.x)
        local dy = (closest.y - nw.y) / (se.y - nw.y)
        
        local northZ = nw.z * (1 - dx) + self:GetNorthEastZ() * dx
        local southZ = self:GetSouthWestZ() * (1 - dx) + se.z * dx
        closest.z = northZ * (1 - dy) + southZ * dy
        
        return closest
    end

    function navarea.Prototype:GetSizeX()
        local nw = self:GetNorthWestCorner()
        local se = self:GetSouthEastCorner()
        return se.x - nw.x
    end

    function navarea.Prototype:GetSizeY()
        local nw = self:GetNorthWestCorner()
        local se = self:GetSouthEastCorner()
        return se.y - nw.y
    end

    local navladder = Type.GetByName("NavLadder")

    if not navmesh then
        navmesh = {}
        navmesh.info = {}
        navmesh._areas = {}
        navmesh._ladders = {}
        navmesh._tree = new("OctTree")
        navmesh._tree:SetBounds({
            min = Vector(-16384, -16384, -16384),
            max = Vector(16384, 16384, 16384)
        })
    end

    function navmesh.GetNavAreaCount()
        return table.Count(navmesh._areas)
    end

    function navmesh.GetNavAreaByID(id)
        return navmesh._areas[id]
    end

    function navmesh.GetNearestNavArea(pos, anyZ, maxDist, checkLOS, checkGround)
        maxDist = maxDist or 10000
        
        local results = navmesh._tree:QueryRadius(pos, maxDist)
        local closest = nil
        local closestDist = maxDist * maxDist
        
        for _, area in ipairs(results) do
            local point = area:GetClosestPointOnArea(pos)
            local distSq
            
            if anyZ then
                distSq = (pos.x - point.x)^2 + (pos.y - point.y)^2
            else
                distSq = pos:DistToSqr(point)
            end
            
            if distSq < closestDist then
                closest = area
                closestDist = distSq
            end
        end
        
        return closest
    end

    function navmesh.GetNavArea(pos, beneathLimit)
        beneathLimit = beneathLimit or 120
        
        -- Find areas that contain the XY position
        local candidates = navmesh._tree:QueryRadius(pos, beneathLimit)
        local best = nil
        local bestDist = beneathLimit
        
        for _, area in ipairs(candidates) do
            if area:Contains(pos) then
                local point = area:GetClosestPointOnArea(pos)
                local dist = math.abs(pos.z - point.z)
                
                if dist < bestDist and pos.z >= point.z then
                    best = area
                    bestDist = dist
                end
            end
        end
        
        return best
    end

    function navmesh.GetAllNavAreas()
        local areas = {}
        for _, area in pairs(navmesh._areas) do
            table.insert(areas, area)
        end
        return areas
    end

    function navmesh.GetGroundHeight(pos, maxDist)
        maxDist = maxDist or 500
        
        -- Use GetNearestNavArea with anyZ to find closest area regardless of height
        local area = navmesh.GetNearestNavArea(pos, true, maxDist)
        if not area then return nil, nil end
        
        local point = area:GetClosestPointOnArea(pos)
        
        -- Calculate surface normal from the four corners
        local nw = area:GetNorthWestCorner()
        local ne = Vector(area:GetSouthEastCorner().x, nw.y, area:GetNorthEastZ())
        local sw = Vector(nw.x, area:GetSouthEastCorner().y, area:GetSouthWestZ())
        
        -- Cross product of two edge vectors gives the normal
        local edge1 = ne - nw
        local edge2 = sw - nw
        local normal = edge1:Cross(edge2)
        normal:Normalize()
        
        return point.z, normal
    end

    -- Fast pathfinding - simplified A* for speed
    function navmesh.FindPath(startPos, goalPos, maxPathLength)
        maxPathLength = maxPathLength or math.huge
        
        -- Find start and goal areas
        local startArea = navmesh.GetNearestNavArea(startPos, false, 500)
        local goalArea = navmesh.GetNearestNavArea(goalPos, false, 500)
        
        if not startArea then
            print("[FindPath] Could not find start area near", startPos)
            return nil
        end
        
        if not goalArea then
            print("[FindPath] Could not find goal area near", goalPos)
            return nil
        end
        
        print("[FindPath] Start area:", startArea:GetID(), "Goal area:", goalArea:GetID())
        
        -- Debug connections
        local startConn = startArea:GetConnections()
        if startConn then
            local totalConns = 0
            for dir = 1, 4 do
                if startConn[dir] then
                    totalConns = totalConns + #startConn[dir]
                end
            end
            print("[FindPath] Start area has", totalConns, "total connections")
        else
            print("[FindPath] Start area has NO connections table!")
        end
        
        if startArea == goalArea then
            return {startArea}
        end
        
        -- Simple open/closed sets
        local openSet = {startArea}
        local closedSet = {}
        local cameFrom = {}
        local gScore = {[startArea:GetID()] = 0}
        local fScore = {[startArea:GetID()] = startArea:GetCenter():Distance(goalArea:GetCenter())}
        
        local iterations = 0
        local maxIterations = 5000
        
        while #openSet > 0 do
            iterations = iterations + 1
            if iterations > maxIterations then
                print("[FindPath] Max iterations reached, no path found")
                return nil
            end
            
            -- Find lowest fScore in openSet (simple linear search for small sets)
            local current = openSet[1]
            local currentIdx = 1
            local lowestF = fScore[current:GetID()] or math.huge
            
            for i = 2, #openSet do
                local f = fScore[openSet[i]:GetID()] or math.huge
                if f < lowestF then
                    current = openSet[i]
                    currentIdx = i
                    lowestF = f
                end
            end
            
            -- Found goal
            if current == goalArea then
                -- Reconstruct path
                local path = {current}
                while cameFrom[current:GetID()] do
                    current = cameFrom[current:GetID()]
                    table.insert(path, 1, current)
                end
                print("[FindPath] Path found after", iterations, "iterations")
                return path
            end
            
            -- Move current from open to closed
            table.remove(openSet, currentIdx)
            closedSet[current:GetID()] = true
            
            -- Check all connections (NESW)
            local connections = current:GetConnections()
            if connections then
                for dir = 1, 4 do
                    if connections[dir] then
                        for _, neighborID in ipairs(connections[dir]) do
                            local neighbor = navmesh.GetNavAreaByID(neighborID)
                            if neighbor and not closedSet[neighborID] then
                                local tentativeG = (gScore[current:GetID()] or 0) + current:GetCenter():Distance(neighbor:GetCenter())
                                
                                -- Check path length limit
                                if tentativeG > maxPathLength then
                                    continue
                                end
                                
                                local neighborG = gScore[neighborID] or math.huge
                                if tentativeG < neighborG then
                                    -- Better path found
                                    cameFrom[neighborID] = current
                                    gScore[neighborID] = tentativeG
                                    -- Manhattan distance heuristic (faster than Euclidean)
                                    local h = math.abs(neighbor:GetCenter().x - goalArea:GetCenter().x) +
                                              math.abs(neighbor:GetCenter().y - goalArea:GetCenter().y) +
                                              math.abs(neighbor:GetCenter().z - goalArea:GetCenter().z)
                                    fScore[neighborID] = tentativeG + h
                                    
                                    -- Add to open set if not already there
                                    local inOpen = false
                                    for _, area in ipairs(openSet) do
                                        if area:GetID() == neighborID then
                                            inOpen = true
                                            break
                                        end
                                    end
                                    if not inOpen then
                                        table.insert(openSet, neighbor)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- No path found
        print("[FindPath] Open set exhausted after", iterations, "iterations, no path exists")
        return nil
    end

    function navmesh.Load()
        local BATCH_SIZE = 50
        return Promise.Run(function ()

            local serverAreas = RPC.Call("navmesh.GetNavAreaCount"):Await()
            if serverAreas == 0 then
                return true -- No navmesh on server
            end

            local f = file.Open("maps/" .. game.GetMap() .. ".nav", "rb", "GAME")
            assert(f, "Failed to open navmesh file for map " .. game.GetMap())

            local function pause(step, pct)
                hook.Run("Symphony:SetLoadingStatus", "Loading navmesh: " .. step .. " (" .. math.Round(pct, 1) .. "%)")
                print(step, pct)
                Promise.SleepForTicks(10)
            end

            local succ, err = pcall(function ()
                local header = f:ReadULong()
                assert(header == 0xFEEDFACE, "Invalid navmesh header")
                
                local version = f:ReadULong()
                navmesh.info.version = version

                if version >= 10 then
                    navmesh.info.subversion = f:ReadULong()
                end

                if version >= 4 then
                    navmesh.info.saveBspSize = f:ReadULong()
                end

                if version >= 14 then
                    navmesh.info.isAnalyzed = f:ReadByte()
                end

                -- Read places (version 5+)
                if version >= 5 then
                    navmesh.places = {}                
                    pause("places", 0)
                    local placeCount = f:ReadUShort()  -- Places use UShort, not ULong!
                    for i = 1, placeCount do
                        local len = f:ReadUShort()  -- Length is also UShort
                        local name = f:Read(len)
                        navmesh.places[i] = name

                        if i % BATCH_SIZE == 0 then
                            pause("places", i / placeCount * 100)
                        end
                    end

                    if version > 11 then
                        navmesh.info.hasUnnamedAreas = f:ReadByte()
                    end
                end

                pause("areas", 0)
                local numAreas = f:ReadULong()
                for i=1, numAreas do
                    local area = new(navarea)
                    area:SetID(f:ReadULong())

                    if version <= 8 then
                        area:SetAttributeBitField(f:ReadByte())
                    elseif version <= 12 then
                        area:SetAttributeBitField(f:ReadUShort())
                    else
                        area:SetAttributeBitField(f:ReadULong())
                    end

                    area:SetNorthWestCorner(Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat()))
                    area:SetSouthEastCorner(Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat()))
                    area:SetNorthEastZ(f:ReadFloat())
                    area:SetSouthWestZ(f:ReadFloat())

                    -- Connections -- NESW
                    local conn = {}
                    for i=1, 4 do
                        local t = {}

                        local connCount = f:ReadULong()
                        for i=1, connCount do
                            t[i] = f:ReadULong()
                        end
                        conn[i] = t
                    end
                    area:SetConnections(conn)

                    -- Hiding spots
                    local hidingspotCount = f:ReadByte()
                    local spots = {}
                    for i=1, hidingspotCount do
                        spots[f:ReadULong()] = {
                            position = Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat()),
                            attributes = f:ReadByte()
                        }
                    end
                    area:SetHidingSpots(spots)

                    if version <= 15 then
                        -- Approach spots
                    end

                    -- Encounters
                    local encounterCount = f:ReadULong()
                    local encounters = {}
                    for i=1, encounterCount do
                        local t = {
                            EntryAreaID = f:ReadULong(),
                            EntryDirection = f:ReadByte(),
                            DestAreaID = f:ReadULong(),
                            DestDirection = f:ReadByte()
                        }
                        t.Spots = {}
                        local spotCount = f:ReadByte()
                        for j=1, spotCount do
                            t.Spots[j] = {
                                AreaID = f:ReadULong(),
                                ParametricDistance = f:ReadByte()
                            }
                        end

                        encounters[i] = t
                    end
                    area:SetEncounters(encounters)

                    area:SetPlaceID(f:ReadUShort())
                    
                    -- Ladder connections (version >= 7)
                    if version >= 7 then
                        local ladders = {}
                        for j=1, 2 do
                            local count = f:ReadULong()
                            local t = {}
                            ladders[j] = t
                            
                            for k=1, count do
                                t[k] = f:ReadULong()
                            end
                        end
                        area:SetLadders(ladders)
                    end

                    -- Earliest occupy times (version >= 8)
                    if version >= 8 then
                        local MAX_NAV_TEAMS = 2
                        area.EarliestOccupyTime = {}
                        for j=1, MAX_NAV_TEAMS do
                            area.EarliestOccupyTime[j] = f:ReadFloat()
                        end
                    end

                    -- Light intensity (version >= 11)
                    if version >= 11 then
                        local NUM_CORNERS = 4
                        area.LightIntensity = {}
                        for j=1, NUM_CORNERS do
                            area.LightIntensity[j] = f:ReadFloat()
                        end
                    end

                    -- Visible areas (version >= 16)
                    if version >= 16 then
                        local visibleAreaCount = f:ReadULong()
                        area.VisibleAreas = {}
                        for j=1, visibleAreaCount do
                            area.VisibleAreas[j] = {
                                id = f:ReadULong(),
                                attributes = f:ReadByte()
                            }
                        end

                        -- Inherit visibility from area ID
                        area.InheritVisibilityFrom = f:ReadULong()
                    end
                    
                    navmesh._areas[area:GetID()] = area

                    -- Add to octree
                    local nw = area:GetNorthWestCorner()
                    local se = area:GetSouthEastCorner()
                    
                    -- Insert with proper bounds format
                    navmesh._tree:Insert(area, {min = nw, max = se})

                    if i % BATCH_SIZE == 0 then
                        pause("areas", i / numAreas * 100)
                    end
                end
            end)
            f:Close()

            if not succ then
                error(err)
            end

            assert(navmesh.GetNavAreaCount() == serverAreas, "Nav area count mismatch between client and server")

            print("[NavMesh] Loaded", navmesh.GetNavAreaCount(), "areas")
            print("[NavMesh] Octree contains", navmesh._tree:Count(), "items")
            print("[NavMesh] Octree bounds:", navmesh._tree:GetBounds())

            return true
        end)
    end


    hook.Add("Symphony:Initialize", function (promises, data)

        if navmesh.GetNavAreaCount() > 0 then
            return
        end
        --promises[#promises + 1] = navmesh.Load()
    end)

    local nav_debug = CreateClientConVar("nav_debug", "0", false, false, "Debug draw navigation mesh")
    local nav_debug_dist = CreateClientConVar("nav_debug_dist", "2000", false, false, "Max distance to draw nav areas")

    hook.Add("PostDrawTranslucentRenderables", "NavMesh.Debug", function(bDrawingSkybox, bDrawingDepth)
        if bDrawingSkybox or bDrawingDepth then return end
        if nav_debug:GetInt() == 0 then return end
        
        local areaCount = navmesh.GetNavAreaCount()
        if areaCount == 0 then 
            print("[NavMesh Debug] No areas loaded")
            return 
        end

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local pos = ply:GetEyeTrace().HitPos
        local beneath, normal = navmesh.GetGroundHeight(pos)
        if beneath then 
            -- draw a line from the floor to the normal - maybe 16 up
            local p = Vector(pos)
            p.z = beneath
            render.DrawLine(p, p + normal * 32, Color(0, 255, 0), true)
            
            render.DrawLine(p - Vector(16, 0, 0), p + Vector(16, 0, 0), Color(255, 0, 0), true)
            render.DrawLine(p - Vector(0, 16, 0), p + Vector(0, 16, 0), Color(255, 0, 0), true)

        end

        local eyePos = ply:EyePos()
        local maxDist = nav_debug_dist:GetFloat()
        
        -- Get nearby areas (uses pooled results internally)
        local nearby = navmesh._tree:QueryRadius(eyePos, maxDist)
        if not nearby then 
            print("[NavMesh Debug] QueryRadius returned nil")
            return 
        end
        
        local succ, err = pcall(function()
            cam.Start3D()
            
            local drawn = 0
            for _, area in ipairs(nearby) do
                local center = area:GetCenter()
                local dist = center:Distance(eyePos)
                if dist <= maxDist then
                    drawn = drawn + 1
                    
                    -- Draw area bounds
                    local c0 = area:GetCorner(0)
                    local c1 = area:GetCorner(1)
                    local c2 = area:GetCorner(2)
                    local c3 = area:GetCorner(3)
                    
                    -- Fade alpha based on distance
                    local alpha = math.Clamp(255 * (1 - dist / maxDist), 50, 255)
                    
                    -- Draw outline
                    render.DrawLine(c0, c1, Color(255, 255, 255, alpha))
                    render.DrawLine(c1, c2, Color(255, 255, 255, alpha))
                    render.DrawLine(c2, c3, Color(255, 255, 255, alpha))
                    render.DrawLine(c3, c0, Color(255, 255, 255, alpha))
                end
            end
            
            cam.End3D()
            
            if drawn > 0 then
                draw.SimpleText("Nav areas: " .. drawn, "DermaDefault", 10, 10, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end)
        
        if not succ then
            print("[NavMesh Debug] Error:", err)
        end
    end)

    -- Path testing command
    local pathTestStart = nil
    local pathTestPath = nil
    
    concommand.Add("nav_test_path", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local pos = ply:GetEyeTrace().HitPos
        
        if not pathTestStart then
            pathTestStart = pos
            print("[Nav Path Test] Start position set:", pos)
            print("[Nav Path Test] Run command again to set end position and find path")
        else
            print("[Nav Path Test] Finding path from", pathTestStart, "to", pos)
            
            local startTime = SysTime()
            pathTestPath = navmesh.FindPath(pathTestStart, pos)
            local endTime = SysTime()
            
            if pathTestPath then
                print("[Nav Path Test] Path found with", #pathTestPath, "areas in", math.Round((endTime - startTime) * 1000, 2), "ms")
                
                -- Calculate total distance
                local totalDist = 0
                for i = 1, #pathTestPath - 1 do
                    totalDist = totalDist + pathTestPath[i]:GetCenter():Distance(pathTestPath[i + 1]:GetCenter())
                end
                print("[Nav Path Test] Total path distance:", math.Round(totalDist, 2))
            else
                print("[Nav Path Test] No path found!")
            end
            
            pathTestStart = nil
        end
    end)
    
    concommand.Add("nav_clear_path", function()
        pathTestPath = nil
        pathTestStart = nil
        print("[Nav Path Test] Cleared test path")
    end)
    
    hook.Add("PostDrawTranslucentRenderables", "NavMesh.PathTest", function(bDrawingSkybox, bDrawingDepth)
        if bDrawingSkybox or bDrawingDepth then return end
        
        -- Draw start marker
        if pathTestStart then
            render.DrawWireframeSphere(pathTestStart, 20, 8, 8, Color(0, 255, 0), true)
        end
        
        -- Draw path
        if pathTestPath then
            cam.Start3D()
            
            -- Draw lines between area centers
            for i = 1, #pathTestPath - 1 do
                local from = pathTestPath[i]:GetCenter()
                local to = pathTestPath[i + 1]:GetCenter()
                render.DrawLine(from, to, Color(255, 0, 255), true)
                render.DrawWireframeSphere(from, 10, 6, 6, Color(255, 255, 0), true)
            end
            
            -- Draw final node
            if #pathTestPath > 0 then
                local finalPos = pathTestPath[#pathTestPath]:GetCenter()
                render.DrawWireframeSphere(finalPos, 10, 6, 6, Color(255, 0, 0), true)
            end
            
            cam.End3D()
        end
    end)
    
    concommand.Add("nav_benchmark", function(ply, cmd, args)
        local iterations = tonumber(args[1]) or 1000
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local testPos = ply:GetPos()
        
        print("[Nav Benchmark] Running", iterations, "iterations...")
        print("----------------------------------------")
        
        -- Benchmark util.TraceLine
        local traceStart = SysTime()
        for i = 1, iterations do
            local tr = util.TraceLine({
                start = testPos + Vector(0, 0, 100),
                endpos = testPos - Vector(0, 0, 10000),
                mask = MASK_SOLID
            })
            local _ = tr.HitPos.z
        end
        local traceTime = SysTime() - traceStart
        
        -- Benchmark navmesh.GetGroundHeight
        local navStart = SysTime()
        for i = 1, iterations do
            local height, normal = navmesh.GetGroundHeight(testPos)
        end
        local navTime = SysTime() - navStart
        
        -- Results
        print("[Nav Benchmark] Results:")
        print("  util.TraceLine:          " .. math.Round(traceTime * 1000, 3) .. " ms (" .. math.Round(traceTime / iterations * 1000000, 2) .. " µs per call)")
        print("  navmesh.GetGroundHeight: " .. math.Round(navTime * 1000, 3) .. " ms (" .. math.Round(navTime / iterations * 1000000, 2) .. " µs per call)")
        print("  Speedup: " .. math.Round(traceTime / navTime, 2) .. "x " .. (navTime < traceTime and "FASTER" or "SLOWER"))
        print("----------------------------------------")
    end)
else 
    RPC.Register("navmesh.GetNavAreaCount", function ()
        return navmesh.GetNavAreaCount()
    end)
end