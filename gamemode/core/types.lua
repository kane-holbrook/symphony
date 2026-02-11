AddCSLuaFile()

Type = {}
Type.ByName = {} -- @test Type.Register
Type.ByCode = weaktable(false, true) -- @test Type.Register
Type.Instances = weaktable(false, true) -- @test Type.Register
Type.Primitives = weaktable(false, true)
Types = Type
setmetatable(Type, { __index = Type.ByName })

function Type.GenerateID(type)
    local data2 = string.format("%.8x", math.Truncate(math.Rand(0, 4294967295)))
    local data3 = string.format("%.8x", math.Truncate(math.Rand(0, 4294967295)))
    return string.format("%08x-%s-%s-%s-%s%.8x", type.Code, string.sub(data2, 0, 4), string.sub(data2, 5, 8), string.sub(data3, 0, 4), string.sub(data3, 5, 8), math.Truncate(math.Rand(0, 4294967295)))
end

local Metamethods = {
	"__tostring",
	"__eq",
	"__lt",
	"__le",
	"__add",
	"__sub",
	"__mul",
	"__div",
	"__mod",
	"__pow",
	"__unm",
	"__concat",
	"__len",
	"__call",
	"__gc",
	"__mode",
	"__metatable",
	"__index",
	"__newindex",
	"__pairs",
	"__ipairs",
	"__close",
	"__name"
}

-- @test Type.Register
local function CopyMetamethods(from, to)
	for k, v in pairs(Metamethods) do
		to[v] = from[v]
	end
end

