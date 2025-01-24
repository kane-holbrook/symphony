AddCSLuaFile()

Type = Type or {}
Type.Types = Type.Types or {}
Type.TypesByCode = Type.TypesByCode or weaktable(false, true)

Type.Instances = Type.Instances or weaktable(false, true)

local Type = Type
local Types = Type.Types
local TypesByCode = Type.TypesByCode
local Instances = Type.Instances

local Type_MT = getmetatable(Type) or {}
Type_MT.__index = Type.Types
setmetatable(Type, Type_MT)


local TYPE = Types.Type or {}
do
	-- Tested
	function TYPE:GetCode()
		return self.Code
	end

	-- Tested
	function TYPE:GetName()
		return self.Name
	end

	function TYPE:GetSuper()
		return self.Super
	end

	-- Tested
	function TYPE:GetInstances()
		return self.Instances
	end

	function TYPE:GetDerivatives()
		return self.Derivatives
	end

	function TYPE:GetPrototype()
		return self.Prototype
	end

	-- Tested
	function TYPE:CreateProperty(name, type, default, options)
		self.Properties = self.Properties or {}
		self.Properties[name] = {
			Name = name,
			Type = type,
			Default = default,
			Options = options
		}

		self.Prototype["Set" .. name] = function (i, value)
			if type then
				assert(sym.IsType(value, type))
			end

			i[name] = value
		end

		self.Prototype["Get" .. name] = function (i)
			return i[name] or self.Properties[name].Default
		end
	end

	function TYPE:GetProperties()
		return self.Properties
	end

	-- Tested
	function TYPE:__tostring()
		print(getmetatable(self))
		return "Type[" .. self:GetName() .. "]"
	end

	TYPE.Code = 256
	TYPE.Name = "Type"
	TYPE.Instances = TYPE.Instances or {}
	TYPE.Derivatives = TYPE.Derivatives or {}
	
	TYPE.Properties = TYPE.Properties or {}
	table.Empty(TYPE.Properties)
	
	TYPE.Prototype = TYPE.Prototype or {}
	table.Empty(TYPE.Prototype)	
	
	TYPE.Meta = TYPE.Meta or {}
	table.Empty(TYPE.Meta)

	TYPE.Meta.__index = TYPE.Prototype
	function TYPE.Meta:__tostring()
		return self:GetType():GetName() .. "[" .. self:GetId() .. "]"
	end
	
	TYPE.__index = TYPE
	function TYPE:__tostring() 
		return "Type[" .. self:GetName() .. "]"
	end

	TypesByCode[TYPE.Code] = TYPE

	setmetatable(TYPE, {
		__tostring = function ()
			return "Type[Type]"
		end
	})
end
Type.Types.Type = TYPE

local OBJ = Type.Types.Type.Prototype
do
	function OBJ:GetId()
		local mt = getmetatable(self)
		return mt.Id
	end

	function OBJ:GetType()
		local mt = getmetatable(self)
		return mt.Type
	end
end

-- Type statics
do
	function Type.Register(name, super, persist)
		super = super or TYPE

		-- We reuse table references to handle Lua refreshes elegantly.
		local t = Types[name] or {}
		t.Code = 257 + util.CRC(name)
		t.Name = name
		t.Super = super
		t.Instances = t.Instances or {}
		t.Derivatives = t.Derivatives or {}

		t.Prototype = t.Prototype or {}
		table.Empty(t.Prototype)
		setmetatable(t.Prototype, { __index = super.Prototype })

		t.Meta = t.Meta or {}
		table.Empty(t.Meta)
		table.Merge(t.Meta, super.Meta)

		-- We need to go through all instances and derivatives to make sure 
		-- their Meta and Proto points at the right place.

		super.Derivatives[name] = t
		Types[name] = setmetatable(t, TYPE)
		TypesByCode[t.Code] = t

		return t
	end

	function Type.GetTypes()
		return Types
	end

	-- Tested
	function Type.GetTypeByName(name)
		return Types[name]
	end

	-- Tested
	function Type.GetTypeByCode(code)
		return TypesByCode[code]
	end

	function Type.GetObject(uuid)
		return Instances[uuid]
	end

	function Type.GetInstances()
		return Instances
	end

	function Type.New(type, id)
		local t = {}
		local mt = table.Copy(type.Meta)
		mt.Id = id or uuid()
		mt.Type = type
		mt.__index = mt

		setmetatable(mt, { __index = type.Prototype })
		setmetatable(t, mt)

		if t.Init then
			t:Init()
		end

		Instances[mt.Id] = t

		return t
	end


	function Type.GetType(t)
	end

	function Type.Is(tgt, type)
	end

	function Type.IsDerived(tgt, type)
	end
end

-- Primitives
do
	function Type.IsPrimitive(t)
	end
end

