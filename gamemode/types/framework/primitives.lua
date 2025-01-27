AddCSLuaFile()

local PRIMITIVE = Type.Register("Primitive", Type.Proxy)
	
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

local MATRIX = Type.Register("Matrix", PRIMITIVE)
Type.Primitives[TYPE_MATRIX] = MATRIX

function FromPrimitive(obj)
    local t = Type.Primitives[TypeID(obj)]
    assert(t, "Object is not a primitive.")
    
    local o = Type.New(t)
    o:SetValue(obj)
    return o
end

function ToPrimitive(obj)
    assert(IsPrimitive(obj), "Object is not a primitive.")
    return obj:GetValue()
end

function IsPrimitive(obj)
    if not obj or not obj.GetType then
        return false
    end
    return Type.IsDerived(obj:GetType(), PRIMITIVE)
end


hook.Add("Test.Register", "Primitives", function ()
    Test.Register("Primitives", function ()
        local num = Type.New(Type.Primitives[TYPE_NUMBER])
        num:SetValue(123)
        Test.Equals(num:GetValue(), 123)
        Test.Equals(tostring(num), "Proxy[123]")

        local str = Type.New(Type.Primitives[TYPE_STRING])
        str:SetValue("Hello")
        Test.Equals(str:GetValue(), "Hello")
        Test.Equals(tostring(str), "Proxy[\"Hello\"]")

        local bool = Type.New(Type.Primitives[TYPE_BOOL])
        bool:SetValue(true)
        Test.Equals(bool:GetValue(), true)
        Test.Equals(tostring(bool), "Proxy[true]")

        Test.Equals(IsPrimitive(num), true)
        Test.Equals(IsPrimitive(str), true)
        Test.Equals(IsPrimitive(bool), true)

        local x = FromPrimitive(32)
        Test.Equals(x:GetValue(), 32)
        Test.Equals(x:GetType(), Type.Primitives[TYPE_NUMBER])
    end)
end)