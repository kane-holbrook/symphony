AddCSLuaFile()

local PRIMITIVE = Type.Register("Primitive")
local Deref = false

function PRIMITIVE:Encode(value)
    return value
end

function PRIMITIVE:Decode(data)
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
    return self:Parse(value)
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


local NAVAREA = Type.Register("NavArea", PRIMITIVE, { Code = TYPE_NAVAREA })
function NAVAREA:Encode(value)
    return game.GetMap() .. ":" .. value:GetID()
end

function NAVAREA:Decode(data)
    local map, id = string.Split(data, ":")
    assert(map == game.GetMap(), "NavArea map mismatch: expected " .. game.GetMap() .. ", got " .. map)
    return navmesh.GetNavAreaByID(tonumber(id))
end
if SERVER then
    PopulateMetaTable(FindMetaTable("CNavArea"), NAVAREA)
end

local NAVLADDER = Type.Register("NavLadder", PRIMITIVE, { Code = TYPE_NAVLADDER })
function NAVLADDER:Encode(value)
    return game.GetMap() .. ":" .. value:GetID()
end

function NAVLADDER:Decode(data)
    local map, id = string.Split(data, ":")
    assert(map == game.GetMap(), "NavArea map mismatch: expected " .. game.GetMap() .. ", got " .. map)
    return navmesh.GetNavLadderByID(tonumber(id))
end
if SERVER then
    PopulateMetaTable(FindMetaTable("CNavLadder"), NAVLADDER)
end

local TABLE = Type.Register("Table", nil, { Code = TYPE_TABLE, DatabaseType = "BLOB" })
function TABLE:Encode(value)
    local out = {}
    for k, v in pairs(value) do
        out[k] = Type.Encode(v)
    end
    return out
end

function TABLE:Decode(data)
    local out = {}

    for k, v in pairs(data) do
        out[k] = Type.Decode(v)
    end
    return out
end

function TABLE:DatabaseEncode(value)
    return string.format("%q", util.Base64Encode(sfs.encode(self:Encode(value))))
end

function TABLE:DatabaseDecode(value)
    local data = sfs.decode(util.Base64Decode(value))
    return self:Decode(data)
end


function Type.IsPrimitive(obj, allowNil)
    if (not allowNil and not obj) or not obj.GetType then
        return false
    end
    return Type.Is(obj:GetType(), PRIMITIVE)
end


local MATERIAL = Type.Register("Material", PRIMITIVE, { Code = TYPE_MATERIAL })
function MATERIAL:Encode(m)
    local out = {}
    out[1] = m:GetName()
    out[2] = m:GetShader()

    local kv = {}    
    for k, v in pairs(m:GetKeyValues()) do
        kv[k] = Type.Encode(v)
    end
    out[3] = kv

    return out
end

function MATERIAL:Decode(m)
    local name = m[1]
    local shader = m[2]
    local params = m[3]

    local data = {}
    for k, v in pairs(params) do
        data[k] = Type.Decode(v)
    end

    out = CreateMaterial(name, shader, data)
    for k, v in pairs(params) do
        if isvector(v) then
            out:SetVector(k, v)
        end
    end
    return out
end
PopulateMetaTable(FindMetaTable("IMaterial"), MATERIAL)

local ITEXTURE = Type.Register("Texture", PRIMITIVE, { Code = TYPE_TEXTURE })
function ITEXTURE:Encode(t)
    return t:GetName()
end

function ITEXTURE:Decode(t)
    return t
end
PopulateMetaTable(FindMetaTable("ITexture"), ITEXTURE)

if SERVER then

    local function GetName(mat)
        return mat.Name
    end

    local function GetShader(mat)
        return mat.Shader
    end

    local function GetParams(mat)
        return mat.Params
    end

    local function SetKeyValue(mat, key, value)
        mat.Params[key] = value
    end

    function CreateMaterial(name, shader, data)
        local t = Type.New(MATERIAL)
        t.Name = name
        t.Shader = shader
        t.Params = data
        
        t.GetName = GetName
        t.GetShader = GetShader
        t.GetKeyValues = GetParams
        t.SetKeyValue = SetKeyValue
        return t
    end
end

IsPrimitive = Type.IsPrimitive