-- Base Type
local TYPE = Type.Type or {}
do
	TYPE.Code = 256
	TYPE.Name = "Type"
	TYPE.Super = nil

	function TYPE:New(id)
		local t = id and Type.Instances[id]
		if t then
			return t
		else
			t = {}

			local mt = table.Copy(self.Metamethods)
			mt.Id = id --or GenerateId(self) -- (string.format("%08x", self.Code) .. string.sub(uuid(), 9, -1))
			mt.Type = self
			local super = self:GetSuper()
			mt.Base = super.Prototype
			mt.__index = mt -- The object should point at this metatable (so the object itself can remain clean).
			setmetatable(mt, {
				__index = self.Prototype -- However, if keys aren't found on the MT, they should be pulled from the proto.
			})

			setmetatable(t, mt)

			for k, v in pairs(self:GetPropertiesMap()) do
				local default = v.Options.Default
				if default == nil then
					continue
				end

				if isfunction(default) then
					t[k] = default(t)
				elseif istable(default) then
					t[k] = table.Copy(default)
				else
					t[k] = default
				end
			end

			t:Initialize()
		end
		return t
	end

	-- @test Type.Register
	function TYPE:GetCode()
		return self.Code
	end

	-- @test Type.Register
	function TYPE:GetName()
		return self.Name
	end

	-- @test Type.Register
	function TYPE:GetSuper()
		return self.Super
	end

	function TYPE:GetType()
		return TYPE
	end

	-- @test Type.Register
	function TYPE:__tostring()
		return "Type[" .. self.Name .. "]"
	end

	function TYPE:__call(...)
		if self.OnTypeCalled then
			return self.OnTypeCalled(...)
		end
	end

	TYPE.Ancestry = {} -- @test Type.Register

	-- Properties
	TYPE.Properties = {} -- @test Type.Register
	TYPE.PropertiesByName = weaktable(false, true) -- Effectively a cache. -- @test Type.Register

	local ReservedNames = {
		Type = true
	}

	-- @test Type.Register
	function TYPE:CreateProperty(name, type, options)
		options = options or {}
		assert(not ReservedNames[name], "Cannot create property with reserved name: " .. name)

		if rawget(self.PropertiesByName, name) then
			local prop = self.PropertiesByName[name]
			prop.Type = type
			prop.Options = options
			if options.Priority then
				table.SortByMember(self.Properties, "Priority")
			end
			return prop
		end

		local prop = {
			Name = name,
			Type = type,
			Options = options,
			Code = tonumber(util.CRC(name))
		}

		if not options.NoSetter then
			self.Prototype["Set" .. name] = function (self, value, ...)
				return self:SetProperty(name, value, ...)
			end
		end

		if not options.NoGetter then
			self.Prototype["Get" .. name] = function (self, ...)
				return self:GetProperty(name, ...)
			end
		end

		if options.Priority then
			prop.Priority = options.Priority
			table.insert(self.Properties, prop)
			table.SortByMember(self.Properties, "Priority") -- This breaks priorities
		else
			prop.Priority = table.insert(self.Properties, prop)
		end

		self.PropertiesByName[name] = prop
		self.PropertiesByCode[prop.Code] = prop

		hook.Run("Type.CreateProperty", self, name, type, options)
		
		return prop
	end

	function TYPE:GetProperties()
		local props = {}
		local super = self:GetSuper()

		local idx = 0
		if super then
			for k, v in pairs(super:GetProperties()) do
				idx = idx + 1
				props[idx] = v
			end
		end

		idx = idx + 1
		for k, v in pairs(self.Properties) do
			idx = idx + 1
			props[idx] = v
		end

		return props
	end

	function TYPE:GetPropertiesMap()
		
		local props = {}
		local super = self:GetSuper()
		if super then
			for k, v in pairs(super:GetPropertiesMap()) do
				props[k] = v
			end
		end

		for k, v in pairs(self.PropertiesByName) do
			props[k] = v
		end

		return props
	end

	function TYPE:GetPropertiesByCode()
		return self.PropertiesByCode
	end

	function TYPE:GetPropertyByCode(code)
		return self.PropertiesByCode[code]
	end

	function TYPE:GetProperty(name)
		return self.PropertiesByName[name]
	end

	-- Prototype
	TYPE.Prototype = {}
	setmetatable(TYPE.Prototype, { Type = TYPE })

	-- @test Type.Register
	function TYPE:GetPrototype()
		return self.Prototype
	end

	-- Metamethods for the PROTOTYPE.
	TYPE.Metamethods = {}
	function TYPE:GetMetamethods()
		return self.Metamethods
	end

	-- @test Type.Register
	function TYPE.Metamethods:__tostring()
		return self:GetType():GetName()
	end
	
	-- @test Type.Register
	TYPE.Derivatives = weaktable(false, true)

	function TYPE:OnDerive(child)
		local s = self:GetSuper()
		if s then
			s:OnDerive(child)
		end
	end

	function TYPE:GetDerivatives(recursive)
        if not recursive then
            return self.Derivatives
        end

        local out = {}
        for k, v in pairs(self.Derivatives) do
            table.insert(out, v)

            local sub = v:GetDerivatives(true)
            for k2, v2 in pairs(sub) do
                table.insert(out, v2)
            end
        end
        return out
	end

	TYPE.Options = { DatabaseType = "JSON" }
	function TYPE:GetOptions()
		return self.Options
	end

	
	function Type.Encode(data)
		local typ = Type.GetType(data)
		assert(typ, "Cannot encode data of unknown type: " .. tostring(data))
		
		local out = { typ:GetCode(), typ:Encode(data) }
		return sfs.encode(out)
    end

	function Type.Decode(data)
		local t = sfs.decode(data)
		local typeId = t[1]
		local values = t[2]

		local typ = Type.GetByCode(typeId)
		return typ:Decode(values)
	end
	
	function TYPE:Encode(obj)
		local props = obj:GetProperties()
		local propMap = self:GetPropertiesMap()

		local out = {}
		for k, v in pairs(props) do
			local pm = propMap[k]

			if pm.Type then
				out[pm.Code] = pm.Type:Encode(v)
			else
				local pt = Type.GetType(v)
				out[pm.Code] = { pt:GetCode(), pt:Encode(v) }
			end
		end

		return out
	end

	function TYPE:Decode(data)

		local obj = self:New()

		local map = self:GetPropertiesByCode()
		for k, v in pairs(data) do
			local prop = map[k]
			assert(prop, "Unknown property code " .. tostring(k) .. " for type " .. self:GetName() .. "!")

			if prop.Type then
				obj:SetProperty(prop.Name, prop.Type:Decode(v))
			else
				local pt = Type.GetByCode(v[1])
				assert(pt, "Unknown property type code " .. tostring(v[1]) .. " for property " .. prop.Name .. " on type " .. self:GetName() .. "!")
				obj:SetProperty(prop.Name, pt:Decode(v[2]))
			end
		end

		return obj
	end

	-- Database
	

    function TYPE:DatabaseEncode(obj)
		return self:Encode(obj)
    end

    function TYPE:DatabaseDecode(data)
        return self:Decode(data)
    end

	function TYPE:TryParse(value)
		if self.Parse then
			return pcall(self.Parse, self, value)
		end
		return false, nil
	end

	-- Registering us
	Type.ByName.Type = TYPE -- @test Type.Register
	Type.ByCode[TYPE.Code] = TYPE -- @test Type.Register

	setmetatable(TYPE, { __tostring = TYPE.__tostring }) -- @test Type.Register
