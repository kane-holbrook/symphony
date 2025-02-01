AddCSLuaFile()

local PRIMITIVE = Type.Register("Primitive")

function PRIMITIVE:Serialize(data, ply, root)
    return data
end

function PRIMITIVE:Deserialize(data)
    return data
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

        error("Attempt to index a " .. type(self) .. " value (" .. tostring(key) .. ").", 2)
    end
end

local STRING = Type.Register("String", PRIMITIVE, { Code = TYPE_STRING, DatabaseType = "TEXT" })
function STRING.Parse(value)
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
function NUMBER.Parse(value)
    return tonumber(value)
end

function NUMBER:DatabaseEncode(value)
    return tostring(value)
end

function NUMBER:DatabaseDecode(value)
    return tonumber(value)
end
debug.setmetatable(32, { __index = GenerateIndexer(NUMBER.Prototype), Type = NUMBER })


local BOOLEAN = Type.Register("Boolean", PRIMITIVE, { Code = TYPE_BOOL, DatabaseType = "BOOLEAN" })
function BOOLEAN.Parse(value)
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
function NIL.Parse(value)
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
function VECTOR.Parse(value)
    local x, y, z = string.match(value, "%(([%d%.]+),%s*([%d%.]+),%s*([%d%.]+)%)")
    return Vector(tonumber(x), tonumber(y), tonumber(z))
end

function VECTOR:DatabaseEncode(value)
    return string.format("\"(%.2f,%.2f,%.2f)\"", value.x, value.y, value.z)
end

function VECTOR:DatabaseDecode(value)
    return Vector.Parse(value)
end
PopulateMetaTable(FindMetaTable("Vector"), VECTOR)


local ANGLE = Type.Register("Angle", PRIMITIVE, { Code = TYPE_ANGLE, DatabaseType = "CHAR(16)" })
function ANGLE.Parse(value)
    local p, y, r = string.match(value, "%(([%d%.]+),%s*([%d%.]+),%s*([%d%.]+)%)")
    return Angle(tonumber(p), tonumber(y), tonumber(r))
end

function ANGLE:DatabaseEncode(value)
    return string.format("\"(%.2f,%.2f,%.2f)\"", value.p, value.y, value.r)
end

function ANGLE:DatabaseDecode(value)
    return Angle.Parse(value)
end
PopulateMetaTable(FindMetaTable("Angle"), ANGLE)


local COLOR = Type.Register("Color", PRIMITIVE, { Code = TYPE_COLOR, DatabaseType = "CHAR(16)" })
function COLOR.Parse(value)
    local r, g, b, a = string.match(value, "(%d+),%s*(%d+),%s*(%d+),%s*(%d+)")
    return Color(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
end

function COLOR:DatabaseEncode(value)
    return string.format("\"(%d,%d,%d,%d)\"", value.r, value.g, value.b, value.a)
end

function COLOR:DatabaseDecode(value)
    return Color.Parse(value)
end
PopulateMetaTable(FindMetaTable("Color"), COLOR)


local MATRIX = Type.Register("Matrix", PRIMITIVE, { Code = TYPE_MATRIX, DatabaseType = "JSON" })
function MATRIX.Parse(value)
    return Matrix(util.JSONToTable(value))
end

function MATRIX:DatabaseEncode(value)
    return string.format("%q", util.TableToJSON(value:ToTable()))
end

function MATRIX:DatabaseDecode(value)
    return Matrix.Parse(value)
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

function TABLE.Parse(value)
    return util.JSONToTable(value)
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

        Test.Equals(STRING.Parse("Hello"), "Hello")
        Test.Equals(NUMBER.Parse("32"), 32)
        Test.Equals(BOOLEAN.Parse("true"), true)
        Test.Equals(BOOLEAN.Parse("false"), false)
        Test.Equals(NIL.Parse(nil), nil)
        Test.Equals(VECTOR.Parse("(1, 2, 3)"), Vector(1, 2, 3))
        Test.Equals(ANGLE.Parse("(1, 2, 3)"), Angle(1, 2, 3))
        Test.Equals(COLOR.Parse("(1, 2, 3, 4)"), Color(1, 2, 3, 4))
        Test.Equals(MATRIX.Parse("{{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}"), Matrix({{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}))
        Test.Equals(TABLE.Parse("{\"a\": 1}").a, 1)
    end)
end)