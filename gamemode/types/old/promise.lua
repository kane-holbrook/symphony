AddCSLuaFile()

local PROMISE = sym.RegisterType("promise")
PROMISE:SetTransmit(TRANSMIT_NEVER)
CURRENT_PROMISE = nil

function PROMISE:Init(t, func)
    if func then
        t:SetFunction(func)
    end

    t.awaits = {}
    t.coroutines = {}
    t.threads = {}

    t.OnComplete = sym.event()
    t.OnCompleted = sym.event()
    t.OnError = sym.event()
    t.Completed = false
    return t
end

function PROMISE:__printtable(indent, done, dontIgnoreMetaMethods)
    MsgC("<Promise:" .. (self:IsComplete() and "complete" or "incomplete") .. ">")
end

function PROMISE:ThrowError(err)
    self.OnError:Invoke(err)
    error(err)
end

function PROMISE:SetFunction(func)
    assert(isfunction(func) or sym.IsDelegate(func), "func parameter must be a function/delegate")
    self.thread = coroutine.create(func)
end

function PROMISE:Resume(...)
    assert(coroutine.status(self.thread) ~= "dead", "Promise is dead")

    local LAST_PROMISE = CURRENT_PROMISE
    CURRENT_PROMISE = self
        local args = { coroutine.resume(self.thread, ...) }
        
        local succ = args[1]
        if not succ then
            self:ThrowError(args[2])
        end

        local rtn = tablex.Splice(args, 2)
        if #rtn > 0 or coroutine.status(self.thread) == "dead" then
            self:Complete(unpack(rtn))
        end

    CURRENT_PROMISE = LAST_PROMISE
end
PROMISE.Start = PROMISE.Resume
PROMISE.__call = PROMISE.Resume

function PROMISE:Await()
    if self:IsComplete() then
        return self:GetResult()
    end

    table.insert(self.awaits, CURRENT_PROMISE)
    return coroutine.yield()
end

function PROMISE:__tostring()
    return "Promise[" .. self:GetObjectId() .. "]"
end

function PROMISE:Complete(...)
    local args = {...}
    self.Result = args

    timer.Simple(0, function ()
        self.OnComplete:Invoke(unpack(args))

        for k, v in pairs(self.awaits) do
            v:Resume(unpack(args))
        end

        for k, v in pairs(self.coroutines) do
            coroutine.resume(v, unpack(args))
        end

        self.OnCompleted:Invoke(unpack(args))
    end)
    self.Completed = true
end

function PROMISE:IsComplete()
    return self.Completed
end

function PROMISE:GetResult()
    return unpack(self.Result)
end

function sym.promise(func)
    return sym.CreateInstance(PROMISE, func)
end

function sym.IsPromise(t)
    return sym.IsType(t, sym.types.promise)
end

function sym.WhenAll(promises)
    local out = sym.Promise(function ()
        local rtn = {}

        for k, p in pairs(promises) do
            if not p:IsComplete() then
                p:Await()
            end
            rtn[k] = p:GetResult() 
        end

        return rtn
    end)
    return out
end