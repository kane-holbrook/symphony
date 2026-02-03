AddCSLuaFile()

local TREE = Type.Register("OctTree")
TREE:CreateProperty("Bounds", Type.Table) -- { min = Vector, max = Vector }
TREE:CreateProperty("Depth", Type.Number, { Default = 0 })
TREE:CreateProperty("MaxDepth", Type.Number, { Default = 8 })
TREE:CreateProperty("MaxItems", Type.Number, { Default = 8 })
TREE:CreateProperty("Items", Type.Table, { Default = function() return {} end })
TREE:CreateProperty("Children", Type.Table) -- Array of 8 child OctTrees (or nil if not subdivided)
TREE:CreateProperty("Subdivided", Type.Boolean, { Default = false })

-- Result table pool to avoid GC
local resultPool = {}
local function GetPooledResults()
	local results = table.remove(resultPool)
	if results then
		table.Empty(results)
		return results
	end
	return {}
end

local function ReturnPooledResults(results)
	if #resultPool < 100 then -- Limit pool size
		table.insert(resultPool, results)
	end
end

function TREE.Prototype:Initialize()
	base(self, "Initialize")
end

-- Helper function to normalize bounds (handle both Vector and {min,max} format)
function TREE.Prototype:NormalizeBounds(bounds)
	if not bounds then return nil end
	
	-- If it's a Vector, convert to bounds format
	if bounds.x and bounds.y and bounds.z then
		return { min = bounds, max = bounds }
	end
	
	-- Already in bounds format
	if bounds.min and bounds.max then
		return bounds
	end
	
	return nil
end

-- Helper function to check if a point is within bounds
function TREE.Prototype:ContainsPoint(point)
	local bounds = self:GetBounds()
	if not bounds or not bounds.min or not bounds.max then
		return false
	end
	
	return point.x >= bounds.min.x and point.x <= bounds.max.x and
	       point.y >= bounds.min.y and point.y <= bounds.max.y and
	       point.z >= bounds.min.z and point.z <= bounds.max.z
end

-- Helper function to check if two bounding boxes intersect
function TREE.Prototype:BoundsIntersect(bounds1, bounds2)
	if not bounds1 or not bounds2 then return false end
	if not bounds1.min or not bounds1.max or not bounds2.min or not bounds2.max then return false end
	
	return bounds1.min.x <= bounds2.max.x and bounds1.max.x >= bounds2.min.x and
	       bounds1.min.y <= bounds2.max.y and bounds1.max.y >= bounds2.min.y and
	       bounds1.min.z <= bounds2.max.z and bounds1.max.z >= bounds2.min.z
end

-- Helper function to check if bounds are fully contained within another
function TREE.Prototype:BoundsContains(containerBounds, testBounds)
	if not containerBounds or not testBounds then return false end
	if not containerBounds.min or not containerBounds.max or not testBounds.min or not testBounds.max then return false end
	
	return testBounds.min.x >= containerBounds.min.x and testBounds.max.x <= containerBounds.max.x and
	       testBounds.min.y >= containerBounds.min.y and testBounds.max.y <= containerBounds.max.y and
	       testBounds.min.z >= containerBounds.min.z and testBounds.max.z <= containerBounds.max.z
end

