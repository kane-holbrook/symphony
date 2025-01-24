AddCSLuaFile()

__SYM = {}
__SYM.types = __SYM.types or {}
sym.types = __SYM.types

sym.NetworkedObjects = {}
sym.NetworkedObjectsByType = {}
NetObj = __SYM.NetworkedObjects

local TypesById = {}

local TYPE = {}
local PROPERTY = {}

TRANSMIT_PAS = 4
TRANSMIT_WHITELIST = 5
TRANSMIT_ADMIN = 6
TRANSMIT_ENTITY = 7
TRANSMIT_WITHPARENT = 8
TRANSMIT_CUSTOM = 9

local TYPE_START = 256
TYPE_SYMTYPE = 256

-- Statics
do
	-- @tested 25/07/2024
	function sym.RegisterType(name, super, ...)
		super = super or TYPE
		assert(name, "Must provide a symtype name.")
		assert(sym.IsType(super) and not super:IsInstance(), "Super must be a Type")
		
		local t = sym.types[name] or {}
		table.Empty(t)
		
		t.__type = name
		t.__super = super
		t.__typeId = TYPE_START + util.CRC(name) -- I think this should be safe for <1000 values
		t.__index = super.__index
		t.__properties = {}
		if super then
			for k, v in pairs(super.__properties) do
				t.__properties[k] = v
			end
		end

		t.__newindex = super.__newindex
		t.__mode = super.__mode
		t.__add = super.__add
		t.__sub = super.__sub
		t.__mul = super.__mul
		t.__div = super.__div
		t.__unm = super.__unm
		t.__mod = super.__mod
		t.__pow = super.__pow
		t.__eq = super.__eq
		t.__lt = super.__lt
		t.__le = super.__le
		t.__concat = super.__concat
		t.__gc = super.__gc
		t.__len = super.__len
		t.__call = super.__call
		t.__new = super.__new

		if super and super.__derive then
			super:__derive(t, ...)
		end

		setmetatable(t, t)
		sym.types[name] = t
		TypesById[t.__typeId] = t

		local collisionCheck = TypesById[t.__typeId]
		if collisionCheck and collisionCheck.__type ~= name then
			error("CRC32 collision on type index generation!")
		end

		if sym.event then
			t.OnNetCreated = sym.event()
			t.OnNetUpdated = sym.event()
		end

		return t
	end

	function sym.GetNetworkedObject(uuid)
		return sym.NetworkedObjects[uuid]
	end

	function sym.GetNetworkedObjects(type)
		return sym.NetworkedObjectsByType[type]
	end


	-- @tested 25/07/2024
	function sym.CreateUninitializedInstance(symtype, id)
		assert(sym.IsType(symtype), "Must provide a symtype (not `" .. type(symtype) .. "`)")

		if symtype:IsInstance() then
			debug.Trace()
			error("symtype must be a Type, not an instance. (" .. symtype:GetTypeName() .. ")")
		end
		
		local t = setmetatable({}, symtype)

		-- Checked my maths on this. If we instantiated 100k instances per second, which'd 
		-- probably kill the server anyway, it'd take ~2800 years to overflow. 
		t.__id = id or uuid()

		t.__super = symtype
		t.__lasttransmit = weaktable(true, false)

		if symtype ~= sym.types.event then
			-- This will exist before events are defined, so we construct it manually.
			t.OnPropChanged = sym.event()
			t.OnNetUpdated = sym.event()
		end
		
		for k, v in pairs(symtype.__properties) do
			local name = v:GetName()
			local opt = v:GetOptions()

			local p = setmetatable({}, { __index = v })
			p.value = sym.proxy()
			p.lastmodify = CurTime()
			p.lasttransmit = weaktable(true, false)
			p.parent = t

			if opt.Default then
				if istable(opt.Default) then
					p.value:Set(table.Copy(opt.Default))
				elseif isfunction(opt.Default) then
					p.value:Set(opt.Default(self))
				else
					p.value:Set(opt.Default)
				end
			end

			if symtype ~= sym.types.event then
				p.value.OnSet:Hook(nil, function (ev, ...)
					t.OnPropChanged:Invoke(t, name, ...)
				end)
			end

			t[name] = p
		end


		return t
	end


	-- @tested 25/07/2024
	function sym.CreateInstance(symtype, ...)
		local t = sym.CreateUninitializedInstance(symtype)

		if symtype.Init then
			t = symtype:Init(t, ...)
		end

		return t
	end


	-- @tested 25/07/2024 on both server and client
	function sym.GetTypeById(typeid)
		return TypesById[typeid]
	end


	-- @tested 25/07/2024
	function sym.IsType(obj, type, bNoRecurse)

		if not istable(obj) or not obj.GetType then
			return false
		elseif not type then
			return true
		end

		local objType = obj:GetType()
		if objType == type then 
			return true 
		end

		if not bNoRecurse and objType.__super then
			local super = objType
			repeat
				if super == type then
					return true
				end
				super = super.__super
			until not super
		end

		return false
	end

	-- @tested 25/07/2024
	function sym.GetTypeId(obj)
		local typ = TypeID(obj)
		if typ == TYPE_TABLE and obj.__typeId then
			return obj.__typeId
		else
			return typ
		end
	end



	function sym.DeregisterType(type)
		sym.types[type.__type] = nil
		TypesById[type.__typeId] = nil
	end
