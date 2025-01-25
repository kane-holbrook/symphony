Type = Type or {}
Type.ByName = {}
Type.ByCode = weaktable(false, true)
Type.Instances = weaktable(false, true)

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

	function TYPE:GetCode()
		return self.Code
	end

	function TYPE:GetName()
		return self.Name
	end

	function TYPE:GetSuper()
		return self.Super
	end

	function TYPE:__tostring()
		return "Type[" .. self.Name .. "]"
	end

	TYPE.Ancestry = {}

	-- Properties
	TYPE.Properties = {}
	TYPE.PropertiesByName = weaktable(false, true) -- Effectively a cache.

	function TYPE:CreateProperty(name, type, options)
		local prop = {
			Name = name,
			Type = type,
			Options = options
		}

		self.Prototype["Set" .. name] = function(self, value)
			local old = self[name]
			self:Invoke("PropertyChanged", name, value, old)
			self[name] = value
		end

		self.Prototype["Get" .. name] = function(self)
			return self[name]
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
	function TYPE:GetPrototype()
		return self.Prototype
	end

	-- Metamethods for the PROTOTYPE.
	TYPE.Metamethods = {}
	function TYPE.Metamethods:__tostring()
		return self:GetType():GetName() .. "[" .. self:GetId() .. "]"
	end

	TYPE.Instances = weaktable(false, true)
	TYPE.InstanceCount = 0
	function TYPE:GetInstances()
		return self.Instances
	end

	function TYPE:GetNumInstances()
		return self.InstanceCount
	end
	
	TYPE.Derivatives = weaktable(false, true)
	function TYPE:GetDerivatives()
		return self.Derivatives
	end

	-- Registering us
	Type.ByName.Type = TYPE
	Type.ByCode[TYPE.Code] = TYPE

	setmetatable(TYPE, { __tostring = TYPE.__tostring })
end

local function Propagate(t, method, ...)
	print("Propagate", t, method, ...)
end

-- Base Object
local OBJ = TYPE.Prototype
do
	function OBJ:Initialize()
		base()
	end

	-- Single threaded so this isn't a problem
	local base__Name
	local base__Source
	local base__Next
	local base__Args

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

	function OBJ:GetId()
		local mt = getmetatable(self)
		return mt.Id
	end

	function OBJ:GetType()
		local mt = getmetatable(self)
		return mt.Type
	end

	function OBJ:GetBase()
		local mt = getmetatable(self)
		return self.Base
	end

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
end

-- Statics
do
	function Type.Register(name, super)
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
		t.NumInstances = 0

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

	function Type.GetByName(name)
		return Type.ByName[name]
	end

	function Type.GetByCode(code)
		return Type.ByCode[code]
	end

	function Type.Is(obj, type)
	end

	function Type.IsDerived(type, super)
		return type.Ancestry[super] == true
	end

	function Type.New(type, ...)
		local t = {}
		local mt = table.Copy(type.Metamethods)

		--mt.Id = uuid()
		mt.Type = type

		local super = type:GetSuper()
		mt.Base = super.Prototype

		mt.__index = mt -- The object should point at this metatable (so the object itself can remain clean).
		setmetatable(mt, { __index = type.Prototype }) -- However, if keys aren't found on the MT, they should be pulled from the proto.
		setmetatable(t, mt)

		type.NumInstances = type.NumInstances + 1
		type.Instances[type.NumInstances] = t

		t:Invoke("Initialize")
		return t
	end
end


-- Testing
Test = Type.Register("Test")
Test:CreateProperty("TestProperty")

function Test.Prototype:Initialize()
end

Test2 = Type.Register("Test2", Test)
function Test2.Prototype:Initialize()
end

Inst = Type.New(Test2)

--[[
	TODO:
	1. Make sure that Types inherit from one another properly. ✔️
	2. Make sure that instances inherit from Type.Prototype ✔️
	3. Make sure that instances inherit their metamethods from Type.Metamethods ✔️
	4. Make sure that instances are physically empty. ✔️
	5. Make sure that instances have a unique ID. ✔️
	6. Make sure that instances inherit their properties from Type.Properties. ✔️

	7. Add a method to remove properties from a type.
	8. Add a method to remove instances of a type.
	9. Add a method to check if an instance has a specific property.
	10. Add a method to clone an instance.
	11. Add a method to serialize and deserialize instances.
	12. Add a method to compare two instances of the same type.
	13. Add a method to get the ancestry of a type.
	14. Add a method to get all derivatives of a type.
	15. Add a method to get the number of derivatives of a type.
	16. Add a method to get the number of properties of a type.
	17. Add a method to get the number of instances of a type.
	18. Add a method to get the number of properties of an instance.
	19. Add a method to get the number of derivatives of an instance.
	20. Add a method to get the number of properties of a type including inherited properties.
	21. Add a method to get the number of derivatives of a type including inherited derivatives.
	22. Add a method to get the number of instances of a type including inherited instances.
	23. Add a method to get the number of properties of an instance including inherited properties.
	24. Add a method to get the number of derivatives of an instance including inherited derivatives.
	25. Add a method to get the number of instances of a type including inherited instances.
]]