end

-- Base Object
local OBJ = TYPE.Prototype
do
	-- @test Type.New
	function OBJ:Initialize(id)
		base(self, "Initialize", id)
	end

	-- Single threaded so this isn't a problem
	local base__Name
	local base__Source
	local base__Next
	local base__Depth = 0

	-- @test Type.New
	function base(self, name, ...)
		
		assert(self and self.GetBase, "base() called without self", 2)
		assert(name, "base() called without a name", 2)
 
		local top = false

		-- If we're calling it for the first time, we're the bottom-most object.
		if self ~= base__Source or name ~= base__Name then

			base__Depth = base__Depth + 1
			local p = self
			while p do
					
				local mt = getmetatable(p)
				assert(mt)

				if p[name] then
					base__Next = p
					break
				end

				p = mt.Base
			end

			if not base__Next then
				return
			end

			
			base__Source = self
			base__Name = name

			top = true
		end
	
		assert(self.GetBase, "base() called without self")
		assert(base__Name, "base() called without a name", 2)
		assert(base__Source, "base() called without a source", 2)
		assert(base__Next, "base() called without a next", 2)

		local src = base__Source
		base__Next = getmetatable(base__Next).Base

		local out = {}
		if base__Next and base__Next[base__Name] then
			local last = this
			this = base__Next
			base__Depth = base__Depth + 1
			out = { base__Next[name](src, ...) }
			base__Depth = base__Depth - 1
			base__Source = src
			base__Name = name
			this = last
		end

		if top then
			base__Source = nil
			base__Next = nil
			base__Name = nil
			this = nil
			base__Depth = base__Depth - 1
		end

		return unpack(out)
	end

	function OBJ:GetTableRef()
		local mt = getmetatable(self)
		setmetatable(self, nil)
		local id = tostring(self)
		setmetatable(self, mt)
		return id
	end

	-- @test Type.New
	function OBJ:GetType()
		local mt = getmetatable(self)
		return mt.Type
	end

	-- @test Type.New
	function OBJ:GetBase()
		local mt = getmetatable(self)
		return self.Base
	end

	function OBJ:SetProperty(name, value, noParse)
		local p = Type.GetType(self):GetPropertiesMap()[name]

		if p then
			local opt = p.Options
			if opt then
				if opt.Parse and not noParse then
					value = opt.Parse(self, name, value)
                    noParse = true
				end
			end

			if p.Type then

                if value ~= nil and not Type.Is(value, p.Type) then
                    local succ, parsedValue = p.Type:TryParse(value)
                    if succ then
                        value = parsedValue
                    else
                        error(tostring(self) .. ": Property " .. name .. " expects " .. p.Type:GetName() .. " but got " .. Type.GetType(value):GetName() .. " - " .. tostring(parsedValue))
                    end
                end
			end
        end

		local old = self[name]
		self[name] = value
		self:OnPropertyChanged(name, value, old)
		return self
	end

	function OBJ:OnPropertyChanged(name, value, old)
	end

	function OBJ:GetProperty(name)
		return self[name]
	end

	-- @test Type.New
	function OBJ:GetProperties()
		local props = self:GetType():GetPropertiesMap()
		local out = {}
		for k, v in pairs(props) do
			out[k] = self[k]
		end
		return out
	end

	function OBJ:Clone()
		local typ = self:GetType()
		local obj = Type.New(typ)

		for k, v in pairs(self) do
			obj[k] = v
		end

		return obj
	end

	function OBJ:Dispose()
		local mt = getmetatable(self)
		mt.Disposed = true

		if self.OnDisposed then
			self:OnDisposed()
		end
	end

	function OBJ:IsDisposed()
		local mt = getmetatable(self)
		return mt.Disposed == true
	end

	function OBJ:IsValid()
		return not self:IsDisposed()
	end
