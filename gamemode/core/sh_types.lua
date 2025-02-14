Type = {}
Type.ByName = {} -- @test Type.Register
Type.ByCode = weaktable(false, true) -- @test Type.Register
Type.Instances = weaktable(false, true) -- @test Type.Register
Type.Primitives = weaktable(false, true)

setmetatable(Type, { __index = Type.ByName })


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
		local t = {}
		self:Apply(t, id)
		return t
	end

	function TYPE:Apply(t, id)
		local mt = table.Copy(self.Metamethods)
		mt.Id = id or uuid()
		mt.Type = self
		local super = self:GetSuper()
		mt.Base = super.Prototype
		mt.__index = mt -- The object should point at this metatable (so the object itself can remain clean).
		setmetatable(mt, {
			__index = self.Prototype -- However, if keys aren't found on the MT, they should be pulled from the proto.
		})

		setmetatable(t, mt)
		self.InstanceCount = self.InstanceCount + 1
		self.Instances[self.InstanceCount] = t

		Type.Instances[t:GetId()] = t

		t:Initialize()
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

	-- @test Type.Register
	function TYPE:CreateProperty(name, type, options)
		options = options or {}
		local prop = {
			Name = name,
			Type = type,
			Options = options
		}

		if not options.NoSetter then
			self.Prototype["Set" .. name] = function (self, value, ...)
				self:SetProperty(name, value, ...)
			end
		end

		if not options.NoGetter then
			self.Prototype["Get" .. name] = function (self, ...)
				return self:GetProperty(name, ...)
			end
		end

		if options.Priority then
			table.insert(self.Properties, prop)
			table.SortByMember(self.Properties, "Priority") -- This breaks priorities
		else
			table.insert(self.Properties, prop)
		end

		self.PropertiesByName[name] = prop
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
		return self:GetType():GetName() .. "[" .. self:GetId() .. "]"
	end

	TYPE.Instances = weaktable(false, true) -- @test Type.Register
	TYPE.InstanceCount = 0

	-- @test Type.Register
	function TYPE:GetInstances()
		return self.Instances
	end

	-- @test Type.Register
	function TYPE:GetInstanceCount()
		return self.InstanceCount
	end
	
	-- @test Type.Register
	TYPE.Derivatives = weaktable(false, true)

	function TYPE:OnDerive(child)
		local s = self:GetSuper()
		if s then
			s:OnDerive(child)
		end
	end

	function TYPE:GetDerivatives()
		return self.Derivatives
	end

	TYPE.Options = { DatabaseType = "JSON" }
	function TYPE:GetOptions()
		return self.Options
	end
	
	function TYPE:Serialize(obj, ply)
		return obj:GetProperties()
	end

	function TYPE:Deserialize(obj, data)
		for k, v in pairs(data) do
			obj:SetProperty(k, v)
		end
		return obj
	end

	-- Database
	function TYPE:GetDatabaseTable()
		return self:GetOptions().Table
	end

	function TYPE:GetDatabaseKey()
		return self:GetOptions().Key or "Id"
	end

	function TYPE:CreateDatabaseTable()
		local name = self:GetOptions().Table
		if not name then
			return
		end
		
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
				i[2] = Database.Escape(f.Type:GetOptions().DatabaseType)

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
				i[2] = Database.Escape(f.Type:GetOptions().DatabaseType)

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

	function TYPE:DatabaseEncode(obj)
		return "\"" .. Database.Escape(util.TableToJSON(Type.Serialize(obj))) .. "\""
	end

	function TYPE:DatabaseDecode(data)
		return Type.Deserialize(util.JSONToTable(data))
	end

	function TYPE:TryParse(value)
		if self.Parse then
			return pcall(self.Parse, self, value)
		end
		return false, nil
	end

	function TYPE:Select(field, value)

		if not value then
			value = field
			field = self:GetDatabaseKey()
		end
		
		
		local qry 
		if field then
			qry = "SELECT * FROM `" .. Database.Escape(self:GetDatabaseTable()) .. "` WHERE `" .. Database.Escape(field) .. "` = " .. Type.GetType(value):DatabaseEncode(value)
		else
			qry = "SELECT * FROM `" .. Database.Escape(self:GetDatabaseTable()) .. "`"
		end

		local data = Database.Query(qry):Await()
		local out = {}


		for k, v in pairs(data) do
			local obj = new(self, v["Id"])
		
			local props = self:GetPropertiesMap()
			for k, v in pairs(data[1]) do
				local p = props[k]
				if not p then
					continue
				end

				obj:SetProperty(k, p.Type:DatabaseDecode(v))
			end
			getmetatable(obj).LastRefresh = CurTime()

			out[k] = obj
		end

		return out
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
	function OBJ:Initialize()
		base(self, "Initialize")
	end

	-- Single threaded so this isn't a problem
	local base__Name
	local base__Source
	local base__Next
	local base__Depth = 0

	-- @test Type.New
	function base(self, name, ...)
		
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
			this = base__Next
			base__Depth = base__Depth + 1
			out = { base__Next[name](src, ...) }
			base__Depth = base__Depth - 1
			base__Source = src
			base__Name = name
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

	-- @test Type.New
	function OBJ:GetId()
		local mt = getmetatable(self)
		return mt.Id
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

	function OBJ:SetProperty(name, value)
		local p = Type.GetType(self):GetPropertiesMap()[name]
		if p and p.Type and not p.Options.NoValidate then
			assert(value == nil or Type.Is(value, p.Type), "Property " .. name .. " expects " .. p.Type:GetName() .. " but got " .. Type.GetType(value):GetName())
		end

		local old = self[name]
		self[name] = value
		self:OnPropertyChanged(name, value, old)
	end

	function OBJ:OnPropertyChanged(name, value, old)
	end

	function OBJ:GetProperty(name)
		return self[name]
	end

	function OBJ:GetLastRefresh()
		local mt = getmetatable(self)
		return mt.LastRefresh
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

	function OBJ:Refresh()
		return Promise.Run(function ()
			local qry = "SELECT * FROM `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` WHERE `" .. Database.Escape(self:GetType():GetDatabaseKey()) .. "` = " .. Type.GetType(self:GetId()):DatabaseEncode(self:GetId()) .. " LIMIT 1"
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

				self:SetProperty(k, p.Type:DatabaseDecode(v))
			end
			getmetatable(self).LastRefresh = CurTime()
		end)
	end

	function OBJ:Commit()

		if not self:GetLastRefresh() then
			-- Insert
			local mt = getmetatable(self)
			local fields = {}
			local values = {}

			if self:GetType():GetDatabaseKey() == "Id" then
				table.insert(fields, "`Id`")
				table.insert(values, string.format("%q", self:GetId()))
			end

			for k, v in pairs(self:GetProperties()) do
				table.insert(fields, "`" .. Database.Escape(k) .. "`")
				table.insert(values, Type.GetType(v):DatabaseEncode(v))
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

			for k, v in pairs(self:GetProperties()) do
				table.insert(kvp, "`" .. Database.Escape(k) .. "` = " .. Type.GetType(v):DatabaseEncode(v))
			end

			local qry = "UPDATE `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` SET " .. table.concat(kvp, ", ") .. " WHERE `" .. Database.Escape(key) .. "` = " .. Type.GetType(id):DatabaseEncode(id)
			mt.LastRefresh = CurTime()

			return Database.Query(qry)
		end
	end

	function OBJ:DeleteFromDatabase()
		assert(self:GetLastRefresh())

		local mt = getmetatable(self)
		local key = self:GetType():GetDatabaseKey()
		local id = self[key]

		local qry = "DELETE FROM `" .. Database.Escape(self:GetType():GetDatabaseTable()) .. "` WHERE `" .. Database.Escape(key) .. "` = " .. Type.GetType(id):DatabaseEncode(id)
		mt.LastRefresh = nil
		return Database.Query(qry)
	end
