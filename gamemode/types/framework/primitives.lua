AddCSLuaFile()

local PRIMITIVE = Type.Register("Primitive")
local Deref = false

function PRIMITIVE:Serialize(data, ply, root)
    return data
end

function PRIMITIVE:Deserialize(data)
    return data
end

function PRIMITIVE:GetValue()
    return istable(self) and self.Value or self
end


local function PopulateMetaTable(mt, type)
    mt.GetType = function() return type end
    mt.GetCode = function() return type.Code end
end

local function GenerateIndexer(t)
    return function(self, key)
        local v = t[key]
        if v then
            return v
        end

        if Deref then
            return nil
        end

        error("Attempt to index a " .. type(self) .. " value (" .. tostring(key) .. ").", 2)
    end
end
function deref(f)
    Deref = true
    local out = { f() }
    Deref = false
    return unpack(out)
end

local STRING = Type.Register("String", PRIMITIVE, { Code = TYPE_STRING, DatabaseType = "TEXT" })
function STRING:Parse(value)
    return tostring(value)
end

function STRING:DatabaseEncode(value)
    return string.format("%q", value)
end

function STRING:DatabaseDecode(value)
    return value
end
PopulateMetaTable(string, STRING)


local NUMBER = Type.Register("Number", PRIMITIVE, { Code = TYPE_NUMBER, DatabaseType = "DOUBLE" })
function NUMBER:Parse(value)
    return tonumber(value)
end

function NUMBER:DatabaseEncode(value)
    return tostring(value)
end

function NUMBER:DatabaseDecode(value)
    return tonumber(value)
end
debug.setmetatable(32, { __index = GenerateIndexer(NUMBER.Prototype), Type = NUMBER })


local FUNCTION = Type.Register("Function", PRIMITIVE, {
    Code = TYPE_FUNCTION
})

function FUNCTION:Parse(value)
    return error("Can't parse a function from a string")
end

function FUNCTION:DatabaseEncode(value)
    return error("Cannot encode a function")
end

function FUNCTION:DatabaseDecode(value)
    return error("Cannot decode a function")
end

debug.setmetatable(debug.setmetatable, {
    __index = GenerateIndexer(FUNCTION.Prototype),
    Type = FUNCTION
})

local BOOLEAN = Type.Register("Boolean", PRIMITIVE, { Code = TYPE_BOOL, DatabaseType = "BOOLEAN" })
function BOOLEAN:Parse(value)
    
    if isbool(value) then
        return value
    end

    value = string.lower(value)
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    end

    return nil
end

function BOOLEAN:DatabaseEncode(value)
    return value and "true" or "false"
end

function BOOLEAN:DatabaseDecode(value)
    return value == 1
end
debug.setmetatable(true, { __index = GenerateIndexer(BOOLEAN.Prototype), Type = BOOLEAN })


local NIL = Type.Register("Nil", PRIMITIVE, { Code = TYPE_NIL })
function NIL:Parse(value)
    return nil
end

function NIL:DatabaseEncode(value)
    return "NULL"
end

function NIL:DatabaseDecode(value)
    return nil
end
debug.setmetatable(nil, { __index = GenerateIndexer(NIL.Prototype), Type = NIL })


local ENTITY = Type.Register("Entity", PRIMITIVE, { Code = TYPE_ENTITY })
PopulateMetaTable(FindMetaTable("Entity"), ENTITY)


local VECTOR = Type.Register("Vector", PRIMITIVE, { Code = TYPE_VECTOR, DatabaseType = "CHAR(16)" })
function VECTOR:Parse(value)
    if istable(value) then
        return value
    end

    local x, y, z = string.match(value, "%(([%d%.]+),%s*([%d%.]+),%s*([%d%.]+)%)")
    return Vector(tonumber(x), tonumber(y), tonumber(z))
end

function VECTOR:DatabaseEncode(value)
    return string.format("\"(%.2f,%.2f,%.2f)\"", value.x, value.y, value.z)
end

function VECTOR:DatabaseDecode(value)
    return Vector:Parse(value)
end
PopulateMetaTable(FindMetaTable("Vector"), VECTOR)


local ANGLE = Type.Register("Angle", PRIMITIVE, { Code = TYPE_ANGLE, DatabaseType = "CHAR(16)" })
function ANGLE:Parse(value)
    if istable(value) then
        return value
    end

    local p, y, r = string.match(value, "%(([%d%.]+),%s*([%d%.]+),%s*([%d%.]+)%)")
    return Angle(tonumber(p), tonumber(y), tonumber(r))
end

function ANGLE:DatabaseEncode(value)
    return string.format("\"(%.2f,%.2f,%.2f)\"", value.p, value.y, value.r)
end

function ANGLE:DatabaseDecode(value)
    return Angle:Parse(value)
end
PopulateMetaTable(FindMetaTable("Angle"), ANGLE)