-- Subdivide this node into 8 children
function TREE.Prototype:Subdivide()
	if self:GetSubdivided() then
		return
	end
	
	local bounds = self:GetBounds()
	if not bounds or not bounds.min or not bounds.max then
		return
	end
	
	local min = bounds.min
	local max = bounds.max
	local center = (min + max) / 2
	local depth = self:GetDepth()
	local maxDepth = self:GetMaxDepth()
	local maxItems = self:GetMaxItems()
	
	local children = {}
	
	-- Create 8 octants
	-- Bottom octants (z: min to center)
	children[1] = new("OctTree") -- Bottom-Front-Left
	children[1]:SetBounds({ min = Vector(min.x, min.y, min.z), max = Vector(center.x, center.y, center.z) })
	children[1]:SetDepth(depth + 1)
	children[1]:SetMaxDepth(maxDepth)
	children[1]:SetMaxItems(maxItems)
	
	children[2] = new("OctTree") -- Bottom-Front-Right
	children[2]:SetBounds({ min = Vector(center.x, min.y, min.z), max = Vector(max.x, center.y, center.z) })
	children[2]:SetDepth(depth + 1)
	children[2]:SetMaxDepth(maxDepth)
	children[2]:SetMaxItems(maxItems)
	
	children[3] = new("OctTree") -- Bottom-Back-Left
	children[3]:SetBounds({ min = Vector(min.x, center.y, min.z), max = Vector(center.x, max.y, center.z) })
	children[3]:SetDepth(depth + 1)
	children[3]:SetMaxDepth(maxDepth)
	children[3]:SetMaxItems(maxItems)
	
	children[4] = new("OctTree") -- Bottom-Back-Right
	children[4]:SetBounds({ min = Vector(center.x, center.y, min.z), max = Vector(max.x, max.y, center.z) })
	children[4]:SetDepth(depth + 1)
	children[4]:SetMaxDepth(maxDepth)
	children[4]:SetMaxItems(maxItems)
	
	-- Top octants (z: center to max)
	children[5] = new("OctTree") -- Top-Front-Left
	children[5]:SetBounds({ min = Vector(min.x, min.y, center.z), max = Vector(center.x, center.y, max.z) })
	children[5]:SetDepth(depth + 1)
	children[5]:SetMaxDepth(maxDepth)
	children[5]:SetMaxItems(maxItems)
	
	children[6] = new("OctTree") -- Top-Front-Right
	children[6]:SetBounds({ min = Vector(center.x, min.y, center.z), max = Vector(max.x, center.y, max.z) })
	children[6]:SetDepth(depth + 1)
	children[6]:SetMaxDepth(maxDepth)
	children[6]:SetMaxItems(maxItems)
	
	children[7] = new("OctTree") -- Top-Back-Left
	children[7]:SetBounds({ min = Vector(min.x, center.y, center.z), max = Vector(center.x, max.y, max.z) })
	children[7]:SetDepth(depth + 1)
	children[7]:SetMaxDepth(maxDepth)
	children[7]:SetMaxItems(maxItems)
	
	children[8] = new("OctTree") -- Top-Back-Right
	children[8]:SetBounds({ min = Vector(center.x, center.y, center.z), max = Vector(max.x, max.y, max.z) })
	children[8]:SetDepth(depth + 1)
	children[8]:SetMaxDepth(maxDepth)
	children[8]:SetMaxItems(maxItems)
	
	self:SetChildren(children)
	self:SetSubdivided(true)
	
	-- Redistribute existing items to children
	local items = self:GetItems()
	for i, itemData in ipairs(items) do
		for j, child in ipairs(children) do
			if child:BoundsIntersect(child:GetBounds(), itemData.bounds) then
				child:Insert(itemData.item, itemData.bounds)
			end
		end
	end
	
	-- Clear items from this node as they're now in children
	self:SetItems({})
end

-- Insert an item with its bounding box
function TREE.Prototype:Insert(item, itemBounds)
	itemBounds = self:NormalizeBounds(itemBounds)
	if not itemBounds then
		error("OctTree:Insert requires itemBounds (Vector or {min=Vector, max=Vector})")
		return false
	end
	
	-- Check if item bounds intersect with this node's bounds
	if not self:BoundsIntersect(self:GetBounds(), itemBounds) then
		return false
	end
	
	-- If we're subdivided, try to insert into children
	if self:GetSubdivided() then
		local inserted = false
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			if child:Insert(item, itemBounds) then
				inserted = true
			end
		end
		return inserted
	end
	
	-- Add to this node
	local items = self:GetItems()
	table.insert(items, { item = item, bounds = itemBounds })
	
	-- Check if we need to subdivide
	if #items > self:GetMaxItems() and self:GetDepth() < self:GetMaxDepth() then
		self:Subdivide()
	end
	
	return true
end

-- Query for items within a bounding box
function TREE.Prototype:Query(queryBounds, results, usePool)
	if usePool == nil then usePool = true end
	results = results or (usePool and GetPooledResults() or {})
	
	queryBounds = self:NormalizeBounds(queryBounds)
	if not queryBounds then
		return results
	end
	
	-- Check if query bounds intersect with this node
	if not self:BoundsIntersect(self:GetBounds(), queryBounds) then
		return results
	end
	
	-- If subdivided, query children
	if self:GetSubdivided() then
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			child:Query(queryBounds, results, false) -- Don't pool nested calls
		end
	else
		-- Add items from this node that intersect with query
		local items = self:GetItems()
		for i, itemData in ipairs(items) do
			if self:BoundsIntersect(queryBounds, itemData.bounds) then
				table.insert(results, itemData.item)
			end
		end
	end
	
	return results