end

-- Statics
do
	-- @test Type.Register
	function Type.Register(name, super, options)
		if isstring(super) then
			super = Type.GetByName(super)
		end

		super = super or Type.Type
		options = setmetatable(options or {}, { __index = super.Options })

		local t = Type.ByName[name]
		if not t then
			t = {}
			t.Code = rawget(options, "Code") or (256 + tonumber(util.CRC(name))) -- This is the unique int32 code used in networking etc.
			assert(not Type.ByCode[t.Code], "Type code collision: " .. name)
		end

		t.Name = name
		t.Super = super

		t.Properties = setmetatable({}, { __index = super.Properties })
		t.PropertiesByName = setmetatable({}, { __index = super.PropertiesByName })
		t.PropertiesByCode = setmetatable({}, { __index = super.PropertiesByCode })
		t.Prototype = setmetatable({}, { __index = super.Prototype, Type = t, Super = super, Base = super.Prototype })
		t.Metamethods = table.Copy(super.Metamethods)
		t.Derivatives = {}
		t.Instances = weaktable(false, true)
		t.Options = options

		super.Derivatives[name] = t
		
		-- Effectively a cache of ancestors for speeding up Type.Is
		t.Ancestry = {}
		for k, v in pairs(super.Ancestry) do
			t.Ancestry[k] = true
		end
		t.Ancestry[super] = true

		Type.ByName[name] = t
		Type.ByCode[t.Code] = t

		local mt = getmetatable(t) or {}
		CopyMetamethods(super, mt)
		mt.__index = super

		-- Inherit from super type
		setmetatable(t, mt)

		super:OnDerive(t)

		hook.Run("Type.Register", t)

		return t
	end

	function Type.Unregister(type)
		Type.ByName[type:GetName()] = nil
		Type.ByCode[type:GetCode()] = nil
	end

	-- @test Type.Register
	function Type.GetByName(name)
		return Type.ByName[name]
	end

	function Type.GetById(id)
		assert(id, "Must provide an ID to Type.GetById")
		local code = string.sub(id, 1, 8)
		return Type.ByCode[tonumber(code, 16)]
	end

	function Type.GetInstanceById(id)
		return Type.Instances[id]
	end

	-- @test Type.Register
	function Type.GetByCode(code)
		return Type.ByCode[code]
	end

	function Type.GetType(obj)
		if obj.GetType then
			return obj:GetType()
		elseif istable(obj) then
			return Type.Table
		end
	end

	function Type.GetAll()
		return Type.ByName
	end

	-- @test Type.Register  @REVIEW
	function Type.Is(obj, super)
		local type = Type.GetType(obj)
		if type ~= Type.Type then
			obj = type
		end

		if not obj.Ancestry then
			return false
		end
		
		if obj:GetCode() == super:GetCode() then
			return true
		end

		return obj.Ancestry[super] == true
	end
	Is = Type.Is

	-- @test Type.New  @REVIEW
	function Type.New(type, id)
		if isstring(type) then
			type = Type.GetByName(type)
		end
		assert(type, "Must provide a type to Type.New")
		assert(rawget(type:GetOptions(), "Abstract") ~= true, "Cannot instantiate abstract type: " .. type:GetName())

		return type:New(id)
	end
	new = Type.New

	function net.WriteObject(obj)
		local data = Type.Encode(obj)
		local len = string.len(data)
		net.WriteUInt64(len)
		net.WriteData(data, len)
	end

	function net.ReadObject()
		local len = net.ReadUInt64()
		local data = net.ReadData(len)
		return Type.Decode(data)
	end

	function rtc.WriteObject(obj)
		local data = Type.Encode(obj)
		local len = string.len(data)
		rtc.WriteUInt64(len)
		rtc.WriteData(data, len)
	end

	function rtc.ReadObject()
		local len = rtc.ReadUInt64()
		local data = rtc.ReadData(len)
		return Type.Decode(data)
	end