local COLOR = Type.Register("Color", PRIMITIVE, { Code = TYPE_COLOR, DatabaseType = "CHAR(16)" })
function COLOR:Parse(value)
    if istable(value) then
        return value
    end

    if value == nil then
        return color_transparent
    end

    local h = colorex.GetByName(value)
    if h then
        return h
    end
    
    h = colorex.FromHex(value)
    if h then
        return h
    end

    local r, g, b, a = string.match(string.Replace(string.Replace(value, ",", " "), "  ", " "), "(%d+) %s*(%d+) %s*(%d+) %s*(%d+)")
    r = tonumber(r)
    g = tonumber(g)
    b = tonumber(b)
    a = tonumber(a) or 255

    assert(r, "Failed to parse color r value from " .. value)
    assert(g, "Failed to parse color g value from " .. value)
    assert(b, "Failed to parse color b value from " .. value)
    assert(a, "Failed to parse color a value from " .. value)

    return Color(r, g, b, a)
end

function COLOR:DatabaseEncode(value)
    return string.format("\"%d %d %d %d\"", value.r, value.g, value.b, value.a)
end

function COLOR:DatabaseDecode(value)
    return Color:Parse(value)
end
PopulateMetaTable(FindMetaTable("Color"), COLOR)


local MATRIX = Type.Register("Matrix", PRIMITIVE, { Code = TYPE_MATRIX, DatabaseType = "JSON" })
function MATRIX:Parse(value)
    if ismatrix(value) then
        return value
    end

    return Matrix(util.JSONToTable(value))
end

function MATRIX:DatabaseEncode(value)
    return string.format("%q", util.TableToJSON(value:ToTable()))
end

function MATRIX:DatabaseDecode(value)
    return Matrix:Parse(value)
end
PopulateMetaTable(FindMetaTable("VMatrix"), MATRIX)


local TABLE = Type.Register("Table", nil, { Code = TYPE_TABLE, DatabaseType = "JSON" })

function TABLE:Serialize(value, ply, root)
    return value
end

function TABLE:Deserialize(obj, data)
    for k, v in pairs(data) do
        obj[k] = v
    end
end

function TABLE:Parse(value)
    if istable(value) then 
        return value
    end

    return util.JSONToTable(value)
end



local MATERIAL = Type.Register("Material", PRIMITIVE, { Code = TYPE_MATERIAL })
function MATERIAL:Parse(value)
    if not isstring(value) then
        return value
    end

    return Material(value, "mips smooth noclamp")
end

function MATERIAL:DatabaseEncode(value)
    return string.format("%q", value:GetName())
end

function MATERIAL:DatabaseDecode(value)
    return Material:Parse(value)
end
PopulateMetaTable(FindMetaTable("IMaterial"), MATERIAL)



local CALLABLE = Type.Register("Callable")
CALLABLE:CreateProperty("Function")

function CALLABLE.Metamethods:__call(...)
    return self:GetFunction()(...)
end

function CALLABLE.Metamethods:__tostring()
    return "Callable[" .. tostring(self:GetFunction()) .. "]"
end

function wrapfunc(f)
    if istable(f) then
        return f
    end

    local c = Type.New(CALLABLE)
    c:SetFunction(f)
    return c
end

function iscallable(obj)
    if isfunction(obj) then
        return true
    elseif istable(obj) then
        return getmetatable(obj).__call ~= nil
    else
        return false
    end
end


function Type.IsPrimitive(obj, allowNil)
    if (not allowNil and not obj) or not obj.GetType then
        return false
    end
    return Type.Is(obj:GetType(), PRIMITIVE)
end
IsPrimitive = Type.IsPrimitive


hook.Add("Test.Register", "Primitives", function ()
    Test.Register("Primitives", function ()
        Test.Equals(("a"):GetType(), STRING)
        Test.Equals((1):GetType(), NUMBER)
        Test.Equals((true):GetType(), BOOLEAN)
        Test.Equals((nil):GetType(), NIL)
        Test.Equals(Entity(1):GetType(), ENTITY)
        Test.Equals(Vector(1, 2, 3):GetType(), VECTOR)
        Test.Equals(Angle(1, 2, 3):GetType(), ANGLE)
        Test.Equals(Color(1, 2, 3):GetType(), COLOR)
        Test.Equals(Matrix():GetType(), MATRIX)

        Test.Equals(IsPrimitive(32), true)
        Test.Equals(IsPrimitive("Hello"), true)
        Test.Equals(IsPrimitive(true), true)
        Test.Equals(IsPrimitive(nil, true), true)
        Test.Equals(IsPrimitive(nil, false), false)
        Test.Equals(IsPrimitive(Entity(1)), true)
        Test.Equals(IsPrimitive(Vector(1, 2, 3)), true)
        Test.Equals(IsPrimitive(Angle(1, 2, 3)), true)

        Test.Equals(STRING:Parse("Hello"), "Hello")
        Test.Equals(NUMBER:Parse("32"), 32)
        Test.Equals(BOOLEAN:Parse("true"), true)
        Test.Equals(BOOLEAN:Parse("false"), false)
        Test.Equals(NIL:Parse(nil), nil)
        Test.Equals(VECTOR:Parse("(1, 2, 3)"), Vector(1, 2, 3))
        Test.Equals(ANGLE:Parse("(1, 2, 3)"), Angle(1, 2, 3))
        Test.Equals(COLOR:Parse("(1, 2, 3, 4)"), Color(1, 2, 3, 4))
        Test.Equals(MATRIX:Parse("{{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}"), Matrix({{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}))
        Test.Equals(TABLE:Parse("{\"a\": 1}").a, 1)
    end)
end)