-- Testing
hook.Add("Sym:RegisterTests", "sym:sh_types.lua", function ()
	local root = Test.Register("Type")

	root:AddTest("Register", function ()
		local t = Type.Register("TestType")

		assert(t:GetCode() > 256)
		Test.Equals(t:GetName(), "TestType")
		Test.Equals(t:GetSuper(), TYPE)
		Test.Equals(tostring(t), "Type[TestType]")

		local t2 = Type.Register("TestType2", t)
		assert(t2:GetCode() > 256)
		Test.Equals(t2:GetName(), "TestType2")
		Test.Equals(t2:GetSuper(), t)
		Test.Equals(tostring(t2), "Type[TestType2]")

		local t3 = Type.Register("TestType3", t2)
		assert(t3:GetCode() > 256)
		Test.Equals(t3:GetName(), "TestType3")
		Test.Equals(t3:GetSuper(), t2)
		Test.Equals(tostring(t3), "Type[TestType3]")

		local t4 = Type.Register("TestType4", t)
		assert(t4:GetCode() > 256)
		Test.Equals(t4:GetName(), "TestType4")
		Test.Equals(t4:GetSuper(), t)
		Test.Equals(tostring(t4), "Type[TestType4]")

		Type.Types["TestType"] = nil
		Type.Types["TestType2"] = nil
		Type.Types["TestType3"] = nil
		Type.Types["TestType4"] = nil

		return true
	end)

	root:AddTest("GetTypes", function ()
		local t = Type.Register("TestType")

		assert(Type.GetTypes()["TestType"] == t)
	end)

	root:AddTest("GetTypeByName", function ()
		local t = Type.Register("TestType")

		assert(Type.GetTypeByName("TestType") == t)

		Type.Types["TestType"] = nil
		Type.Types["TestType2"] = nil
		Type.Types["TestType3"] = nil
		Type.Types["TestType4"] = nil
	end)

	root:AddTest("GetTypeByCode", function ()
		local t = Type.Register("TestType")

		assert(Type.GetTypeByCode(t:GetCode()) == t)

		Type.Types["TestType"] = nil
		Type.Types["TestType2"] = nil
		Type.Types["TestType3"] = nil
		Type.Types["TestType4"] = nil
	end)

	root:AddTest("__gc", function ()
		collectgarbage("collect")

		local numTypes = table.Count(Type.Types)
		local numTypesByCode = table.Count(Type.TypesByCode)

		local t = Type.Register("TestType")

		assert(Type.GetTypeByCode(t:GetCode()) == t)

		Type.Types["TestType"] = nil
		collectgarbage("collect")
		
		Test.Equals(table.Count(Type.Types), numTypes)
		Test.Equals(table.Count(Type.TypesByCode), numTypesByCode)
	end)
	

	local inst = root:AddTest("New", function ()
		local t = Type.Register("TestType")
		function t.Prototype:DoStuff()
			return "Stuff"
		end
		t:CreateProperty("Name", Type.String, "Test")
		
		local t2 = Type.Register("TestType2", t)
		function t2.Prototype:DoStuff()
			return "Stuff2"
		end
		t2:CreateProperty("Name2", Type.String, "Test A")

		local t3 = Type.Register("TestType3", t)
		local t4 = Type.Register("TestType4")

		local i = Type.New(t)
		Test.Equals(i:DoStuff(), "Stuff")
		Test.Equals(i:GetName(), "Test")
		i:SetName("Test 2")
		Test.Equals(i:GetName(), "Test 2")
		assert(not i.GetName2)

		local i2 = Type.New(t2)
		Test.Equals(i2:DoStuff(), "Stuff2")
		Test.Equals(i2:GetName(), "Test")
		Test.Equals(i2:GetName2(), "Test A")

		local i3 = Type.New(t3)
		Test.Equals(i3:DoStuff(), "Stuff")

		local i4 = Type.New(t4)
		assert(not i4.DoStuff)

		Type.Types["TestType"] = nil

	end)
	
	inst:AddTest("Properties", function ()
		local t = Type.Register("TestType")
		t:CreateProperty("Name", Type.String, "Test")
		local t2 = Type.Register("TestType2", t)
		t2:CreateProperty("Name2", Type.String, "Test A")
		local t3 = Type.Register("TestType3", t2)
		local t4 = Type.Register("TestType4")

		local i = Type.New(t)
		Test.Equals(i:GetName(), "Test")
		i:SetName("Test 2")
		Test.Equals(i:GetName(), "Test 2")
		assert(not i.GetName2)

		local i2 = Type.New(t2)
		Test.Equals(i2:GetName(), "Test")
		Test.Equals(i2:GetName2(), "Test A")

		local i3 = Type.New(t3)
		Test.Equals(i3:GetName(), "Test")
		Test.Equals(i3:GetName2(), "Test A")

		local i4 = Type.New(t4)
		assert(not i4.GetName)

		Type.Types["TestType"] = nil
		Type.Types["TestType2"] = nil
		Type.Types["TestType3"] = nil
		Type.Types["TestType4"] = nil
	end)

	inst:AddTest("Metamethods", function ()
		return "TODO"
	end)

	inst:AddTest("GetId", function ()
		return "TODO"
	end)
	
	inst:AddTest("GetType", function ()
		return "TODO"
	end)

	inst:AddTest("Init", function ()
		return "TODO"
	end)

	inst:AddTest("__gc", function ()
		return "TODO"
	end)

	root:AddTest("Refreshes", function ()
		local t = Type.Register("TestType")

		assert(Type.GetTypeByCode(t:GetCode()) == t)

		Type.Types["TestType"] = nil
		Type.Types["TestType2"] = nil
		Type.Types["TestType3"] = nil
		Type.Types["TestType4"] = nil
	end)
	
	
	-- Registration X
	-- Instantiation X
	-- Properties X
	-- Metamethods X
	-- Inheritance X
	-- Performance
	-- Garbage collection X
	-- Lua Refreshes X
	-- Primitives
	-- Encoding/decoding
	-- Networking
	-- Database
	-- Parenting
	  -- Entity
	  -- Type
	-- Events and lifecycles
end)

_G.new = Type.New