end

-- Statics
do
	-- @test Type.Register
	function Type.Register(name, super, options)
		super = super or Type.Type
		options = setmetatable(options or {}, { __index = super.Options })

		local t = Type.ByName[name]
		if not t then
			t = {}
			t.Code = options.Code or (256 + util.CRC(name)) -- This is the unique int32 code used in networking etc.
			assert(not Type.ByCode[t.Code], "Type code collision: " .. name)
		end

		t.Name = name
		t.Super = super
		t.Properties = setmetatable({}, { __index = super.Properties })
		t.PropertiesByName = setmetatable({}, { __index = super.PropertiesByName })
		t.Prototype = setmetatable({}, { __index = super.Prototype, Type = t, Super = super, Base = super.Prototype })
		t.Metamethods = table.Copy(super.Metamethods)
		t.Derivatives = {}
		t.Instances = {}
		t.InstanceCount = 0
		t.Options = options

		super.Derivatives[name] = t
		
		-- Effectively a cache of ancestors for speeding up Type.Is
		t.Ancestry = {}
		for k, v in pairs(super.Ancestry) do
			t.Ancestry[v] = true
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
		
		if obj == super then
			return true
		end

		return obj.Ancestry[super] == true
	end
	Is = Type.Is

	-- @test Type.New  @REVIEW
	function Type.New(type, id)
		assert(type, "Must provide a type to Type.New")
		return type:New(id)
	end
	new = Type.New

	function Type.Serialize(data, ply, root)
		-- Effectively this just parses data, calling encode where necessary on objects, which call this
		-- recursively.

		if not root then
			-- If we're the root element (i.e. the first call), we need to create a root object.
			root = {}
			root.map = {}
			root.items = {}
			root.num = 0
			root.firstType, root.first = Type.Serialize(data, ply, root)
			root.map = nil
			root.num = nil

			return root
		end
		
		local tp = Type.GetType(data)		
		local code = tp:GetCode()
		
		if istable(data) then
			local e = root.map[data]
			if e then
				return code, e
			end

			local t = {}
			local id = root.num + 1
			root.map[data] = id
			root.num = id

			for k, v in pairs(tp:Serialize(data)) do
				t[k] = { Type.Serialize(v, ply, root) }
			end

			if data.GetId then
				t.Id = { Type.String:GetCode(), data:GetId() }
			end

			root.items[id] = t

			return code, id
		else
			return code, tp:Serialize(data)
		end
	end

	function Type.Deserialize(data, root)		
		if not root then
			root = {}
			root.map = {}
			root.items = data.items
			root.first = data.first
			root.firstType = data.firstType
			root.seen = {}

			return Type.Deserialize({root.firstType, root.first}, root)
		else
			Test.Assert(data, "Data is nil", 2)
			local typeId = data[1]
			local value = data[2]

			local type = Type.GetByCode(typeId)
			Test.Assert(type, "Type not found for code: " .. typeId)

			if Is(type, Type.Primitive) then
				return type:Deserialize(value)
			else
				local key = value

				local seen = root.seen[key]
				if seen then
					return seen
				end

				value = root.items[key]

				local id
				if typeId ~= TYPE_TABLE then
					id = Type.Deserialize(value.Id, root)
					value.Id = nil
				end

				local obj = new(type, id)
				root.seen[key] = obj

				local t = {}
				for k, v in pairs(value) do
					t[k] = Type.Deserialize(v, root)
				end	

				type:Deserialize(obj, t)
				return obj
			end
		end
	end

	function net.WriteObject(obj, ply)
		net.WriteTable(Type.Serialize(obj, ply))
	end

	function net.ReadObject()
		local t = net.ReadTable()
		return Type.Deserialize(t)
	end
