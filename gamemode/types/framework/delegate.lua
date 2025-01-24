AddCSLuaFile()

local DELEGATE = sym.RegisterType("delegate")
DELEGATE:SetTransmit(TRANSMIT_NEVER)

function DELEGATE:Init(t, func, ...)
    t.func = func
    t.params = {...}
    return t
end

function DELEGATE:__tostring()
    return "Delegate"
end

function DELEGATE:Invoke(...)
    local args = self.params
    table.Add(args, {...})
    return self.func(unpack(args))
end
DELEGATE.__call = DELEGATE.Invoke

function sym.delegate(func, ...)
    assert(func, "Must provide a function to create a delegate.")
    return sym.CreateInstance(DELEGATE, func, ...)
end

function sym.IsDelegate(obj)
    return sym.IsType(obj, DELEGATE)
end