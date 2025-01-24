AddCSLuaFile()


local TUPLE = {}
TUPLE.__index = self
function TUPLE:__eq(tgt)
    if table.Count(self) ~= table.Count(tgt) then
        return false
    end

    for k, v in pairs(self) do
        if self[k] ~= tgt[k] then
            return false
        end
    end

    return true
end

function TUPLE:__tostring()
    return table.concat(self, string.char(37))
end

function Tuple(...)
    local t = setmetatable({...}, TUPLE)
    return t
end
RegisterMetaTable("Tuple", TUPLE)

local weakkey = { __mode = "k" }
local weakvalue = { __mode = "v" }
local weakboth = { __mode = "kv" }
function weaktable(k, v)
    local mt = weakboth
    if k and v then
        mt = weakboth
    elseif k and not v then
        mt = weakkey
    else
        mt = weakvalue
    end

    return setmetatable({}, mt)
end