end

-- Disposable
local DISP = Type.Register("Disposable")
do
	function DISP.Prototype:Initialize()
		local mt = getmetatable(self)
		mt.userdata = newproxy(true)
		getmetatable(mt.userdata).__gc = function ()
			print("Dispose GC")
			self:Dispose()
		end
		print("Init")
	end

	function DISP.Prototype:Dispose()
		print("Disposed")
	end

end


-- Set the metatable of _G to fall back to the type system.
local GMeta = FindMetaTable("_G") or {}
GMeta.__index = Type.ByName
setmetatable(_G, GMeta)
RegisterMetaTable("_G", GMeta)


local TEST_NET_PROMISE
hook.Add("Test.Register", "Types", function ()			
	local root = Test.Register("Type")
	root:AddTest("Registration", function()
		local t = Type.Register("TestType", nil, { Test = true })
		Test.Equals(t:GetName(), "TestType")
		Test.Equals(t:GetCode(), 3784073340)
		Test.Equals(t:GetSuper(), Type.Type)
		Test.Equals(t:GetOptions()["Test"], true)

		assert(Type.ByName["TestType"] == t, "Type not registered in ByName")
		assert(Type.ByCode[t:GetCode()] == t, "Type not registered in ByCode")
		assert(Type.Is(t, Type.Type), "Type not derived from Type")
		
		
		local code = t:GetCode()
		t = nil
		Type.ByName["TestType"] = nil
		collectgarbage("collect")
		assert(not Type.ByCode[code], "Type not __gc'd in ByCode")
	end)

	root:AddTest("Instantiation", function ()
		local t = Type.Register("Life", nil, { TestOption = true })
		t:CreateProperty("CanFly")

		function t.Prototype:Initialize()
			self.Test = true
		end

		function t.Prototype:Fly()
			return self:GetCanFly() or false
		end

		local t2 = Type.Register("Mammal", t)
		Test.Equals(t2:GetOptions()["TestOption"], true)

		function t2:Initialize()
			base(self, "Initialize")
			self.Test2 = true
			Test.Equals(self.Test, true)
		end

		local t3 = Type.Register("Human", t2, { TestOption = 32 })
		function t3:Initialize()
			base(self, "Initialize")
			self.Test3 = true
			Test.Equals(self.Test, true)
			Test.Equals(self.Test2, true)
		end

		function t3.Prototype:PlayGMod()
			return true
		end

		function t3.Metamethods:__tostring()
			return "HUMAN"
		end
		Test.Equals(t3:GetOptions()["TestOption"], 32)

		local t4 = Type.Register("Bird", t)
		function t4.Prototype:Initialize()
			Test.Equals(self.Test, nil)
			base(self, "Initialize")
			self:SetCanFly(true)
			Test.Equals(self.Test, true)
		end
		Test.Equals(t4:GetOptions()["TestOption"], true)

		local t5 = Type.Register("Rock")
		t5:CreateProperty("TestString", Type.String)
		assert(not t5:GetOptions()["TestOption"])

		local life = new(t)
		local mammal = new(t2)
		local human = new(t3)
		local bird = new(t4)
		local rock = new(t5)

		Test.Equals(life:Fly(), false)
		Test.Equals(mammal:Fly(), false)
		Test.Equals(human:Fly(), false)
		Test.Equals(bird:Fly(), true)
		assert(rock.Fly == nil)

		assert(not life.PlayGMod)
		assert(not mammal.PlayGMod)
		Test.Equals(human:PlayGMod(), true)
		assert(not bird.PlayGMod)
		assert(not rock.PlayGMod)

		Test.Equals(tostring(human), "HUMAN")
		assert(tostring(rock) ~= "HUMAN")
		assert(tostring(mammal) ~= "HUMAN")
		assert(tostring(life) ~= "HUMAN")
		assert(tostring(bird) ~= "HUMAN")

		-- Check IDs and OBJ functions.
		assert(human:GetId() ~= bird:GetId())
		Test.Equals(human:GetType(), t3)
		Test.Equals(bird:GetType(), t4)
		Test.Equals(human:GetBase(), t2.Prototype)
		Test.Equals(bird:GetBase(), t.Prototype)
		assert(bird:GetProperties().CanFly == true)

		-- Test strict typing
		rock:SetTestString("Hello")
		local succ, msg = pcall(rock.SetTestString, rock, 32)
		assert(not succ)
		assert(string.find(msg, "Property TestString expects String but got Number"))

		t5:GetPropertiesMap()["TestString"].Options.NoValidate = true
		rock:SetTestString(32)


		Type.Unregister(t)
		Type.Unregister(t2)
		Type.Unregister(t3)
		Type.Unregister(t4)
		Type.Unregister(t5)
	end)

	root:AddTest("Serialization", function ()
		-- Test the primitive types first
		Test.Equals(Type.Deserialize(Type.Serialize(32)), 32)
		Test.Equals(Type.Deserialize(Type.Serialize("Hello")), "Hello")
		Test.Equals(Type.Deserialize(Type.Serialize(true)), true)

		-- Now test a basic table
		local r = Type.Deserialize(Type.Serialize({
			Hello = "World",
			Number = 32,
			Bool = true,
			Table = {
				Hello = "World",
				Table2 = {
					A = 32
				}
			}
		}))
		Test.Equals(r.Hello, "World")
		Test.Equals(r.Number, 32)
		Test.Equals(r.Bool, true)
		Test.Equals(r.Table.Hello, "World")
		Test.Equals(r.Table.Table2.A, 32)

		local t = Type.Register("TestType")
		t:CreateProperty("Value")
		t:CreateProperty("Child")

		local i = new(t)
		i:SetValue(32)

		local i2 = new(t)
		i2:SetValue(40)
		i2:SetChild(i)
		r = Type.Deserialize(util.JSONToTable(util.TableToJSON(Type.Serialize(i2))))

		
		Test.Equals(r:GetType(), t)
		Test.Equals(r:GetChild():GetType(), t)

		Test.Equals(r:GetChild():GetValue(), 32)
		Test.Equals(r:GetValue(), 40)
		Test.Equals(r:GetId(), i2:GetId())--]]

		Type.Unregister(t)
	end)

	root:AddTest("Networking", function ()
		
		local t = Type.Register("TEST_OBJECT", nil)
		t:CreateProperty("Bool")
		t:CreateProperty("Number")
		t:CreateProperty("String")
		t:CreateProperty("Table")
		t:CreateProperty("Child")
		
		local obj = Type.New(t)
		obj:SetBool(true)
		obj:SetNumber(32)
		obj:SetString("Hello")
		obj:SetTable({ Hello = { Value = "World" } })
		obj:SetChild(obj)

		TEST_NET_PROMISE = Promise.Create()

		net.Start("Types.TestNetwork")
			net.WriteObject(obj)
		net.SendToServer()

		local r = TEST_NET_PROMISE:Await()

		Test.Equals(r:GetId(), obj:GetId())
		Test.Equals(r:GetBool(), true)
		Test.Equals(r:GetNumber(), 32)
		Test.Equals(r:GetString(), "Hello")
		Test.Equals(r:GetTable().Hello.Value, "World")
		Test.Equals(r:GetChild(), r)


		TEST_NET_PROMISE = nil		
		Type.Unregister(t)
		collectgarbage("collect")
	end)

	RPC.Register("Test.Types.Database", Realm.Server, function ()
		return Promise.Run(function ()
			assert(Database.hndl, "No database")

			Database.Query("DROP TABLE IF EXISTS `test_object`"):wait()
			Database.Tables["test_object"] = nil

			local t = Type.Register("TEST_OBJECT", nil, { Table = "test_object", PrimaryKey = "Id" })
			t:CreateProperty("String", Type.String)
			
			t:CreateDatabaseTable()
			
			local r = Database.Query("SHOW CREATE TABLE `test_object`"):Await()

			Test.Equals(r[1]["Create Table"], [[CREATE TABLE `test_object` (
  `Id` uuid DEFAULT NULL,
  `String` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci]])

			t:CreateProperty("Number", Type.Number)
			t:CreateProperty("Boolean", Type.Boolean)
			t:CreateProperty("Table", Type.Table)

 
			-- Tests ALTER
			t:CreateDatabaseTable()

			r = Database.Query("SHOW CREATE TABLE `test_object`"):Await()

			Test.Equals(r[1]["Create Table"], [[CREATE TABLE `test_object` (
  `Id` uuid DEFAULT NULL,
  `String` text DEFAULT NULL,
  `Number` double DEFAULT NULL,
  `Boolean` tinyint(1) DEFAULT NULL,
  `Table` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`Table`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci]])
			
			local i = new(t)
			i:SetString("Test")
			i:SetNumber(32)
			i:SetBoolean(true)
			i:SetTable({ Hello = "World" })

			i:Commit():Await()

			local i2 = new(t, i:GetId())
			i2:Refresh():Await()
			
			Test.Equals(i2:GetString(), "Test")
			Test.Equals(i2:GetNumber(), 32)
			Test.Equals(i2:GetBoolean(), true)
			Test.Equals(i2:GetTable().Hello, "World")			

			-- Update
			i:SetString("Test2")
			i:Commit():Await()

			i2:Refresh():Await()

			Test.Equals(i2:GetString(), "Test2")

			local i3 = t:Select(i:GetId())
			Test.Equals(#i3, 1)
			Test.Equals(i3[1]:GetString(), "Test2")

			i2:DeleteFromDatabase():Await()

			Test.Equals(Database.Query("SELECT COUNT(*) FROM `test_object`"):Await()[1]["COUNT(*)"], 0)

			Type.Unregister(t)
			collectgarbage("collect")
			return true
		end)
	end)

	Test.Register("Database", function ()
		
		local succ, msg = RPC.Call("Test.Types.Database"):Await()
		assert(succ, msg)
		
	end)
end)

if SERVER then
	util.AddNetworkString("Types.TestNetwork")
	net.Receive("Types.TestNetwork", function (len, ply)
		local t = Type.Register("TEST_OBJECT", nil)
		t:CreateProperty("Bool")
		t:CreateProperty("Number")
		t:CreateProperty("String")
		t:CreateProperty("Table")
		t:CreateProperty("Child")
		
		local obj = net.ReadObject()
		net.Start("Types.TestNetwork")
			net.WriteObject(obj)
		net.Send(ply)

		Type.ByName["Life"] = nil
		collectgarbage("collect")
	end)
else
	net.Receive("Types.TestNetwork", function (len)
		TEST_NET_PROMISE:Complete(net.ReadObject())
	end)
end