AddCSLuaFile()

local EVENTRESULT = sym.RegisterType("eventresult")
function EVENTRESULT:Init(out)
    out.Cancelled = false
    return out
end

function EVENTRESULT:WasCancelled()
    return self.Cancelled
end

function EVENTRESULT:Cancel(reason, src)
    self.Cancelled = true
    self.CancelReason = reason
    self.CancelSource = src
end

function sym.EventResult()
    return EVENTRESULT()
end

local EVENT = sym.RegisterType("event")
EVENT:SetTransmit(TRANSMIT_NEVER)

function EVENT:Init(t)
    return t
end
EVENT.__call = nil

function EVENT:__printtable(indent, done, dontIgnoreMetaMethods)
    MsgC("<Event>")
end

function EVENT:Await()
    self.promise = self.promise or sym.promise()
    return self.promise
end

-- @overload EVENT:Hook(function:func(...), varargs:params)
-- @overload EVENT:Hook(string:uniqueId, function:func(...), varargs:params)
-- func(last, ...)
function EVENT:Hook(uniqueId, func, idx)
    local isn = isnumber(func)
    if not func or isn then
        idx = func
        func = uniqueId
        uniqueId = nil
    end
    assert(func, "event:Hook func cannot be nil")

    if not self.count then
        self.callbacks = {}
        self.count = 1
    else
        self.count = self.count + 1
    end

    if not uniqueId then
        uniqueId = self.count
    end

    idx = idx or table.Count(self.callbacks)
    self.callbacks[uniqueId] = { idx = idx, func = func }
    self.cache = nil
end


-- @example
-- ```local rtn, num = myevent:Invoke(test)
-- for k, v in pairs(rtn) do
--    -- do stuff
-- end```
-- 
-- or for just the last,
-- rtn[num]
function EVENT:Invoke(...)
    if not self.callbacks then
        return
    end

    local cache = self.cache
    if not cache then
        cache = table.ClearKeys(self.callbacks)
        table.SortByMember(cache, "idx", true)
        self.cache = cache
    end
    
    local ev
    local args = {...}
    if sym.IsType(args[1], EVENTRESULT) then
        ev = args[1]
        args = table.Splice(args, 2)
    else
        ev = sym.EventResult()
    end

    local rtn = {}
    for k, t in pairs(cache) do
        ev[k] = t.func(ev, ...)
    end

    if self.promise then
        self.promise:Complete(ev, ...)
    end

    return ev
end


function EVENT:Unhook(uniqueId)
    assert(uniqueId, "Cannot provide nil value to event:Unhook uniqueId")
    
    if not self.callbacks then
        return
    end

    self.callbacks[uniqueId] = nil
    self.cache = nil
    return true
end

function sym.event()
    return sym.CreateInstance(EVENT)
end



sym.events = {}
