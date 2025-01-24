AddCSLuaFile()

local PROXY = sym.RegisterType("proxy")

-- @tested 25/07/2024
function PROXY:Init(t, value)
    t.OnSet = sym.event() -- @tested 25/07/2024
    t:Set(value)
    return t
end

function PROXY:__printtable(indent, done, dontIgnoreMetaMethods)
    MsgC("Proxy[")
        local tf = sym.logging.TypeFuncs[TypeID(self.value)] or sym.logging.TypeFuncs["default"]
        MsgC(tf(self.value))
    MsgC("]")
end

function PROXY:DbWrite()
    return self.value
end

function PROXY:DbRead(value)
    assert(not self:IsInstance(), "DbRead can only be invoked from a type.")
    return self(value)
end

function PROXY:__eq(v)
    if sym.IsType(v) then
        v = v.value
    end
    
    return self.value == v
end

function PROXY:__lt(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value < v
end

function PROXY:__unm(v)
    if sym.IsType(v) then
        v = v.value
    end

    return -self.value
end

function PROXY:__add(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value + v
end

function PROXY:__sub(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value - v
end

function PROXY:__mul(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value * v
end

function PROXY:__div(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value / v
end

function PROXY:__pow(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value ^ v
end

function PROXY:__mod(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value % v
end

function PROXY:FromString(v)
    return self(v)
end

function PROXY:__le(v)
    if sym.IsType(v) then
        v = v.value
    end

    return self.value <= v
end

-- @tested 25/07/2024
function PROXY:Set(value, ...)
    self.OnSet:Invoke(value, ...)
    self.value = value
end

-- @tested 25/07/2024
function PROXY:Get()
    return self.value
end

function PROXY:__tostring()
    if self == PROXY then
        return "Type[Proxy]"
    end
    
    return "Proxy[" .. tostring(self:Get()) .. "]"
end

function sym.proxy(v, bAllowNesting)
    if not bAllowNesting and sym.IsProxy(v) then
        return v -- If we pass a proxy into here, return the original proxy.
    else
        return sym.CreateInstance(PROXY, v)
    end
end

function sym.IsProxy(t)
    return sym.IsType(t, PROXY)
end