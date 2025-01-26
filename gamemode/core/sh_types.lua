Type = Type or {}
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

	-- @test Type.Register
	function TYPE:__tostring()
		return "Type[" .. self.Name .. "]"
	end

	TYPE.Ancestry = {} -- @test Type.Register

	-- Properties
	TYPE.Properties = {} -- @test Type.Register
	TYPE.PropertiesByName = weaktable(false, true) -- Effectively a cache. -- @test Type.Register

	-- @test Type.Register
	function TYPE:CreateProperty(name, type, options)
		local prop = {
			Name = name,
			Type = type,
			Options = options
		}

		self.Prototype["Set" .. name] = function (self, value)
			self:SetProperty(name, value)
		end

		self.Prototype["Get" .. name] = function (self)
			return self:GetProperty(name)
		end

		table.insert(self.Properties, prop)
		self.PropertiesByName[name] = prop
	end

	function TYPE:GetProperties()
		local props = tablex.ShallowCopy(self.Properties)
		local super = self:GetSuper()
		if super then
			table.Merge(props, self:GetSuper():GetProperties())
		end
		return props
	end

	function TYPE:GetPropertiesMap()
		local props = tablex.ShallowCopy(self.PropertiesByName)
		local super = self:GetSuper()
		if super then
			table.Merge(props, self:GetSuper():GetPropertiesMap())
		end
		return props
	end

	-- Prototype
	TYPE.Prototype = {}
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
	function TYPE:GetDerivatives()
		return self.Derivatives
	end

	TYPE.Options = {}
	function TYPE:GetOptions()
		return self.Options
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
		base()
	end

	-- Single threaded so this isn't a problem
	local base__Name
	local base__Source
	local base__Next
	local base__Args

	-- @test Type.New
	function base(name, ...)
		name = name or base__Name
		
		local src = base__Source
		
		assert(name, "base() called without a name")
		assert(src, "base() called without a source")
		assert(base__Next, "base() called without a next")

		base__Next = base__Next:GetBase()

		if not base__Next then
			base__Name = nil
			base__Source = nil
			base__Args = nil
		elseif base__Next[name] then
			base__Next[name](src, unpack(base__Args))
		end
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
		local old = self[name]
		self:Invoke("OnPropertyChanged", name, value, old)
		self[name] = value
	end

	function OBJ:GetProperty(name)
		return self[name]
	end

	-- @test Type.New
	function OBJ:Invoke(event, ...)
		if self[event] then
			base__Name = event
			base__Source = self
			base__Next = self
			base__Args = {...}

			self[event](self, self, ...)
			
			base__Name = nil
			base__Source = self
			base__Next = nil
			base__Args = nil
		end
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

	function OBJ:Serialize()
		local out = self:GetProperties()
		return out
	end

	function OBJ:Deserialize(data)
		for k, v in pairs(data) do
			self:SetProperty(k, v)
		end
	end
end

-- Statics
do
	-- @test Type.Register
	function Type.Register(name, super, options)
		super = super or Type.Type

		local t = Type.ByName[name]
		if not t then
			t = {}
			t.Code = 256 + util.CRC(name) -- This is the unique int32 code used in networking etc.
			assert(not Type.ByCode[t.Code], "Type code collision: " .. name)
		end

		t.Name = name
		t.Super = super
		t.Properties = setmetatable({}, { __index = super.Properties })
		t.PropertiesByName = setmetatable({}, { __index = super.PropertiesByName })
		t.Prototype = setmetatable({}, { __index = super.Prototype })
		t.Metamethods = table.Copy(super.Metamethods)
		t.Derivatives = {}
		t.Instances = {}
		t.InstanceCount = 0
		t.Options = setmetatable(options or {}, { __index = super.Options })

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

		return t
	end

	-- @test Type.Register
	function Type.GetByName(name)
		return Type.ByName[name]
	end

	-- @test Type.Register
	function Type.GetByCode(code)
		return Type.ByCode[code]
	end

	function Type.Is(obj, type)		
		if not istable(obj) then
			return false
		end

		if obj.Id then
			obj = obj:GetType()
		end		

		if not obj.Ancestry then
			return false
		end

		return obj == type 
	end
	Is = Type.Is

	function Type.IsObject(obj)
		return Type.IsDerived(obj, TYPE)
	end
	IsObject = Type.IsObject

	-- @test Type.Register
	function Type.IsDerived(obj, super)
		if not istable(obj) then
			return false
		end

		if obj.Id then
			obj = obj:GetType()
		end

		if not obj.Ancestry then
			return false
		end
		
		if obj == super then
			return true
		end

		return obj.Ancestry[super] == true
	end

	-- @test Type.New
	function Type.New(type, id)
		assert(type, "Must provide a type to Type.New")

		local t = {}
		local mt = table.Copy(type.Metamethods)

		mt.Id = id or uuid()
		mt.Type = type

		local super = type:GetSuper()
		mt.Base = super.Prototype

		mt.__index = mt -- The object should point at this metatable (so the object itself can remain clean).
		setmetatable(mt, { __index = type.Prototype }) -- However, if keys aren't found on the MT, they should be pulled from the proto.
		setmetatable(t, mt)

		type.InstanceCount = type.InstanceCount + 1
		type.Instances[type.InstanceCount] = t

		t:Invoke("Initialize")
		return t
	end
	new = Type.New

	function Type.Serialize(data, root)
		-- Effectively this just parses data, calling encode where necessary on objects, which call this
		-- recursively.

		if not root then
			-- If we're the root element (i.e. the first call), we need to create a root object.
			root = {}
			root.map = {}
			root.items = {}
			root.num = 0
			root.firstType, root.first = Type.Serialize(data, root)
			root.map = nil
			root.num = nil
			return root
		end
		
		local typeId = TypeID(data)
		if typeId == TYPE_TABLE then

			local e = root.map[data]
			if root.map[data] then
				return TYPE_TABLE, e
			end

			local t = {}
			if Type.IsObject(data) then
				for k, v in pairs(data:Serialize()) do
					t[k] = { Type.Serialize(v, root) }
				end
				t.Id = { TYPE_STRING, data:GetId() }

				typeId = data:GetType():GetCode()
			else
				for k, v in pairs(data) do
					t[k] = { Type.Serialize(v, root) }
				end
			end

			root.num = root.num + 1
			local id = root.num
			root.map[data] = id
			root.items[id] = t
			
			return typeId, id
		else
			return typeId, data
		end
	end

	function Type.Deserialize(data, root)		
		if not root then
			root = {}
			root.map = {}
			root.items = data.items
			root.first = data.first
			root.firstType = data.firstType

			return Type.Deserialize({root.firstType, root.first}, root)
		else
			local typeId = data[1]
			if typeId == TYPE_TABLE or typeId >= 256 then
				local t = {}
				local k = data[2]
				local val = root.items[k]
				
				for k, v in pairs(val) do
					t[k] = Type.Deserialize(v, root)
				end

				if typeId >= 256 then
					local id = t.Id
					t.Id = nil

					local o = Type.New(Type.GetByCode(typeId), id)
					o:Deserialize(t)
					return o
				else
					return t
				end
			else
				return data[2]
			end
		end
	end

	function net.WriteObject(obj, ply)
		net.WriteTable(Type.Serialize(obj, ply))
	end

	function net.ReadObject()
		return Type.Deserialize(net.ReadTable())
	end
end


-- The tests for sh_types.lua are in sh_tests.lua.