end

-- ORM
do
	-- @test Type.New
	function TYPE:GetDatabaseTable()
		return self:GetOptions().Table
	end

	function TYPE:GetDatabaseKey()
		return self:GetOptions().Key or "Id"
	end

	if SERVER then
		function TYPE:CreateDatabaseTable()
			local name = self:GetOptions().Table
			if not name then
				return
			end
			name = string.lower(name)
			
			local key = string.lower(self:GetDatabaseKey())

			local qry
			local fieldSQL = {}
			if not Database.Tables[name] then
				if self:GetDatabaseKey() == "Id" then
					table.insert(fieldSQL, "Id UUID")
				end

				for k, f in pairs(self:GetProperties()) do
					local opt = f.Options
					if opt.Transient then
						continue
					end


					local i = {}
					local fname = f.Name
					i[1] = "`" .. Database.Escape(fname) .. "`"
					i[2] = opt.DatabaseType or (f.Type and Database.Escape(f.Type:GetOptions().DatabaseType)) or "TEXT"

					if opt.not_null then
						table.insert(i, "NOT NULL")
					end

					if opt.auto_increment then
						table.insert(i, "AUTO_INCREMENT")
					end

					if string.lower(fname) == key then
						table.insert(i, "PRIMARY KEY")
					end

					table.insert(fieldSQL, table.concat(i, " "))
				end 

				qry = "CREATE TABLE `" .. Database.Escape(name) .. "` (\n\t" .. table.concat(fieldSQL, ",\n\t") .. "\n)"

				local p = Database.Query(qry)
				p:wait()

				Database.Tables[name] = self
			else
				for k, f in pairs(self:GetProperties()) do
					local opt = f.Options
					if opt.Transient then
						continue
					end

					local i = {}
					local fname = f.Name
					i[1] = "`" .. Database.Escape(fname) .. "`"
					i[2] = opt.DatabaseType or (f.Type and Database.Escape(f.Type:GetOptions().DatabaseType)) or "TEXT"

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
				
				qry = "ALTER TABLE `" .. Database.Escape(name) .. "` \n\t" .. table.concat(fieldSQL, ",\n\t")
				
				local p = Database.Query(qry)
				p:wait()

				Database.Tables[name] = self
			end
		end

		function TYPE:Select(field, value)

			local promise = Promise.Create()

			if field and not value then
				value = field
				field = self:GetDatabaseKey()
			end
			
			
			local qry 
			if field then
				qry = "SELECT * FROM `" .. Database.Escape(self:GetDatabaseTable()) .. "` WHERE `" .. Database.Escape(field) .. "` = " .. Type.GetType(value):DatabaseEncode(value)
			else
				qry = "SELECT * FROM `" .. Database.Escape(self:GetDatabaseTable()) .. "`"
			end

			promise.Query = Database.Query(qry)
			promise.Query:Then(function (data)
				local out = {}

				for i, r in pairs(data) do
					local obj = new(self, r["Id"])
				
					local props = self:GetPropertiesMap()
					for k, v in pairs(r) do
						local p = props[k]
						if not p then
							continue
						end

						local val
						if p.Type then
							val = p.Type:DatabaseDecode(v)
						else
							local t = sfs.decode(util.Base64Decode(v))
							local typeId = t[1]
							local values = t[2]
							
							local typ = Type.GetByCode(typeId)
							assert(typ, "Failed to decode property " .. k .. " for type " .. self:GetName() .. ": unknown type code " .. tostring(typeId))
							val = typ:Decode(values)
						end

						obj:SetProperty(k, val)
					end
					getmetatable(obj).LastRefresh = CurTime()

					out[i] = obj
				end

				
				promise:Complete(out)
			end)

			return promise
		end

		function OBJ:GetId()
			return self.Id
		end

		function OBJ:GetLastRefresh()
			local mt = getmetatable(self)
			return mt.LastRefresh
		end

		function OBJ:Refresh()
			return Promise.Run(function ()
				local dk = self:GetType():GetDatabaseKey()
				local dk_val = self[dk]

				local qry = "SELECT * FROM `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` WHERE `" .. Database.Escape(self:GetType():GetDatabaseKey()) .. "` = " .. Type.GetType(dk_val):DatabaseEncode(dk_val) .. " LIMIT 1"
				local data = Database.Query(qry):Await()

				if not data[1] then
					error("No data found for " .. self:GetType():GetName() .. " with ID " .. self:GetId())
				end

				local props = self:GetType():GetPropertiesMap()
				for k, v in pairs(data[1]) do
					local p = props[k]
					if not p then
						continue
					end

					
					local val
					if p.Type then
						val = p.Type:DatabaseDecode(v)
					else
						local t = sfs.decode(util.Base64Decode(v))
						local typeId = t[1]
						local values = t[2]
						
						local typ = Type.GetByCode(typeId)
						assert(typ, "Failed to decode property " .. k .. " for type " .. self:GetType():GetName() .. ": unknown type code " .. tostring(typeId))
						val = typ:Decode(values)
					end

					self:SetProperty(k, val)
				end
				getmetatable(self).LastRefresh = CurTime()
			end)
		end

		function OBJ:Commit()

			hook.Run("Database.Commit", self)

			if not self:GetLastRefresh() then
				-- Insert
				local mt = getmetatable(self)
				local fields = {}
				local values = {}

				if self:GetType():GetDatabaseKey() == "Id" then
					table.insert(fields, "`Id`")
					table.insert(values, string.format("%q", self:GetId()))
				end

				local props = self:GetType():GetPropertiesMap()
				for k, v in pairs(self:GetProperties()) do
					local pm = props[k]

					if pm.Options and pm.Options.Transient then
						continue
					end

					local ft = pm.Type
					table.insert(fields, "`" .. Database.Escape(k) .. "`")


					if ft then
						table.insert(values, props[k].Type:DatabaseEncode(v))
					else
						local enc = util.Base64Encode(sfs.encode({ v:GetType():GetCode(), Type.GetType():Encode(v) }))
						_enc = enc
						table.insert(values, string.format("%q", enc))
					end
				end

				local qry = "INSERT INTO `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` (" .. table.concat(fields, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
				mt.LastRefresh = CurTime()

				return Database.Query(qry)
			else
				-- Update
				local mt = getmetatable(self)
				local kvp = {}

				local key = self:GetType():GetDatabaseKey()
				local id = self[key]

				local props = self:GetType():GetPropertiesMap()
				for k, v in pairs(self:GetProperties()) do
					
					local pm = props[k]
					if pm.Options and pm.Options.Transient then
						continue
					end

					local ft = pm.Type

					if ft then
						table.insert(kvp, "`" .. Database.Escape(k) .. "` = " .. Type.GetType(v):DatabaseEncode(v))
					else
						local enc = util.Base64Encode(sfs.encode({ v:GetType():GetCode(), Type.GetType(v):Encode(v) }))
						table.insert(kvp, "`" .. Database.Escape(k) .. "` = " .. string.format("%q", enc))
					end
				end

				local qry = "UPDATE `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` SET " .. table.concat(kvp, ", ") .. " WHERE `" .. Database.Escape(key) .. "` = " .. Type.GetType(id):DatabaseEncode(id)
				mt.LastRefresh = CurTime()

				return Database.Query(qry)
			end
		end	
			
		function OBJ:DeleteFromDatabase()
			assert(self:GetLastRefresh())
			
			
			hook.Run("Database.Delete", self)
			
			local mt = getmetatable(self)
			local key = self:GetType():GetDatabaseKey()
			local id = self[key]
			
			local qry = "DELETE FROM `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` WHERE `" .. Database.Escape(key) .. "` = " .. Type.GetType(id):DatabaseEncode(id)
			mt.LastRefresh = nil
			return Database.Query(qry)
		end
	end
end