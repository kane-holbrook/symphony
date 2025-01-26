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

	function OBJ:Encode()
		local out = self:GetProperties()
		return out
	end
end

-- Statics
do
	-- @test Type.Register
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
		t.InstanceCount = 0

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
	end

	-- @test Type.Register
	function Type.IsDerived(type, super)
		return type.Ancestry[super] == true
	end

	-- @test Type.New
	function Type.New(type, ...)
		local t = {}
		local mt = table.Copy(type.Metamethods)

		mt.Id = uuid()
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
end

-- Primitives
do
	local PROXY = Type.Register("Proxy")
	PROXY:CreateProperty("Value")
	PROXY.Prototype.Set = PROXY.Prototype.SetValue
	PROXY.Prototype.Get = PROXY.Prototype.GetValue

	local PRIMITIVE = Type.Register("Primitive", PROXY)
	
	local STRING = Type.Register("String", PRIMITIVE)
	Type.Primitives[TYPE_STRING] = STRING

	local NUMBER = Type.Register("Number", PRIMITIVE)
	Type.Primitives[TYPE_NUMBER] = NUMBER

	local BOOLEAN = Type.Register("Boolean", PRIMITIVE)
	Type.Primitives[TYPE_BOOL] = BOOLEAN

	local TABLE = Type.Register("Table", PRIMITIVE)
	Type.Primitives[TYPE_TABLE] = TABLE

	local ENTITY = Type.Register("Entity", PRIMITIVE)
	Type.Primitives[TYPE_ENTITY] = ENTITY

	local VECTOR = Type.Register("Vector", PRIMITIVE)
	Type.Primitives[TYPE_VECTOR] = VECTOR

	local ANGLE = Type.Register("Angle", PRIMITIVE)
	Type.Primitives[TYPE_ANGLE] = ANGLE

	local COLOR = Type.Register("Color", PRIMITIVE)
	Type.Primitives[TYPE_COLOR] = COLOR

	local FUNCTION = Type.Register("Function", PRIMITIVE)
	Type.Primitives[TYPE_FUNCTION] = FUNCTION

	local PLAYER = Type.Register("Player", PRIMITIVE)
	Type.Primitives[TYPE_PLAYER] = PLAYER

	local MATRIX = Type.Register("Matrix", PRIMITIVE)
	Type.Primitives[TYPE_MATRIX] = MATRIX

end

-- Unit testing
hook.Add("Sym:RegisterTests", "sym/sh_types.lua", function ()

	local root = Test.Register("Type")
	root:AddTest("Registration", function()
		local t = Type.Register("TestType")
		Test.Equals(t:GetName(), "TestType")
		Test.Equals(t:GetCode(), 3784073340)
		Test.Equals(t:GetSuper(), Type.Type)
		assert(Type.ByName["TestType"] == t, "Type not registered in ByName")
		assert(Type.ByCode[t:GetCode()] == t, "Type not registered in ByCode")
		assert(Type.IsDerived(t, Type.Type), "Type not derived from Type")
		local code = t:GetCode()
		t = nil
		Type.ByName["TestType"] = nil
		collectgarbage("collect")
		assert(not Type.ByCode[code], "Type not __gc'd in ByCode")
	end)

	root:AddTest("Instantiation", function ()
		local t = Type.Register("Life")
		t:CreateProperty("CanFly")

		function t.Prototype:Fly()
			return self:GetCanFly() or false
		end

		local t2 = Type.Register("Mammal", t)

		local t3 = Type.Register("Human", t2)
		function t3.Prototype:PlayGMod()
			return true
		end

		function t3.Metamethods:__tostring()
			return "HUMAN"
		end

		local t4 = Type.Register("Bird", t)
		function t4.Prototype:Initialize()
			base()
			self:SetCanFly(true)
		end

		local t5 = Type.Register("Rock")

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

		Type.ByName["Life"] = nil
		Type.ByName["Mammal"] = nil
		Type.ByName["Human"] = nil
		Type.ByName["Bird"] = nil

		-- Check IDs and OBJ functions.
		assert(human:GetId() ~= bird:GetId())
		Test.Equals(human:GetType(), t3)
		Test.Equals(bird:GetType(), t4)
		Test.Equals(human:GetBase(), t2.Prototype)
		Test.Equals(bird:GetBase(), t.Prototype)
		assert(bird:GetProperties().CanFly == true)
	end)
end)

--[[
	TODO:
	1. Make sure that Types inherit from one another properly. ✔️
	2. Make sure that instances inherit from Type.Prototype ✔️
	3. Make sure that instances inherit their metamethods from Type.Metamethods ✔️
	4. Make sure that instances are physically empty. ✔️
	5. Make sure that instances have a unique ID. ✔️
	6. Make sure that instances inherit their properties from Type.Properties. ✔️
]]