end

-- Query for items at a specific point
function TREE.Prototype:QueryPoint(point, results)
	results = results or {}
	
	if not self:ContainsPoint(point) then
		return results
	end
	
	-- If subdivided, query children
	if self:GetSubdivided() then
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			child:QueryPoint(point, results)
		end
	else
		-- Check items in this node
		local items = self:GetItems()
		for i, itemData in ipairs(items) do
			local bounds = itemData.bounds
			if point.x >= bounds.min.x and point.x <= bounds.max.x and
			   point.y >= bounds.min.y and point.y <= bounds.max.y and
			   point.z >= bounds.min.z and point.z <= bounds.max.z then
				table.insert(results, itemData.item)
			end
		end
	end
	
	return results
end

-- Move an item from old bounds to new bounds
function TREE.Prototype:Move(item, oldBounds, newBounds)
	oldBounds = self:NormalizeBounds(oldBounds)
	newBounds = self:NormalizeBounds(newBounds)
	
	if not oldBounds or not newBounds then
		error("OctTree:Move requires both oldBounds and newBounds (Vector or {min=Vector, max=Vector})")
		return false
	end
	
	-- Remove from old position
	local removed = self:Remove(item, oldBounds)
	if not removed then
		return false
	end
	
	-- Insert at new position
	return self:Insert(item, newBounds)
end

-- Remove an item from the tree
function TREE.Prototype:Remove(item, itemBounds)
	if not itemBounds then
		-- If no bounds provided, we need to search the entire tree
		return self:RemoveSlow(item)
	end
	
	itemBounds = self:NormalizeBounds(itemBounds)
	
	-- Check if item bounds intersect with this node's bounds
	if not self:BoundsIntersect(self:GetBounds(), itemBounds) then
		return false
	end
	
	-- If subdivided, try to remove from children
	if self:GetSubdivided() then
		local removed = false
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			if child:Remove(item, itemBounds) then
				removed = true
			end
		end
		return removed
	end
	
	-- Try to remove from this node
	local items = self:GetItems()
	for i = #items, 1, -1 do
		if items[i].item == item then
			table.remove(items, i)
			return true
		end
	end
	
	return false
end

-- Slow removal without bounds (searches entire tree)
function TREE.Prototype:RemoveSlow(item)
	if self:GetSubdivided() then
		local removed = false
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			if child:RemoveSlow(item) then
				removed = true
			end
		end
		return removed
	end
	
	local items = self:GetItems()
	for i = #items, 1, -1 do
		if items[i].item == item then
			table.remove(items, i)
			return true
		end
	end
	
	return false
end

-- Clear all items from the tree
function TREE.Prototype:Clear()
	self:SetItems({})
	self:SetChildren(nil)
	self:SetSubdivided(false)
end

-- Get total count of items in tree
function TREE.Prototype:Count()
	local count = 0
	
	if self:GetSubdivided() then
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			count = count + child:Count()
		end
	else
		count = #self:GetItems()
	end
	
	return count
end

-- Get all items in the tree
function TREE.Prototype:GetAllItems()
	local results = {}
	
	if self:GetSubdivided() then
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			local childItems = child:GetAllItems()
			for j, item in ipairs(childItems) do
				table.insert(results, item)
			end
		end
	else
		local items = self:GetItems()
		for i, itemData in ipairs(items) do
			table.insert(results, itemData.item)
		end
	end
	
	return results
end

