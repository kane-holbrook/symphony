AddCSLuaFile()

Promise = Type.Register("Promise")
Promise.All = weaktable(true, false)
Promise.TTL = 30

do
    Promise:CreateProperty("Result")
    Promise:CreateProperty("Completed")
    Promise:CreateProperty("TTL")
    Promise:CreateProperty("Error")
    Promise:CreateProperty("SuppressError")

    -- @test sh_tests/Promises
    function Promise.Prototype:Initialize()
        self.id = Type.GenerateID(Promise)
        self.awaits = {}
        self.coroutines = {}
        self.threads = {}
        self.callback = nil

        self:SetCompleted(false)
        self:SetTTL(Promise.TTL)
        Promise.All[self] = true
    end

    function Promise.Prototype:GetId()
        return self.id
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:SetFunc(func)
        self.func = func
        
        if func then
            self.thread = coroutine.create(func)
        else
            self.thread = nil
        end
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:Then(func)
        self.callback = func
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:ThrowError(err)
        timer.Remove(self:GetId())
        err = err .. "\n" .. debug.traceback()
--        self.Events:Run("Error", err)
        self:SetError(err)

        return err
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:Resume(...)
        local cr = self:GetCoroutine()
        assert(coroutine.status(cr) ~= "dead", "Promise is dead")
        
        local LAST_Promise = Promise.Current
        Promise.Current = self

        timer.Create(self:GetId(), self:GetTTL(), 0, function() error(tostring(self) .. " exceeded TTL=" .. self:GetTTL()) end)

        local args = { coroutine.resume(cr, ...) }
        local succ = args[1]
        
        if not succ then
            error(tostring(args[2])) 
        end
        
        if coroutine.status(cr) == "dead" then 
            self:Complete(unpack(args)) 
        end
     
        Promise.Current = LAST_Promise

        return self
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:Await()
        if self:IsComplete() then
            -- Consider delaying this 1 tick so that hooks run first, as this effectively sidesteps?
            return self:GetResult()
        end

        table.insert(self.awaits, Promise.Current)
        return coroutine.yield()
    end    

    -- @test sh_tests/Promises
    function Promise.Prototype:Complete(...)
        local args = {...}
        self:SetResult(args)
        timer.Simple(0, function ()
            
            --self.Events:Run("Complete", unpack(args))
            if self.callback then
                self.callback(unpack(args))
            end

            for k, v in pairs(self.awaits) do
                v:Resume(unpack(args))
            end

            for k, v in pairs(self.coroutines) do
                coroutine.resume(v, unpack(args))
            end
            
        end)
        self.Completed = true
        
        timer.Remove(self:GetId())

        Promise.All[self] = nil
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:IsComplete()
        return self.Completed
    end

    -- @test sh_tests/Promises
    function Promise.Prototype:GetResult()
        return unpack(self.Result)
    end

    function Promise.Prototype:GetCoroutine()
        return self.thread
    end

    -- @test sh_tests/Promises
    function Promise.Metamethods:__tostring()
        if self:GetCoroutine() then
            return "Promise[" .. self:GetId() .. "](" .. coroutine.status(self:GetCoroutine()) .. ")"
        else
            return "Promise[" .. self:GetId() .. "](" .. (self:IsComplete() and "complete" or "pending") .. ")"
        end
    end

    Promise.Prototype.Start = Promise.Prototype.Resume
end

-- @test sh_tests/Promises
function Promise.Create(func, ttl)
    local p = Type.New(Promise)
    p:SetFunc(func)
    p:SetTTL(ttl or 30)
    return p
end

-- @test sh_tests/Promises
function Promise.Run(func, ttl)
    assert(func, "Must provide function if using Promise.Run")
    local p = Promise.Create(func, ttl)
    p:Start()
    return p
end

-- @test sh_tests/Promises
function Promise.Sleep(t)
    local cr = Promise.Current
    timer.Simple(t, function ()
        cr:Resume()
    end)
    coroutine.yield()
end

function Promise.SleepForTicks(ticks)
    local cr = Promise.Current

    nticks(ticks, cr.Resume, cr)
    coroutine.yield()
end

function Promise.GetPromise()
    return Promise.Current
end

function Promise.GetPromises()
    return Promise.All
end

function Promise.AwaitAll(promises)
    local p = Promise.Create()
    local num = 0
    local sz = #promises
    if sz == 0 then
        p:Complete({})
        return p
    end

    local results = {}

    local handler = function (...)
        num = num + 1
        table.insert(results, {...})
        if num >= sz then
            p:Complete(results)
        end
    end

    for k, v in pairs(promises) do
        v:Then(handler)
    end

    return p
end

function ispromise(obj)
    return Type.Is(obj, Type.Promise)
end



local Deferred = {}
function Promise.Defer(func, ...)
    local p = Promise.Create()
    table.insert(Deferred, { func, p, {...} })
    return p
end

hook.Add("Think", "Deferred", function()
    local top = table.remove(Deferred, 1)
    if top then
        local func, p, args = unpack(top)
        local out = { pcall(func, unpack(args)) }
        if out[1] then
            p:Complete(unpack(out, 2))
        else 
            p:ThrowError(out[2])
        end
    end
end)


-- Async
if SERVER then
    function Promise.RunThreaded(func, ...)
        local p = Promise.Create()

        local thread = threading.newThread()
        local dc = thread:OpenChannel("data")

        dc:Receive(function (bytes, tag)
            local succ = dc:ReadBool()
            if not succ then
                error(dc:ReadString())
                return
            end

            p:Complete(unpack(dc:ReadTable()))
        end)
        
        thread:Run(function ()
            local dc = engine:OpenChannel("data")
            local bytes, tag = dc:Wait()

            local func = dc:ReadFunction()
            local data = dc:ReadTable()

            local out = { pcall(func, unpack(data)) }
            local succ = table.remove(out, 1)
            if not succ then
                dc:StartPacket()
                    dc:WriteBool(false)
                    dc:WriteString(out[1])
                dc:PushPacket()
            else
                dc:StartPacket()
                    dc:WriteBool(true)
                    dc:WriteTable(out)
                dc:PushPacket()
            end
        end)

        dc:StartPacket()
            dc:WriteFunction(func)
            dc:WriteTable({...})
        dc:PushPacket()

        return p
    end
end