AddCSLuaFile()

Promise = {}
Promise.All = weaktable(true, false)

local PROMISE = Type.Register("Promise")
do
    PROMISE:CreateProperty("Result")
    PROMISE:CreateProperty("Completed")

    function PROMISE.Prototype:Initialize()
        base()

        self.Events = Type.New(Type.EventBus)
        self.awaits = {}
        self.coroutines = {}
        self.threads = {}

        self:SetCompleted(false)
    end

    function PROMISE.Prototype:SetFunc(func)
        self.func = func
        self.thread = coroutine.create(func)
    end

    function PROMISE.Prototype:Hook(...)
        self.Events:Hook("Complete", ...)
    end

    function PROMISE.Prototype:Unhook(...)
        self.Events:Unhook(...)
    end

    function PROMISE.Prototype:ThrowError(err)
        self.Events:Invoke("Error", err)
        error(err)
    end

    function PROMISE.Prototype:Resume(...)
        assert(coroutine.status(self.thread) ~= "dead", "Promise is dead")
        
        local LAST_PROMISE = Promise.Current
        Promise.Current = self
        
        local args = { coroutine.resume(self.thread, ...) }
        local succ = args[1]
        
        if not succ then 
            self:ThrowError(args[2]) 
        end
        
        local rtn = tablex.Splice(args, 2)
        if #rtn > 0 or coroutine.status(self.thread) == "dead" then 
            self:Complete(unpack(rtn)) 
        end

        Promise.All[self] = true        
        Promise.Current = LAST_PROMISE
    end

    function PROMISE.Prototype:Await()
        if self:IsComplete() then
            return self:GetResult()
        end

        table.insert(self.awaits, Promise.Current)
        return coroutine.yield()
    end    

    function PROMISE.Prototype:Complete(...)
        local args = {...}
        self:SetResult(args)

        timer.Simple(0, function ()
            self.Events:Invoke("Complete", unpack(args))

            for k, v in pairs(self.awaits) do
                v:Resume(unpack(args))
            end

            for k, v in pairs(self.coroutines) do
                coroutine.resume(v, unpack(args))
            end

            self.Events:Invoke("Complete", unpack(args))
        end)
        self.Completed = true

        Promise.All[self] = nil
    end

    function PROMISE.Prototype:IsComplete()
        return self.Completed
    end

    function PROMISE:GetResult()
        return unpack(self.Result)
    end

    function PROMISE.Metamethods:__tostring()
        return "Promise[" .. self:GetId() .. "]"
    end

    PROMISE.Prototype.Start = PROMISE.Prototype.Resume
end

function Promise.Create(func)
    local p = Type.New(PROMISE)
    p:SetFunc(func)
    return p
end

function Promise.GetPromise()
    return Promise.Current
end

function Promise.GetPromises()
    return Promise.All
end

function ispromise(obj)
    return Type.IsDerived(obj, Type.Promise)
end