-- Query items within a radius (sphere) from a center point
function TREE.Prototype:QueryRadius(center, radius, results, usePool)
	if usePool == nil then usePool = true end
	results = results or (usePool and GetPooledResults() or {})
	
	-- Create bounding box for the sphere
	local searchBounds = {
		min = center - Vector(radius, radius, radius),
		max = center + Vector(radius, radius, radius)
	}
	
	-- First get all items in the bounding box
	local candidates = self:Query(searchBounds, {}, false)
	
	-- Filter by actual spherical distance
	local radiusSqr = radius * radius
	for i, item in ipairs(candidates) do
		-- Find the item's position (center of bounds)
		local itemPos = item
		if item.IsValid and not item:IsValid() then
			continue
		end
		
		if item.GetCenter then
			itemPos = item:GetCenter()
		elseif item.GetPos then
			itemPos = item:GetPos()
		elseif istable(item) and item.pos then
			itemPos = item.pos
		end
		
		if isvector(itemPos) then
			local distSqr = center:DistToSqr(itemPos)
			if distSqr <= radiusSqr then
				table.insert(results, item)
			end
		end
	end
	
	return results
end

-- Helper: Check if a point is inside a cone
local function PointInCone(point, origin, direction, angle, distance)
	local toPoint = point - origin
	local dist = toPoint:Length()
	
	if dist > distance then
		return false
	end
	
	if dist == 0 then
		return true
	end
	
	local cosAngle = math.cos(math.rad(angle))
	local dot = toPoint:Dot(direction) / dist
	
	return dot >= cosAngle
end

-- Query items within a cone/frustum
function TREE.Prototype:QueryCone(origin, direction, angle, distance, results)
	results = results or {}
	
	direction = direction:GetNormalized()
	
	-- Create bounding box for the cone
	local searchBounds = {
		min = origin - Vector(distance, distance, distance),
		max = origin + Vector(distance, distance, distance)
	}
	
	-- Get all items in the bounding box
	local candidates = self:Query(searchBounds, {})
	
	-- Filter by cone test
	for i, item in ipairs(candidates) do
		if item.IsValid and not item:IsValid() then
			continue
		end
		
		local itemPos = item
		if item.GetCenter then
			itemPos = item:GetCenter()
		elseif item.GetPos then
			itemPos = item:GetPos()
		elseif istable(item) and item.pos then
			itemPos = item.pos
		end
		
		if isvector(itemPos) then
			if PointInCone(itemPos, origin, direction, angle, distance) then
				table.insert(results, item)
			end
		end
	end
	
	return results
end

-- Helper: Ray-AABB intersection test
local function RayAABBIntersect(rayOrigin, rayDir, boxMin, boxMax)
	local tmin = (boxMin - rayOrigin) / rayDir
	local tmax = (boxMax - rayOrigin) / rayDir
	
	-- Swap if needed
	local t1 = Vector(math.min(tmin.x, tmax.x), math.min(tmin.y, tmax.y), math.min(tmin.z, tmax.z))
	local t2 = Vector(math.max(tmin.x, tmax.x), math.max(tmin.y, tmax.y), math.max(tmin.z, tmax.z))
	
	local tNear = math.max(t1.x, t1.y, t1.z)
	local tFar = math.min(t2.x, t2.y, t2.z)
	
	return tNear <= tFar and tFar >= 0
end

-- Query items along a line/ray
function TREE.Prototype:QueryLine(startPos, endPos, results)
	results = results or {}
	
	local rayDir = endPos - startPos
	local rayLength = rayDir:Length()
	rayDir = rayDir / rayLength
	
	-- Create bounding box for the line
	local searchBounds = {
		min = Vector(
			math.min(startPos.x, endPos.x),
			math.min(startPos.y, endPos.y),
			math.min(startPos.z, endPos.z)
		),
		max = Vector(
			math.max(startPos.x, endPos.x),
			math.max(startPos.y, endPos.y),
			math.max(startPos.z, endPos.z)
		)
	}
	
	-- Check if this node's bounds intersect with search bounds
	if not self:BoundsIntersect(self:GetBounds(), searchBounds) then
		return results
	end
	
	-- If subdivided, query children
	if self:GetSubdivided() then
		local children = self:GetChildren()
		for i, child in ipairs(children) do
			child:QueryLine(startPos, endPos, results)
		end
	else
		-- Check items in this node
		local items = self:GetItems()
		for i, itemData in ipairs(items) do
			local bounds = itemData.bounds
			
			-- Test if ray intersects item bounds
			if RayAABBIntersect(startPos, rayDir, bounds.min, bounds.max) then
				table.insert(results, itemData.item)
			end
		end
	end
	
	return results
end