end

-- Type
do
	TYPE.__type = "Type"
	TYPE.__typeId = TYPE_START
	TYPE.__properties = {}
	TYPE.__dbtype = "JSON" -- Assume everything is a table by default.
	TYPE.__transmit = TRANSMIT_WITHPARENT

	TypesById[TYPE.__typeId] = TYPE
	sym.types.type = TYPE
	setmetatable(TYPE, TYPE)

	-- @tested 25/07/2024
	TYPE.__call = sym.CreateInstance

	function TYPE:__derive(t, ...)
	end

	function TYPE:__index(k)
		-- Do we exist on the current type?
		local r = rawget(self, k)
		if r then return r end


		local mt = getmetatable(self)
		r = rawget(mt, k)

		if r then return r end

		local super = rawget(mt, "__super")

		if super then
			--r = super[k] -- somehow this is about 3500x faster than just a return???
			return super[k]
		end

		return nil
		--return r
	end

	function TYPE:Clone()
		assert(self:IsInstance(), "You can can only clone instances, not types.")
		return setmetatable(table.Copy(self), getmetatable(self))
	end

	function TYPE:GetObjectId()
		return self.__id
	end

	function TYPE:SetObjectId(value)
		assert(value, "Must provide a value.")

		local old = self:GetObjectId()
		if sym.NetworkedObjects[old] then
			local typ = self:GetType()
			sym.NetworkedObjects[old] = nil
			sym.NetworkedObjectsByType[typ][old] = nil
			sym.NetworkedObjects[value] = self
			sym.NetworkedObjectsByType[typ][value] = self
		end

		self.__id = value
	end

	-- @tested 25/07/2024
	function TYPE:GetType()
		return self.__super
	end 

	function TYPE:GetTypeId()
		return self.__typeId
	end

	function TYPE:GetTypeName()
		return self.__type
	end

	function TYPE:IsInstance()
		return self:GetObjectId() ~= nil
	end

	function TYPE:FromString()
		error("FromString not implemented on " .. self:GetTypeName())
	end

	function TYPE:GetParameterWrapper(panel, param, text, active)
		local data = param:GetData()

		text = text or ""
		text = stringex.EscapeHTML(text)

		if data.Mentions then
			panel:HandleMentionUI(text, { Index = param:GetIndex() })
		end

		if data.Emotes then
			panel:HandleEmoteUI(text, { Index = param:GetIndex() })
		end

		if data.Mentions then
			text = sym.ParseMentions(text)
		end

		if data.Emotes then
			text = sym.ParseEmotes(LocalPlayer(), text, true)
		end

		if data.Markdown then
			text = sym.ParseMarkdown(text, true)
		end

		return "<span class='parameter " .. (active and "active" or "") .. "'><span class='parameter-hint'>" .. stringex.EscapeHTML(param:GetName() or "") .. ":</span><span class='parameter-content'>" .. text .. "</span></span>"
	end
	
	function TYPE:ParameterStartEntry(p, text)
	end

	function TYPE:ParameterUpdateEntry(p, text)
	end

	function TYPE:ParameterFinishEntry(p, text)
	end

	function TYPE:__tostring()
		local super = self.__super
		if self == TYPE then
			return "Type"
		elseif super == TYPE then
			return "Type[" .. stringex.TitleCase(self.__type) .. "]"
		else
			return stringex.TitleCase(self.__type)
		end
	end

	-- Properties
	do
		function TYPE:AddProperty(name, type, options)
			assert(not self:IsInstance(), "Properties should only be added to types, not instances.")
			--assert(sym.IsType(type), "Properties must have a type")

			for k, v in pairs(self.__properties) do
				if v:GetName() == name then
					error(name .. " has already been added to this object.")
				end
			end

			options = options or {}
			local prop = sym.CreateInstance(PROPERTY, self, name, type, options)
			prop.index = table.Count(self.__properties)

			if not options.NoAccessors then
				if not options.NoSetter then
					self["Set" .. name] = function (x, ...) x:SetProperty(name, ...) return x end
				end
				
				if not options.NoGetter then
					self["Get" .. name] = function (x, ...) return x:GetProperty(name, ...) end
				end
			end

			self.__properties[name] = prop
		end

		function TYPE:GetPropertyMetadata()
			return self.__properties
		end

		function TYPE:GetProperties()
			local out = {}
			for k, v in pairs(self:GetPropertyMetadata()) do
				out[k] = self:GetProperty(k)
			end
			return out
		end

		function TYPE:GetPropertyObjects()
			local out = {}
			for k, v in pairs(self:GetPropertyMetadata()) do
				out[k] = self:GetPropertyObject(k)
			end
			return out
		end

		function TYPE:SetProperty(name, value)
			assert(self:IsInstance(), "Properties should only be set on instances, not types.")
			
			local prop = self[name]
			assert(prop, "Non-existent property: " .. name)

			self[name].value:Set(value)
		end

		function TYPE:GetProperty(name)
			assert(self:IsInstance(), "Properties should only be get on instances, not types.")

			local prop = self[name]
			assert(prop and prop.GetPropertyType, "Non-existent property: " .. name)
			

			return self[name].value:Get()
		end

		function TYPE:GetPropertyObject(name)
			assert(self:IsInstance(), "Properties should only be get on instances, not types.")

			local prop = self[name]
			assert(prop and prop.GetPropertyType, "Non-existent property: " .. name)

			return self[name]
		end
	end

	-- Database
	do
		function TYPE:SetDatabaseTable(name, idField, cache)
			assert(not self:IsInstance(), "Database table can only be set on the types, not instances.")
			
			assert(isstring(name), "Must provide a table name")
			assert(isstring(idField), "Must provide an ID field (the name of a property specifically).")
			assert(not cache or isbool(cache) or istable(cache), "`cache` parameter must be an existing table, a bool, or nil.")

			if not SERVER then
				return
			end

			self.__dbTable = name
			self.__dbId = idField

			if cache then
				self.__dbCache = istable(cache) and cache or sym.weaktable("v")	
			end
		end

		function TYPE:GetDatabaseTable()
			return self.__dbTable
		end

		function TYPE:GetDatabaseKey()
			return self.__dbId
		end

		function TYPE:GetDatabaseId()
			assert(self:IsInstance(), "Can only call GetDatabaseId on an instance.")
			return self:GetProperty(self:GetDatabaseKey())
		end

		function TYPE:GetDatabaseCache()
			return self.__dbCache
		end

		function TYPE:DbWrite(wv)
			assert(not self:IsInstance(), "Can only call DbWrite on an type.")
			
			if not wv then
				return nil
			end

			return "\"" .. sym.db.escape(util.TableToJSON(wv:GetProperties())) .. "\""
		end

		function TYPE:CreateDatabaseTable(tables)
			assert(not self:IsInstance(), "CreateDatabaseTable can only be invoked from a type.")

			local name = self:GetDatabaseTable()
			if not name then
				return
			end
			local key = string.lower(self:GetDatabaseKey())

			local qry
			local fieldSQL = {}
			if not tables[name] then
				local sorted = table.ClearKeys(self:GetPropertyMetadata())
				table.SortByMember(sorted, "index", true)

				for k, f in pairs(sorted) do
					local opt = f:GetOptions()
					if opt.Transient then
						continue
					end

					local i = {}
					local fname = f:GetName()
					i[1] = "`" .. hndl:escape(fname) .. "`"
					i[2] = hndl:escape(f:GetPropertyType().__dbtype)

					if opt.not_null then
						table.insert(i, "NOT NULL")
					end

					if opt.auto_increment then
						table.insert(i, "AUTO_INCREMENT")
					end

					if string.lower(fname) == key then
						table.insert(i, "PRIMARY KEY")
					end

					if opt.field_options then
						table.insert(i, opt.field_options)
					end

					table.insert(fieldSQL, table.concat(i, " "))
				end

				qry = "CREATE TABLE `" .. hndl:escape(name) .. "` (\n\t" .. table.concat(fieldSQL, ",\n\t") .. "\n)"
				sym.debug("CREATE_TABLE", "Creating MySQL table for type ", FromPrimitive(stringex.TitleCase(self:GetTypeName())), color_white, ":\n", FromPrimitive(qry))

				local p = sym.db.Query(qry)
				p.query:wait()
			else
				for k, f in pairs(self:GetPropertyMetadata()) do
					local opt = f:GetOptions()
					if opt.Transient then
						continue
					end

					local i = {}
					local fname = f:GetName()
					i[1] = "`" .. hndl:escape(fname) .. "`"
					i[2] = hndl:escape(f:GetPropertyType().__dbtype)

					if opt.not_null then
						table.insert(i, "NOT NULL")
					end

					if string.lower(fname) == key then
						table.insert(i, "PRIMARY KEY")
					end

					if opt.field_options then
						table.insert(i, opt.field_options)
					end
					
					table.insert(fieldSQL, "ADD COLUMN IF NOT EXISTS (" .. table.concat(i, " ") .. ")")

				end
				
				qry = "ALTER TABLE `" .. hndl:escape(name) .. "` \n\t" .. table.concat(fieldSQL, ",\n\t")
				sym.debug("ALTER_TABLE", "Adjusting MySQL table for type ", FromPrimitive(stringex.TitleCase(self:GetTypeName())))

				local p = sym.db.Query(qry)
				p.query:wait()
			end
		end

		function TYPE:Query()
			assert(not self:IsInstance(), "CreateDatabaseTable can only be invoked from a type.")
			return sym.types.dbselect(self)
		end

		local function WriteDatabaseId(id)
			if sym.IsType(id) then
				return id:DbWrite()
			elseif isstring(id) then
				return "\"" .. id .. "\""
			else
				return id
			end
		end

		function TYPE:DbRefresh()
			assert(self:IsInstance(), "Can only call DbRefresh on an instance.")

			local q = self:GetType():Query()
			q:where(self:GetDatabaseKey(), self:GetDatabaseId())
			
			local data = q:ExecuteAsync():Await()
			for k, _ in pairs(self:GetPropertyMetadata()) do
				self:SetProperty(k, data[k])
			end
			self.__dbinserted = true

			return data
		end

		function TYPE:IsInserted()
			assert(self:IsInstance(), "Can only call IsInserted on an instance.")
			return self.__dbinserted
		end

		function TYPE:DbInsert()

			assert(self:IsInstance(), "Can only call DbInsert on an instance.")
			assert(self:GetDatabaseTable(), "This type doesn't have an associated database table set via TYPE:SetDatabaseTable()")
			assert(not self:IsInserted(), "This instance has already been inserted")


			local props = self:GetPropertyMetadata()
			local key_name = self:GetDatabaseKey()
			local key = props[key_name]
			local key_data = self:GetProperty(key_name)
			local opt = key:GetOptions()
			assert(opt.auto_increment or key_data, "Primary key must have a value.")

			self.__dbinserted = true

			local keys = {}
			local values = {}
			for k, v in pairs(props) do
				
				if v:GetOptions().Transient then
					continue
				end

				local typ = v:GetPropertyType()
				local wv = self:GetProperty(v:GetName())
				wv = typ:DbWrite(wv)

				if not wv then
					wv = "NULL"
				end

				table.insert(keys, "`" .. k .. "`")
				table.insert(values, wv)
			end

			local qry = "INSERT INTO `" .. self:GetDatabaseTable() .. "` (" .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")" .. ";"
			sym.debug("DB_INSERT")
			
			local p = sym.db.Query(qry)
			local p2 = sym.promise(function ()
				local data = p:Await()

				if opt.auto_increment then
					self:SetProperty(key_name, p.query:lastInsert())
				end

				return true
			end)
			p2()
			p2.query = p.query
			return p2
		end

		function TYPE:DbUpdate()
			
			assert(self:IsInstance(), "Can only call DbUpdate on an instance.")
			assert(self:GetDatabaseTable(), "This type doesn't have an associated database table set via TYPE:SetDatabaseTable()")
			assert(self:IsInserted(), "This instance hasn't been inserted")


			local props = self:GetPropertyMetadata()
			local key_name = self:GetDatabaseKey()
			local key = props[key_name]
			local key_data = self:GetProperty(key_name)
			local opt = key:GetOptions()
			assert(opt.auto_increment or key_data, "Primary key must have a value.")

			self.__dbinserted = true

			local values = {}
			for k, v in pairs(props) do
				
				if v:GetOptions().Transient then
					continue
				end
				
				local typ = v:GetPropertyType()
				local wv = self:GetProperty(v:GetName())
				wv = typ:DbWrite(wv)

				if not wv then
					wv = "NULL"
				end

				table.insert(values, "`" .. k .. "` = " .. wv)
			end

			local qry = "UPDATE `" .. self:GetDatabaseTable() .. "` SET " .. table.concat(values, ", ") .. " WHERE `" .. self:GetDatabaseKey() .. "` = " .. WriteDatabaseId(self:GetDatabaseId()) .. ";"
			sym.debug("DB_UPDATE")
			
			local p = sym.db.Query(qry)
			return p
		end

		function TYPE:DbRemove()
			assert(self:IsInstance(), "Can only call DbUpdate on an instance.")
			assert(self:GetDatabaseTable(), "This type doesn't have an associated database table set via TYPE:SetDatabaseTable()")

			self.__dbinserted = false
			return sym.db.Query("DELETE FROM `" .. self:GetDatabaseTable() .. "` WHERE `" .. self:GetDatabaseKey() .. "` = " .. WriteDatabaseId(self:GetDatabaseId()) .. ";")
		end
	end

	-- Networking
	do
		function TYPE:SetTransmit(value, b)		
			assert(not (value == TRANSMIT_WITHPARENT and self:IsInstance()), "TRANSMIT_WITHPARENT can only be set on instances")
			assert(not ((value == TRANSMIT_PVS or value == TRANSMIT_PAS) and not self.GetPos), "TRANSMIT_PVS and TRANSMIT_PAS only valid if the Type has a GetPos function.")

			self.__transmit = value
			if value == TRANSMIT_WHITELIST then
				self.__whitelist = weaktable(true, false)
			elseif value == TRANSMIT_WITHPARENT then
				self.__parent = b

				b.__children = b.__children or {}  
				b.__children[self] = true 
			end
		end

		function TYPE:AddWhitelist(ply)
			assert(self:IsInstance(), "Only can be called on instances")
			assert(self:GetTransmitMode() == TRANSMIT_WHITELIST, "Can only call NetAddPlayer on an object with transmit mode TRANSMIT_WHITELIST")

			self.__whitelist[ply] = true
		end

		function TYPE:RemoveWhitelist(ply)
			assert(self:IsInstance(), "Only can be called on instances")
			assert(self:GetTransmitMode() == TRANSMIT_WHITELIST, "Can only call NetAddPlayer on an object with transmit mode TRANSMIT_WHITELIST")

			self.__whitelist[ply] = nil
		end

		function TYPE:ClearWhitelist(ply)
			assert(self:IsInstance(), "Only can be called on instances")
			assert(self:GetTransmitMode() == TRANSMIT_WHITELIST, "Can only call NetAddPlayer on an object with transmit mode TRANSMIT_WHITELIST")

			table.Empty(self.__whitelist)
		end

		function TYPE:GetTransmit()
			return self.__transmit, self.__parent
		end

		function TYPE:GetTransmitMode()
			return self.__transmit
		end

		function TYPE:GetTransmitParent()
			return self.__parent
		end

		function TYPE:GetTransmittedPlayers()
			assert(self:IsInstance(), "Only can be called on instances")
			return self.__lasttransmit
		end
				
		function TYPE:ShouldTransmit(ply)
			local mode, parent = self:GetTransmit()
			if mode == TRANSMIT_ALWAYS then
				return true
			end

			if mode == TRANSMIT_WHITELIST then
				return self.__whitelist[ply] == true
			end

			if mode == TRANSMIT_ADMIN then
				return self:IsAdmin()
			end

			if mode == TRANSMIT_PVS then
				return NikNaks.PVS.IsPositionVisible(ply:GetPos(), self:GetPos())
			end

			if mode == TRANSMIT_PAS then
				return NikNaks.PAS.IsPositionVisible(ply:GetPos(), self:GetPos())
			end

			if isfunction(mode) then
				return mode(self, ply)
			end

			return false
		end

		function TYPE:ShouldTransmitProperty(ply, prop, fullUpdate)
			local opt = prop:GetOptions()
			local mode = opt.Transmit or TRANSMIT_WITHPARENT

			if not fullUpdate then
				local lasttransmit = prop.lasttransmit[ply]
				if lasttransmit and lasttransmit < prop.lastmodify then
					return false
				end
				prop.lasttransmit[ply] = CurTime()
			end
			
			if isany(mode, TRANSMIT_ALWAYS, TRANSMIT_WITHPARENT) then
				return true
			end

			if mode == TRANSMIT_WHITELIST then
				prop.__whitelist = prop.__whitelist or {}
				return prop.__whitelist[ply] == true
			end

			if mode == TRANSMIT_ADMIN then
				return ply:IsAdmin()
			end

			if mode == TRANSMIT_PVS then
				return NikNaks.PVS.IsPositionVisible(ply:GetPos(), parent:GetPos())
			end

			if mode == TRANSMIT_PAS then
				return NikNaks.PAS.IsPositionVisible(ply:GetPos(), parent:GetPos())
			end

			if isfunction(mode) then
				return mode(self, ply, obj, parent)
			end

			return false
		end
		
		function TYPE:Transmit(ply, fullUpdate, parent)
			if not ply then
				for k, v in pairs(player.GetAll()) do
					self:Transmit(v, fullUpdate)
				end
				return
			end

			if not self:ShouldTransmit(ply) then
				return false
			end

			local ct = CurTime()
			local last = self:GetTransmittedPlayers()[ply]

			local t = payload.Get(ply, "objects")
			if not t then
				t = {}
				payload.Set(ply, "objects", t)
			end

			local id = self:GetObjectId()
			local data = {}

			data["$_id"] = id
			data["$_type"] = self:GetTypeId()
			local items = {}
			data["$_props"]  = items

			for k, p in pairs(self:GetPropertyObjects()) do
				if not self:ShouldTransmitProperty(ply, p, fullUpdate) then
					continue
				end

				local v = p.value:Get()
				if sym.IsType(v) then
					local transmit = p:GetTransmit()
					if transmit == TRANSMIT_WITHPARENT then
						items[k] = sym.Encode(v, { EncodeNilsAsNull = true } )
					else
						v:Transmit(ply, fullUpdate, self)
						items[k] = { ["$ref"] = v:GetObjectId() }
					end
				else
					items[k] = sym.Encode(v, { EncodeNilsAsNull = true })
				end
			end


			self:GetTransmittedPlayers()[ply] = CurTime()
			
			t[id] = data
			sym.NetworkedObjects[id] = self

			local typ = self:GetType()
			local typt = sym.NetworkedObjectsByType[typ]
			if not typ_t then
				typ_t = {}
				sym.NetworkedObjectsByType[typ] = typ_t
			end

			typ_t[id] = self

			sym.fine("NETOBJ_TRANSMIT", "Transmitting ", FromPrimitive(id), color_white, " <", COL_PRIM, self:GetTypeName(), color_white,"> to ", FromPrimitive(ply))
			return true
		end
	end

	function sym.Encode(obj, ctx, top)
		ctx = ctx or {}

		if not istable(obj) then
			if isentity(obj) then
				return { ["$ent"] = obj:EntIndex() }
			end

			if ctx.EncodeNilsAsNull and obj == nil then
				return { ["$nil"] = true }
			end
			return obj
		end

		local root = false
		if not top then
			root = true
			top = 
			{
				["$data"] = {}
			}
		end
		
		local data = top["$data"]
		local rtn = obj

		if sym.IsType(obj) then
			if not data[obj:GetObjectId()] then
				obj:Encode(ctx, top)
			end
			rtn = { ["$ref"] = obj:GetObjectId() }
		elseif istable(obj) then

			if obj["$root"] and obj["$data"] then
				for k, v in pairs(obj["$data"]) do
					if not data[k] then
						data[k] = v
					end
				end

				rtn = { ["$ref"] = obj["$root"] }
			else
				local id = tostring(obj)
				if not data[id] then
					local out = {}
					for k, v in pairs(obj) do
						out[k] = sym.Encode(v, ctx, top)
					end

					data[id] = out
				end

				rtn = { ["$ref"] = id }
			end
		elseif not obj then
			rtn = { ["$ref"] = "" }
		end

		if root then
			top["$root"] = sym.IsType(obj) and obj:GetObjectId() or tostring(obj)
			return top
		else
			return rtn
		end
	end

	function TYPE:Encode(ctx, top)
		assert(self:IsInstance(), "Only instances can be encoded")
				
		local out = {}
		out["$id"] = self:GetObjectId()
		out["$type"] = self:GetTypeId()

		local propmap = self:GetPropertyMetadata()
		for k, v in pairs(self:GetPropertyObjects()) do
			out[k] = sym.Encode(v.value:Get(), ctx, top)
		end
		
		top["$data"][self:GetObjectId()] = out
		return
	end

	local function DecodeTable(id, obj, ctx, top, data)
		local inst = {}

		sym.finest("DECODE_TABLE", "[", FromPrimitive(id), color_white, "]: Decoding item to <", COL_PRIM, "table*", color_white, ">")
		for k, v in pairs(obj) do
			if istable(v) then
				if v["$ent"] then
					inst[k] = Entity(v["$ent"])
					continue
				end

				if v["$nil"] then
					inst[k] = ctx.NilsAsNull and sym.null or nil
					continue
				end

				local ref = v["$ref"]
				assert(ref, "No $ref key in Decode")

				if ref == "" then
					inst[k] = nil
					continue
				end
				
				local item = top[ref]
				if item then
					sym.finest("DECODE_TABLE_REF", "[", FromPrimitive(id), color_white, "]: ", FromPrimitive(ref), color_white, " already exists; using instance")
					inst[k] = item
				else
					item = data[ref]
					assert(item, ref .. " could not be found in data table.")
					
					local typId = item["$type"]
					if typId then
						local typ = sym.GetTypeById(typId)
						inst[k] = typ:Decode(item, ctx, top, data)
					else
						if item["$nil"] then
							inst[k] = ctx.EncodeNilsAsNull and sym.null or nil
						elseif item["$ent"] then
							inst[k] = Entity(item["$ent"])
						else
							inst[k] = DecodeTable(ref, item, ctx, top, data)
						end
					end
				end
			else
				inst[k] = v
			end
		end

		top[id] = inst

		return inst
	end

	function sym.Decode(obj, ctx)
		ctx = ctx or {}
		if not istable(obj) then
			return obj
		end

		local root = obj["$root"]
		local data = obj["$data"]
		local top = {}
		sym.finest("DECODE", "Decoding object")

		if not data then
			return nil
		end

		for k, v in pairs(data) do
			local typeId = v["$type"]
			if v["$type"] then
				local id = v["$id"]
				local inst = top[id]
				if not inst then
					local typ = sym.GetTypeById(typeId)
					typ:Decode(v, ctx, top, data)
				end
			else
				if v["$nil"] then
					top[k] = ctx.EncodeNilsAsNull and sym.null or nil
				elseif v["$ent"] then
					top[k] = Entity(v["$ent"])
				else
					DecodeTable(k, v, ctx, top, data)
				end
			end
		end

		return top[root]
	end

	function TYPE:Decode(obj, ctx, top, data)
		local inst = sym.CreateUninitializedInstance(self)

		local id = obj["$id"]

		obj["$id"] = nil
		obj["$type"] = nil

		sym.finest("DECODE_TYPE", "[", FromPrimitive(id), color_white, "]: Decoding item to <", COL_PRIM, self:GetTypeName(), ">")
		for k, v in pairs(obj) do
			if istable(v) then
				if v["$nil"] then
					inst:SetProperty(k, ctx.NilsAsNull and sym.null or nil)
					continue
				end

				if v["$ent"] then
					inst:SetProperty(k, Entity(v["$ent"]))
					continue
				end

				local ref = v["$ref"]
				assert(ref, "No $ref key in Decode")

				local item = top[ref]
				if item then
					sym.finest("DECODE_TYPE_REF", "[" .. id .. "]: " .. ref .. " already exists; using pre-existing instance.")
					inst:SetProperty(k, item)
				else
					item = data[ref]
					local typId = item["$type"]
					if typId then
						local typ = sym.GetTypeById(typId)
						inst:SetProperty(k, typ:Decode(item, ctx, top, data))
					else
						if item["$nil"] then
							inst:SetProperty(k, ctx.EncodeNilsAsNull and sym.null or nil)
						else
							inst:SetProperty(k, DecodeTable(k, item, ctx, top, data))
						end
					end
				end
			else
				inst:SetProperty(k, v)
			end
		end

		inst.__id = id

		if self.Init then
			self:Init(inst)
		end

		top[id] = inst

		return inst
	end

	function TYPE:Dispose(bNoNetwork)
		assert(self:IsInstance(), "Can only dispose instances.")

		if self:IsDisposed() then
			return
		end

		local id = self:GetObjectId()
		sym.NetworkedObjects[id] = nil -- GC would get it but still
		self.__disposed = true

		self:OnDisposed()

		if SERVER and bNonetwork then
			net.Start("sym_dispose")
				net.WriteString(id)
			net.Send(table.GetKeys(self:GetTransmittedPlayers()))
		end
		sym.debug("NETOBJ_DISPOSE", FromPrimitive(id), color_white, " <", COL_PRIM, self:GetTypeName(), color_white, ">")
	end

	function TYPE:OnDisposed()
	end

	function TYPE:IsDisposed()
		return self.__disposed
	end

	if CLIENT then
		net.Receive("sym_dispose", function (len)
			local id = net.ReadString()
			local obj = sym.NetworkedObjects[id]
			if obj then
				obj:Dispose()
				sym.OnNetObjectDisposed:Invoke(id, obj)
				sym.debug("NETOBJ_DISPOSE", FromPrimitive(id), color_white, " <", COL_PRIM, obj:GetTypeName(), color_white, ">")
			end
		end)
	end

	if SERVER then
		util.AddNetworkString("sym_dispose")
	end
end

-- PROPERTY
do
	PROPERTY = sym.RegisterType("property")
    function PROPERTY:Init(t, parent, name, type, options)
        t.parent = parent
		t.name = name
        t.type = type
        t.options = options
        return t
    end

    function PROPERTY:GetName()
        return self.name
    end

    function PROPERTY:GetPropertyType()
        return self.type
    end

    function PROPERTY:GetOptions()
        return self.options
    end

	function PROPERTY:GetParent()
		return self.parent
	end

	function PROPERTY:__tostring()
		return "Property[" .. tostring(self.name) .. "]"
	end
	

	function PROPERTY:AddWhitelist(ply)
		assert(self:IsInstance(), "Only can be called on instances")
		
		self.__whitelist = self.__whitelist or {}
		self.__whitelist[ply] = true
	end

	function PROPERTY:RemoveWhitelist(ply)
		assert(self:IsInstance(), "Only can be called on instances")
		
		self.__whitelist = self.__whitelist or {}
		self.__whitelist[ply] = nil
	end

	function PROPERTY:ClearWhitelist(ply)
		assert(self:IsInstance(), "Only can be called on instances")
		
		self.__whitelist = self.__whitelist or {}
		table.Empty(self.__whitelist)
	end
end